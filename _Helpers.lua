local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];

function g_Module.PrintToChat(a_Text)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF008080CatRotationHelper:|r " .. a_Text);
end

function g_Module.GetSpellName(a_SpellID)
	local spellName = GetSpellInfo(a_SpellID);

	if (not spellName) then
		-- Happens when abilities are removed in new patch
		g_Module.PrintToChat("Spell not found : " .. a_SpellID);
	end

	return spellName;
end

function g_Module.GetMyImage(a_ImageName)
	return "Interface\\AddOns\\CatRotationHelper\\Images\\" .. a_ImageName;
end

-- Broken as of WoW 6.0.2 (Warlords of Draenor)
function g_Module.GetGlobalCooldown()
	local startTime, duration = GetSpellCooldown(61304);
	if (spellStart == nil) then
		return 0;
	end
	
	return duration;
end
