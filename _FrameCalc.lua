local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

-- Get information about target's debuff
-- \return NumStacks, ExpirationTime
-- Notes:
-- It is generally considered "slow" to iterate over all auras, rather then just auras filtered by SpellName.
--     However, filtering by spell name have an inevitable problem with distinguishing auras with the same SpellName.
--         For example, in WoW Legion, there are two auras named 'Rake':
--             155722 - The actual bleed debuff.
--             163505 - Stun applied when you use Rake from stealth.
--         Finding aura by SpellName sometimes selects stun aura and addon shows wrong timing.
--     I have tested performances:
--         All times are measured in 10^-6 sec (microseconds)
--             enum - Measured with implementation which you can see below
--             name - Measured with calling UnitDebuff() with cached SpellName
--         54 debuffs on target, a_CastByMe=true, target has queried debuff: enum=03.6 name=03.0
--         43 debuffs on target, a_CastByMe=true, target has queried debuff: enum=02.0 name=02.6
--         57 debuffs on target, a_CastByMe=true, queried debuff missing   : enum=15.1 name=09.2
--         96 debuffs on target, a_CastByMe=true, queried debuff missing   : enum=18.8 name=15.2
--     From these measurements, I draw conclusion that the difference is negligible.
function g_Addon.GetTargetDebuffInfo(a_SpellID, a_CastByMe)
	local filter = nil;
	if (a_CastByMe) then
		filter = "PLAYER";
	end

	local iAura = 1;
	while true do
		local _, _, stacks, _, _, expTime, _, _, _, spellID = UnitDebuff("target", iAura, filter);
		if (not spellID) then
			break;
		end

		if (spellID == a_SpellID) then
			return stacks, expTime;
		end

		iAura = iAura + 1;
	end

	return nil;
end

-- Get information about player's buff
-- \return  IsBuffPresent, ExpirationTime
function g_Addon.GetPlayerBuffInfo(a_SpellID)
	local iAura = 1;
	while true do
		local _, _, stacks, _, _, expTime, _, _, _, spellID = UnitBuff("player", iAura);
		if (not spellID) then
			break;
		end

		if (spellID == a_SpellID) then
			return true, expTime;
		end

		iAura = iAura + 1;
	end

	return false;
end

function g_Addon.CalcFrameFromDebuff(a_SpellID, a_MinimumStacks, a_CastByMe)
	local stacks, expTime = g_Addon.GetTargetDebuffInfo(a_SpellID, a_CastByMe);
	if (not stacks) then
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
