local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

-- spellIDs
local CRH_SPELLID_CLEARCAST				= 16870;

-- state variables
local clearCast = false;
local unlocked = false;
local g_IsActive = true;
local g_LastShapeshiftForm = nil;

-- saved variables
crhScale = 1;
crhSurvivalScale = 1.15;
crhEventScale = 1.15;
crhCp = true;
crhLacCounter = true;
crhEnableClearcast = true;
crhShowBear = true;
crhShowCat = true;
crhShowCatSurvival = true;
crhShowBearSurvival = true;
crhEventAngle = 270;
crhSurvivalAngle = 270;
crhMainAngle = 0;
crhCounterStartTime = 30;

-- FIXME: Settings not working
crhShowCatBerserk = true;
crhShowFeralCharge = true;
crhShowBearBerserk = true;
crhShowPredatorsSwiftness = true;

local function UpdateFrames(a_Type, a_ShowEffects)
	if (not g_IsActive) then
		return;
	end
	
	for _, frameList in pairs(g_Module.FrameLists) do
		for _, frame in pairs(frameList) do
			if ((not a_Type) or (frame.m_CrhLogic.Type == a_Type)) then
				g_Module.FrameUpdateFromLogic(frame, a_ShowEffects);
			end
		end
	end
end

local function UpdateComboPoints()
	local comboPoints = g_Module.ActivePackage.GetComboPoints();
	CatRotationHelperSetCPEffects(g_Module.FrameLists[1], comboPoints);
end

local function UpdateEverything()
	UpdateFrames(nil, false);
	UpdateComboPoints();
	CatRotationHelperCheckClearcast();
end

function g_Module.ShowAllFrames(a_IsShow)
	local frameCount = 0;
	for _, frameList in pairs(g_Module.FrameLists) do
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

function g_Module.ReloadPackage(a_NoUpdate)
	g_Module.FrameDeallocAll();
	g_IsActive = false;
	g_LastShapeshiftForm = GetShapeshiftForm();

	local playerClass = select(2, UnitClass("player"));
	g_Module.ActivePackage = g_Module.GetPackage[playerClass]();
	
	for logicListIdx, logicList in pairs(g_Module.ActivePackage.LogicLists) do
		local frameList = {};
		g_Module.FrameLists[logicListIdx] = frameList;
		
		for logicIdx, logic in pairs(logicList) do
			local frame = g_Module.FrameAlloc();
			frameList[logicIdx] = frame;
			
			frame.m_CrhLogic = logic;
			g_Module.FrameSetStatus(frame, g_Consts.STATUS_READY, nil, false);
			g_Module.FrameSetTexture(frame, frame.m_CrhLogic.Texture, frame.m_CrhLogic.MakeRoundIcon);
		end
	end
	
	CatRotationFrameSetMainScale();
	CatRotationFrameSetEventScale();
	CatRotationFrameSetSurvivalScale();
	CatRotationFrameSetMainStyle();
	CatRotationFrameSetEventStyle();
	CatRotationFrameSetSurvivalStyle();

	if (not a_NoUpdate) then
		-- Simulate target switching to decide whether to show/update frames
		g_Module.OnTargetSwitched();
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

function g_Module.OnTargetSwitched()
	if (not IsEnemyTarget()) then
		g_Module.ShowAllFrames(false);
		-- FIXME: fix lacerate wearoff animation
		-- CatRotationHelper_TimerLacerate:Hide();
		return;
	end

	g_Module.ShowAllFrames(true);
	UpdateEverything();
end

function g_Module.OnPackageChanged()
	g_Module.ReloadPackage();
end

function g_Module.OnShapeShift()
	if (g_LastShapeshiftForm == GetShapeshiftForm()) then
		-- Casting "Predatory Swiftness" will send two UPDATE_SHAPESHIFT_FORM in WOW6.2 for some reason
		return;
	end
	
	g_Module.ReloadPackage();
end

function CatRotationHelperUnlock()
	CatRotationHelper_BoxMain:Show();
	CatRotationHelper_BoxEvnt:Show();
	CatRotationHelper_BoxSurv:Show();
	CatRotationHelper_DlgMoveHint:Show();
	HideUIPanel(InterfaceOptionsFrame)
	unlocked = true;

	-- Hide effects
	CatRotationHelper_TimerLacerate:Hide();
	CatRotationHelperSetCPEffects(g_Module.FrameLists[1], 0);

	-- Show all frames in their default state, even if they should be currently hidden
	g_Module.ReloadPackage(true);
