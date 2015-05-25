local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

g_Module.LogicUnusedFrame =
{
	Type			= nil,
};

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
	else
		g_Module.PrintToChat("Unknown frame logic Type: " .. logic.Type);
	end
end
