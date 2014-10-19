-- spellIDs
local CRH_SPELLID_BARKSKIN				= 22812;
local CRH_SPELLID_BERSERK 				= 106952;
local CRH_SPELLID_CLEARCAST				= 16870;
local CRH_SPELLID_FAERIE_FIRE			= 770;
local CRH_SPELLID_FAERIE_SWARM			= 102355;
local CRH_SPELLID_FERAL_CHARGE			= 102401;
local CRH_SPELLID_LACERATE				= 33745;
local CRH_SPELLID_MANGLE_BEAR			= 33917;
local CRH_SPELLID_PREDATORS_SWIFTNESS	= 69369;
local CRH_SPELLID_RAKE					= 59881;
local CRH_SPELLID_RIP					= 1079;
local CRH_SPELLID_SAVAGE_DEFENSE		= 62606;
local CRH_SPELLID_SAVAGE_DEFENSE_BUFF	= 132402;
local CRH_SPELLID_SAVAGE_ROAR			= 52610;
local CRH_SPELLID_SURVIVAL_INSTINCTS	= 61336;
local CRH_SPELLID_THRASH				= 77758;
local CRH_SPELLID_TIGERS_FURY			= 5217;

local CRH_SHAPE_BEAR 					= 1;
local CRH_SHAPE_CAT						= 2;

local CRH_GLOBAL_COOLDOWN_VALUE			= 1.6;

local CRH_FAERIE_FIRE_SPELLID_LIST		=
{
	CRH_SPELLID_FAERIE_FIRE,
	CRH_SPELLID_FAERIE_SWARM
}

-- Frame IDs
local CRH_FRAME_TIGERSFURY				= 1;
local CRH_FRAME_CAT_UNUSED3				= 2;
local CRH_FRAME_SAVAGEROAR				= 3;
local CRH_FRAME_RAKE					= 4;
local CRH_FRAME_RIP						= 5;
local CRH_FRAME_BEAR_UNUSED5			= 6;
local CRH_FRAME_THRASH					= 7;
local CRH_FRAME_BEAR_MANGLE				= 8;
local CRH_FRAME_LACERATE				= 9;
local CRH_FRAME_BEAR_UNUSED4 			= 10;

local CRH_FRAME_BARKSKIN				= 1;
local CRH_FRAME_SURVINSTINCTS			= 2;
local CRH_FRAME_SURV_UNUSED3 			= 3;

-- change order of icons here
local g_CrhFrameOrderCat = {CRH_FRAME_TIGERSFURY, CRH_FRAME_SAVAGEROAR, CRH_FRAME_CAT_UNUSED3, CRH_FRAME_RAKE, CRH_FRAME_RIP}
local g_CrhFrameOrderBear = {CRH_FRAME_BEAR_MANGLE, CRH_FRAME_LACERATE, CRH_FRAME_THRASH, CRH_FRAME_BEAR_UNUSED4, CRH_FRAME_BEAR_UNUSED5}
local g_CrhFrameOrderSurv = {CRH_FRAME_SURV_UNUSED3, CRH_FRAME_SURVINSTINCTS, CRH_FRAME_BARKSKIN}

local g_CrhFramesMain = {};
local g_CrhFramesEvents = {};
local g_CrhFramesSurv = {};
local textures = {};
local blueTextures = {};
local survivalTextures = {};

local function crhPrintToChat(a_Text)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF008080CatRotationHelper:|r " .. a_Text);
end

local function GetImagePath(a_ImageName)
	return "Interface\\AddOns\\CatRotationHelper\\Images\\" .. a_ImageName;
end

