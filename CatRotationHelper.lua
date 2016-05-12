local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

-- spellIDs
local CRH_SPELLID_CLEARCAST				= 16870;
local CRH_SPELLID_LACERATE				= 33745;

local CRH_SHAPE_BEAR 					= 1;
local CRH_SHAPE_CAT						= 2;

local function CreateFrameWithLogic(a_Logic)
	local frame = CreateFrame("Frame", nil, UIParent);
	frame.m_CrhLogic = a_Logic;
	return frame;
end

local g_FramesCat =
{
	CreateFrameWithLogic(g_Module.LogicDruidCatTigersFury),
	CreateFrameWithLogic(g_Module.LogicDruidCatSavageRoar),
	CreateFrameWithLogic(g_Module.LogicDruidCatRake),
	CreateFrameWithLogic(g_Module.LogicDruidCatRip),
	CreateFrameWithLogic(g_Module.LogicDruidCatThrash),
};

local g_FramesBear =
{
	CreateFrameWithLogic(g_Module.LogicDruidBearMangle),
	CreateFrameWithLogic(g_Module.LogicDruidBearLacerate),
	CreateFrameWithLogic(g_Module.LogicDruidBearThrash),
	CreateFrameWithLogic(g_Module.LogicUnusedFrame),
	CreateFrameWithLogic(g_Module.LogicUnusedFrame),
};

local g_FramesEvents =
{
	CreateFrameWithLogic(g_Module.LogicDruidBerserk),
	CreateFrameWithLogic(g_Module.LogicDruidWildCharge),
	CreateFrameWithLogic(g_Module.LogicDruidCatPredatorySwiftness),
};

local g_FramesSurv =
{
	CreateFrameWithLogic(g_Module.LogicDruidSurvivalInstincts),
	CreateFrameWithLogic(g_Module.LogicDruidBearBarkskin),
};

-- state variables
local inCatForm = false;
local inBearForm = false;
local enemyTarget = false;
local clearCast = false;
local unlocked = false;

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

local function crhIsAddonUseful()
	local specID = GetSpecialization();
	if ((specID ~= 2) and (specID ~= 3)) then
		return false;
	end
	
	return true;
end

-- Shows/hides all frames in a_FrameList
local function ShowFrames(a_FrameList, a_IsShow)
	for i=1, #a_FrameList do
		a_FrameList[i]:SetShown(a_IsShow);
	end
end

local function UpdateFramesByType(a_FrameList, a_Type, a_ShowEffects)
	for i = 1, #a_FrameList do
		local frame = a_FrameList[i];
	
		if ((not a_Type) or (frame.m_CrhLogic.Type == a_Type)) then
			g_Module.FrameUpdateFromLogic(frame, a_ShowEffects);
		end
	end
end

