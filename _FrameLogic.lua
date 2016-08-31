local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

g_Addon.LogicUnusedFrame =
{
	Type			= nil,
};

function g_Addon.Logic_IsAvailable(a_Logic)
	if (nil ~= a_Logic.IsAvailable) then
		return a_Logic.IsAvailable(a_Logic);
	end
	
	if (nil ~= a_Logic.TalentID) then
		return g_Addon.IsTalentTaken(a_Logic.TalentID);
	end
	
	if (nil ~= a_Logic.SkillID) then
		return IsPlayerSpell(a_Logic.SkillID);
	end

	if (nil ~= a_Logic.SpellID) then
		return IsPlayerSpell(a_Logic.SpellID);
	end

	return false;
end

function g_Addon.Logic_AddIfItsGood(a_Table, a_Logic)
	if (not g_Addon.Logic_IsAvailable(a_Logic)) then
		return;
	end
	
	table.insert(a_Table, a_Logic);
end

function g_Addon.Logic_AddFirstGood(a_Table, ...)
	local logicList = {...};
	for _, logic in pairs(logicList) do
		if (g_Addon.Logic_IsAvailable(logic)) then
			table.insert(a_Table, logic);
			return;
		end
	end
end

function g_Addon.Logic_AddUnused(a_Table, a_MinCount)
	local currentCount = #a_Table;
	if (currentCount >= a_MinCount) then
		return;
	end
	
	local unusedSlots = a_MinCount - currentCount;
	for i = 1, unusedSlots do
		table.insert(a_Table, g_Addon.LogicUnusedFrame);
	end
end

function g_Addon.FrameUpdateFromLogic(a_Frame, a_ShowEffects)
	local logic = a_Frame.m_CrhLogic;

	if     (nil == logic.Type) then
		-- Empty frame
		return;
	elseif (g_Consts.LOGIC_TYPE_SKILL == logic.Type) then
		local status, expiration = g_Addon.CalcFrameFromSkill(logic.SpellID);
		g_Addon.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_BUFF == logic.Type) then
		local status, expiration = g_Addon.CalcFrameFromBuff(logic.SpellID);
		g_Addon.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_DEBUFF == logic.Type) then
		local status, expiration = g_Addon.CalcFrameFromDebuff(logic.SpellID, logic.MinimumStacks, logic.CastByMe);
		g_Addon.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_BURST == logic.Type) then
		local status, expiration = g_Addon.CalcFrameFromBurst(logic.SpellID);
		g_Addon.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_PROC == logic.Type) then
		local status, expiration = g_Addon.CalcFrameFromProc(logic.SpellID);
		g_Addon.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	else
		g_Addon.PrintToChat("Unknown frame logic Type: " .. logic.Type);
	end
end
