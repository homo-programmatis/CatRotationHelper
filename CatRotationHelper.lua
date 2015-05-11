local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

-- spellIDs
local CRH_SPELLID_BARKSKIN				= 22812;
local CRH_SPELLID_BERSERK 				= 106952;
local CRH_SPELLID_CLEARCAST				= 16870;
local CRH_SPELLID_FAERIE_FIRE			= 770;
local CRH_SPELLID_FAERIE_SWARM			= 102355;
local CRH_SPELLID_FERAL_CHARGE			= 102401;
local CRH_SPELLID_LACERATE				= 33745;
local CRH_SPELLID_PREDATORS_SWIFTNESS	= 69369;
local CRH_SPELLID_SAVAGE_DEFENSE		= 62606;
local CRH_SPELLID_SAVAGE_DEFENSE_BUFF	= 132402;
local CRH_SPELLID_SURVIVAL_INSTINCTS	= 61336;

local CRH_SHAPE_BEAR 					= 1;
local CRH_SHAPE_CAT						= 2;

local CRH_FAERIE_FIRE_SPELLID_LIST		=
{
	CRH_SPELLID_FAERIE_FIRE,
	CRH_SPELLID_FAERIE_SWARM
}

-- Frame IDs
local CRH_FRAME_BARKSKIN				= 1;
local CRH_FRAME_SURVINSTINCTS			= 2;
local CRH_FRAME_SURV_UNUSED3 			= 3;

-- change order of icons here
local g_CrhFrameOrderSurv = {CRH_FRAME_SURV_UNUSED3, CRH_FRAME_SURVINSTINCTS, CRH_FRAME_BARKSKIN}

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

-- Temporary hack for code refactoring
local g_FramesAll = 
{
	g_FramesCat[1],
	g_FramesCat[2],
	g_FramesCat[3],
	g_FramesCat[4],
	g_FramesCat[5],

	g_FramesBear[1],
	g_FramesBear[2],
	g_FramesBear[3],
	g_FramesBear[4],
	g_FramesBear[5],
}

local g_CrhFramesEvents = {};
local g_CrhFramesSurv = {};
local survivalTextures = {};

local function InitFrames()
	-- Survival: Barkskin
	g_CrhFramesSurv[CRH_FRAME_BARKSKIN] = CreateFrame("Frame", nil, UIParent);
	survivalTextures[CRH_FRAME_BARKSKIN] = g_Module.GetMyImage("Barkskin.tga");

	-- Survival: Survival instincts
	g_CrhFramesSurv[CRH_FRAME_SURVINSTINCTS] = CreateFrame("Frame", nil, UIParent);
	survivalTextures[CRH_FRAME_SURVINSTINCTS] = g_Module.GetMyImage("SurvivalInstincts.tga");

	-- Survival: Unused3
	g_CrhFramesSurv[CRH_FRAME_SURV_UNUSED3] = CreateFrame("Frame", nil, UIParent);
	survivalTextures[CRH_FRAME_SURV_UNUSED3] = nil;
	
	-- Events
	g_CrhFramesEvents[1] = CreateFrame("Frame", nil, UIParent);
	g_CrhFramesEvents[2] = CreateFrame("Frame", nil, UIParent);
	g_CrhFramesEvents[3] = CreateFrame("Frame", nil, UIParent);
	g_CrhFramesEvents[4] = CreateFrame("Frame", nil, UIParent);
end

InitFrames();

eventCdTimers = {
--	nil, -- Berserk
--	nil, -- Feral Charge
--	nil, -- Enrage
--	nil, -- Savage defense
}

survivalCdTimers = {
--	nil, -- Barkskin
--	nil, -- Survival Instincts
--	nil, -- Might of ursoc
}

-- state variables
local inCatForm = false;
local inBearForm = false;
local enemyTarget = false;
local showCat = false;
local showBear = false;
local clearCast = false;
local unlocked = false;

-- eventframe variables
local eventList = {}
local eventTimers = {}
local eventEffects = {}

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
crhEventAngle = 90;
crhSurvivalAngle = 270;
crhMainAngle = 0;
crhCounterStartTime = 30;

crhShowCatFaerieFire = true;
crhShowCatBerserk = true;
crhShowFeralCharge = true;
crhShowBearBerserk = true;
crhShowPredatorsSwiftness = true;
crhShowSavageDefense = true;
crhShowBearFaerieFire = true;

local function CatRotationHelperFormatTime(time)
	if (time >= 60) then
		return ceil(time / 60).."m";
	elseif(time >= 1) then
		return floor(time);
	else
		return "."..floor(time*10);
	end
end

-- start fade effects for event & survival frame icons
local function showEventIcon(frame)
	if(not frame:IsVisible() or frame.fading) then
		frame:SetScript("OnUpdate",CatRotationHelperEventFadeFunc)
		frame:Show()
		frame.fading = false
		frame.startTime = GetTime()
	end
end

local function showSurvivalIcon(frame, a_ShowEffects)
	if(not frame:IsVisible() or frame.fading) then
		frame:SetScript("OnUpdate",CatRotationHelperEventFadeFunc)
		frame:Show()
		frame.fading = false
		frame.startTime = GetTime()
		
		if(a_ShowEffects) then
			frame.overlay.animIn:Play()
		end	
	end
end

local function crhIsAddonUseful()
	local specID = GetSpecialization();
	if ((specID ~= 2) and (specID ~= 3)) then
		return false;
	end
	
	return true;
end

local function hideEventIcon(frame)
	if(frame:IsVisible() and not frame.fading) then
		frame:SetScript("OnUpdate",CatRotationHelperEventFadeFunc)
		frame.fading = true
		frame.startTime = GetTime()
	end
end

