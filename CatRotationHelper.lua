local CRH_FRAME_TIGERSFURY, CRH_FRAME_CAT_WEAKARMOR, CRH_FRAME_SAVAGEROAR, CRH_FRAME_RAKE, CRH_FRAME_RIP, CRH_FRAME_BEAR_WEAKARMOR, CRH_FRAME_THRASH, CRH_FRAME_BEAR_MANGLE, CRH_FRAME_LACERATE, CRH_FRAME_WEAKBLOWS = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
local BARKSKIN, SURVINSTINCTS, FRENZIEDREG = 1, 2, 3;

-- change order of icons here
local crhCatFrames = {CRH_FRAME_TIGERSFURY, CRH_FRAME_SAVAGEROAR, CRH_FRAME_CAT_WEAKARMOR, CRH_FRAME_RAKE, CRH_FRAME_RIP}
local crhBearFrames = {CRH_FRAME_BEAR_MANGLE, CRH_FRAME_WEAKBLOWS, CRH_FRAME_LACERATE, CRH_FRAME_THRASH, CRH_FRAME_BEAR_WEAKARMOR}
local crhSurvivalFrames = {FRENZIEDREG, SURVINSTINCTS, BARKSKIN}

-- spellIDs
local CRH_SPELLID_FAERIE_FIRE			= 770;
local CRH_SPELLID_FAERIE_SWARM			= 102355;
local CRH_SPELLID_BERSERK 				= 50334;
local CRH_SPELLID_SAVAGE_ROAR			= 52610;
local CRH_SPELLID_WEAKENED_ARMOR		= 113746;
local CRH_SPELLID_ENRAGE				= 5229;
local CRH_SPELLID_MAUL					= 6807;
local CRH_SPELLID_SURVIVAL_INSTINCTS	= 61336;
local CRH_SPELLID_TIGERS_FURY			= 5217;
local CRH_SPELLID_THRASH				= 77758;
local CRH_SPELLID_BARKSKIN				= 22812;
local CRH_SPELLID_MANGLE_BEAR			= 33878;
local CRH_SPELLID_FERAL_CHARGE			= 102401;
local CRH_SPELLID_FRENZIED_REGENERATION	= 22842;
local CRH_SPELLID_PREDATORS_SWIFTNESS	= 69369;
local CRH_SPELLID_RAKE					= 59881;
local CRH_SPELLID_RIP					= 1079;
local CRH_SPELLID_LACERATE				= 33745;
local CRH_SPELLID_CLEARCAST				= 16870;
local CRH_SPELLID_WEAKENED_BLOWS		= 115798;

local CRH_GLOBAL_COOLDOWN_VALUE			= 1.6;

local frames = {
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent)
}

local events = {
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent)
}

local survival = {
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent),
	CreateFrame("Frame", nil, UIParent)
}

eventCdTimers = {
--	nil, -- Berserk
--	nil, -- Feral Charge
--	nil, -- Enrage
--	nil, -- Maul
}

survivalCdTimers = {
--	nil, -- Barkskin
--	nil, -- Survival Instincts
--	nil, -- Frenzied Regeneration
}

local function GetImagePath(a_ImageName)
	return "Interface\\AddOns\\CatRotationHelper\\Images\\" .. a_ImageName;
end

local textures = {
	GetImagePath("TigersFury.tga"),
	GetImagePath("FaerieFire.tga"),
	GetImagePath("SavageRoar.tga"),
	GetImagePath("Rake.tga"),
	GetImagePath("Rip.tga"),
	GetImagePath("FaerieFire.tga"), -- @@@@ needs new icon
	GetImagePath("Thrash.tga"),
	GetImagePath("Mangle.tga"),
	GetImagePath("Lacerate.tga"),
	GetImagePath("DemoRoar.tga")
}

local blueTextures = {
	GetImagePath("TigersFury-Blue.tga"),
	GetImagePath("FaerieFire-Blue.tga"),
	GetImagePath("SavageRoar-Blue.tga"),
	GetImagePath("Rake-Blue.tga"),
	GetImagePath("Rip-Blue.tga"),
	GetImagePath("FaerieFire-Blue.tga"),
	GetImagePath("Thrash-Blue.tga"),
	GetImagePath("Mangle-Blue.tga"),
	GetImagePath("Lacerate-Blue.tga"),
	GetImagePath("DemoRoar-Blue.tga")
}

local survivalTextures = {
	GetImagePath("Barkskin.tga"),
	GetImagePath("SurvivalInstincts.tga"),
	GetImagePath("FrenziedReg.tga")
}

--                      r    g    b    a
local fadedcolor   = {0.35,0.35,0.35,0.70};
local upcolor      = {1.00,1.00,1.00,1.00};

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
crhEnableClearcast = false;
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
crhShowMaul = true;
crhShowBearFaerieFire = true;
crhShowEnrage = true;

--bugfix
local function crhSpellName(id)
	local name = GetSpellInfo(id)
	return name
end

local function crhGetDebuffExpiration(a_SpellID, a_Stacks, a_MyOnly)
	local filter = "HARMFUL";
	if (a_MyOnly) then
		filter = "PLAYER|" .. filter;
	end
	
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitAura("target", crhSpellName(a_SpellID), nil, filter);
	if (not name) then
		return 0;
	end
	
	if (a_Stacks and (stacks ~= a_Stacks)) then
		return 0;
	end
	
	return expTime;
end

local function crhGetBuffExpiration(a_SpellID, a_Stacks, a_MyOnly)
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitBuff("player", crhSpellName(a_SpellID));
	if (not name) then
		return 0;
	end
	
	return expTime;
end

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

