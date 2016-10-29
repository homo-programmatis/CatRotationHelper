local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

-- spellIDs
local CRH_SPELLID_CLEARCAST				= 16870;

-- state variables
local g_IsMovingFrames = false;
local g_IsActive = true;
local g_LastShapeshiftForm = nil;

local function UpdateFrames(a_Type, a_ShowEffects)
	if (not g_IsActive) then
		return;
	end
	
	for _, frameList in pairs(g_Addon.FrameLists) do
		for _, frame in pairs(frameList) do
			if ((not a_Type) or (frame.m_CrhLogic.Type == a_Type)) then
				g_Addon.FrameUpdateFromLogic(frame, a_ShowEffects);
			end
		end
	end
end

local function UpdateComboPoints()
	local comboPoints = g_Addon.ActivePackage.GetComboPoints();
	CatRotationHelperSetCPEffects(g_Addon.FrameLists[1], comboPoints);
end

local function UpdateClearcast()
	isBuffPresent = g_Addon.GetPlayerBuffInfo(CRH_SPELLID_CLEARCAST);
	if (1 == GetShapeshiftForm()) then
		-- Ignore clearcast on bear (can happen when feral is shapeshifted to bear)
		isBuffPresent = false;
	end
	
	for _, frame in pairs(g_Addon.FrameLists[1]) do
		g_Addon.FrameSetClearcast(frame, isBuffPresent);
	end
end

local function UpdateEverything()
	UpdateFrames(nil, false);
	UpdateComboPoints();
	UpdateClearcast();
end

function g_Addon.ShowAllFrames(a_IsShow)
	local frameCount = 0;
	for _, frameList in pairs(g_Addon.FrameLists) do
		for _, frame in pairs(frameList) do
			frame:SetShown(a_IsShow);
			frameCount = frameCount + 1;
		end
	end

	if (0 == frameCount) then
		-- Optimization: with (g_IsActive == false), no events are processed
		-- If we have 0 frames anyway, processing events doesn't make sense
		g_IsActive = false;
	else
		g_IsActive = a_IsShow;
	end
end

function g_Addon.ReloadPackage(a_Flags)
	local isSettings = a_Flags and a_Flags.IsSettings;
	
	g_Addon.FrameDeallocAll();
	g_IsActive = false;
	
	if (isSettings) then
		-- A different package can be loaded for the purposes of settings
		g_LastShapeshiftForm = nil;
	else
		g_LastShapeshiftForm = GetShapeshiftForm();
	end

	local playerClass = select(2, UnitClass("player"));
	g_Addon.ActivePackage = g_Addon.GetPackage[playerClass](a_Flags);
	
	for logicListIdx, logicList in pairs(g_Addon.ActivePackage.LogicLists) do
		local frameList = {};
		g_Addon.FrameLists[logicListIdx] = frameList;
		
		for logicIdx, logic in pairs(logicList) do
			local frame = g_Addon.FrameAlloc();
			frameList[logicIdx] = frame;
			
			frame.m_CrhLogic = logic;
			g_Addon.FrameSetStatus(frame, g_Consts.STATUS_READY, nil, false);
			g_Addon.FrameSetTexture(frame, frame.m_CrhLogic.Texture, frame.m_CrhLogic.MakeRoundIcon);
		end
	end
	
	g_Addon.FrameBoxes_LoadSettings();

	if (not isSettings) then
		g_Addon.DecideShowHideFrames();
	end
end

local function IsCombat()
	return UnitAffectingCombat("player");
end

local function IsEnemyTarget()
	if (not UnitExists("target")) then
		return false;
	end

	if (not UnitCanAttack("player", "target")) then
		return false;
	end
	
	if (UnitIsDead("target")) then
		return false;
	end
	
	return true;
end

function g_Addon.IsShallShowFrames()
	local showWhen = g_Addon.Settings.ShowWhen;

	if     (g_Consts.UI_SHOWWHEN_ALWAYS == showWhen) then
		return true;
	elseif (g_Consts.UI_SHOWWHEN_COMBAT == showWhen) then
		return IsCombat();
	elseif (g_Consts.UI_SHOWWHEN_TARGET == showWhen) then
		return IsEnemyTarget();
	elseif (g_Consts.UI_SHOWWHEN_COMBAT_OR_TARGET == showWhen) then
		return (IsCombat() or IsEnemyTarget());
	elseif (g_Consts.UI_SHOWWHEN_COMBAT_AND_TARGET == showWhen) then
		return (IsCombat() and IsEnemyTarget());
	else
		error("Invalid settings value", 2);
	end
end

function g_Addon.DecideShowHideFrames()
	if (not g_Addon.IsShallShowFrames()) then
		g_Addon.ShowAllFrames(false);
		return;
	end

	g_Addon.ShowAllFrames(true);
	UpdateEverything();
end

function g_Addon.OnPackageChanged()
	g_Addon.ReloadPackage();
end

function g_Addon.OnShapeShift()
	if (g_LastShapeshiftForm == GetShapeshiftForm()) then
		-- Casting "Predatory Swiftness" will send two UPDATE_SHAPESHIFT_FORM in WOW6.2 for some reason
		return;
	end
	
	g_Addon.ReloadPackage();
end

function CatRotationHelperUnlock()
	for _, frameBox in pairs(g_Addon.FrameBoxes) do
		frameBox:Show();
		frameBox:SetMovable(true);
		frameBox:EnableMouse(true);
	end
	
	CatRotationHelper_DlgMoveHint:Show();
	
	HideUIPanel(InterfaceOptionsFrame)
	g_IsMovingFrames = true;

	-- Hide effects
	CatRotationHelperSetCPEffects(g_Addon.FrameLists[1], 0);

	-- Show all frames in their default state, even if they should be currently hidden
	g_Addon.ReloadPackage({IsSettings = true});