local function UpdateFramesByType(a_FrameList, a_Type)
	for i = 1, #a_FrameList do
		local frame = a_FrameList[i];
	
		if ((not a_Type) or (frame.m_CrhLogic.Type == a_Type)) then
			g_Module.FrameUpdateFromLogic(frame);
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
			CatRotationHelperShowCat();
			UpdateFramesByType(g_FramesCat);
			CatRotationHelperSetCatCP(GetComboPoints("player"));
			CatRotationHelperUpdateSurvival(false)
			CatRotationHelperUpdateEvents(false)
		end

	elseif(GetShapeshiftForm() == CRH_SHAPE_BEAR and crhShowBear) then
		if(inCatForm) then
			CatRotationHelperHideAll()
			inCatForm = false
		end

		inBearForm = true

		if(enemyTarget) then
			CatRotationHelperShowBear();
			UpdateFramesByType(g_FramesBear);
			crhUpdateLacerate();
			CatRotationHelperUpdateSurvival(false)
			CatRotationHelperUpdateEvents(false)
		end
	else
		CatRotationHelperHideAll();
		inCatForm = false
 		inBearForm = false
	end

end

function CatRotationHelperUnlock()
	CatRotationHelperHeader:Show();
	CatRotationHelperEvents:Show();
	CatRotationHelperSurvival:Show();
	CatRotationHelperLockFrame:Show();
	HideUIPanel(InterfaceOptionsFrame)
	unlocked = true;

	-- hide bear frames
	if(showBear) then
		showBear = false

		for i=1, #g_FramesBear do
			g_Module.FrameSetStatus(g_FramesBear[i], g_Consts.STATUS_READY);
			g_FramesBear[i]:Hide()
		end
		CatRotationHelperLacerateCounter:Hide()
		CatRotationHelperSetBearCP(0)

	-- stop cat counters and cps
	elseif(showCat) then
		showCat = false

		for i=1, #g_FramesCat do
			g_Module.FrameSetStatus(g_FramesCat[i], g_Consts.STATUS_READY);
		end

		CatRotationHelperSetCatCP(0)
	end

	-- interrupt previous fade
	CatRotationHelperFadeFrame:Hide();

	-- show static cat frames
	for i=1, #g_FramesCat do
		local frame = g_FramesCat[i];

		frame:Show();
		frame:SetAlpha(1);
		g_Module.FrameDrawActive(frame.icon);
	end

	-- show static event frames
	eventList[1] = g_Module.GetMyImage("Berserk.tga")
	eventList[2] = g_Module.GetMyImage("FaerieFire.tga")
	eventList[3] = g_Module.GetMyImage("FeralCharge.tga")
	eventList[4] = g_Module.GetMyImage("PredatoryStrikes.tga")

	for i=1, #g_CrhFramesEvents do
		g_CrhFramesEvents[i]:Show()
		g_CrhFramesEvents[i]:SetAlpha(1)
		g_CrhFramesEvents[i].fading = false
		g_CrhFramesEvents[i].startTime = nil
		g_CrhFramesEvents[i].countframe:Hide();
		g_CrhFramesEvents[i].countframe.endTime = nil;
		g_CrhFramesEvents[i]:SetScript("OnUpdate",nil)
		g_CrhFramesEvents[i].icon:SetTexture(eventList[i])
	end

	-- show static survival frames
	for i=1, #g_CrhFramesSurv do
		g_CrhFramesSurv[i]:Show()
		g_CrhFramesSurv[i]:SetAlpha(1)
		g_CrhFramesSurv[i].fading = false
		g_CrhFramesSurv[i].startTime = nil
		g_CrhFramesSurv[i].countframe:Hide();
		g_CrhFramesSurv[i].countframe.endTime = nil;
		g_CrhFramesSurv[i]:SetScript("OnUpdate",nil)
	end

end

function CatRotationHelperLock()
	if(not unlocked) then
		return
	end

	CatRotationHelperHeader:Hide();
	CatRotationHelperEvents:Hide();
	CatRotationHelperSurvival:Hide();
	CatRotationHelperLockFrame:Hide();

	unlocked = false;
	clearCast = false;

	for i=1, #g_FramesAll do
		local frame = g_FramesAll[i]

		frame:Hide()
		g_Module.FrameDrawFaded(frame.icon);
		g_Module.FrameSetTexture(frame.icon, frame.m_CrhLogic.Texture);
		frame.countframe.durtext:SetTextColor(1.00, 1.00, 0.00);
		frame.countframe.dur2text:SetTextColor(1.00, 1.00, 0.00);
		frame.countframe:Hide();
		frame.cpicon:SetTexture(g_Module.GetMyImage("Cp.tga"))
	end

	for i=1, #g_CrhFramesEvents do
		g_CrhFramesEvents[i]:Hide()
	end

	for i=1, #g_CrhFramesSurv do
		g_CrhFramesSurv[i]:Hide()
	end

	CatRotationHelperUpdateEverything()
end

-- shows num combo point circles using frames in a_FrameList
local function CatRotationHelperSetCPEffects(a_FrameList, num)
	for i=1, #a_FrameList do
		local frame = a_FrameList[i];

		if(i <= num) then
			if(not frame.hascp) then
				if(clearCast) then
					frame.countframe.durtext:SetTextColor(0.40, 0.70, 0.95);
					frame.countframe.dur2text:SetTextColor(0.40, 0.70, 0.95);
				else
					frame.countframe.durtext:SetTextColor(0.90, 0.70, 0.00);
					frame.countframe.dur2text:SetTextColor(0.90, 0.70, 0.00);
				end
				frame.hascp = true;
				frame.cpframe:Show()
				frame.cpframe:SetScript("OnUpdate", CatRotationHelperCpEffect)
				frame.cpframe.startTime = GetTime()
				frame.cpframe.reverse = false
			end
		else
			if(frame.hascp) then
				if(clearCast) then
					frame.countframe.durtext:SetTextColor(0.50, 0.85, 1.00);
					frame.countframe.dur2text:SetTextColor(0.50, 0.85, 1.00);
				else
					frame.countframe.durtext:SetTextColor(1.00, 1.00, 0.00);
					frame.countframe.dur2text:SetTextColor(1.00, 1.00, 0.00);
				end
				frame.hascp = false;
				frame.cpframe:SetScript("OnUpdate", CatRotationHelperCpEffect)
				frame.cpframe.startTime = GetTime()
				frame.cpframe.reverse = true
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