local function showSurvivalIcon(frame, showeffects)
	if(not frame:IsVisible() or frame.fading) then
		frame:SetScript("OnUpdate",CatRotationHelperEventFadeFunc)
		frame:Show()
		frame.fading = false
		frame.startTime = GetTime()
		
		if(showeffects) then
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

	if(GetShapeshiftForm() == 3 and crhShowCat) then
		if(inBearForm) then
			CatRotationHelperHideAll()
			inBearForm = false
		end

		inCatForm = true

		if(enemyTarget) then
			CatRotationHelperShowCat();
			CatRotationHelperCheckCatBuffs();
			CatRotationHelperCheckCatDebuffs();
			CatRotationHelperCheckCatCooldown()
			CatRotationHelperSetCatCP(GetComboPoints("player"));
			CatRotationHelperUpdateSurvival(false)
			CatRotationHelperUpdateEvents(false)
		end

	elseif(GetShapeshiftForm() == 1 and crhShowBear) then
		if(inCatForm) then
			CatRotationHelperHideAll()
			inCatForm = false
		end

		inBearForm = true

		if(enemyTarget) then
			CatRotationHelperShowBear();
			CatRotationHelperCheckBearDebuffs();
			CatRotationHelperCheckBearCooldown();
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

		for i=1, #crhBearFrames do
			CatRotationFrameStopCounter(frames[crhBearFrames[i]]);
			frames[crhBearFrames[i]]:Hide()
		end
		CatRotationHelperLacerateCounter:Hide()
		CatRotationHelperSetBearCP(0)

	-- stop cat counters and cps
	elseif(showCat) then
		showCat = false

		for i=1, #crhCatFrames do
			CatRotationFrameStopCounter(frames[crhCatFrames[i]]);
		end

		CatRotationHelperSetCatCP(0)
	end

	-- interrupt previous fade
	CatRotationHelperFadeFrame:Hide();

	-- show static cat frames
	for i=1, #crhCatFrames do
		local frame = frames[crhCatFrames[i]]

		frame:Show();
		frame:SetAlpha(1);
		frame.icon:SetVertexColor(upcolor[1], upcolor[2], upcolor[3], upcolor[4]);
	end

	-- show static event frames
	eventList[1] = GetImagePath("Berserk.tga")
	eventList[2] = GetImagePath("FaerieFire.tga")
	eventList[3] = GetImagePath("FeralCharge.tga")
	eventList[4] = GetImagePath("PredatoryStrikes.tga")

	for i=1, #events do
		events[i]:Show()
		events[i]:SetAlpha(1)
		events[i].fading = false
		events[i].startTime = nil
		events[i].countframe:Hide();
		events[i].countframe.endTime = nil;
		events[i]:SetScript("OnUpdate",nil)
		events[i].icon:SetTexture(eventList[i])
	end

	-- show static survival frames
	for i=1, #survival do
		survival[i]:Show()
		survival[i]:SetAlpha(1)
		survival[i].fading = false
		survival[i].startTime = nil
		survival[i].countframe:Hide();
		survival[i].countframe.endTime = nil;
		survival[i]:SetScript("OnUpdate",nil)
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

	for i=1, #frames do
		local frame = frames[i]

		frame:Hide()
		frame.icon:SetVertexColor(fadedcolor[1], fadedcolor[2], fadedcolor[3], fadedcolor[4]);
		frame.icon:SetTexture(textures[i])
		frame.countframe.durtext:SetTextColor(1.00, 1.00, 0.00);
		frame.countframe.dur2text:SetTextColor(1.00, 1.00, 0.00);
		frame.countframe:Hide();
		frame.cpicon:SetTexture(GetImagePath("Cp.tga"))
	end

	for i=1, #events do
		events[i]:Hide()
	end

	for i=1, #survival do
		survival[i]:Hide()
	end

	CatRotationHelperUpdateEverything()
end

-- shows num combo point circles using frames in framesTable
local function CatRotationHelperSetCPEffects(framesTable, num)
	for i=1, #framesTable do
		local frame = frames[framesTable[i]]

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

	CatRotationHelperSetCPEffects(crhCatFrames, num);
end

function CatRotationHelperSetBearCP(num)
	if(not crhLacCounter) then return; end

	CatRotationHelperSetCPEffects(crhBearFrames, num);
end


-- show all frames in frameTable
local function CatRotationHelperShowByFrame(frameTable)
	--if interrupting previous fade, hide frames
	for i=1, #frames do
		frames[i]:Hide();
	end

	for i=1, #frameTable do
		frames[frameTable[i]]:Show();
	end

	-- fade effect
	CatRotationHelperFadeFrame:Show();
	CatRotationHelperFadeFrame.fading = false;
	CatRotationHelperFadeFrame.startTime = GetTime();
end

function CatRotationHelperShowCat()
	if(showCat) then return; end
	showCat = true;

	CatRotationHelperShowByFrame(crhCatFrames);
end

function CatRotationHelperShowBear()
	if(showBear) then return; end
	showBear = true;

	CatRotationHelperShowByFrame(crhBearFrames);
end

function CatRotationHelperUpdateFrame(self, endTime)
    if (not self.counting or endTime ~= self.countframe.endTime) then
    	-- new buff applied
		if(not self.counting or self.countframe.endTime - GetTime() < 11) then
			self.overlay.animIn:Play()
		end
		
		self.counting = true
		self.icon:SetVertexColor(upcolor[1], upcolor[2], upcolor[3], upcolor[4])

    	self.countframe.endTime = endTime
    	self.countframe:Show()
		self.countframe.dur2text:Show();
		self.countframe.durtext:SetText("");
	end
end

function CatRotationFrameStopCounter(self)
	if (not self.counting) then
		return;
	end

	self.counting = false
	self.countframe:Hide();
	self.countframe.endTime = nil;
	self.icon:SetVertexColor(fadedcolor[1], fadedcolor[2], fadedcolor[3], fadedcolor[4]);
	self.overlay.animOut:Play()
end

local function crhUpdateFrameWithExpiration(a_Self, a_Expiration)
	if (a_Expiration ~= 0) then
		CatRotationHelperUpdateFrame(a_Self, a_Expiration);
	else
		CatRotationFrameStopCounter(a_Self);
	end
end

local function crhUpdateFrameFromDebuff(a_FrameID, a_SpellID, a_Stacks, a_MyOnly)
	crhUpdateFrameWithExpiration(frames[a_FrameID], crhGetDebuffExpiration(a_SpellID, a_Stacks, a_MyOnly))
