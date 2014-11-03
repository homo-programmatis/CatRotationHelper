local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];

function g_Module.FrameUpdateFromDebuff(a_Frame, a_SpellID, a_Stacks, a_MyOnly)
	g_Module.FrameSetExpiration(a_Frame, g_Module.CalcFrameFromDebuff(a_SpellID, a_Stacks, a_MyOnly));
end

function g_Module.FrameUpdateFromBuff(a_Frame, a_SpellID)
	g_Module.FrameSetExpiration(a_Frame, g_Module.CalcFrameFromBuff(a_SpellID));
end

function g_Module.FrameUpdateFromSkill(a_Frame, a_SpellID)
	g_Module.FrameSetExpiration(a_Frame, g_Module.CalcFrameFromSkill(a_SpellID));
end