-- show all frames in a_FrameList
local function CatRotationHelperShowByFrame(a_FrameList)
	--if interrupting previous fade, hide frames
	for i=1, #g_FramesAll do
		g_FramesAll[i]:Hide();
	end

	for i=1, #a_FrameList do
		a_FrameList[i]:Show();
	end

	-- fade effect
	CatRotationHelperFadeFrame:Show();
	CatRotationHelperFadeFrame.fading = false;
	CatRotationHelperFadeFrame.startTime = GetTime();
end

function CatRotationHelperShowCat()
	if(showCat) then return; end
	showCat = true;

	CatRotationHelperShowByFrame(g_FramesCat);
end

function CatRotationHelperShowBear()
	if(showBear) then return; end
	showBear = true;

	CatRotationHelperShowByFrame(g_FramesBear);
end

function CatRotationFrameSetMainScale()
	for i=1, #g_FramesAll do
		g_FramesAll[i]:SetScale(crhScale);
		g_FramesAll[i].parentFrame:SetScale(crhScale);
	end

	CatRotationHelperHeader:SetScale(crhScale);
end

function CatRotationFrameSetEventScale()
	for i=1, #g_CrhFramesEvents do
		g_CrhFramesEvents[i]:SetScale(crhEventScale);
		g_CrhFramesEvents[i].parentFrame:SetScale(crhEventScale);
	end

	CatRotationHelperEvents:SetScale(crhEventScale);
end

function CatRotationFrameSetSurvivalScale()
	for i=1, #g_CrhFramesSurv do
		g_CrhFramesSurv[i]:SetScale(crhSurvivalScale);
		g_CrhFramesSurv[i].parentFrame:SetScale(crhSurvivalScale);
	end

	CatRotationHelperSurvival:SetScale(crhSurvivalScale);
end

-- rotate main frame
function CatRotationHelperMainOnClick()

	if(crhMainAngle == 270) then
		crhMainAngle = 0
	else
		crhMainAngle = crhMainAngle + 90
	end

	CatRotationFrameSetMainStyle()
end

function CatRotationFrameSetMainStyle()
	for i=1, #g_FramesAll do
		g_FramesAll[i].parentFrame:ClearAllPoints()
	end

	local headerFrame = CatRotationHelperHeader;

	if(crhMainAngle == 0) then
		headerFrame:SetHeight(36)
		headerFrame:SetWidth(176)

		g_FramesCat[1].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);
		g_FramesBear[1].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);

		g_FramesCat[2].parentFrame:SetPoint("TOPLEFT", g_FramesCat[1].parentFrame, "TOPRIGHT", 5, 0);
		g_FramesBear[2].parentFrame:SetPoint("TOPLEFT", g_FramesBear[1].parentFrame, "TOPRIGHT", 5, 0);

		g_FramesCat[3].parentFrame:SetPoint("TOPLEFT", g_FramesCat[2].parentFrame, "TOPRIGHT", 5, 0);
		g_FramesBear[3].parentFrame:SetPoint("TOPLEFT", g_FramesBear[2].parentFrame, "TOPRIGHT", 5, 0);

		g_FramesCat[4].parentFrame:SetPoint("TOPLEFT", g_FramesCat[3].parentFrame, "TOPRIGHT", 5, 0);
		g_FramesBear[4].parentFrame:SetPoint("TOPLEFT", g_FramesBear[3].parentFrame, "TOPRIGHT", 5, 0);

		g_FramesCat[5].parentFrame:SetPoint("TOPLEFT", g_FramesCat[4].parentFrame, "TOPRIGHT", 5, 0);
		g_FramesBear[5].parentFrame:SetPoint("TOPLEFT", g_FramesBear[4].parentFrame, "TOPRIGHT", 5, 0);

	elseif(crhMainAngle == 90) then
		headerFrame:SetHeight(176)
		headerFrame:SetWidth(36)

		g_FramesCat[1].parentFrame:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 3, 3);
		g_FramesBear[1].parentFrame:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 3, 3);

		g_FramesCat[2].parentFrame:SetPoint("BOTTOMLEFT", g_FramesCat[1].parentFrame, "TOPLEFT", 0, 5);
		g_FramesBear[2].parentFrame:SetPoint("BOTTOMLEFT", g_FramesBear[1].parentFrame, "TOPLEFT", 0, 5);

		g_FramesCat[3].parentFrame:SetPoint("BOTTOMLEFT", g_FramesCat[2].parentFrame, "TOPLEFT", 0, 5);
		g_FramesBear[3].parentFrame:SetPoint("BOTTOMLEFT", g_FramesBear[2].parentFrame, "TOPLEFT", 0, 5);

		g_FramesCat[4].parentFrame:SetPoint("BOTTOMLEFT", g_FramesCat[3].parentFrame, "TOPLEFT", 0, 5);
		g_FramesBear[4].parentFrame:SetPoint("BOTTOMLEFT", g_FramesBear[3].parentFrame, "TOPLEFT", 0, 5);

		g_FramesCat[5].parentFrame:SetPoint("BOTTOMLEFT", g_FramesCat[4].parentFrame, "TOPLEFT", 0, 5);
		g_FramesBear[5].parentFrame:SetPoint("BOTTOMLEFT", g_FramesBear[4].parentFrame, "TOPLEFT", 0, 5);

	elseif(crhMainAngle == 180) then
		headerFrame:SetHeight(36)
		headerFrame:SetWidth(176)

		g_FramesCat[1].parentFrame:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -3, -3);
		g_FramesBear[1].parentFrame:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -3, -3);

		g_FramesCat[2].parentFrame:SetPoint("TOPRIGHT", g_FramesCat[1].parentFrame, "TOPLEFT", -5, 0);
		g_FramesBear[2].parentFrame:SetPoint("TOPRIGHT", g_FramesBear[1].parentFrame, "TOPLEFT", -5, 0);

		g_FramesCat[3].parentFrame:SetPoint("TOPRIGHT", g_FramesCat[2].parentFrame, "TOPLEFT", -5, 0);
		g_FramesBear[3].parentFrame:SetPoint("TOPRIGHT", g_FramesBear[2].parentFrame, "TOPLEFT", -5, 0);

		g_FramesCat[4].parentFrame:SetPoint("TOPRIGHT", g_FramesCat[3].parentFrame, "TOPLEFT", -5, 0);
		g_FramesBear[4].parentFrame:SetPoint("TOPRIGHT", g_FramesBear[3].parentFrame, "TOPLEFT", -5, 0);

		g_FramesCat[5].parentFrame:SetPoint("TOPRIGHT", g_FramesCat[4].parentFrame, "TOPLEFT", -5, 0);
		g_FramesBear[5].parentFrame:SetPoint("TOPRIGHT", g_FramesBear[4].parentFrame, "TOPLEFT", -5, 0);

	else
		headerFrame:SetHeight(176)
		headerFrame:SetWidth(36)

		g_FramesCat[1].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);
		g_FramesBear[1].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);

		g_FramesCat[2].parentFrame:SetPoint("TOPLEFT", g_FramesCat[1].parentFrame, "BOTTOMLEFT", 0, -5);
		g_FramesBear[2].parentFrame:SetPoint("TOPLEFT", g_FramesBear[1].parentFrame, "BOTTOMLEFT", 0, -5);

		g_FramesCat[3].parentFrame:SetPoint("TOPLEFT", g_FramesCat[2].parentFrame, "BOTTOMLEFT", 0, -5);
		g_FramesBear[3].parentFrame:SetPoint("TOPLEFT", g_FramesBear[2].parentFrame, "BOTTOMLEFT", 0, -5);

		g_FramesCat[4].parentFrame:SetPoint("TOPLEFT", g_FramesCat[3].parentFrame, "BOTTOMLEFT", 0, -5);
		g_FramesBear[4].parentFrame:SetPoint("TOPLEFT", g_FramesBear[3].parentFrame, "BOTTOMLEFT", 0, -5);

		g_FramesCat[5].parentFrame:SetPoint("TOPLEFT", g_FramesCat[4].parentFrame, "BOTTOMLEFT", 0, -5);
		g_FramesBear[5].parentFrame:SetPoint("TOPLEFT", g_FramesBear[4].parentFrame, "BOTTOMLEFT", 0, -5);
	end