end

local function crhUpdateFrameFromBuff(a_FrameID, a_SpellID)
	crhUpdateFrameWithExpiration(frames[a_FrameID], crhGetBuffExpiration(a_SpellID))
end

local function crhUpdateFrameFromSkill(a_FrameID, a_SpellID)
	local spellStart, spellDuration = GetSpellCooldown(a_SpellID);
	if (spellStart == nil) then
		-- Forced reset; skill could be ready ahead of cd due to proc
		CatRotationFrameStopCounter(frames[a_FrameID]);
		return;
	end

	if (spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
		return;
	end
	
	CatRotationHelperUpdateFrame(frames[a_FrameID], spellStart + spellDuration)
end

function CatRotationFrameSetMainScale()
	for i=1, #frames do
		frames[i]:SetScale(crhScale);
		frames[i].parentFrame:SetScale(crhScale);
	end

	CatRotationHelperHeader:SetScale(crhScale);
end

function CatRotationFrameSetEventScale()
	for i=1, #events do
		events[i]:SetScale(crhEventScale);
		events[i].parentFrame:SetScale(crhEventScale);
	end

	CatRotationHelperEvents:SetScale(crhEventScale);
end

function CatRotationFrameSetSurvivalScale()
	for i=1, #survival do
		survival[i]:SetScale(crhSurvivalScale);
		survival[i].parentFrame:SetScale(crhSurvivalScale);
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
	for i=1, #frames do
		frames[i].parentFrame:ClearAllPoints()
	end

	local headerFrame = CatRotationHelperHeader;

	if(crhMainAngle == 0) then
		headerFrame:SetHeight(36)
		headerFrame:SetWidth(176)

		frames[crhCatFrames[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);
		frames[crhBearFrames[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);

		frames[crhCatFrames[2]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[1]].parentFrame, "TOPRIGHT", 5, 0);
		frames[crhBearFrames[2]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[1]].parentFrame, "TOPRIGHT", 5, 0);

		frames[crhCatFrames[3]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[2]].parentFrame, "TOPRIGHT", 5, 0);
		frames[crhBearFrames[3]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[2]].parentFrame, "TOPRIGHT", 5, 0);

		frames[crhCatFrames[4]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[3]].parentFrame, "TOPRIGHT", 5, 0);
		frames[crhBearFrames[4]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[3]].parentFrame, "TOPRIGHT", 5, 0);

		frames[crhCatFrames[5]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[4]].parentFrame, "TOPRIGHT", 5, 0);
		frames[crhBearFrames[5]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[4]].parentFrame, "TOPRIGHT", 5, 0);

	elseif(crhMainAngle == 90) then
		headerFrame:SetHeight(176)
		headerFrame:SetWidth(36)

		frames[crhCatFrames[1]].parentFrame:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 3, 3);
		frames[crhBearFrames[1]].parentFrame:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 3, 3);

		frames[crhCatFrames[2]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhCatFrames[1]].parentFrame, "TOPLEFT", 0, 5);
		frames[crhBearFrames[2]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhBearFrames[1]].parentFrame, "TOPLEFT", 0, 5);

		frames[crhCatFrames[3]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhCatFrames[2]].parentFrame, "TOPLEFT", 0, 5);
		frames[crhBearFrames[3]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhBearFrames[2]].parentFrame, "TOPLEFT", 0, 5);

		frames[crhCatFrames[4]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhCatFrames[3]].parentFrame, "TOPLEFT", 0, 5);
		frames[crhBearFrames[4]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhBearFrames[3]].parentFrame, "TOPLEFT", 0, 5);

		frames[crhCatFrames[5]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhCatFrames[4]].parentFrame, "TOPLEFT", 0, 5);
		frames[crhBearFrames[5]].parentFrame:SetPoint("BOTTOMLEFT", frames[crhBearFrames[4]].parentFrame, "TOPLEFT", 0, 5);

	elseif(crhMainAngle == 180) then
		headerFrame:SetHeight(36)
		headerFrame:SetWidth(176)

		frames[crhCatFrames[1]].parentFrame:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -3, -3);
		frames[crhBearFrames[1]].parentFrame:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -3, -3);

		frames[crhCatFrames[2]].parentFrame:SetPoint("TOPRIGHT", frames[crhCatFrames[1]].parentFrame, "TOPLEFT", -5, 0);
		frames[crhBearFrames[2]].parentFrame:SetPoint("TOPRIGHT", frames[crhBearFrames[1]].parentFrame, "TOPLEFT", -5, 0);

		frames[crhCatFrames[3]].parentFrame:SetPoint("TOPRIGHT", frames[crhCatFrames[2]].parentFrame, "TOPLEFT", -5, 0);
		frames[crhBearFrames[3]].parentFrame:SetPoint("TOPRIGHT", frames[crhBearFrames[2]].parentFrame, "TOPLEFT", -5, 0);

		frames[crhCatFrames[4]].parentFrame:SetPoint("TOPRIGHT", frames[crhCatFrames[3]].parentFrame, "TOPLEFT", -5, 0);
		frames[crhBearFrames[4]].parentFrame:SetPoint("TOPRIGHT", frames[crhBearFrames[3]].parentFrame, "TOPLEFT", -5, 0);

		frames[crhCatFrames[5]].parentFrame:SetPoint("TOPRIGHT", frames[crhCatFrames[4]].parentFrame, "TOPLEFT", -5, 0);
		frames[crhBearFrames[5]].parentFrame:SetPoint("TOPRIGHT", frames[crhBearFrames[4]].parentFrame, "TOPLEFT", -5, 0);

	else
		headerFrame:SetHeight(176)
		headerFrame:SetWidth(36)

		frames[crhCatFrames[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);
		frames[crhBearFrames[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);

		frames[crhCatFrames[2]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[1]].parentFrame, "BOTTOMLEFT", 0, -5);
		frames[crhBearFrames[2]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[1]].parentFrame, "BOTTOMLEFT", 0, -5);

		frames[crhCatFrames[3]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[2]].parentFrame, "BOTTOMLEFT", 0, -5);
		frames[crhBearFrames[3]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[2]].parentFrame, "BOTTOMLEFT", 0, -5);

		frames[crhCatFrames[4]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[3]].parentFrame, "BOTTOMLEFT", 0, -5);
		frames[crhBearFrames[4]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[3]].parentFrame, "BOTTOMLEFT", 0, -5);

		frames[crhCatFrames[5]].parentFrame:SetPoint("TOPLEFT", frames[crhCatFrames[4]].parentFrame, "BOTTOMLEFT", 0, -5);
		frames[crhBearFrames[5]].parentFrame:SetPoint("TOPLEFT", frames[crhBearFrames[4]].parentFrame, "BOTTOMLEFT", 0, -5);
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
	events[1].parentFrame:ClearAllPoints()
	events[2].parentFrame:ClearAllPoints()
	events[3].parentFrame:ClearAllPoints()
	events[4].parentFrame:ClearAllPoints()
	
	local eventFrame = CatRotationHelperEvents

	if(crhEventAngle == 0) then
		eventFrame:SetHeight(36)
		eventFrame:SetWidth(140)

		events[1].parentFrame:SetPoint("TOPLEFT", eventFrame, "TOPLEFT", 3, -3);
		events[2].parentFrame:SetPoint("TOPLEFT", events[1].parentFrame, "TOPRIGHT", 4, 0);
		events[3].parentFrame:SetPoint("TOPLEFT", events[2].parentFrame, "TOPRIGHT", 4, 0);
		events[4].parentFrame:SetPoint("TOPLEFT", events[3].parentFrame, "TOPRIGHT", 4, 0);
		
	elseif(crhEventAngle == 90) then
		eventFrame:SetHeight(140)
		eventFrame:SetWidth(36)

		events[1].parentFrame:SetPoint("BOTTOMLEFT", eventFrame, "BOTTOMLEFT", 3, 3);
		events[2].parentFrame:SetPoint("BOTTOMLEFT", events[1].parentFrame, "TOPLEFT", 0, 4);
		events[3].parentFrame:SetPoint("BOTTOMLEFT", events[2].parentFrame, "TOPLEFT", 0, 4);
		events[4].parentFrame:SetPoint("BOTTOMLEFT", events[3].parentFrame, "TOPLEFT", 0, 4);
		
	elseif(crhEventAngle == 180) then
		eventFrame:SetHeight(36)
		eventFrame:SetWidth(140)

		events[1].parentFrame:SetPoint("TOPRIGHT", eventFrame, "TOPRIGHT", -3, -3);
		events[2].parentFrame:SetPoint("TOPRIGHT", events[1].parentFrame, "TOPLEFT", -4, 0);
		events[3].parentFrame:SetPoint("TOPRIGHT", events[2].parentFrame, "TOPLEFT", -4, 0);
		events[4].parentFrame:SetPoint("TOPRIGHT", events[3].parentFrame, "TOPLEFT", -4, 0);

	else
		eventFrame:SetHeight(140)
		eventFrame:SetWidth(36)

		events[1].parentFrame:SetPoint("TOPLEFT", eventFrame, "TOPLEFT", 3, -3);
		events[2].parentFrame:SetPoint("TOPLEFT", events[1].parentFrame, "BOTTOMLEFT", 0, -4);
		events[3].parentFrame:SetPoint("TOPLEFT", events[2].parentFrame, "BOTTOMLEFT", 0, -4);
		events[4].parentFrame:SetPoint("TOPLEFT", events[3].parentFrame, "BOTTOMLEFT", 0, -4);
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
	survival[1].parentFrame:ClearAllPoints()
	survival[2].parentFrame:ClearAllPoints()
	survival[3].parentFrame:ClearAllPoints()

	local survFrame = CatRotationHelperSurvival

	if(crhSurvivalAngle == 0) then
		survFrame:SetHeight(36)
		survFrame:SetWidth(105)

		survival[crhSurvivalFrames[1]].parentFrame:SetPoint("TOPLEFT", survFrame, "TOPLEFT", 3, -3);
		survival[crhSurvivalFrames[2]].parentFrame:SetPoint("TOPLEFT", survival[crhSurvivalFrames[1]].parentFrame, "TOPRIGHT", 4, 0);
		survival[crhSurvivalFrames[3]].parentFrame:SetPoint("TOPLEFT", survival[crhSurvivalFrames[2]].parentFrame, "TOPRIGHT", 4, 0);

	elseif(crhSurvivalAngle == 90) then
		survFrame:SetHeight(105)
		survFrame:SetWidth(36)

		survival[crhSurvivalFrames[1]].parentFrame:SetPoint("BOTTOMLEFT", survFrame, "BOTTOMLEFT", 3, 3);
		survival[crhSurvivalFrames[2]].parentFrame:SetPoint("BOTTOMLEFT", survival[crhSurvivalFrames[1]].parentFrame, "TOPLEFT", 0, 4);
		survival[crhSurvivalFrames[3]].parentFrame:SetPoint("BOTTOMLEFT", survival[crhSurvivalFrames[2]].parentFrame, "TOPLEFT", 0, 4);

	elseif(crhSurvivalAngle == 180) then
		survFrame:SetHeight(36)
		survFrame:SetWidth(105)

		survival[crhSurvivalFrames[1]].parentFrame:SetPoint("TOPRIGHT", survFrame, "TOPRIGHT", -3, -3);
		survival[crhSurvivalFrames[2]].parentFrame:SetPoint("TOPRIGHT", survival[crhSurvivalFrames[1]].parentFrame, "TOPLEFT", -4, 0);
		survival[crhSurvivalFrames[3]].parentFrame:SetPoint("TOPRIGHT", survival[crhSurvivalFrames[2]].parentFrame, "TOPLEFT", -4, 0);

	else
		survFrame:SetHeight(105)
		survFrame:SetWidth(36)

		survival[crhSurvivalFrames[1]].parentFrame:SetPoint("TOPLEFT", survFrame, "TOPLEFT", 3, -3);
		survival[crhSurvivalFrames[2]].parentFrame:SetPoint("TOPLEFT", survival[crhSurvivalFrames[1]].parentFrame, "BOTTOMLEFT", 0, -4);
		survival[crhSurvivalFrames[3]].parentFrame:SetPoint("TOPLEFT", survival[crhSurvivalFrames[2]].parentFrame, "BOTTOMLEFT", 0, -4);
	end