end

function CatRotationHelperLock()
	if(not unlocked) then
		return
	end

	CatRotationHelper_BoxMain:Hide();
	CatRotationHelper_BoxEvnt:Hide();
	CatRotationHelper_BoxSurv:Hide();
	CatRotationHelper_DlgMoveHint:Hide();

	unlocked = false;
	clearCast = false;

	g_Module.OnPackageChanged();
end

-- shows num combo point circles using frames in a_FrameList
function CatRotationHelperSetCPEffects(a_FrameList, num)
	for i=1, #a_FrameList do
		local frame = a_FrameList[i];

		if(i <= num) then
			if(not frame.hascp) then
				frame.hascp = true;
				g_Module.FrameUpdateTimerColor(frame, clearCast, frame.hascp);
				
				frame.FrameCombo:Show()
				frame.FrameCombo:SetScript("OnUpdate", CatRotationHelperCpEffect)
				frame.FrameCombo.startTime = GetTime()
				frame.FrameCombo.reverse = false
			end
		else
			if(frame.hascp) then
				frame.hascp = false;
				g_Module.FrameUpdateTimerColor(frame, clearCast, frame.hascp);

				frame.FrameCombo:SetScript("OnUpdate", CatRotationHelperCpEffect)
				frame.FrameCombo.startTime = GetTime()
				frame.FrameCombo.reverse = true
			else
				return;
			end
		end
	end
end

function CatRotationFrameSetMainScale()
	for _, frame in pairs(g_Module.FrameLists[1]) do
		frame:SetScale(crhScale);
	end

	CatRotationHelper_BoxMain:SetScale(crhScale);
end

function CatRotationFrameSetEventScale()
	for _, frame in pairs(g_Module.FrameLists[2]) do
		frame:SetScale(crhScale);
	end

	CatRotationHelper_BoxEvnt:SetScale(crhEventScale);
end

function CatRotationFrameSetSurvivalScale()
	for _, frame in pairs(g_Module.FrameLists[3]) do
		frame:SetScale(crhScale);
	end

	CatRotationHelper_BoxSurv:SetScale(crhSurvivalScale);
end

-- rotate main frame
function CatRotationHelper_BoxMain_OnClick()
	crhMainAngle = (crhMainAngle + 90) % 360;
	CatRotationFrameSetMainStyle()
end

function CatRotationFrameSetMainStyle()
	g_Module.FramesSetPosition(g_Module.FrameLists[1], CatRotationHelper_BoxMain, crhMainAngle);
end

-- rotate event frame
function CatRotationHelper_BoxEvnt_OnClick()
	crhEventAngle = (crhEventAngle + 90) % 360;
	CatRotationFrameSetEventStyle()
end

function CatRotationFrameSetEventStyle()
	-- FIXME: Need better positioning
	g_Module.FramesSetPosition(g_Module.FrameLists[2], CatRotationHelper_BoxEvnt, crhEventAngle);
end

-- rotate survival frame
function CatRotationHelper_BoxSurv_OnClick()
	crhSurvivalAngle = (crhSurvivalAngle + 90) % 360;
	CatRotationFrameSetSurvivalStyle()
end

function CatRotationFrameSetSurvivalStyle()
	-- FIXME: Need better positioning
	g_Module.FramesSetPosition(g_Module.FrameLists[3], CatRotationHelper_BoxSurv, crhSurvivalAngle);
end

------------------------------
-- Bear - Main Frame Checks --
------------------------------

-- FIXME: Fix lacerate wearoff animation
-- function crhUpdateLacerate()
-- 	local name, stacks, expTime = g_Module.GetTargetDebuffInfo(CRH_SPELLID_LACERATE, true);
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

-- Check for Clearcast procs - cat (has no effect for bear)
function CatRotationHelperCheckClearcast()
	if (not crhEnableClearcast) then
		return;
	end

	isBuffPresent = g_Module.GetPlayerBuffInfo(CRH_SPELLID_CLEARCAST);
	if (1 == GetShapeshiftForm()) then
		-- Ignore clearcast on bear
		isBuffPresent = false;
	end
	
	if (isBuffPresent) then
		if(not clearCast) then
			clearCast = true;

			for _, frame in pairs(g_Module.FrameLists[1]) do
				frame.FrameCombo.IconCombo:SetTexture(g_Module.GetMyImage("Cp-Blue.tga"))
				g_Module.FrameSetTexture(frame, frame.m_CrhLogic.TextureSpecial);
				g_Module.FrameUpdateTimerColor(frame, clearCast, frame.hascp);
			end
		end
	else
		if(clearCast) then
			clearCast = false;

			for _, frame in pairs(g_Module.FrameLists[1]) do
				frame.FrameCombo.IconCombo:SetTexture(g_Module.GetMyImage("Cp.tga"))
				g_Module.FrameSetTexture(frame, frame.m_CrhLogic.Texture);
				g_Module.FrameUpdateTimerColor(frame, clearCast, frame.hascp);
			end
		end
	end