end

-- rotate event frame
function CatRotationHelperEventsOnClick()

	if(crhEventAngle == 270) then
		crhEventAngle = 0
	else
		crhEventAngle = crhEventAngle + 90
	end

	CatRotationFrameSetEventStyle()
end

function CatRotationFrameSetEventStyle()
	g_CrhFramesEvents[1].parentFrame:ClearAllPoints()
	g_CrhFramesEvents[2].parentFrame:ClearAllPoints()
	g_CrhFramesEvents[3].parentFrame:ClearAllPoints()
	g_CrhFramesEvents[4].parentFrame:ClearAllPoints()
	
	local eventFrame = CatRotationHelperEvents

	if(crhEventAngle == 0) then
		eventFrame:SetHeight(36)
		eventFrame:SetWidth(140)

		g_CrhFramesEvents[1].parentFrame:SetPoint("TOPLEFT", eventFrame, "TOPLEFT", 3, -3);
		g_CrhFramesEvents[2].parentFrame:SetPoint("TOPLEFT", g_CrhFramesEvents[1].parentFrame, "TOPRIGHT", 4, 0);
		g_CrhFramesEvents[3].parentFrame:SetPoint("TOPLEFT", g_CrhFramesEvents[2].parentFrame, "TOPRIGHT", 4, 0);
		g_CrhFramesEvents[4].parentFrame:SetPoint("TOPLEFT", g_CrhFramesEvents[3].parentFrame, "TOPRIGHT", 4, 0);
		
	elseif(crhEventAngle == 90) then
		eventFrame:SetHeight(140)
		eventFrame:SetWidth(36)

		g_CrhFramesEvents[1].parentFrame:SetPoint("BOTTOMLEFT", eventFrame, "BOTTOMLEFT", 3, 3);
		g_CrhFramesEvents[2].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesEvents[1].parentFrame, "TOPLEFT", 0, 4);
		g_CrhFramesEvents[3].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesEvents[2].parentFrame, "TOPLEFT", 0, 4);
		g_CrhFramesEvents[4].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesEvents[3].parentFrame, "TOPLEFT", 0, 4);
		
	elseif(crhEventAngle == 180) then
		eventFrame:SetHeight(36)
		eventFrame:SetWidth(140)

		g_CrhFramesEvents[1].parentFrame:SetPoint("TOPRIGHT", eventFrame, "TOPRIGHT", -3, -3);
		g_CrhFramesEvents[2].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesEvents[1].parentFrame, "TOPLEFT", -4, 0);
		g_CrhFramesEvents[3].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesEvents[2].parentFrame, "TOPLEFT", -4, 0);
		g_CrhFramesEvents[4].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesEvents[3].parentFrame, "TOPLEFT", -4, 0);

	else
		eventFrame:SetHeight(140)
		eventFrame:SetWidth(36)

		g_CrhFramesEvents[1].parentFrame:SetPoint("TOPLEFT", eventFrame, "TOPLEFT", 3, -3);
		g_CrhFramesEvents[2].parentFrame:SetPoint("TOPLEFT", g_CrhFramesEvents[1].parentFrame, "BOTTOMLEFT", 0, -4);
		g_CrhFramesEvents[3].parentFrame:SetPoint("TOPLEFT", g_CrhFramesEvents[2].parentFrame, "BOTTOMLEFT", 0, -4);
		g_CrhFramesEvents[4].parentFrame:SetPoint("TOPLEFT", g_CrhFramesEvents[3].parentFrame, "BOTTOMLEFT", 0, -4);
	end

end

-- rotate survival frame
function CatRotationHelperSurvivalOnClick()

	if(crhSurvivalAngle == 270) then
		crhSurvivalAngle = 0
	else
		crhSurvivalAngle = crhSurvivalAngle + 90
	end

	CatRotationFrameSetSurvivalStyle()