end

function CatRotationHelperHideAll()
	local framesTable

	-- decide what frames to hide
	if(showBear) then
		showBear = false

		framesTable = crhBearFrames
		CatRotationHelperLacerateCounter:Hide()
		CatRotationHelperSetBearCP(0)
	elseif(showCat) then
		showCat = false

		framesTable = crhCatFrames
		CatRotationHelperSetCatCP(0)
	else
		return
	end

	-- stop running timers
	for i=1, #framesTable do
		CatRotationFrameStopCounter(frames[framesTable[i]]);
	end

	-- general fade animation
	CatRotationHelperFadeFrame:Show();
	CatRotationHelperFadeFrame.fading = true;
	CatRotationHelperFadeFrame.startTime = GetTime();

	-- hide events
	for i=1, #events do
		hideEventIcon(events[i])
	end

	for i=1, #survival do
		hideEventIcon(survival[i])
	end
end

-----------------------------
-- Cat - Main Frame Checks --
-----------------------------

function CatRotationHelperCheckCatBuffs()
	crhUpdateFrameFromBuff(CRH_FRAME_SAVAGEROAR, CRH_SPELLID_SAVAGE_ROAR);
end

function CatRotationHelperCheckCatDebuffs()
	crhUpdateFrameFromDebuff(CRH_FRAME_CAT_WEAKARMOR, CRH_SPELLID_WEAKENED_ARMOR, 3);
	crhUpdateFrameFromDebuff(CRH_FRAME_RAKE, CRH_SPELLID_RAKE, nil, true);
	crhUpdateFrameFromDebuff(CRH_FRAME_RIP, CRH_SPELLID_RIP, nil, true);
