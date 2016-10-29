local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

local function GetPackage_DruidCat(a_Flags)
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
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_TigersFury);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_SavageRoar);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Rake);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_LunarInspiration);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Rip);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_PredatorySwiftness_Bloodtalons);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Bloodtalons);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Thrash_Cat);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_BrutalSlash);
	g_Addon.Logic_AddUnused   (logicList, a_Flags, 5);

	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Addon.Logic_AddFirstGood(logicList, a_Flags, g_Addon.Logics.Druid_Incarnation_Cat, g_Addon.Logics.Druid_Berserk, g_Addon.Logics.Druid_Incarnation_Bear); -- BearIncarnation - In case of Guardian in cat form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_AshamanesFrenzy);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_ElunesGuidance);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_WildCharge);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_PredatorySwiftness);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_SurvivalInstincts);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_RageOfTheSleeper);   -- In case of Guardian in cat form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Barkskin);           -- In case of Guardian in cat form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Renewal);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_LunarBeam);          -- In case of Guardian in cat form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_BristlingFur);       -- In case of Guardian in cat form
	
	return newPackage;
end

local function GetPackage_DruidBear(a_Flags)
	local newPackage =
	{
		GetComboPoints = function()
			local stacks, expTime = g_Addon.GetTargetDebuffInfo(g_Addon.Logics.Druid_Thrash_Bear_Debuff.SpellID, true);
			if (stacks == nil) then
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
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Mangle_Bear);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Thrash_Bear);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Pulverize);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_GalacticGuardian);
	g_Addon.Logic_AddUnused   (logicList, a_Flags, 3);
	
	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Addon.Logic_AddFirstGood(logicList, a_Flags, g_Addon.Logics.Druid_Incarnation_Bear, g_Addon.Logics.Druid_Incarnation_Cat, g_Addon.Logics.Druid_Berserk);	-- CatIncarnation/Berserk - in case of Feral in bear form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_AshamanesFrenzy);     -- In case of Feral in bear form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_ElunesGuidance);      -- In case of Feral in bear form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_WildCharge);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_SurvivalInstincts);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_RageOfTheSleeper);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Barkskin);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_Renewal);                -- In case of Feral in bear form
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_LunarBeam);
	g_Addon.Logic_AddIfItsGood(logicList, a_Flags, g_Addon.Logics.Druid_BristlingFur);
	
	return newPackage;
end

local function GetPackage_DruidOther(a_Flags)
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

-- Figure which shapeshift icons to use for configuring frame positions
local function GetSettingsShapeshift()
	local spec = GetSpecialization();
	
	if (g_Consts.SPEC_DRUID_FERAL == spec) then
		-- Feral's primary shapeshift is Cat
		return g_Consts.SHAPE_DRUID_CAT;
	elseif (g_Consts.SPEC_DRUID_GUARDIAN == spec) then
		-- Guardian's primary shapeshift is Bear
		return g_Consts.SHAPE_DRUID_BEAR;
	end

	return 0;
end

g_Addon.GetPackage["DRUID"] = function(a_Flags)
	local shapeshiftForm = GetShapeshiftForm();
	if (a_Flags and a_Flags.IsSettings) then
		shapeshiftForm = GetSettingsShapeshift();
	end

	if (g_Consts.SHAPE_DRUID_BEAR == shapeshiftForm) then
		return GetPackage_DruidBear(a_Flags);
	elseif (g_Consts.SHAPE_DRUID_CAT == shapeshiftForm) then
		return GetPackage_DruidCat(a_Flags);
	else
		return GetPackage_DruidOther(a_Flags);
	end
end

