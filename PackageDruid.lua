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
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_TigersFury);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_SavageRoar);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Rake);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_LunarInspiration);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Rip);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Thrash_Cat);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_BrutalSlash);
	g_Addon.AddLogicUnused(logicList, 5);

	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Addon.AddLogicFirstAvailable(logicList, g_Addon.Logics.Druid_Incarnation_Cat, g_Addon.Logics.Druid_Berserk, g_Addon.Logics.Druid_Incarnation_Bear); -- BearIncarnation - In case of Guardian in cat form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_ElunesGuidance);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_WildCharge);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_PredatorySwiftness);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_SurvivalInstincts);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Barkskin);           -- In case of Guardian in cat form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Renewal);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_LunarBeam);          -- In case of Guardian in cat form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_BristlingFur);       -- In case of Guardian in cat form
	
	return newPackage;
end

local function GetPackage_DruidBear()
	local newPackage =
	{
		GetComboPoints = function()
			local name, stacks, expTime = g_Addon.GetTargetDebuffInfo(g_Addon.Logics.Druid_Thrash_Bear.SpellID, true);
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
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Mangle_Bear);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Thrash_Bear);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Pulverize);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_GalacticGuardian);
	g_Addon.AddLogicUnused(logicList, 3);
	
	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Addon.AddLogicFirstAvailable(logicList, g_Addon.Logics.Druid_Incarnation_Bear, g_Addon.Logics.Druid_Incarnation_Cat, g_Addon.Logics.Druid_Berserk);	-- CatIncarnation/Berserk - in case of Feral in bear form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_ElunesGuidance);      -- In case of Feral in bear form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_WildCharge);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_SurvivalInstincts);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Barkskin);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_Renewal);                -- In case of Feral in bear form
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_LunarBeam);
	g_Addon.AddLogicIfAvailable(logicList, g_Addon.Logics.Druid_BristlingFur);
	
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

