local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

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
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidCatTigersFury);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidCatSavageRoar);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidCatRake);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidCatLunarInspiration);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidCatRip);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidCatThrash);
	g_Module.AddLogicUnused(logicList, 5);

	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Module.AddLogicFirstAvailable(logicList, g_Module.LogicDruidCatIncarnation, g_Module.LogicDruidBerserk);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidWildCharge);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidCatPredatorySwiftness);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidSurvivalInstincts);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidBearBarkskin);           -- In case of Guardian in cat form
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidRenewal);
	
	return newPackage;
end

local function GetPackage_DruidBear()
	local newPackage =
	{
		GetComboPoints = function()
			local name, stacks, expTime = g_Module.GetTargetDebuffInfo(g_Module.LogicDruidBearThrash.SpellID, true);
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
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidBearMangle);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidBearThrash);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidBearPulverize);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidBearGalacticGuardian);
	g_Module.AddLogicUnused(logicList, 3);
	
	-- Events box
	logicList = newPackage.LogicLists[2];
	g_Module.AddLogicFirstAvailable(logicList, g_Module.LogicDruidCatIncarnation, g_Module.LogicDruidBerserk);	-- In case of Feral in bear form
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidWildCharge);

	-- Survival box
	logicList = newPackage.LogicLists[3];
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidSurvivalInstincts);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidBearBarkskin);
	g_Module.AddLogicIfAvailable(logicList, g_Module.LogicDruidRenewal);                -- In case of Feral in bear form
	
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

g_Module.GetPackage["DRUID"] = function()
	local shapeshiftForm = GetShapeshiftForm();

	if (1 == shapeshiftForm) then
		return GetPackage_DruidBear();
	elseif (2 == shapeshiftForm) then
		return GetPackage_DruidCat();
	else
		return GetPackage_DruidOther();
	end
end