local function InitFrames()
	-- Cat's Tiger's fury
	g_CrhFramesMain[CRH_FRAME_TIGERSFURY] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_TIGERSFURY] = GetImagePath("TigersFury.tga");
	blueTextures[CRH_FRAME_TIGERSFURY] = GetImagePath("TigersFury-Blue.tga");

	-- Cat's Unused3
	g_CrhFramesMain[CRH_FRAME_CAT_UNUSED3] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_CAT_UNUSED3] = nil;
	blueTextures[CRH_FRAME_CAT_UNUSED3] = nil;

	-- Cat's Savage Roar
	g_CrhFramesMain[CRH_FRAME_SAVAGEROAR] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_SAVAGEROAR] = GetImagePath("SavageRoar.tga");
	blueTextures[CRH_FRAME_SAVAGEROAR] = GetImagePath("SavageRoar-Blue.tga");

	-- Cat's Rake
	g_CrhFramesMain[CRH_FRAME_RAKE] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_RAKE] = GetImagePath("Rake.tga");
	blueTextures[CRH_FRAME_RAKE] = GetImagePath("Rake-Blue.tga");

	-- Cat's Rip
	g_CrhFramesMain[CRH_FRAME_RIP] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_RIP] = GetImagePath("Rip.tga");
	blueTextures[CRH_FRAME_RIP] = GetImagePath("Rip-Blue.tga");
	
	-- Bear's Unused5
	g_CrhFramesMain[CRH_FRAME_BEAR_UNUSED5] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_BEAR_UNUSED5] = nil;
	blueTextures[CRH_FRAME_BEAR_UNUSED5] = nil;
	
	-- Bear's Thrash
	g_CrhFramesMain[CRH_FRAME_THRASH] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_THRASH] = GetImagePath("Thrash.tga");
	blueTextures[CRH_FRAME_THRASH] = GetImagePath("Thrash-Blue.tga");

	-- Bear's Mangle
	g_CrhFramesMain[CRH_FRAME_BEAR_MANGLE] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_BEAR_MANGLE] = GetImagePath("Mangle.tga");
	blueTextures[CRH_FRAME_BEAR_MANGLE] = GetImagePath("Mangle-Blue.tga");

	-- Bear's Lacerate
	g_CrhFramesMain[CRH_FRAME_LACERATE] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_LACERATE] = GetImagePath("Lacerate.tga");
	blueTextures[CRH_FRAME_LACERATE] = GetImagePath("Lacerate-Blue.tga");

	-- Bear's Unused4
	g_CrhFramesMain[CRH_FRAME_BEAR_UNUSED4] = CreateFrame("Frame", nil, UIParent);
	textures[CRH_FRAME_BEAR_UNUSED4] = nil;
	blueTextures[CRH_FRAME_BEAR_UNUSED4] = nil;
	
	-- Survival: Barkskin
	g_CrhFramesSurv[CRH_FRAME_BARKSKIN] = CreateFrame("Frame", nil, UIParent);
	survivalTextures[CRH_FRAME_BARKSKIN] = GetImagePath("Barkskin.tga");

	-- Survival: Survival instincts
	g_CrhFramesSurv[CRH_FRAME_SURVINSTINCTS] = CreateFrame("Frame", nil, UIParent);
	survivalTextures[CRH_FRAME_SURVINSTINCTS] = GetImagePath("SurvivalInstincts.tga");

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
crhShowEnrage = true;

local function crhSpellName(a_SpellID)
	local spellName = GetSpellInfo(a_SpellID);

	if (not spellName) then
		-- Happens when abilities are removed in new patch
		crhPrintToChat("Spell not found : " .. a_SpellID);
	end

	return spellName;
end

local function crhGetTargetDebuffInfo(a_SpellID, a_MyOnly)
	local filter = "HARMFUL";
	if (a_MyOnly) then
		filter = "PLAYER|" .. filter;
	end
	
	local spellName = crhSpellName(a_SpellID);
	if (not spellName) then
		return nil;
	end
	
	local name, rank, icon, stacks, debuffType, duration, expTime = UnitAura("target", spellName, nil, filter);
	if (not name) then
		return nil;
	end

	return name, stacks, expTime;
end

local function crhGetDebuffExpiration(a_SpellID, a_Stacks, a_MyOnly)
	local name, stacks, expTime = crhGetTargetDebuffInfo(a_SpellID, a_MyOnly);
	if (not name) then
		return 0;
	end
	
	if (a_Stacks and (stacks ~= a_Stacks)) then
		return 0;
	end
	
	return expTime;
end