function CatRotationHelperUpdateEverything()
	if(not crhIsAddonUseful()) then
		return
	end
	
	if(UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")) then
		enemyTarget = true
	else
		enemyTarget = false
		CatRotationHelperHideAll()
	end

	if(GetShapeshiftForm() == CRH_SHAPE_CAT and crhShowCat) then
		if(inBearForm) then
			CatRotationHelperHideAll()
			inBearForm = false
		end

		inCatForm = true

		if(enemyTarget) then
			ShowFrames(g_FramesCat, true);
			ShowFrames(g_FramesBear, false);
			UpdateFramesByType(g_FramesCat, nil, false);
			CatRotationHelperSetCatCP(GetComboPoints("player"));
			ShowFrames(g_FramesSurv, crhShowCatSurvival);
			UpdateFramesByType(g_FramesSurv, nil, false);
			ShowFrames(g_FramesEvents, true);
			UpdateFramesByType(g_FramesEvents, nil, false);
		end

	elseif(GetShapeshiftForm() == CRH_SHAPE_BEAR and crhShowBear) then
		if(inCatForm) then
			CatRotationHelperHideAll()
			inCatForm = false
		end

		inBearForm = true

		if(enemyTarget) then
			ShowFrames(g_FramesBear, true);
			ShowFrames(g_FramesCat, false);
			UpdateFramesByType(g_FramesBear, nil, false);
			crhUpdateLacerate();
			ShowFrames(g_FramesSurv, crhShowBearSurvival);
			UpdateFramesByType(g_FramesSurv, nil, false);
			ShowFrames(g_FramesEvents, true);
			UpdateFramesByType(g_FramesEvents, nil, false);
		end
	else
		CatRotationHelperHideAll();
		inCatForm = false
 		inBearForm = false
	end
end

function CatRotationHelperUnlock()
	CatRotationHelper_BoxMain:Show();
	CatRotationHelper_BoxEvnt:Show();
	CatRotationHelper_BoxSurv:Show();
	CatRotationHelper_DlgMoveHint:Show();
	HideUIPanel(InterfaceOptionsFrame)
	unlocked = true;

	-- Hide bear frames
	ShowFrames(g_FramesBear, false);
	CatRotationHelper_TimerLacerate:Hide()
	CatRotationHelperSetBearCP(0)

	-- show static cat frames
	CatRotationHelperSetCatCP(0)

	for i=1, #g_FramesCat do
		local frame = g_FramesCat[i];

		g_Module.FrameSetStatus(frame, g_Consts.STATUS_READY, nil, false);
		frame:Show();
	end

	for i=1, #g_FramesEvents do
		g_FramesEvents[i]:Show()
		g_Module.FrameSetStatus(g_FramesEvents[i], g_Consts.STATUS_READY, nil, false);
	end

	for i=1, #g_FramesSurv do
		g_FramesSurv[i]:Show()
		g_Module.FrameSetStatus(g_FramesSurv[i], g_Consts.STATUS_READY, nil, false);
	end
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

	for i=1, #g_FramesCat do
		local frame = g_FramesCat[i]

		frame:Hide()
		g_Module.FrameDrawFaded(frame);
	end

	for i=1, #g_FramesBear do
		local frame = g_FramesBear[i]

		frame:Hide()
		g_Module.FrameDrawFaded(frame);
	end

	for i=1, #g_FramesEvents do
		local frame = g_FramesEvents[i];

		frame:Hide()
		g_Module.FrameDrawFaded(frame);
	end

	for i=1, #g_FramesSurv do
		local frame = g_FramesSurv[i];

		frame:Hide()
		g_Module.FrameDrawFaded(frame);
	end

	CatRotationHelperUpdateEverything()
end

-- shows num combo point circles using frames in a_FrameList
local function CatRotationHelperSetCPEffects(a_FrameList, num)
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

function CatRotationHelperSetCatCP(num)
	if(not crhCp) then return; end

	CatRotationHelperSetCPEffects(g_FramesCat, num);
end

function CatRotationHelperSetBearCP(num)
	if(not crhLacCounter) then return; end

	CatRotationHelperSetCPEffects(g_FramesBear, num);
end

function CatRotationFrameSetMainScale()
	for i=1, #g_FramesCat do
		g_FramesCat[i]:SetScale(crhScale);
	end

	for i=1, #g_FramesBear do
		g_FramesBear[i]:SetScale(crhScale);
	end

	CatRotationHelper_BoxMain:SetScale(crhScale);
end

function CatRotationFrameSetEventScale()
	for i=1, #g_FramesEvents do
		g_FramesEvents[i]:SetScale(crhEventScale);
	end

	CatRotationHelper_BoxEvnt:SetScale(crhEventScale);
end

function CatRotationFrameSetSurvivalScale()
	for i=1, #g_FramesSurv do
		g_FramesSurv[i]:SetScale(crhSurvivalScale);
	end

	CatRotationHelper_BoxSurv:SetScale(crhSurvivalScale);
end

-- rotate main frame
function CatRotationHelper_BoxMain_OnClick()
	crhMainAngle = (crhMainAngle + 90) % 360;
	CatRotationFrameSetMainStyle()
end

function CatRotationFrameSetMainStyle()
	g_Module.FramesSetPosition(g_FramesCat,  CatRotationHelper_BoxMain, crhMainAngle);
	g_Module.FramesSetPosition(g_FramesBear, CatRotationHelper_BoxMain, crhMainAngle);
end

-- rotate event frame
function CatRotationHelper_BoxEvnt_OnClick()
	crhEventAngle = (crhEventAngle + 90) % 360;
	CatRotationFrameSetEventStyle()
end

function CatRotationFrameSetEventStyle()
	-- FIXME: Need better positioning
	g_Module.FramesSetPosition(g_FramesEvents, CatRotationHelper_BoxEvnt, crhEventAngle);
end

-- rotate survival frame
function CatRotationHelper_BoxSurv_OnClick()
	crhSurvivalAngle = (crhSurvivalAngle + 90) % 360;
	CatRotationFrameSetSurvivalStyle()
end

function CatRotationFrameSetSurvivalStyle()
	-- FIXME: Need better positioning
	g_Module.FramesSetPosition(g_FramesSurv, CatRotationHelper_BoxSurv, crhSurvivalAngle);
end

function CatRotationHelperHideAll()
	CatRotationHelper_TimerLacerate:Hide();

	CatRotationHelperSetBearCP(0);
	CatRotationHelperSetCatCP(0);

	ShowFrames(g_FramesCat, false);
	ShowFrames(g_FramesBear, false);
	ShowFrames(g_FramesEvents, false);
	ShowFrames(g_FramesSurv, false);
end

------------------------------
-- Bear - Main Frame Checks --
------------------------------

function crhUpdateLacerate()
	local name, stacks, expTime = g_Module.GetTargetDebuffInfo(CRH_SPELLID_LACERATE, true);
	if (name == nil) then
		CatRotationHelper_TimerLacerate:Hide();
		CatRotationHelperSetBearCP(0);
		return;
	end
	
	-- stop possible cp animation when lacerate is refreshed
	local i = 1;
	for i=1, #g_FramesBear do
		g_FramesBear[i].FrameCombo:SetAlpha(1)
		g_FramesBear[i].FrameCombo:SetScale(1)
	end

	-- setup lacerate warning
	CatRotationHelper_TimerLacerate:Show()
	CatRotationHelper_TimerLacerate.expTime = expTime

	-- set cp effects
	CatRotationHelperSetBearCP(stacks);
end

-- Check for Clearcast procs - cat (has no effect for bear)
function CatRotationHelperCheckClearcast()
	if (not crhEnableClearcast) then
		return;
	end

	isBuffPresent = g_Module.GetPlayerBuffInfo(CRH_SPELLID_CLEARCAST);
	if (isBuffPresent) then
		if(not clearCast) then
			clearCast = true;

			for i=1, #g_FramesCat do
				local frame = g_FramesCat[i];

				frame.FrameCombo.IconCombo:SetTexture(g_Module.GetMyImage("Cp-Blue.tga"))
				g_Module.FrameSetTexture(frame, frame.m_CrhLogic.TextureSpecial);
				g_Module.FrameUpdateTimerColor(frame, clearCast, frame.hascp);
			end
		end
	else
		if(clearCast) then
			clearCast = false;

			for i=1,#g_FramesCat do
				local frame = g_FramesCat[i];

				frame.FrameCombo.IconCombo:SetTexture(g_Module.GetMyImage("Cp.tga"))
				g_Module.FrameSetTexture(frame, frame.m_CrhLogic.Texture);
				g_Module.FrameUpdateTimerColor(frame, clearCast, frame.hascp);
			end
		end
	end
end

local function FrameSetup(a_Frame, a_FrameName)
	a_Frame.hascp = false;

	a_Frame:SetSize(g_Consts.UI_SIZE_FRAME, g_Consts.UI_SIZE_FRAME);
	a_Frame:Hide();

	a_Frame.FrameCombo = CreateFrame("Frame", a_FrameName .. "CP", a_Frame);
	a_Frame.FrameCombo:SetFrameStrata("BACKGROUND");
	a_Frame.FrameCombo:SetPoint("CENTER");
	a_Frame.FrameCombo:SetSize(g_Consts.UI_SIZE_FRAME * 1.13, g_Consts.UI_SIZE_FRAME * 1.13);
	a_Frame.FrameCombo.startTime = nil;
	a_Frame.FrameCombo:Hide();

	a_Frame.FrameCombo.IconCombo = a_Frame.FrameCombo:CreateTexture(nil, "BACKGROUND");
	a_Frame.FrameCombo.IconCombo:SetTexture(g_Module.GetMyImage("Cp.tga"));
	a_Frame.FrameCombo.IconCombo:SetAllPoints(a_Frame.FrameCombo);

	a_Frame.IconSpell = a_Frame:CreateTexture(nil, "ARTWORK");
	a_Frame.IconSpell:SetAllPoints(a_Frame);

	-- buff fade/gain effects
	local overlayOffs = g_Consts.UI_SIZE_FRAME * 0.20;
	a_Frame.FrameOverlay = CreateFrame("Frame", a_FrameName .. "O", a_Frame, "CatRotationHelper_FrameBaseOverlay");
	a_Frame.FrameOverlay.IconSpell:SetBlendMode("ADD");
	a_Frame.FrameOverlay:SetPoint("TOPLEFT", a_Frame, "TOPLEFT", -overlayOffs, overlayOffs);
	a_Frame.FrameOverlay:SetPoint("BOTTOMRIGHT", a_Frame, "BOTTOMRIGHT", overlayOffs, -overlayOffs);

	a_Frame.FrameTimer = CreateFrame("Frame", a_FrameName .. "C", a_Frame);
	a_Frame.FrameTimer:SetScript("OnUpdate", g_Module.FrameTimer_OnUpdate);
	a_Frame.FrameTimer:Hide();
	a_Frame.FrameTimer.endTime = nil;

	a_Frame.FrameTimer.TextTime = a_Frame.FrameTimer:CreateFontString(nil, "OVERLAY", "CatRotationHelper_Font_Normal");
	a_Frame.FrameTimer.TextTime:SetPoint("CENTER", a_Frame, "CENTER", 0, 0);
	a_Frame.FrameTimer.TextStar = a_Frame.FrameTimer:CreateFontString(nil, "OVERLAY", "CatRotationHelper_Font_Bigger");
	a_Frame.FrameTimer.TextStar:SetPoint("CENTER", a_Frame, "CENTER", 0, -5);
	a_Frame.FrameTimer.TextStar:SetText("*");
	a_Frame.FrameTimer.TextStar:Hide();
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

	-- setup cat
	for i=1, #g_FramesCat do
		local frame = g_FramesCat[i];
		FrameSetup(frame, "CatRotationHelper_Cat_" .. i);
		
		g_Module.FrameSetStatus(frame, g_Consts.STATUS_READY, nil, false);
		g_Module.FrameSetTexture(frame, frame.m_CrhLogic.Texture, frame.m_CrhLogic.MakeRoundIcon);
	end

	-- setup bear
	for i=1, #g_FramesBear do
		local frame = g_FramesBear[i];
		FrameSetup(frame, "CatRotationHelper_Bear_" .. i);
		
		g_Module.FrameSetStatus(frame, g_Consts.STATUS_READY, nil, false);
		g_Module.FrameSetTexture(frame, frame.m_CrhLogic.Texture, frame.m_CrhLogic.MakeRoundIcon);
	end

	-- setup events
	for i=1, #g_FramesEvents do
		local frame = g_FramesEvents[i];
		FrameSetup(frame, "CatRotationHelper_Event_" .. i);
		
		g_Module.FrameSetStatus(frame, g_Consts.STATUS_READY, nil, false);
		g_Module.FrameSetTexture(frame, frame.m_CrhLogic.Texture, frame.m_CrhLogic.MakeRoundIcon);
	end

	-- setup survival frame
	for i=1, #g_FramesSurv do
		local frame = g_FramesSurv[i];
		FrameSetup(frame, "CatRotationHelper_Surv_" .. i);

		g_Module.FrameSetStatus(frame, g_Consts.STATUS_READY, nil, false);
		g_Module.FrameSetTexture(frame, frame.m_CrhLogic.Texture, frame.m_CrhLogic.MakeRoundIcon);
	end

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
		if(enemyTarget) then
			if(inCatForm) then
				if(arg1 == "player") then
					UpdateFramesByType(g_FramesCat, g_Consts.LOGIC_TYPE_BUFF, true);
					UpdateFramesByType(g_FramesCat, g_Consts.LOGIC_TYPE_BURST, true);
					CatRotationHelperCheckClearcast();
					UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_BUFF, true);
					UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_BURST, true);
					UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_BUFF, true);
					UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_BURST, true);
					UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_PROC, true);
				elseif(arg1 == "target") then
					UpdateFramesByType(g_FramesCat, g_Consts.LOGIC_TYPE_DEBUFF, true);
				end
			elseif(inBearForm) then
				if(arg1 == "player") then
					UpdateFramesByType(g_FramesBear, g_Consts.LOGIC_TYPE_BUFF, true);
					UpdateFramesByType(g_FramesBear, g_Consts.LOGIC_TYPE_BURST, true);
					UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_BUFF, true);
					UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_BURST, true);
					UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_BUFF, true);
					UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_BURST, true);
					UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_PROC, true);
				elseif(arg1 == "target") then
					UpdateFramesByType(g_FramesBear, g_Consts.LOGIC_TYPE_DEBUFF, true);
				end
			end
		end

	elseif(event == "UNIT_COMBO_POINTS") then
		if(arg1 == "player") then
			CatRotationHelperSetCatCP(GetComboPoints("player"))
		end

	elseif(event == "SPELL_UPDATE_COOLDOWN") then
		if(enemyTarget) then
			if(inBearForm) then
				UpdateFramesByType(g_FramesBear, g_Consts.LOGIC_TYPE_SKILL, true);
				UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_SKILL, true);
				UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_BURST, true);
				UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_SKILL, true);
				UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_BURST, true);
			elseif(inCatForm) then
				UpdateFramesByType(g_FramesCat, g_Consts.LOGIC_TYPE_SKILL, true);
				UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_SKILL, true);
				UpdateFramesByType(g_FramesSurv, g_Consts.LOGIC_TYPE_BURST, true);
				UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_SKILL, true);
				UpdateFramesByType(g_FramesEvents, g_Consts.LOGIC_TYPE_BURST, true);
			end
		end

	elseif(event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_FACTION" and arg1 == "target")) then
		-- checking UNIT_FACTION so starting a duel behaves like changing target
		CatRotationHelperUpdateEverything()

	--elseif(event == "UNIT_ATTACK_POWER" or event == "UNIT_ATTACK_SPEED" or event == "COMBAT_RATING_UPDATE") then

	elseif(event == "PLAYER_TALENT_UPDATE") then
		if(crhIsAddonUseful()) then
			self:RegisterEvent("UNIT_AURA");
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
			self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
			self:RegisterEvent("UNIT_FACTION");
			self:RegisterEvent("SPELL_UPDATE_COOLDOWN");

			if(crhCp) then
				self:RegisterEvent("UNIT_COMBO_POINTS");
			end

			CatRotationHelperUpdateEverything()
		else
			self:UnregisterEvent("UNIT_AURA");
			self:UnregisterEvent("PLAYER_TARGET_CHANGED");
			self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
			self:UnregisterEvent("UNIT_FACTION");
			self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
			self:UnregisterEvent("UNIT_COMBO_POINTS");

			CatRotationHelperHideAll();
		end

	elseif(event == "ADDON_LOADED" and arg1 == "CatRotationHelper") then
		CatRotationFrameSetMainScale()
		CatRotationFrameSetEventScale()
		CatRotationFrameSetSurvivalScale()
		CatRotationFrameSetMainStyle()
		CatRotationFrameSetEventStyle()
		CatRotationFrameSetSurvivalStyle()
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