end

function CatRotationHelperCheckCatCooldown()
	crhUpdateFrameFromSkill(CRH_FRAME_TIGERSFURY, CRH_SPELLID_TIGERS_FURY);
end

------------------------------
-- Bear - Main Frame Checks --
------------------------------

local function crhUpdateLacerate()
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitAura("target", crhSpellName(CRH_SPELLID_LACERATE), nil, "PLAYER|HARMFUL");
	if (name == nil) then
		CatRotationFrameStopCounter(frames[CRH_FRAME_LACERATE]);
		CatRotationHelperLacerateCounter:Hide();
		CatRotationHelperSetBearCP(0);
		return;
	end
	
	CatRotationHelperUpdateFrame(frames[CRH_FRAME_LACERATE], expTime);

	-- stop possible cp animation when lacerate is refreshed
	local i = 1;
	for i=1, #crhBearFrames do
		frames[crhBearFrames[i]].cpframe:SetAlpha(1)
		frames[crhBearFrames[i]].cpframe:SetScale(1)
	end

	-- setup lacerate warning
	CatRotationHelperLacerateCounter:Show()
	CatRotationHelperLacerateCounter.expTime = expTime

	-- set cp effects
	CatRotationHelperSetBearCP(stacks);
end

function CatRotationHelperCheckBearDebuffs()
	crhUpdateFrameFromDebuff(CRH_FRAME_WEAKBLOWS, CRH_SPELLID_WEAKENED_BLOWS);
	crhUpdateFrameFromDebuff(CRH_FRAME_BEAR_WEAKARMOR, CRH_SPELLID_WEAKENED_ARMOR, 3);
	crhUpdateLacerate();
end

function CatRotationHelperCheckBearCooldown()
	crhUpdateFrameFromSkill(CRH_FRAME_THRASH, CRH_SPELLID_THRASH);
	crhUpdateFrameFromSkill(CRH_FRAME_BEAR_MANGLE, CRH_SPELLID_MANGLE_BEAR);
end

local function crhTargetHasFaerieFire()
	if (crhGetDebuffExpiration(CRH_SPELLID_FAERIE_FIRE)) then
		return true;
	end

	if (crhGetDebuffExpiration(CRH_SPELLID_FAERIE_SWARM)) then
		return true;
	end

	return false
end

-- Check for Clearcast procs - Bear & Cat
function CatRotationHelperCheckClearcast()
	name = UnitBuff("player", crhSpellName(CRH_SPELLID_CLEARCAST));
	if(name and crhEnableClearcast) then
		if(not clearCast) then
			for i=1, #frames do
				frames[i].cpicon:SetTexture(GetImagePath("Cp-Blue.tga"))
				frames[i].icon:SetTexture(blueTextures[i])
				frames[i].overlay.icon:SetTexture(blueTextures[i])

				if(frames[i].hascp) then
					frames[i].countframe.durtext:SetTextColor(0.40, 0.70, 0.95);
					frames[i].countframe.dur2text:SetTextColor(0.40, 0.70, 0.95);
				else
					frames[i].countframe.durtext:SetTextColor(0.50, 0.85, 1.00);
					frames[i].countframe.dur2text:SetTextColor(0.50, 0.85, 1.00);
				end
			end

			clearCast = true;
		end

	else
		if(clearCast) then
			for i=1,#frames do
				frames[i].cpicon:SetTexture(GetImagePath("Cp.tga"))
				frames[i].icon:SetTexture(textures[i])
				frames[i].overlay.icon:SetTexture(textures[i])

				if(frames[i].hascp) then
					frames[i].countframe.durtext:SetTextColor(0.90, 0.70, 0.00);
					frames[i].countframe.dur2text:SetTextColor(0.90, 0.70, 0.00);
				else
					frames[i].countframe.durtext:SetTextColor(1.00, 1.00, 0.00);
					frames[i].countframe.dur2text:SetTextColor(1.00, 1.00, 0.00);
				end

			end

			clearCast = false;
		end
	end