local function crhGetBuffExpiration(a_SpellID)
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
			CatRotationHelperCheckCatBuffs();
			CatRotationHelperCheckCatDebuffs();
			CatRotationHelperCheckCatCooldown()
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

		for i=1, #g_CrhFrameOrderBear do
			CatRotationFrameStopCounter(g_CrhFramesMain[g_CrhFrameOrderBear[i]]);
			g_CrhFramesMain[g_CrhFrameOrderBear[i]]:Hide()
		end
		CatRotationHelperLacerateCounter:Hide()
		CatRotationHelperSetBearCP(0)

	-- stop cat counters and cps
	elseif(showCat) then
		showCat = false

		for i=1, #g_CrhFrameOrderCat do
			CatRotationFrameStopCounter(g_CrhFramesMain[g_CrhFrameOrderCat[i]]);
		end

		CatRotationHelperSetCatCP(0)
	end

	-- interrupt previous fade
	CatRotationHelperFadeFrame:Hide();

	-- show static cat frames
	for i=1, #g_CrhFrameOrderCat do
		local frame = g_CrhFramesMain[g_CrhFrameOrderCat[i]]

		frame:Show();
		frame:SetAlpha(1);
		frame.icon:SetVertexColor(upcolor[1], upcolor[2], upcolor[3], upcolor[4]);
	end

	-- show static event frames
	eventList[1] = GetImagePath("Berserk.tga")
	eventList[2] = GetImagePath("FaerieFire.tga")
	eventList[3] = GetImagePath("FeralCharge.tga")
	eventList[4] = GetImagePath("PredatoryStrikes.tga")

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

function CrhSetTexture(a_Frame, a_Texture)
	if (not a_Texture) then
		return
	end

	a_Frame:SetTexture(a_Texture)
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

	for i=1, #g_CrhFramesMain do
		local frame = g_CrhFramesMain[i]

		frame:Hide()
		frame.icon:SetVertexColor(fadedcolor[1], fadedcolor[2], fadedcolor[3], fadedcolor[4]);
		CrhSetTexture(frame.icon, textures[i]);
		frame.countframe.durtext:SetTextColor(1.00, 1.00, 0.00);
		frame.countframe.dur2text:SetTextColor(1.00, 1.00, 0.00);
		frame.countframe:Hide();
		frame.cpicon:SetTexture(GetImagePath("Cp.tga"))
	end

	for i=1, #g_CrhFramesEvents do
		g_CrhFramesEvents[i]:Hide()
	end

	for i=1, #g_CrhFramesSurv do
		g_CrhFramesSurv[i]:Hide()
	end

	CatRotationHelperUpdateEverything()
end

-- shows num combo point circles using frames in framesTable
local function CatRotationHelperSetCPEffects(framesTable, num)
	for i=1, #framesTable do
		local frame = g_CrhFramesMain[framesTable[i]]

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

	CatRotationHelperSetCPEffects(g_CrhFrameOrderCat, num);
end

function CatRotationHelperSetBearCP(num)
	if(not crhLacCounter) then return; end

	CatRotationHelperSetCPEffects(g_CrhFrameOrderBear, num);
end


-- show all frames in frameTable
local function CatRotationHelperShowByFrame(frameTable)
	--if interrupting previous fade, hide frames
	for i=1, #g_CrhFramesMain do
		g_CrhFramesMain[i]:Hide();
	end

	for i=1, #frameTable do
		g_CrhFramesMain[frameTable[i]]:Show();
	end

	-- fade effect
	CatRotationHelperFadeFrame:Show();
	CatRotationHelperFadeFrame.fading = false;
	CatRotationHelperFadeFrame.startTime = GetTime();
end

function CatRotationHelperShowCat()
	if(showCat) then return; end
	showCat = true;

	CatRotationHelperShowByFrame(g_CrhFrameOrderCat);
end

function CatRotationHelperShowBear()
	if(showBear) then return; end
	showBear = true;

	CatRotationHelperShowByFrame(g_CrhFrameOrderBear);
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
	crhUpdateFrameWithExpiration(g_CrhFramesMain[a_FrameID], crhGetDebuffExpiration(a_SpellID, a_Stacks, a_MyOnly))
end

local function crhUpdateFrameFromBuff(a_FrameID, a_SpellID)
	crhUpdateFrameWithExpiration(g_CrhFramesMain[a_FrameID], crhGetBuffExpiration(a_SpellID))
end

