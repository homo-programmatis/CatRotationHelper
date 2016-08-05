local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

function g_Addon.GetTargetDebuffInfo(a_SpellID, a_CastByMe)
	local filter = "HARMFUL";
	if (a_CastByMe) then
		filter = "PLAYER|" .. filter;
	end
	
	local spellName = g_Addon.GetSpellName(a_SpellID);
	if (not spellName) then
		return nil;
	end
	
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitAura("target", spellName, nil, filter);
	if (not name) then
		return nil;
	end

	return name, stacks, expTime;
end

-- Get information about player's buff 
-- \return  IsBuffPresent, ExpirationTime
function g_Addon.GetPlayerBuffInfo(a_SpellID)
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitBuff("player", g_Addon.GetSpellName(a_SpellID));
	if (not name) then
		return false;
	end
	
	return true, expTime;
end

function g_Addon.CalcFrameFromDebuff(a_SpellID, a_MinimumStacks, a_CastByMe)
	local name, stacks, expTime = g_Addon.GetTargetDebuffInfo(a_SpellID, a_CastByMe);
	if (not name) then
		return g_Consts.STATUS_READY, nil;
	end
	
	if (a_MinimumStacks and (stacks < a_MinimumStacks)) then
		return g_Consts.STATUS_READY, nil;
	end
	
	return g_Consts.STATUS_COUNTING, expTime;
end

function g_Addon.CalcFrameFromBuff(a_SpellID)
	local isBuffPresent, expTime = g_Addon.GetPlayerBuffInfo(a_SpellID);
	if (not isBuffPresent) then
		return g_Consts.STATUS_READY, nil;
	end
	
	return g_Consts.STATUS_COUNTING, expTime;
end

function g_Addon.CalcFrameFromSkill(a_SpellID)
	local spellStart, spellDuration = GetSpellCooldown(a_SpellID);
	
	if (spellStart == 0) then
		-- No cooldown
		return g_Consts.STATUS_READY, nil;
	end

	if (spellStart == nil) then
		-- Unknown legacy safety code
		return g_Consts.STATUS_READY, nil;
	end
	
	if (spellDuration < g_Consts.GCD_LENGTH) then
		-- If spell's full cooldown is less then GCD, then it's not
		-- on cooldown really, it's on GCD. Returning 0 here
		-- is consistent with Buff / Debuff calculation
		return g_Consts.STATUS_READY, nil;
	end

	return g_Consts.STATUS_COUNTING, spellStart + spellDuration;
end

function g_Addon.CalcFrameFromBurst(a_SpellID)
	-- First of all, check if currently bursting.
	-- When bursting, remaining burst time is more important then cooldown.
	local isBuffPresent, expTime = g_Addon.GetPlayerBuffInfo(a_SpellID);
	if (isBuffPresent) then
		-- Burst buff is active
		return g_Consts.STATUS_BURSTING, expTime;
	end

	-- When not bursting, use default skill logic.
	return g_Addon.CalcFrameFromSkill(a_SpellID);
end

function g_Addon.CalcFrameFromProc(a_SpellID)
	local isBuffPresent, expTime = g_Addon.GetPlayerBuffInfo(a_SpellID);
	if (isBuffPresent) then
		-- Proc is up
		return g_Consts.STATUS_PROC, expTime;
	end
	
	return g_Consts.STATUS_WAITING, nil;
end