end

function CatRotationHelperLock()
	if (not g_IsMovingFrames) then
		return
	else
		g_IsMovingFrames = false;
	end

	for _, frameBox in pairs(g_Addon.FrameBoxes) do
		frameBox:Hide();
		frameBox:SetMovable(false);
		frameBox:EnableMouse(false);
	end

	CatRotationHelper_DlgMoveHint:Hide();

	g_Addon.OnPackageChanged();
end

-- shows num combo point circles using frames in a_FrameList
function CatRotationHelperSetCPEffects(a_FrameList, num)
	for i=1, #a_FrameList do
		local frame = a_FrameList[i];
		local isCombo = (i <= num);
		g_Addon.FrameSetCombo(frame, isCombo);
	end
end

function CatRotationHelper_EntryPoint_OnLoad(self)
	local playerClass = select(2, UnitClass("player"))
	if (nil == g_Addon.GetPackage[playerClass]) then
		-- This class is not supported, do not load addon at all
		return;
	end

	CatRotationHelper_EntryPoint:RegisterEvent("ADDON_LOADED");
	CatRotationHelper_EntryPoint:RegisterEvent("PLAYER_TALENT_UPDATE")
end

local function InitializeAddon()
	g_Addon.Settings_Load();

	g_Addon.FrameBoxes =
	{
		CatRotationHelper_BoxMain,
		CatRotationHelper_BoxEvnt,
		CatRotationHelper_BoxSurv,
	};
	
	for index, frameBox in pairs(g_Addon.FrameBoxes) do
		frameBox.m_Index = index;
	
		frameBox:SetBackdropColor(0, 0, 0);
		frameBox:RegisterForClicks("RightButtonUp");
		frameBox:RegisterForDrag("LeftButton");
		frameBox:SetClampedToScreen(true);
		
		frameBox:SetScript("OnDragStart", frameBox.StartMoving);
		frameBox:SetScript("OnDragStop", g_Addon.FrameBox_OnDragStop);
		frameBox:SetScript("OnClick", g_Addon.FrameBox_OnClick);
	end
	
	g_Addon.SettingsUI_Initialize();
end

-- Event Handling
function CatRotationHelper_EntryPoint_OnEvent(self, event, arg1, ...)
	if (g_IsMovingFrames) then
		return
	end

	if(event == "UNIT_AURA") then
		if(arg1 == "player") then
			UpdateFrames(g_Consts.LOGIC_TYPE_BUFF, true);
			UpdateFrames(g_Consts.LOGIC_TYPE_BURST, true);
			UpdateFrames(g_Consts.LOGIC_TYPE_PROC, true);
			UpdateClearcast();
		elseif(arg1 == "target") then
			UpdateFrames(g_Consts.LOGIC_TYPE_DEBUFF, true);
			UpdateComboPoints(); -- Bear "combo points"
		end
	elseif(event == "UNIT_POWER") then
		if(arg1 == "player") then
			UpdateComboPoints();
		end
	elseif(event == "SPELL_UPDATE_COOLDOWN") then
		UpdateFrames(g_Consts.LOGIC_TYPE_SKILL, true);
		UpdateFrames(g_Consts.LOGIC_TYPE_BURST, true);
	elseif (event == "UPDATE_SHAPESHIFT_FORM") then
		g_Addon.OnShapeShift();
	elseif (event == "PLAYER_EQUIPMENT_CHANGED") then
		if (INVSLOT_MAINHAND == arg1) then
			-- Handle possible artifact swap
			g_Addon.ReloadPackage();
		end
	elseif ((event == "PLAYER_REGEN_DISABLED") or (event == "PLAYER_REGEN_ENABLED")) then
		-- Actually means entering/leaving combat
		g_Addon.DecideShowHideFrames();
	elseif(event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_FACTION" and arg1 == "target")) then
		-- checking UNIT_FACTION so starting a duel behaves like changing target
		g_Addon.DecideShowHideFrames();
	elseif(event == "PLAYER_TALENT_UPDATE") then
		self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:RegisterEvent("PLAYER_TARGET_CHANGED");
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
		self:RegisterEvent("UNIT_AURA");
		self:RegisterEvent("UNIT_FACTION");
		self:RegisterEvent("UNIT_POWER");
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");

		g_Addon.OnPackageChanged();
	elseif(event == "ADDON_LOADED" and arg1 == "CatRotationHelper") then
		InitializeAddon();
	end
end

function g_Addon.OnShowChatCommandsHelp()
	g_Addon.PrintToChat("'" .. SLASH_CATROTATIONHELPER1 .. " reset' - resets settings for this addon");
	g_Addon.PrintToChat("'" .. SLASH_CATROTATIONHELPER1 .. " restore' - swaps active and backup settings (settings backed up on 'reset'). Will not work after UI reload / logout.");
end

function g_Addon.OnDebugTest()
	
end

SLASH_CATROTATIONHELPER1 = '/catrotationhelper';
SLASH_CATROTATIONHELPER2 = '/crh';
function SlashCmdList.CATROTATIONHELPER(a_CommandLine, a_TextBox)
	local command, args = a_CommandLine:match("^(%S*)%s*(.-)$");
	
	if     (command == "") then
		g_Addon.OnShowChatCommandsHelp();
	elseif (command == "reset") then
		g_Addon.Settings_Reset();
		g_Addon.ReloadPackage(); -- Reload everything to apply settings
	elseif (command == "restore") then
		g_Addon.Settings_UndoReset();
		g_Addon.ReloadPackage(); -- Reload everything to apply settings
	elseif (command == "test") then
		g_Addon.OnDebugTest(args);
	else
		g_Addon.PrintToChat("Unknown slash command: " .. command);
	end
end
