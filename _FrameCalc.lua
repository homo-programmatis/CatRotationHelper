local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

function g_Module.GetTargetDebuffInfo(a_SpellID, a_CastByMe)
	local filter = "HARMFUL";
	if (a_CastByMe) then
		filter = "PLAYER|" .. filter;
	end
	
	local spellName = g_Module.GetSpellName(a_SpellID);
	if (not spellName) then
		return nil;
	end
	
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitAura("target", spellName, nil, filter);
	if (not name) then
		return nil;
	end

	return name, stacks, expTime;
end

function g_Module.CalcFrameFromDebuff(a_SpellID, a_MinimumStacks, a_CastByMe)
	local name, stacks, expTime = g_Module.GetTargetDebuffInfo(a_SpellID, a_CastByMe);
	if (not name) then
		return g_Consts.STATUS_READY, nil;
	end
	
	if (a_MinimumStacks and (stacks < a_MinimumStacks)) then
		return g_Consts.STATUS_READY, nil;
	end
	
	return g_Consts.STATUS_COUNTING, expTime;
end

function g_Module.CalcFrameFromBuff(a_SpellID)
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitBuff("player", g_Module.GetSpellName(a_SpellID));
	if (not name) then
		return g_Consts.STATUS_READY, nil;
	end
	
	return g_Consts.STATUS_COUNTING, expTime;
end

function g_Module.CalcFrameFromSkill(a_SpellID)
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
