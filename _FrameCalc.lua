local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];

function g_Module.GetTargetDebuffInfo(a_SpellID, a_MyOnly)
	local filter = "HARMFUL";
	if (a_MyOnly) then
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

function g_Module.CalcFrameFromDebuff(a_SpellID, a_Stacks, a_MyOnly)
	local name, stacks, expTime = g_Module.GetTargetDebuffInfo(a_SpellID, a_MyOnly);
	if (not name) then
		return 0;
	end
	
	if (a_Stacks and (stacks ~= a_Stacks)) then
		return 0;
	end
	
	return expTime;
end

function g_Module.CalcFrameFromBuff(a_SpellID)
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitBuff("player", g_Module.GetSpellName(a_SpellID));
	if (not name) then
		return 0;
	end
	
	return expTime;
end