end

function CatRotationFrameSetSurvivalStyle()
	g_CrhFramesSurv[1].parentFrame:ClearAllPoints()
	g_CrhFramesSurv[2].parentFrame:ClearAllPoints()
	g_CrhFramesSurv[3].parentFrame:ClearAllPoints()

	local survFrame = CatRotationHelperSurvival

	if(crhSurvivalAngle == 0) then
		survFrame:SetHeight(36)
		survFrame:SetWidth(105)

		g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame:SetPoint("TOPLEFT", survFrame, "TOPLEFT", 3, -3);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame, "TOPRIGHT", 4, 0);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[3]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame, "TOPRIGHT", 4, 0);

	elseif(crhSurvivalAngle == 90) then
		survFrame:SetHeight(105)
		survFrame:SetWidth(36)

		g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame:SetPoint("BOTTOMLEFT", survFrame, "BOTTOMLEFT", 3, 3);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame, "TOPLEFT", 0, 4);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[3]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame, "TOPLEFT", 0, 4);

	elseif(crhSurvivalAngle == 180) then
		survFrame:SetHeight(36)
		survFrame:SetWidth(105)

		g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame:SetPoint("TOPRIGHT", survFrame, "TOPRIGHT", -3, -3);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame, "TOPLEFT", -4, 0);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[3]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame, "TOPLEFT", -4, 0);

	else
		survFrame:SetHeight(105)
		survFrame:SetWidth(36)

		g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame:SetPoint("TOPLEFT", survFrame, "TOPLEFT", 3, -3);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesSurv[g_CrhFrameOrderSurv[1]].parentFrame, "BOTTOMLEFT", 0, -4);
		g_CrhFramesSurv[g_CrhFrameOrderSurv[3]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesSurv[g_CrhFrameOrderSurv[2]].parentFrame, "BOTTOMLEFT", 0, -4);
	end

end

function CatRotationHelperHideAll()
	local frameList

	-- decide what frames to hide
	if(showBear) then
		showBear = false

		frameList = g_FramesBear
		CatRotationHelperLacerateCounter:Hide()
		CatRotationHelperSetBearCP(0)
	elseif(showCat) then
		showCat = false

		frameList = g_FramesCat
		CatRotationHelperSetCatCP(0)
	else
		return
	end

	-- stop running timers
	for i=1, #frameList do
		g_Module.FrameSetStatus(frameList[i], g_Consts.STATUS_READY);
	end

	-- general fade animation
	CatRotationHelperFadeFrame:Show();
	CatRotationHelperFadeFrame.fading = true;
	CatRotationHelperFadeFrame.startTime = GetTime();

	-- hide events
	for i=1, #g_CrhFramesEvents do
		hideEventIcon(g_CrhFramesEvents[i])
	end

	for i=1, #g_CrhFramesSurv do
		hideEventIcon(g_CrhFramesSurv[i])
	end
end

------------------------------
-- Bear - Main Frame Checks --
------------------------------

function crhUpdateLacerate()
	local name, stacks, expTime = g_Module.GetTargetDebuffInfo(CRH_SPELLID_LACERATE, true);
	if (name == nil) then
		CatRotationHelperLacerateCounter:Hide();
		CatRotationHelperSetBearCP(0);
		return;
	end
	
	-- stop possible cp animation when lacerate is refreshed
	local i = 1;
	for i=1, #g_FramesBear do
		g_FramesBear[i].cpframe:SetAlpha(1)
		g_FramesBear[i].cpframe:SetScale(1)
	end

	-- setup lacerate warning
	CatRotationHelperLacerateCounter:Show()
	CatRotationHelperLacerateCounter.expTime = expTime

	-- set cp effects
	CatRotationHelperSetBearCP(stacks);
end

-- Check for Clearcast procs - cat (has no effect for bear)
function CatRotationHelperCheckClearcast()
	name = UnitBuff("player", g_Module.GetSpellName(CRH_SPELLID_CLEARCAST));
	if(name and crhEnableClearcast) then
		if(not clearCast) then
			for i=1, #g_FramesCat do
				local frame = g_FramesCat[i];

				frame.cpicon:SetTexture(g_Module.GetMyImage("Cp-Blue.tga"))
				g_Module.FrameSetTexture(frame.icon, frame.m_CrhLogic.TextureSpecial);
				g_Module.FrameSetTexture(frame.overlay.icon, frame.m_CrhLogic.TextureSpecial);

				if(frame.hascp) then
					frame.countframe.durtext:SetTextColor(0.40, 0.70, 0.95);
					frame.countframe.dur2text:SetTextColor(0.40, 0.70, 0.95);
				else
					frame.countframe.durtext:SetTextColor(0.50, 0.85, 1.00);
					frame.countframe.dur2text:SetTextColor(0.50, 0.85, 1.00);
				end
			end

			clearCast = true;
		end

	else
		if(clearCast) then
			for i=1,#g_FramesCat do
				local frame = g_FramesCat[i];

				frame.cpicon:SetTexture(g_Module.GetMyImage("Cp.tga"))
				g_Module.FrameSetTexture(frame.icon, frame.m_CrhLogic.Texture);
				g_Module.FrameSetTexture(frame.overlay.icon, frame.m_CrhLogic.Texture);

				if(frame.hascp) then
					frame.countframe.durtext:SetTextColor(0.90, 0.70, 0.00);
					frame.countframe.dur2text:SetTextColor(0.90, 0.70, 0.00);
				else
					frame.countframe.durtext:SetTextColor(1.00, 1.00, 0.00);
					frame.countframe.dur2text:SetTextColor(1.00, 1.00, 0.00);
				end

			end

			clearCast = false;
		end
	end
end

local function crhResetNotificationFrame(a_FrameID)
	eventList[a_FrameID] = nil
	eventTimers[a_FrameID] = nil
	eventEffects[a_FrameID] = nil
end