end

function CatRotationHelper_EntryPoint_OnLoad(self)
	-- load addon on druids only
	local class = select(2, UnitClass("player"))
	if(class ~= "DRUID") then
		return;
	end

	CatRotationHelper_BoxMain:SetBackdropColor(0, 0, 0);
	CatRotationHelper_BoxMain:RegisterForClicks("RightButtonUp")
	CatRotationHelper_BoxMain:RegisterForDrag("LeftButton")
	CatRotationHelper_BoxMain:SetClampedToScreen(true)

	CatRotationHelper_BoxEvnt:SetBackdropColor(0, 0, 0);
	CatRotationHelper_BoxEvnt:RegisterForClicks("RightButtonUp")
	CatRotationHelper_BoxEvnt:RegisterForDrag("LeftButton")
	CatRotationHelper_BoxEvnt:SetClampedToScreen(true)

	CatRotationHelper_BoxSurv:SetBackdropColor(0, 0, 0);
	CatRotationHelper_BoxSurv:RegisterForClicks("RightButtonUp")
	CatRotationHelper_BoxSurv:RegisterForDrag("LeftButton")
	CatRotationHelper_BoxSurv:SetClampedToScreen(true)

	CatRotationHelper_EntryPoint:RegisterEvent("ADDON_LOADED");
	CatRotationHelper_EntryPoint:RegisterEvent("PLAYER_TALENT_UPDATE")
end

-- Event Handling
function CatRotationHelper_EntryPoint_OnEvent(self, event, ...)
	local arg1 = ...
	if(unlocked) then
		return
	end

	if(event == "UNIT_AURA") then
		if(arg1 == "player") then
			UpdateFrames(g_Consts.LOGIC_TYPE_BUFF, true);
			UpdateFrames(g_Consts.LOGIC_TYPE_BURST, true);
			UpdateFrames(g_Consts.LOGIC_TYPE_PROC, true);
			CatRotationHelperCheckClearcast();
		elseif(arg1 == "target") then
			UpdateFrames(g_Consts.LOGIC_TYPE_DEBUFF, true);
			UpdateComboPoints(); -- Bear "combo points"
		end
	elseif(event == "UNIT_COMBO_POINTS") then
		if(arg1 == "player") then
			UpdateComboPoints();
		end
	elseif(event == "SPELL_UPDATE_COOLDOWN") then
		UpdateFrames(g_Consts.LOGIC_TYPE_SKILL, true);
		UpdateFrames(g_Consts.LOGIC_TYPE_BURST, true);
	elseif (event == "UPDATE_SHAPESHIFT_FORM") then
		g_Module.OnShapeShift();
	elseif(event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_FACTION" and arg1 == "target")) then
		-- checking UNIT_FACTION so starting a duel behaves like changing target
		g_Module.OnTargetSwitched();
	elseif(event == "PLAYER_TALENT_UPDATE") then
		self:RegisterEvent("UNIT_AURA");
		self:RegisterEvent("PLAYER_TARGET_CHANGED");
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		self:RegisterEvent("UNIT_FACTION");
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN");

		if(crhCp) then
			self:RegisterEvent("UNIT_COMBO_POINTS");
		end

		g_Module.OnPackageChanged();
	elseif(event == "ADDON_LOADED" and arg1 == "CatRotationHelper") then
		
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

-- fade cps in/out
function CatRotationHelperCpEffect(self)
	local elapsed = GetTime() - self.startTime;

	if(elapsed >= 0.4) then
		if(self.reverse) then
			self:Hide();
		else
			self:SetScale(1)
			self:SetAlpha(1)
			self:SetScript("OnUpdate",nil)
		end
		return;
	end

	if(self.reverse) then
		elapsed = 0.4-elapsed
	end

	self:SetScale(1.3-elapsed*0.75)
	self:SetAlpha(elapsed*2.5)
end