local function crhUpdateFrameFromSkill(a_FrameID, a_SpellID)
	local spellStart, spellDuration = GetSpellCooldown(a_SpellID);
	if (spellStart == nil) then
		-- Forced reset; skill could be ready ahead of cd due to proc
		CatRotationFrameStopCounter(g_CrhFramesMain[a_FrameID]);
		return;
	end

	if (spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
		return;
	end
	
	CatRotationHelperUpdateFrame(g_CrhFramesMain[a_FrameID], spellStart + spellDuration)
end

function CatRotationFrameSetMainScale()
	for i=1, #g_CrhFramesMain do
		g_CrhFramesMain[i]:SetScale(crhScale);
		g_CrhFramesMain[i].parentFrame:SetScale(crhScale);
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
	for i=1, #g_CrhFramesMain do
		g_CrhFramesMain[i].parentFrame:ClearAllPoints()
	end

	local headerFrame = CatRotationHelperHeader;

	if(crhMainAngle == 0) then
		headerFrame:SetHeight(36)
		headerFrame:SetWidth(176)

		g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);
		g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);

		g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame, "TOPRIGHT", 5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame, "TOPRIGHT", 5, 0);

		g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame, "TOPRIGHT", 5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame, "TOPRIGHT", 5, 0);

		g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame, "TOPRIGHT", 5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame, "TOPRIGHT", 5, 0);

		g_CrhFramesMain[g_CrhFrameOrderCat[5]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame, "TOPRIGHT", 5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[5]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame, "TOPRIGHT", 5, 0);

	elseif(crhMainAngle == 90) then
		headerFrame:SetHeight(176)
		headerFrame:SetWidth(36)

		g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 3, 3);
		g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 3, 3);

		g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame, "TOPLEFT", 0, 5);
		g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame, "TOPLEFT", 0, 5);

		g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame, "TOPLEFT", 0, 5);
		g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame, "TOPLEFT", 0, 5);

		g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame, "TOPLEFT", 0, 5);
		g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame, "TOPLEFT", 0, 5);

		g_CrhFramesMain[g_CrhFrameOrderCat[5]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame, "TOPLEFT", 0, 5);
		g_CrhFramesMain[g_CrhFrameOrderBear[5]].parentFrame:SetPoint("BOTTOMLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame, "TOPLEFT", 0, 5);

	elseif(crhMainAngle == 180) then
		headerFrame:SetHeight(36)
		headerFrame:SetWidth(176)

		g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -3, -3);
		g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -3, -3);

		g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame, "TOPLEFT", -5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame, "TOPLEFT", -5, 0);

		g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame, "TOPLEFT", -5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame, "TOPLEFT", -5, 0);

		g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame, "TOPLEFT", -5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame, "TOPLEFT", -5, 0);

		g_CrhFramesMain[g_CrhFrameOrderCat[5]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame, "TOPLEFT", -5, 0);
		g_CrhFramesMain[g_CrhFrameOrderBear[5]].parentFrame:SetPoint("TOPRIGHT", g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame, "TOPLEFT", -5, 0);

	else
		headerFrame:SetHeight(176)
		headerFrame:SetWidth(36)

		g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);
		g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 3, -3);

		g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[1]].parentFrame, "BOTTOMLEFT", 0, -5);
		g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[1]].parentFrame, "BOTTOMLEFT", 0, -5);

		g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[2]].parentFrame, "BOTTOMLEFT", 0, -5);
		g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[2]].parentFrame, "BOTTOMLEFT", 0, -5);

		g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[3]].parentFrame, "BOTTOMLEFT", 0, -5);
		g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[3]].parentFrame, "BOTTOMLEFT", 0, -5);

		g_CrhFramesMain[g_CrhFrameOrderCat[5]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderCat[4]].parentFrame, "BOTTOMLEFT", 0, -5);
		g_CrhFramesMain[g_CrhFrameOrderBear[5]].parentFrame:SetPoint("TOPLEFT", g_CrhFramesMain[g_CrhFrameOrderBear[4]].parentFrame, "BOTTOMLEFT", 0, -5);
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
	local framesTable

	-- decide what frames to hide
	if(showBear) then
		showBear = false

		framesTable = g_CrhFrameOrderBear
		CatRotationHelperLacerateCounter:Hide()
		CatRotationHelperSetBearCP(0)
	elseif(showCat) then
		showCat = false

		framesTable = g_CrhFrameOrderCat
		CatRotationHelperSetCatCP(0)
	else
		return
	end

	-- stop running timers
	for i=1, #framesTable do
		CatRotationFrameStopCounter(g_CrhFramesMain[framesTable[i]]);
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

-----------------------------
-- Cat - Main Frame Checks --
-----------------------------