local function crhSetNotificationEffects(a_FrameID, a_ShowEffects)
	if (eventList[a_FrameID] == nil) then
		eventEffects[a_FrameID] = a_ShowEffects
	else
		eventEffects[a_FrameID] = nil
	end
end

local function crhUpdateNotificationSpell(a_IsEnabled, a_FrameID, a_CooldownID, a_SpellID, a_BuffId, a_Image, a_ShowEffects)
	if ((not a_IsEnabled) or (not IsPlayerSpell(a_SpellID))) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end
	
	-- If buff is active show its timer, whether or not spell is on cd
	if (a_BuffId) then
		local status, expiration = g_Module.CalcFrameFromBuff(a_BuffId);
		if (g_Consts.STATUS_COUNTING == status) then
			eventList[a_FrameID] = g_Module.GetMyImage(a_Image)
			eventTimers[a_FrameID] = expiration
			eventEffects[a_FrameID] = nil
			return;
		end
	end

	local spellStart, spellDuration = GetSpellCooldown(a_SpellID);
	
	-- Unknown legacy safety code
	if (not spellStart) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end

	-- If spell is ready show notification
	if (0 == spellStart) then
		crhSetNotificationEffects(a_FrameID, a_ShowEffects);
		eventList[a_FrameID] = g_Module.GetMyImage(a_Image)
		eventTimers[a_FrameID] = nil
		return;
	end
	
	-- Prevent blinking on GCD
	if (spellDuration < g_Consts.GCD_LENGTH) then
		return;
	end
	
	eventList[a_FrameID] = nil
	eventTimers[a_FrameID] = nil
	eventEffects[a_FrameID] = nil
	
	if (a_CooldownID) then
		eventCdTimers[a_CooldownID] = spellDuration + spellStart
		CatRotationHelperCdCounter:Show()
	end
end

local function crhUpdateNotificationProc(a_IsEnabled, a_FrameID, a_SpellID, a_Image, a_ShowEffects)
	if (not a_IsEnabled) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end
	
	local status, expiration = g_Module.CalcFrameFromBuff(a_SpellID);
	if (g_Consts.STATUS_COUNTING ~= status) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end
	
	-- On proc, show notification
	crhSetNotificationEffects(a_FrameID, a_ShowEffects);
	eventList[a_FrameID] = g_Module.GetMyImage(a_Image)
	eventTimers[a_FrameID] = expiration
end

local function crhUpdateNotificationDebuff(a_IsEnabled, a_FrameID, a_SpellID_List, a_Image, a_ShowEffects)
	if (not a_IsEnabled) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end
	
	for i = 1, #a_SpellID_List do
		local status, expiration = g_Module.CalcFrameFromDebuff(a_SpellID_List[i]);
		
		if (g_Consts.STATUS_COUNTING == status) then
			-- Has debuff, no notification needed
			crhResetNotificationFrame(a_FrameID);
			return;
		end
	end
	
	-- No debuff, show notification
	crhSetNotificationEffects(a_FrameID, a_ShowEffects);
	eventList[a_FrameID] = g_Module.GetMyImage(a_Image)
	eventTimers[a_FrameID] = nil
end


-- Event Frame - Bear & Cat
function CatRotationHelperUpdateEvents(a_ShowEffects)
	-- first, update eventList table
	if (inCatForm) then
		crhUpdateNotificationSpell(crhShowCatBerserk, 1, 1, CRH_SPELLID_BERSERK, CRH_SPELLID_BERSERK, "Berserk.tga", a_ShowEffects);
		crhUpdateNotificationDebuff(crhShowCatFaerieFire, 2, CRH_FAERIE_FIRE_SPELLID_LIST, "FaerieFire.tga", a_ShowEffects);
		crhUpdateNotificationSpell(crhShowFeralCharge, 3, 2, CRH_SPELLID_FERAL_CHARGE, nil, "FeralCharge.tga", a_ShowEffects);
		crhUpdateNotificationProc(crhShowPredatorsSwiftness, 4, CRH_SPELLID_PREDATORS_SWIFTNESS, "PredatoryStrikes.tga", a_ShowEffects);
	elseif (inBearForm) then
		crhUpdateNotificationSpell(crhShowBearBerserk, 1, 1, CRH_SPELLID_BERSERK, CRH_SPELLID_BERSERK, "Berserk.tga", a_ShowEffects);
		crhUpdateNotificationDebuff(crhShowBearFaerieFire, 2, CRH_FAERIE_FIRE_SPELLID_LIST, "FaerieFire.tga", a_ShowEffects);
		crhUpdateNotificationSpell(crhShowSavageDefense, 4, 4, CRH_SPELLID_SAVAGE_DEFENSE, CRH_SPELLID_SAVAGE_DEFENSE_BUFF, "SavageDefense.tga", a_ShowEffects);
	end

	-- second, fill event frames with information
	j = 1

	for i=1, #g_CrhFramesEvents do
		if(eventList[i] ~= nil) then
			g_CrhFramesEvents[j].icon:SetTexture(eventList[i])
			g_CrhFramesEvents[j].overlay.icon:SetTexture(eventList[i])
			showEventIcon(g_CrhFramesEvents[j])
			
			if(eventEffects[i]) then
				g_CrhFramesEvents[j].overlay.animIn:Play()
			end
			
			if(eventTimers[i] ~= nil) then
				g_CrhFramesEvents[j].countframe.endTime = eventTimers[i]
				g_CrhFramesEvents[j].countframe:Show()
			else
				g_CrhFramesEvents[j].countframe:Hide()
			end

			j = j + 1
		end
	end

	-- hide unused event frames
	while j <= #g_CrhFramesEvents do
		hideEventIcon(g_CrhFramesEvents[j])
		j = j + 1
	end
end