end

-- Event Frame - Bear & Cat
function CatRotationHelperUpdateEvents(showeffects)
	-- first, update eventList table
	if(inCatForm) then
		local spellStart, spellDuration, name, rank, icon, count, debuffType, duration, expTime, unitCaster, isStealable, shouldConsolidate
		
		-- Berserk
		spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_BERSERK);
		if(spellStart ~= nil and crhShowCatBerserk) then
			if(spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
				if(eventList[1] == nil) then
					eventEffects[1] = showeffects
				else
					eventEffects[1] = nil
				end
				eventList[1] = GetImagePath("Berserk.tga")
				eventTimers[1] = nil
			else
				eventList[1] = nil
				eventTimers[1] = nil
				eventEffects[1] = nil
				eventCdTimers[1] = spellDuration + spellStart
				CatRotationHelperCdCounter:Show()

				local i = 1;
				repeat
					name, rank, icon, count, debuffType, duration, expTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("player", i);

					if (spellId == CRH_SPELLID_BERSERK) then
						eventList[1] = GetImagePath("Berserk.tga")
						eventTimers[1] = expTime
					end

					i = i + 1;
				until (spellId == nil)

			end
		else
			eventList[1] = nil
			eventTimers[1] = nil
			eventEffects[1] = nil
		end

		-- Faerie Fire
		if(not crhTargetHasFaerieFire() and crhShowCatFaerieFire) then
			if(eventList[2] == nil) then
				eventEffects[2] = showeffects
			else
				eventEffects[2] = nil
			end
			eventList[2] = GetImagePath("FaerieFire.tga")
			eventTimers[2] = nil
		else
			eventList[2] = nil
			eventTimers[2] = nil
			eventEffects[2] = nil
		end
		
		-- Feral Charge. Probably not learned.
		if (not IsPlayerSpell(CRH_SPELLID_FERAL_CHARGE)) then
			-- @@@@ Clean up spec changes in a better way
			eventList[3] = nil
		else
			spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_FERAL_CHARGE);
			if(crhShowFeralCharge and spellStart ~= nil) then
				if(spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
					if(eventList[3] == nil) then
						eventEffects[3] = showeffects
					else
						eventEffects[3] = nil
					end
					eventList[3] = GetImagePath("FeralCharge.tga")
					eventTimers[3] = nil
				else
					eventCdTimers[2] = spellDuration + spellStart
					eventEffects[3] = nil
					CatRotationHelperCdCounter:Show()
					eventList[3] = nil
					eventTimers[3] = nil
				end
			else
				eventList[3] = nil
				eventTimers[3] = nil
				eventEffects[3] = nil
			end
		end
		
		-- Predator's Swiftness
		name, rank, icon, count, debuffType, duration, expTime = UnitBuff("player", crhSpellName(CRH_SPELLID_PREDATORS_SWIFTNESS));
		if(name and crhShowPredatorsSwiftness) then
			if(eventList[4] == nil) then
				eventEffects[4] = showeffects
			else
				eventEffects[4] = nil
			end
			eventList[4] = GetImagePath("PredatoryStrikes.tga")
			eventTimers[4] = expTime
		else
			eventList[4] = nil
			eventTimers[4] = nil
			eventEffects[4] = nil
		end

	elseif(inBearForm) then
		local spellStart, spellDuration, name, rank, icon, count, debuffType, duration, expTime, unitCaster, isStealable, shouldConsolidate
		
		-- Berserk
		spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_BERSERK);
		if(spellStart ~= nil and crhShowBearBerserk) then
			if(spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
				if(eventList[1] == nil) then
					eventEffects[1] = showeffects
				else
					eventEffects[1] = nil
				end
				eventList[1] = GetImagePath("Berserk.tga")
				eventTimers[1] = nil
			else
				eventList[1] = nil
				eventTimers[1] = nil
				eventEffects[1] = nil

				eventCdTimers[1] = spellDuration + spellStart
				CatRotationHelperCdCounter:Show()

				local i = 1;
				repeat
					name, rank, icon, count, debuffType, duration, expTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("player", i);

					if (spellId == CRH_SPELLID_BERSERK) then
						eventList[1] = GetImagePath("Berserk.tga")
						eventTimers[1] = expTime
					end

					i = i + 1;
				until (spellId == nil)

			end
		else
			eventList[1] = nil
			eventTimers[1] = nil
			eventEffects[1] = nil
		end

		-- Faerie Fire
		if(not crhTargetHasFaerieFire() and crhShowBearFaerieFire) then
			if(eventList[2] == nil) then
				eventEffects[2] = showeffects
			else
				eventEffects[2] = nil
			end
			eventList[2] = GetImagePath("FaerieFire.tga")
			eventTimers[2] = nil
		else
			eventList[2] = nil
			eventTimers[2] = nil
			eventEffects[2] = nil
		end

		-- Enrage
		if (not IsPlayerSpell(CRH_SPELLID_ENRAGE)) then
			-- @@@@ Clean up spec changes in a better way
			eventList[3] = nil
		else
			spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_ENRAGE);
			if(crhShowEnrage and spellStart ~= nil) then
				if(spellStart == 0) then
					if(eventList[3] == nil) then
						eventEffects[3] = showeffects
					else
						eventEffects[3] = nil
					end
					eventList[3] = GetImagePath("Enrage.tga")
					eventTimers[3] = nil
				else
					eventCdTimers[3] = spellDuration + spellStart
					CatRotationHelperCdCounter:Show()
					eventEffects[3] = nil
					
					name, rank, icon, count, debuffType, duration, expTime = UnitBuff("player", crhSpellName(CRH_SPELLID_ENRAGE));
					if(name) then
						-- buff running, show timer
						eventList[3] = GetImagePath("Enrage.tga")
						eventTimers[3] = expTime
					else
						eventList[3] = nil
						eventTimers[3] = nil
					end
		
				end
			else
				eventList[3] = nil
				eventTimers[3] = nil
				eventEffects[3] = nil
			end
		end

		-- Maul
		spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_MAUL);
		if(crhShowMaul and spellStart ~= nil and spellStart == 0) then
			if(eventList[4] == nil) then
				eventEffects[4] = showeffects
			else
				eventEffects[4] = nil
			end
			eventList[4] = GetImagePath("Maul.tga")
			eventTimers[4] = nil
		else
			eventCdTimers[4] = spellDuration + spellStart
			CatRotationHelperCdCounter:Show()

			eventList[4] = nil
			eventTimers[4] = nil
			eventEffects[4] = nil
		end

	end

	-- second, fill event frames with information
	j = 1

	for i=1, #events do
		if(eventList[i] ~= nil) then
			events[j].icon:SetTexture(eventList[i])
			events[j].overlay.icon:SetTexture(eventList[i])
			showEventIcon(events[j])
			
			if(eventEffects[i]) then
				events[j].overlay.animIn:Play()
			end
			
			if(eventTimers[i] ~= nil) then
				events[j].countframe.endTime = eventTimers[i]
				events[j].countframe:Show()
			else
				events[j].countframe:Hide()
			end

			j = j + 1
		end
	end

	-- hide unused event frames
	while j <= #events do
		hideEventIcon(events[j])
		j = j + 1
	end

