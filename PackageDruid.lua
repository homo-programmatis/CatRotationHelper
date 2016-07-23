local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

local function GetPackage_DruidCat()
	local newPackage =
	{
		GetComboPoints = function()
			return UnitPower("player", SPELL_POWER_COMBO_POINTS);
		end,
		
		LogicLists = 
		{
			{},
			{},
			{},
		},
	};
	
	local logicList;
	
	-- Main box
	logicList = newPackage.LogicLists[1];
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatTigersFury);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatSavageRoar);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatRake);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatLunarInspiration);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatRip);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatThrash);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatBrutalSlash);
	g_Addon.AddLogicUnused(logicList, 5);

	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Addon.AddLogicFirstAvailable(logicList, g_Addon.LogicDruidCatIncarnation, g_Addon.LogicDruidBerserk, g_Addon.LogicDruidBearIncarnation); -- BearIncarnation - In case of Guardian in cat form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatElunesGuidance);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidWildCharge);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatPredatorySwiftness);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidSurvivalInstincts);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearBarkskin);           -- In case of Guardian in cat form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidRenewal);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearLunarBeam);          -- In case of Guardian in cat form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearBristlingFur);       -- In case of Guardian in cat form
	
	return newPackage;
end

local function GetPackage_DruidBear()
	local newPackage =
	{
		GetComboPoints = function()
			local name, stacks, expTime = g_Addon.GetTargetDebuffInfo(g_Addon.LogicDruidBearThrash.SpellID, true);
			if (name == nil) then
				return 0;
			end
			
			return stacks;
		end,
		
		LogicLists = 
		{
			{},
			{},
			{},
		},
	};
	
	local logicList;
	
	-- Main box
	logicList = newPackage.LogicLists[1];
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearMangle);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearThrash);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearPulverize);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearGalacticGuardian);
	g_Addon.AddLogicUnused(logicList, 3);
	
	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Addon.AddLogicFirstAvailable(logicList, g_Addon.LogicDruidBearIncarnation, g_Addon.LogicDruidCatIncarnation, g_Addon.LogicDruidBerserk);	-- CatIncarnation/Berserk - in case of Feral in bear form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidCatElunesGuidance);      -- In case of Feral in bear form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidWildCharge);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidSurvivalInstincts);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearBarkskin);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidRenewal);                -- In case of Feral in bear form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearLunarBeam);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.LogicDruidBearBristlingFur);
	
	return newPackage;
end

local function GetPackage_DruidOther()
	local newPackage =
	{
		GetComboPoints = function()
			return 0;
		end,
		
		LogicLists = 
		{
			{},
			{},
			{},
		},
	};
	
	return newPackage;
end

g_Addon.GetPackage["DRUID"] = function()
	local shapeshiftForm = GetShapeshiftForm();

	if (1 == shapeshiftForm) then
		return GetPackage_DruidBear();
	elseif (2 == shapeshiftForm) then
		return GetPackage_DruidCat();
	else
		return GetPackage_DruidOther();
	end
end