local function crhUpdateSurvivalFrame(a_FrameID, a_SpellID, a_ShowEffects)
	local spellStart, spellDuration = GetSpellCooldown(a_SpellID);
	
	-- Unknown legacy safety code
	if (spellStart == nil) then
		return;
	end
	
	-- Spell ready
	if (spellStart == 0) then
		showSurvivalIcon(g_CrhFramesSurv[a_FrameID], a_ShowEffects)
		return;
	end

	-- Prevent blinking on GCD
	if (spellDuration < g_Consts.GCD_LENGTH) then
		return;
	end

	survivalCdTimers[a_FrameID] = spellDuration + spellStart
	CatRotationHelperCdCounter:Show()

	local status, expiration = g_Module.CalcFrameFromBuff(a_SpellID);
	if (g_Consts.STATUS_COUNTING ~= status) then
		hideEventIcon(g_CrhFramesSurv[a_FrameID])
		return;
	end
	
	showEventIcon(g_CrhFramesSurv[a_FrameID])
	g_CrhFramesSurv[a_FrameID].countframe.endTime = expiration
	g_CrhFramesSurv[a_FrameID].countframe:Show()
end

-- Survival Frame - Bear & Cat
function CatRotationHelperUpdateSurvival(a_ShowEffects)
	if ((crhShowCatSurvival and inCatForm) or (crhShowBearSurvival and inBearForm)) then
		crhUpdateSurvivalFrame(CRH_FRAME_BARKSKIN, CRH_SPELLID_BARKSKIN, a_ShowEffects);
		crhUpdateSurvivalFrame(CRH_FRAME_SURVINSTINCTS, CRH_SPELLID_SURVIVAL_INSTINCTS, a_ShowEffects);
	end
end

local function FrameSetup(a_Frame, a_FrameName, a_OnUpdate)
	a_Frame.fading = false;
	a_Frame.startTime = nil;
	a_Frame.hascp = false;
	a_Frame.counting = false;

	a_Frame:SetSize(30, 30);
	a_Frame:Hide();

	a_Frame.parentFrame = CreateFrame("Frame", a_FrameName .. "P", UIParent);
	a_Frame.parentFrame:SetFrameStrata("LOW");
	a_Frame.parentFrame:SetSize(30, 30);
	a_Frame:SetPoint("CENTER", a_Frame.parentFrame, "CENTER", 0, 0);

	a_Frame.cpframe = CreateFrame("Frame", a_FrameName .. "CP", a_Frame);
	a_Frame.cpframe:SetFrameStrata("BACKGROUND");
	a_Frame.cpframe:SetPoint("CENTER");
	a_Frame.cpframe:SetSize(30 * 1.13, 30 * 1.13);
	a_Frame.cpframe.startTime = nil;
	a_Frame.cpframe:Hide();

	a_Frame.cpicon = a_Frame.cpframe:CreateTexture(nil, "BACKGROUND");
	a_Frame.cpicon:SetTexture(g_Module.GetMyImage("Cp.tga"));
	a_Frame.cpicon:SetAllPoints(a_Frame.cpframe);

	a_Frame.icon = a_Frame:CreateTexture(nil, "ARTWORK");
	a_Frame.icon:SetAllPoints(a_Frame);

	-- buff fade/gain effects
	local overlayOffs = 30 * 0.20;
	a_Frame.overlay = CreateFrame("Frame", a_FrameName .. "O", a_Frame, "CatRotationHelperEventAlert");
	a_Frame.overlay.icon:SetBlendMode("ADD");
	a_Frame.overlay:SetPoint("TOPLEFT", a_Frame, "TOPLEFT", -overlayOffs, overlayOffs);
	a_Frame.overlay:SetPoint("BOTTOMRIGHT", a_Frame, "BOTTOMRIGHT", overlayOffs, -overlayOffs);

	a_Frame.countframe = CreateFrame("Frame", a_FrameName .. "C", a_Frame);
	a_Frame.countframe:SetScript("OnUpdate", a_OnUpdate);
	a_Frame.countframe:Hide();
	a_Frame.countframe.endTime = nil;

	a_Frame.countframe.durtext = a_Frame.countframe:CreateFontString(nil, "OVERLAY", "CatRotationHelperDurText");
	a_Frame.countframe.durtext:SetPoint("CENTER", a_Frame, "CENTER", 0, 0);
	a_Frame.countframe.dur2text = a_Frame.countframe:CreateFontString(nil, "OVERLAY", "CatRotationHelperDur2Text");
	a_Frame.countframe.dur2text:SetPoint("CENTER", a_Frame, "CENTER", 0, -5);
	a_Frame.countframe.dur2text:SetText("*");
	a_Frame.countframe.dur2text:Hide();
end

-- OnLoad: Create Frames
function CatRotationHelperOnLoad(self)
	-- load addon on druids only
	local class = select(2, UnitClass("player"))
	if(class ~= "DRUID") then
		return;
	end

	self:SetScript("OnEvent", CatRotationHelperOnEvent)
	
	self:SetBackdropColor(0, 0, 0);
	self:RegisterForClicks("RightButtonUp")
	self:RegisterForDrag("LeftButton")
	self:SetClampedToScreen(true)


	local eventFrame = CatRotationHelperEvents
	eventFrame:SetBackdropColor(0, 0, 0);
	eventFrame:RegisterForClicks("RightButtonUp")
	eventFrame:RegisterForDrag("LeftButton")
	eventFrame:SetClampedToScreen(true)

	local survFrame = CatRotationHelperSurvival
	survFrame:SetBackdropColor(0, 0, 0);
	survFrame:RegisterForClicks("RightButtonUp")
	survFrame:RegisterForDrag("LeftButton")
	survFrame:SetClampedToScreen(true)

	-- setup cat
	for i=1, #g_FramesCat do
		local frame = g_FramesCat[i];
		FrameSetup(frame, "CatRotationHelper_Cat_" .. i, CatRotationFrameCounter);
		
		g_Module.FrameDrawFaded(frame.icon);
		g_Module.FrameSetTexture(frame.icon, frame.m_CrhLogic.Texture);
		g_Module.FrameSetTexture(frame.overlay.icon, frame.m_CrhLogic.Texture);
	end

	-- setup bear
	for i=1, #g_FramesBear do
		local frame = g_FramesBear[i];
		FrameSetup(frame, "CatRotationHelper_Bear_" .. i, CatRotationFrameCounter);
		
		g_Module.FrameDrawFaded(frame.icon);
		g_Module.FrameSetTexture(frame.icon, frame.m_CrhLogic.Texture);
		g_Module.FrameSetTexture(frame.overlay.icon, frame.m_CrhLogic.Texture);
	end

	-- setup events
	for i=1, #g_CrhFramesEvents do
		local frame = g_CrhFramesEvents[i];
		FrameSetup(frame, "CatRotationHelper_Event_" .. i, CatRotationFrameEventCounter);
		
		g_Module.FrameDrawActive(frame.icon);
	end

	-- setup survival frame
	for i=1, #g_CrhFramesSurv do
		local frame = g_CrhFramesSurv[i];
		FrameSetup(frame, "CatRotationHelper_Surv_" .. i, CatRotationFrameEventCounter);

		g_Module.FrameDrawActive(frame.icon);
		g_Module.FrameSetTexture(frame.overlay.icon, survivalTextures[i]);
		g_Module.FrameSetTexture(frame.icon, survivalTextures[i]);
	end

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_TALENT_UPDATE")

	-- power bar
	--self:RegisterEvent("UNIT_ATTACK_POWER")
	--self:RegisterEvent("UNIT_ATTACK_SPEED")
	--self:RegisterEvent("COMBAT_RATING_UPDATE")