end

-- Survival Frame - Bear & Cat
function CatRotationHelperUpdateSurvival(showeffects)
	if( (crhShowCatSurvival and inCatForm) or (crhShowBearSurvival and inBearForm) ) then
		local spellStart, spellDuration, name, rank, icon, count, debuffType, duration, expTime
		
		-- Barkskin
		spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_BARKSKIN);
		if(spellStart ~= nil) then
			if(spellDuration == 0) then
				showSurvivalIcon(survival[BARKSKIN],showeffects)
			else
				survivalCdTimers[1] = spellDuration + spellStart
				CatRotationHelperCdCounter:Show()

				name, rank, icon, count, debuffType, duration, expTime = UnitBuff("player", crhSpellName(CRH_SPELLID_BARKSKIN));
				if(name) then
					-- buff running, show timer
					showEventIcon(survival[BARKSKIN])

					survival[BARKSKIN].countframe.endTime = expTime
					survival[BARKSKIN].countframe:Show()
				else
					hideEventIcon(survival[BARKSKIN])
				end
			end
		end

		-- Survival Instincts
		spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_SURVIVAL_INSTINCTS);
		if(spellStart ~= nil) then
			if(spellDuration == 0) then
				showSurvivalIcon(survival[SURVINSTINCTS],showeffects)
			else
				survivalCdTimers[2] = spellDuration + spellStart
				CatRotationHelperCdCounter:Show()

				name, rank, icon, count, debuffType, duration, expTime = UnitBuff("player", crhSpellName(CRH_SPELLID_SURVIVAL_INSTINCTS));
				if(name) then
					-- buff running, show timer
					showEventIcon(survival[SURVINSTINCTS])

					survival[SURVINSTINCTS].countframe.endTime = expTime
					survival[SURVINSTINCTS].countframe:Show()
				else
					hideEventIcon(survival[SURVINSTINCTS])
				end
			end
		end

		-- Frenzied Regeneration
		if(inBearForm) then
			spellStart, spellDuration = GetSpellCooldown(CRH_SPELLID_FRENZIED_REGENERATION);
			if(spellStart ~= nil) then
				if(spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
					showSurvivalIcon(survival[FRENZIEDREG],showeffects)			
				else
					survivalCdTimers[3] = spellDuration + spellStart
					CatRotationHelperCdCounter:Show()

					name, rank, icon, count, debuffType, duration, expTime = UnitBuff("player", crhSpellName(CRH_SPELLID_FRENZIED_REGENERATION));
					if(name) then
						-- buff running, show timer
						showEventIcon(survival[FRENZIEDREG])

						survival[FRENZIEDREG].countframe.endTime = expTime
						survival[FRENZIEDREG].countframe:Show()
					else
						hideEventIcon(survival[FRENZIEDREG])
					end
				end
			end
		end

	end
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


	SlashCmdList["CRH"] = CatRotationHelperCommand;
	SLASH_CRH1 = "/crh";

	-- setup frames
	for i=1, #frames do
		local frame = frames[i]

		frame.parentFrame = CreateFrame("Frame", nil, UIParent);
		frame.parentFrame:SetFrameStrata("LOW");
		frame.parentFrame:SetWidth(30)
		frame.parentFrame:SetHeight(30)
		frame:SetPoint("CENTER", frame.parentFrame, "CENTER", 0, 0);

		frame:SetWidth(30)
		frame:SetHeight(30)
		frame:Hide()
		frame.hascp = false
		frame.counting = false

		frame.cpframe = CreateFrame("Frame", nil, frame);
		frame.cpframe:SetFrameStrata("BACKGROUND");
		frame.cpframe:SetPoint("CENTER");
		frame.cpframe:SetWidth(34)
		frame.cpframe:SetHeight(34)
		frame.cpframe.startTime = nil;
		frame.cpframe:Hide();

		frame.cpicon = frame.cpframe:CreateTexture(nil,"BACKGROUND")
		frame.cpicon:SetTexture(GetImagePath("Cp.tga"))
		frame.cpicon:SetAllPoints(frame.cpframe)

		frame.icon = frame:CreateTexture(nil,"ARTWORK")
		frame.icon:SetAllPoints(frame)
		frame.icon:SetVertexColor(fadedcolor[1], fadedcolor[2], fadedcolor[3], fadedcolor[4]);
		frame.icon:SetTexture(textures[i])

		-- buff fade/gain effects
		frame.overlay = CreateFrame("Frame", "CatRotationHelperFrameAlert" .. i, frame, "CatRotationHelperEventAlert")
		frame.overlay.icon:SetTexture(textures[i])
		frame.overlay.icon:SetBlendMode("ADD");
		frame.overlay:SetSize(24*1.5, 24*1.5)
		frame.overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", -24*0.25, 24*0.25)
		frame.overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 24*0.25, -24*0.25)		

		frame.countframe = CreateFrame("Frame", nil, frame);
		frame.countframe:SetScript("OnUpdate", CatRotationFrameCounter)
		frame.countframe:Hide();
		frame.countframe.endTime = nil;

		frame.countframe.durtext = frame.countframe:CreateFontString(nil, "OVERLAY", "CatRotationHelperDurText")
		frame.countframe.durtext:SetPoint("CENTER", frame, "CENTER", 0, 0);
		frame.countframe.dur2text = frame.countframe:CreateFontString(nil, "OVERLAY", "CatRotationHelperDur2Text")
		frame.countframe.dur2text:SetPoint("CENTER", frame, "CENTER", 0, -5);
		frame.countframe.dur2text:SetText("*");
		frame.countframe.dur2text:Hide();
	end

	-- setup events
	for i=1, #events do
		local event = events[i]
		event.parentFrame = CreateFrame("Frame", nil, UIParent);
		event.parentFrame:SetFrameStrata("LOW");
		event.parentFrame:SetWidth(30)
		event.parentFrame:SetHeight(30)
		event:SetPoint("CENTER", event.parentFrame, "CENTER", 0, 0);

		event:SetWidth(30)
		event:SetHeight(30)
		event:Hide()
		event.fading = false
		event.startTime = nil

		event.icon = event:CreateTexture(nil,"ARTWORK")
		event.icon:SetAllPoints(event)
		event.icon:SetVertexColor(upcolor[1], upcolor[2], upcolor[3], upcolor[4]);

		event.overlay = CreateFrame("Frame", "CatRotationHelperEventAlert" .. i, event, "CatRotationHelperEventAlert")
		event.overlay.icon:SetBlendMode("ADD");
		event.overlay:SetSize(28*1.5, 28*1.5)
		event.overlay:SetPoint("TOPLEFT", event, "TOPLEFT", -28*0.25, 28*0.25)
		event.overlay:SetPoint("BOTTOMRIGHT", event, "BOTTOMRIGHT", 28*0.25, -28*0.25)

		event.countframe = CreateFrame("Frame", nil, event);
		event.countframe:SetScript("OnUpdate", CatRotationFrameEventCounter)
		event.countframe:Hide();
		event.countframe.endTime = nil;

		event.countframe.durtext = event.countframe:CreateFontString(nil, "OVERLAY", "CatRotationHelperDurText")
		event.countframe.durtext:SetPoint("CENTER", event, "CENTER", 0, 0);
	end

	-- setup survival frame
	for i=1, #survival do
		local event = survival[i]
		event.parentFrame = CreateFrame("Frame", nil, UIParent);
		event.parentFrame:SetFrameStrata("LOW");
		event.parentFrame:SetWidth(30)
		event.parentFrame:SetHeight(30)
		event:SetPoint("CENTER", event.parentFrame, "CENTER", 0, 0);

		event:SetWidth(30)
		event:SetHeight(30)
		event:Hide()
		event.fading = false
		event.startTime = nil

		event.overlay = CreateFrame("Frame", "CatRotationHelperSurvivalAlert" .. i, event, "CatRotationHelperEventAlert")
		event.overlay.icon:SetTexture(survivalTextures[i])
		event.overlay.icon:SetBlendMode("ADD");
		event.overlay:SetSize(28*1.5, 28*1.5)
		event.overlay:SetPoint("TOPLEFT", event, "TOPLEFT", -28*0.25, 28*0.25)
		event.overlay:SetPoint("BOTTOMRIGHT", event, "BOTTOMRIGHT", 28*0.25, -28*0.25)
		
		event.icon = event:CreateTexture(nil,"ARTWORK")
		event.icon:SetAllPoints(event)
		event.icon:SetVertexColor(upcolor[1], upcolor[2], upcolor[3], upcolor[4]);
		event.icon:SetTexture(survivalTextures[i])

		event.countframe = CreateFrame("Frame", nil, event);
		event.countframe:SetScript("OnUpdate", CatRotationFrameEventCounter)
		event.countframe:Hide();
		event.countframe.endTime = nil;

		event.countframe.durtext = event.countframe:CreateFontString(nil, "OVERLAY", "CatRotationHelperDurText")
		event.countframe.durtext:SetPoint("CENTER", event, "CENTER", 0, 0);
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
					CatRotationHelperCheckCatBuffs();
					CatRotationHelperCheckClearcast();
					CatRotationHelperUpdateSurvival(true)
					CatRotationHelperUpdateEvents(true)
				elseif(arg1 == "target") then
					CatRotationHelperCheckCatDebuffs();
					CatRotationHelperUpdateEvents(true)
				end
			elseif(inBearForm) then
				if(arg1 == "target") then
					CatRotationHelperCheckBearDebuffs();
					CatRotationHelperUpdateEvents(true)
				elseif(arg1 == "player") then
					CatRotationHelperCheckClearcast();
					CatRotationHelperUpdateSurvival(true)
					CatRotationHelperUpdateEvents(true)
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
				CatRotationHelperCheckBearCooldown()
				CatRotationHelperUpdateSurvival(true)
				CatRotationHelperUpdateEvents(true)
			elseif(inCatForm) then
				CatRotationHelperCheckCatCooldown();
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
		CatRotationFrameStopCounter(self:GetParent());
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
		for i=1, #crhBearFrames do
			frames[crhBearFrames[i]].cpframe:SetAlpha(1.0-t)
			frames[crhBearFrames[i]].cpframe:SetScale(1.0+0.3*t)
		end
	else
		for i=1, #crhBearFrames do
			frames[crhBearFrames[i]].cpframe:SetAlpha(t)
			frames[crhBearFrames[i]].cpframe:SetScale(1.3-0.3*t)
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
			for i=1, #frames do
				frames[i]:Hide();
			end
		end
	end

	if(self.fading) then
		for i=1, #frames do
			frames[i]:SetAlpha(1-elapsed*2.5);
		end
	else
		for i=1, #frames do
			frames[i]:SetAlpha(elapsed*2.5);
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
