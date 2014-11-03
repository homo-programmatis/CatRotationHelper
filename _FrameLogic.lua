local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];

g_Module.LogicUnusedFrame =
{
	Type			= nil,
};

local function FrameUpdateFromDebuff(a_Frame, a_SpellID, a_Stacks, a_CastByMe)
	g_Module.FrameSetExpiration(a_Frame, g_Module.CalcFrameFromDebuff(a_SpellID, a_Stacks, a_CastByMe));
end

local function FrameUpdateFromBuff(a_Frame, a_SpellID)
	g_Module.FrameSetExpiration(a_Frame, g_Module.CalcFrameFromBuff(a_SpellID));
end

local function FrameUpdateFromSkill(a_Frame, a_SpellID)
	g_Module.FrameSetExpiration(a_Frame, g_Module.CalcFrameFromSkill(a_SpellID));
end

function g_Module.FrameUpdateFromLogic(a_Frame)
	local logic = a_Frame.m_CrhLogic;

	if     (nil == logic.Type) then
		-- Empty frame
		return;
	elseif ("Skill" == logic.Type) then
		FrameUpdateFromSkill(a_Frame, logic.SpellID);
	elseif ("Buff" == logic.Type) then
		FrameUpdateFromBuff(a_Frame, logic.SpellID);
	elseif ("Debuff" == logic.Type) then
		FrameUpdateFromDebuff(a_Frame, logic.SpellID, logic.MinimumStacks, logic.CastByMe);
	else
		g_Module.PrintToChat("Unknown frame logic Type: " .. logic.Type);
	end
end