end

-- Event Handling
function CatRotationHelperOnEvent (self, event, ...)
	local arg1 = ...
	if(unlocked) then
		return
	end

	if(event == "UNIT_AURA") then
		if(enemyTarget) then
			if(inCatForm) then
				if(arg1 == "player") then
					UpdateFramesByType(g_FramesCat, g_Consts.LOGIC_TYPE_BUFF);
					CatRotationHelperCheckClearcast();
					CatRotationHelperUpdateSurvival(true)
					CatRotationHelperUpdateEvents(true)
				elseif(arg1 == "target") then
					UpdateFramesByType(g_FramesCat, g_Consts.LOGIC_TYPE_DEBUFF);
					CatRotationHelperUpdateEvents(true)
				end
			elseif(inBearForm) then
				if(arg1 == "player") then
					UpdateFramesByType(g_FramesBear, g_Consts.LOGIC_TYPE_BUFF);
					CatRotationHelperUpdateSurvival(true)
					CatRotationHelperUpdateEvents(true)
				elseif(arg1 == "target") then
					UpdateFramesByType(g_FramesBear, g_Consts.LOGIC_TYPE_DEBUFF);
					CatRotationHelperUpdateEvents(true)
					crhUpdateLacerate();
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
				UpdateFramesByType(g_FramesBear, g_Consts.LOGIC_TYPE_SKILL);
				CatRotationHelperUpdateSurvival(true)
				CatRotationHelperUpdateEvents(true)
			elseif(inCatForm) then
				UpdateFramesByType(g_FramesCat, g_Consts.LOGIC_TYPE_SKILL);
				CatRotationHelperUpdateSurvival(true)
				CatRotationHelperUpdateEvents(true)
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

-----------------------
-- Counter Functions --
-----------------------

function CatRotationFrameCounter(self)
	local time = self.endTime - GetTime();

	if(time <= 0) then
		g_Module.FrameSetStatus(self:GetParent(), g_Consts.STATUS_READY);
	elseif(time <= crhCounterStartTime) then
		self.durtext:SetText(CatRotationHelperFormatTime(time));
		self.dur2text:Hide();
	end
end

function CatRotationFrameEventCounter(self)
	local time = self.endTime - GetTime();

	if(time <= 0) then
		self:Hide()
		self.durtext:SetText("")
	else
		self.durtext:SetText(CatRotationHelperFormatTime(time));
	end
end

-- combo point animation when lacerate is about to expire
function CatRotationHelperLacerateCounterFunc(self)
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
			g_FramesBear[i].cpframe:SetAlpha(1.0-t)
			g_FramesBear[i].cpframe:SetScale(1.0+0.3*t)
		end
	else
		for i=1, #g_FramesBear do
			g_FramesBear[i].cpframe:SetAlpha(t)
			g_FramesBear[i].cpframe:SetScale(1.3-0.3*t)
		end
	end
end

----------------------
-- Effect Functions --
----------------------

-- fade main frame in/out
function CatRotationHelperFadeFunc(self)
	local elapsed = GetTime() - self.startTime;

	if(elapsed > 0.4) then
		self:Hide();

		if(self.fading) then
			for i=1, #g_FramesAll do
				g_FramesAll[i]:Hide();
			end
		end
	end

	if(self.fading) then
		for i=1, #g_FramesAll do
			g_FramesAll[i]:SetAlpha(1-elapsed*2.5);
		end
	else
		for i=1, #g_FramesAll do
			g_FramesAll[i]:SetAlpha(elapsed*2.5);
		end
	end
end

-- fade single events in/out
function CatRotationHelperEventFadeFunc(self)
	local elapsed = GetTime() - self.startTime;

	if(elapsed > 0.4) then
		if(self.fading) then
			self:Hide()
		else
			self:SetScript("OnUpdate", nil);
		end
	end

	if(self.fading) then
		self:SetAlpha(1-elapsed*2.5);
	else
		self:SetAlpha(elapsed*2.5);
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

function CatRotationHelperCdCounterFunc(self)
	local now = GetTime()
	local found = false

	for i=1, 4 do
		if(eventCdTimers[i] ~= nil) then
			if(eventCdTimers[i] < now) then
				eventCdTimers[i] = nil
				if(enemyTarget) then
					CatRotationHelperUpdateEvents(true)
				end
			else
				found = true
			end
		end
	end

	for i=1, 3 do
		if(survivalCdTimers[i] ~= nil) then
			if(survivalCdTimers[i] < now) then
				survivalCdTimers[i] = nil
				if(enemyTarget) then
					CatRotationHelperUpdateSurvival(true)
				end
			else
				found = true
			end
		end
	end

	if(not found) then
		CatRotationHelperCdCounter:Hide()
	end
end
