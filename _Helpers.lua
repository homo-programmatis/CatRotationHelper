local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

function g_Addon.PrintToChat(a_Text)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF008080CatRotationHelper:|r " .. a_Text);
end

function g_Addon.GetSpellName(a_SpellID)
	local spellName = GetSpellInfo(a_SpellID);

	if (not spellName) then
		-- Happens when abilities are removed in new patch
		g_Addon.PrintToChat("Spell not found : " .. a_SpellID);
	end

	return spellName;
end

function g_Addon.IsTalentTaken(a_TalentID)
	local _, _, _, selected, _ = GetTalentInfoByID(a_TalentID, GetActiveSpecGroup());
	return selected;
end

function g_Addon.GetMyImage(a_ImageName)
	return "Interface\\AddOns\\CatRotationHelper\\Images\\" .. a_ImageName;
end

-- Broken as of WoW 6.0.2 (Warlords of Draenor)
function g_Addon.GetGlobalCooldown()
	local startTime, duration = GetSpellCooldown(61304);
	if (spellStart == nil) then
		return 0;
	end
	
	return duration;
end
