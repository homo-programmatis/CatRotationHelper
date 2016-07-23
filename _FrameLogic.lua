local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

g_Module.LogicUnusedFrame =
{
	Type			= nil,
};

function g_Module.IsLogicAvailable(a_Logic)
	if (nil ~= a_Logic.IsAvailable) then
		return a_Logic.IsAvailable(a_Logic);
	end
	
	if (nil ~= a_Logic.TalentID) then
		return g_Module.IsTalentTaken(a_Logic.TalentID);
	end
	
	if (nil ~= a_Logic.SkillID) then
		return IsPlayerSpell(a_Logic.SkillID);
	end

	if (nil ~= a_Logic.SpellID) then
		return IsPlayerSpell(a_Logic.SpellID);
	end

	return false;
end

function g_Module.AddLogicIfAvailable(a_Table, a_Logic)
	if (not g_Module.IsLogicAvailable(a_Logic)) then
		return;
	end
	
	table.insert(a_Table, a_Logic);
end

function g_Module.AddLogicUnused(a_Table, a_MinCount)
	local currentCount = #a_Table;
	if (currentCount >= a_MinCount) then
		return;
	end
	
	local unusedSlots = a_MinCount - currentCount;
	for i = 1, unusedSlots do
		table.insert(a_Table, g_Module.LogicUnusedFrame);
	end
end

function g_Module.FrameUpdateFromLogic(a_Frame, a_ShowEffects)
	local logic = a_Frame.m_CrhLogic;

	if     (nil == logic.Type) then
		-- Empty frame
		return;
	elseif (g_Consts.LOGIC_TYPE_SKILL == logic.Type) then
		local status, expiration = g_Module.CalcFrameFromSkill(logic.SpellID);
		g_Module.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_BUFF == logic.Type) then
		local status, expiration = g_Module.CalcFrameFromBuff(logic.SpellID);
		g_Module.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_DEBUFF == logic.Type) then
		local status, expiration = g_Module.CalcFrameFromDebuff(logic.SpellID, logic.MinimumStacks, logic.CastByMe);
		g_Module.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_BURST == logic.Type) then
		local status, expiration = g_Module.CalcFrameFromBurst(logic.SpellID);
		g_Module.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	elseif (g_Consts.LOGIC_TYPE_PROC == logic.Type) then
		local status, expiration = g_Module.CalcFrameFromProc(logic.SpellID);
		g_Module.FrameSetStatus(a_Frame, status, expiration, a_ShowEffects);
	else
		g_Module.PrintToChat("Unknown frame logic Type: " .. logic.Type);
	end
end