function CatRotationHelperCheckCatBuffs()
	crhUpdateFrameFromBuff(CRH_FRAME_SAVAGEROAR, CRH_SPELLID_SAVAGE_ROAR);
end

function CatRotationHelperCheckCatDebuffs()
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
		CatRotationFrameStopCounter(g_CrhFramesMain[CRH_FRAME_LACERATE]);
		CatRotationHelperLacerateCounter:Hide();
		CatRotationHelperSetBearCP(0);
		return;
	end
	
	CatRotationHelperUpdateFrame(g_CrhFramesMain[CRH_FRAME_LACERATE], expTime);

	-- stop possible cp animation when lacerate is refreshed
	local i = 1;
	for i=1, #g_CrhFrameOrderBear do
		g_CrhFramesMain[g_CrhFrameOrderBear[i]].cpframe:SetAlpha(1)
		g_CrhFramesMain[g_CrhFrameOrderBear[i]].cpframe:SetScale(1)
	end

	-- setup lacerate warning
	CatRotationHelperLacerateCounter:Show()
	CatRotationHelperLacerateCounter.expTime = expTime

	-- set cp effects
	CatRotationHelperSetBearCP(stacks);
end

function CatRotationHelperCheckBearDebuffs()
	crhUpdateLacerate();
end

function CatRotationHelperCheckBearCooldown()
	crhUpdateFrameFromSkill(CRH_FRAME_THRASH, CRH_SPELLID_THRASH);
	crhUpdateFrameFromSkill(CRH_FRAME_BEAR_MANGLE, CRH_SPELLID_MANGLE_BEAR);
end

