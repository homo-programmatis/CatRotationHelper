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
		-- Simulate target switching to decide whether to show/update frames
		g_Addon.OnTargetSwitched();
	end
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

function g_Addon.OnTargetSwitched()
	if (not IsEnemyTarget()) then
		g_Addon.ShowAllFrames(false);
		-- FIXME: fix lacerate wearoff animation
		-- CatRotationHelper_TimerLacerate:Hide();
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
	CatRotationHelper_TimerLacerate:Hide();
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

------------------------------
-- Bear - Main Frame Checks --
------------------------------

-- FIXME: Fix lacerate wearoff animation
-- function crhUpdateLacerate()
-- 	local name, stacks, expTime = g_Addon.GetTargetDebuffInfo(CRH_SPELLID_LACERATE, true);
-- 	if (name == nil) then
-- 		CatRotationHelper_TimerLacerate:Hide();
-- 		CatRotationHelperSetBearCP(0);
-- 		return;
-- 	end
-- 	
-- 	-- stop possible cp animation when lacerate is refreshed
-- 	local i = 1;
-- 	for i=1, #g_FramesBear do
-- 		g_FramesBear[i].FrameCombo:SetAlpha(1)
-- 		g_FramesBear[i].FrameCombo:SetScale(1)
-- 	end
-- 
-- 	-- setup lacerate warning
-- 	CatRotationHelper_TimerLacerate:Show()
-- 	CatRotationHelper_TimerLacerate.expTime = expTime
-- 
-- 	-- set cp effects
-- 	CatRotationHelperSetBearCP(stacks);
-- end

function CatRotationHelper_EntryPoint_OnLoad(self)
	-- load addon on druids only
	local class = select(2, UnitClass("player"))
	if(class ~= "DRUID") then
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
	g_Addon.SettingsUI_Load();
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
	elseif(event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_FACTION" and arg1 == "target")) then
		-- checking UNIT_FACTION so starting a duel behaves like changing target
		g_Addon.OnTargetSwitched();
	elseif(event == "PLAYER_TALENT_UPDATE") then
		self:RegisterEvent("UNIT_AURA");
		self:RegisterEvent("PLAYER_TARGET_CHANGED");
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		self:RegisterEvent("UNIT_FACTION");
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
		self:RegisterEvent("UNIT_POWER");

		g_Addon.OnPackageChanged();
	elseif(event == "ADDON_LOADED" and arg1 == "CatRotationHelper") then
		InitializeAddon();
	end
end

----------------------
-- Effect Functions --
----------------------

-- combo point animation when lacerate is about to expire
function CatRotationHelper_TimerLacerate_OnUpdate(self)
	local remaining = self.expTime - GetTime()

	if(remaining > 3.0) then
		return
	elseif(remaining <= 0) then
		self:Hide()
		return
	end

	local t = mod(remaining,1)

	if(t <= 0.5) then
		for i=1, #g_FramesBear do
			g_FramesBear[i].FrameCombo:SetAlpha(1.0-t)
			g_FramesBear[i].FrameCombo:SetScale(1.0+0.3*t)
		end
	else
		for i=1, #g_FramesBear do
			g_FramesBear[i].FrameCombo:SetAlpha(t)
			g_FramesBear[i].FrameCombo:SetScale(1.3-0.3*t)
		end
	end
end