-- Check for Clearcast procs - Bear & Cat
function CatRotationHelperCheckClearcast()
	name = UnitBuff("player", crhSpellName(CRH_SPELLID_CLEARCAST));
	if(name and crhEnableClearcast) then
		if(not clearCast) then
			for i=1, #g_CrhFramesMain do
				g_CrhFramesMain[i].cpicon:SetTexture(GetImagePath("Cp-Blue.tga"))
				CrhSetTexture(g_CrhFramesMain[i].icon, blueTextures[i]);
				CrhSetTexture(g_CrhFramesMain[i].overlay.icon, blueTextures[i]);

				if(g_CrhFramesMain[i].hascp) then
					g_CrhFramesMain[i].countframe.durtext:SetTextColor(0.40, 0.70, 0.95);
					g_CrhFramesMain[i].countframe.dur2text:SetTextColor(0.40, 0.70, 0.95);
				else
					g_CrhFramesMain[i].countframe.durtext:SetTextColor(0.50, 0.85, 1.00);
					g_CrhFramesMain[i].countframe.dur2text:SetTextColor(0.50, 0.85, 1.00);
				end
			end

			clearCast = true;
		end

	else
		if(clearCast) then
			for i=1,#g_CrhFramesMain do
				g_CrhFramesMain[i].cpicon:SetTexture(GetImagePath("Cp.tga"))
				CrhSetTexture(g_CrhFramesMain[i].icon, textures[i]);
				CrhSetTexture(g_CrhFramesMain[i].overlay.icon, textures[i]);

				if(g_CrhFramesMain[i].hascp) then
					g_CrhFramesMain[i].countframe.durtext:SetTextColor(0.90, 0.70, 0.00);
					g_CrhFramesMain[i].countframe.dur2text:SetTextColor(0.90, 0.70, 0.00);
				else
					g_CrhFramesMain[i].countframe.durtext:SetTextColor(1.00, 1.00, 0.00);
					g_CrhFramesMain[i].countframe.dur2text:SetTextColor(1.00, 1.00, 0.00);
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
		local expTime = crhGetBuffExpiration(a_BuffId);
		if (0 ~= expTime) then
			eventList[a_FrameID] = GetImagePath(a_Image)
			eventTimers[a_FrameID] = expTime
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
		eventList[a_FrameID] = GetImagePath(a_Image)
		eventTimers[a_FrameID] = nil
		return;
	end
	
	-- Prevent blinking on GCD
	if (spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
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
	
	local expTime = crhGetBuffExpiration(a_SpellID);
	if (0 == expTime) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end
	
	-- On proc, show notification
	crhSetNotificationEffects(a_FrameID, a_ShowEffects);
	eventList[a_FrameID] = GetImagePath(a_Image)
	eventTimers[a_FrameID] = expTime
end

local function crhUpdateNotificationDebuff(a_IsEnabled, a_FrameID, a_SpellID_List, a_Image, a_ShowEffects)
	if (not a_IsEnabled) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end
	
	local expTime = 0;
	for i = 1, #a_SpellID_List do
		local currExpTime = crhGetDebuffExpiration(a_SpellID_List[i]);
		expTime = max(expTime, currExpTime);
	end
	
	-- Has debuff, no notification needed
	if (0 ~= expTime) then
		crhResetNotificationFrame(a_FrameID);
		return;
	end
	
	-- No debuff, show notification
	crhSetNotificationEffects(a_FrameID, a_ShowEffects);
	eventList[a_FrameID] = GetImagePath(a_Image)
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
	if (spellDuration < CRH_GLOBAL_COOLDOWN_VALUE) then
		return;
	end

	survivalCdTimers[a_FrameID] = spellDuration + spellStart
	CatRotationHelperCdCounter:Show()

	local expTime = crhGetBuffExpiration(a_SpellID);
	if (0 ~= expTime) then
		showEventIcon(g_CrhFramesSurv[a_FrameID])
		g_CrhFramesSurv[a_FrameID].countframe.endTime = expTime
		g_CrhFramesSurv[a_FrameID].countframe:Show()
	else
		hideEventIcon(g_CrhFramesSurv[a_FrameID])
	end
end

-- Survival Frame - Bear & Cat
function CatRotationHelperUpdateSurvival(a_ShowEffects)
	if ((crhShowCatSurvival and inCatForm) or (crhShowBearSurvival and inBearForm)) then
		crhUpdateSurvivalFrame(CRH_FRAME_BARKSKIN, CRH_SPELLID_BARKSKIN, a_ShowEffects);
		crhUpdateSurvivalFrame(CRH_FRAME_SURVINSTINCTS, CRH_SPELLID_SURVIVAL_INSTINCTS, a_ShowEffects);
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

	-- setup frames
	for i=1, #g_CrhFramesMain do
		local frame = g_CrhFramesMain[i]

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
		CrhSetTexture(frame.icon, textures[i]);

		-- buff fade/gain effects
		frame.overlay = CreateFrame("Frame", "CatRotationHelperFrameAlert" .. i, frame, "CatRotationHelperEventAlert")
		CrhSetTexture(frame.overlay.icon, textures[i]);
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
	for i=1, #g_CrhFramesEvents do
		local event = g_CrhFramesEvents[i]
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
	for i=1, #g_CrhFramesSurv do
		local event = g_CrhFramesSurv[i]
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
		CrhSetTexture(event.overlay.icon, survivalTextures[i]);
		event.overlay.icon:SetBlendMode("ADD");
		event.overlay:SetSize(28*1.5, 28*1.5)
		event.overlay:SetPoint("TOPLEFT", event, "TOPLEFT", -28*0.25, 28*0.25)
		event.overlay:SetPoint("BOTTOMRIGHT", event, "BOTTOMRIGHT", 28*0.25, -28*0.25)
		
		event.icon = event:CreateTexture(nil,"ARTWORK")
		event.icon:SetAllPoints(event)
		event.icon:SetVertexColor(upcolor[1], upcolor[2], upcolor[3], upcolor[4]);
		CrhSetTexture(event.icon, survivalTextures[i]);

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
		for i=1, #g_CrhFrameOrderBear do
			g_CrhFramesMain[g_CrhFrameOrderBear[i]].cpframe:SetAlpha(1.0-t)
			g_CrhFramesMain[g_CrhFrameOrderBear[i]].cpframe:SetScale(1.0+0.3*t)
		end
	else
		for i=1, #g_CrhFrameOrderBear do
			g_CrhFramesMain[g_CrhFrameOrderBear[i]].cpframe:SetAlpha(t)
			g_CrhFramesMain[g_CrhFrameOrderBear[i]].cpframe:SetScale(1.3-0.3*t)
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
			for i=1, #g_CrhFramesMain do
				g_CrhFramesMain[i]:Hide();
			end
		end
	end

	if(self.fading) then
		for i=1, #g_CrhFramesMain do
			g_CrhFramesMain[i]:SetAlpha(1-elapsed*2.5);
		end
	else
		for i=1, #g_CrhFramesMain do
			g_CrhFramesMain[i]:SetAlpha(elapsed*2.5);
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
