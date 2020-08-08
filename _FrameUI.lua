local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

function g_Addon.FrameCreateNew(a_FrameName)
	local newFrame = CreateFrame("Frame", a_FrameName, UIParent);
	g_Addon.FrameCreateComponents(newFrame, a_FrameName);
	g_Addon.FrameReset(newFrame);

	return newFrame;
end

function g_Addon.FrameCreateComponents(a_Frame, a_FrameName)
	a_Frame:SetSize(g_Consts.UI_SIZE_FRAME, g_Consts.UI_SIZE_FRAME);
	a_Frame:Hide();

	a_Frame.FrameCombo = CreateFrame("Frame", a_FrameName .. "Combo", a_Frame);
	a_Frame.FrameCombo:SetFrameStrata("BACKGROUND");
	a_Frame.FrameCombo:SetPoint("CENTER");
	a_Frame.FrameCombo:SetSize(g_Consts.UI_SIZE_FRAME * 1.13, g_Consts.UI_SIZE_FRAME * 1.13);

	a_Frame.FrameCombo.IconCombo = a_Frame.FrameCombo:CreateTexture(nil, "BACKGROUND");
	a_Frame.FrameCombo.IconCombo:SetAllPoints(a_Frame.FrameCombo);

	a_Frame.IconSpell = a_Frame:CreateTexture(nil, "ARTWORK");
	a_Frame.IconSpell:SetAllPoints(a_Frame);

	-- buff fade/gain effects
	local overlayOffs = g_Consts.UI_SIZE_FRAME * 0.20;
	a_Frame.FrameOverlay = CreateFrame("Frame", a_FrameName .. "Overlay", a_Frame, "CatRotationHelper_FrameBaseOverlay");
	a_Frame.FrameOverlay.IconSpell:SetBlendMode("ADD");
	a_Frame.FrameOverlay:SetPoint("TOPLEFT", a_Frame, "TOPLEFT", -overlayOffs, overlayOffs);
	a_Frame.FrameOverlay:SetPoint("BOTTOMRIGHT", a_Frame, "BOTTOMRIGHT", overlayOffs, -overlayOffs);

	a_Frame.FrameTimer = CreateFrame("Frame", a_FrameName .. "Timer", a_Frame);
	a_Frame.FrameTimer:SetScript("OnUpdate", g_Addon.FrameTimer_OnUpdate);

	a_Frame.FrameTimer.TextTime = a_Frame.FrameTimer:CreateFontString(nil, "OVERLAY", "CatRotationHelper_Font_Normal");
	a_Frame.FrameTimer.TextTime:SetPoint("CENTER", a_Frame, "CENTER", 0, 0);
	a_Frame.FrameTimer.TextStar = a_Frame.FrameTimer:CreateFontString(nil, "OVERLAY", "CatRotationHelper_Font_Bigger");
	a_Frame.FrameTimer.TextStar:SetPoint("CENTER", a_Frame, "CENTER", 0, -5);
	a_Frame.FrameTimer.TextStar:SetText("*");
end

function g_Addon.FrameReset(a_Frame)
	a_Frame.LastStatus     = nil;
	a_Frame.LastExpiration = nil;

	a_Frame.m_IsCombo      = false;
	a_Frame.m_IsClearcast  = false;

	a_Frame.FrameCombo:Hide();
	a_Frame.FrameCombo:SetScript("OnUpdate", nil);
	a_Frame.FrameCombo.IconCombo:SetTexture(g_Addon.GetMyImage("Cp.tga"));

	a_Frame.FrameTimer:Hide();
	a_Frame.FrameTimer.endTime = nil;

	a_Frame.FrameTimer.TextTime:Hide();
	a_Frame.FrameTimer.TextStar:Hide();
	g_Addon.FrameUpdateTimerColor(a_Frame, false, false);
end

function g_Addon.FrameSetClearcast(a_Frame, a_IsClearcast)
	if (a_Frame.m_IsClearcast == a_IsClearcast) then
		return;
	end

	a_Frame.m_IsClearcast = a_IsClearcast;
	g_Addon.FrameUpdateTimerColor(a_Frame, a_Frame.m_IsClearcast, a_Frame.m_IsCombo);

	if (a_IsClearcast) then
		a_Frame.FrameCombo.IconCombo:SetTexture(g_Addon.GetMyImage("Cp-Blue.tga"))
		g_Addon.FrameSetTexture(a_Frame, a_Frame.m_CrhLogic.TextureSpecial);
	else
		a_Frame.FrameCombo.IconCombo:SetTexture(g_Addon.GetMyImage("Cp.tga"))
		g_Addon.FrameSetTexture(a_Frame, a_Frame.m_CrhLogic.Texture);
	end
end

function g_Addon.EffectComboPoint(a_FrameCombo)
	local elapsed = GetTime() - a_FrameCombo.m_EffectStartTime;

	if (elapsed >= 0.4) then
		if(a_FrameCombo.m_EffectIsReverse) then
			a_FrameCombo:Hide();
		else
			a_FrameCombo:SetScale(1);
			a_FrameCombo:SetAlpha(1);
			a_FrameCombo:SetScript("OnUpdate", nil);
		end

		return;
	end

	if (a_FrameCombo.m_EffectIsReverse) then
		elapsed = 0.4 - elapsed;
	end

	a_FrameCombo:SetScale(1.3 - elapsed*0.75);
	a_FrameCombo:SetAlpha(elapsed*2.5);
end

function g_Addon.FrameSetCombo(a_Frame, a_IsCombo)
	if (a_IsCombo == a_Frame.m_IsCombo) then
		return;
	end

	a_Frame.m_IsCombo = a_IsCombo;

	g_Addon.FrameUpdateTimerColor(a_Frame, a_Frame.m_IsClearcast, a_Frame.m_IsCombo);

	a_Frame.FrameCombo:SetScript("OnUpdate", g_Addon.EffectComboPoint);
	a_Frame.FrameCombo.m_EffectStartTime = GetTime();
	a_Frame.FrameCombo.m_EffectIsReverse = not a_IsCombo;

	if (a_IsCombo) then
		a_Frame.FrameCombo:Show();
	end
end

function g_Addon.FrameSetTexture(a_Frame, a_Texture, a_MakeRound)
	if (not a_Texture) then
		a_Frame.IconSpell:SetTexture(nil);
		a_Frame.FrameOverlay.IconSpell:SetTexture(nil);
		return;
	end

	if (not a_MakeRound) then
		a_Frame.IconSpell:SetTexture(a_Texture);
		a_Frame.FrameOverlay.IconSpell:SetTexture(a_Texture);
	else
		SetPortraitToTexture(a_Frame.IconSpell, a_Texture);
		SetPortraitToTexture(a_Frame.FrameOverlay.IconSpell, a_Texture);
	end
end

function g_Addon.FrameUpdateTimerColor(a_Frame, a_IsClearcast, a_IsCombo)
	if (a_IsClearcast) then
		if (a_IsCombo) then
			a_Frame.FrameTimer.TextTime:SetTextColor(0.40, 0.70, 0.95);
			a_Frame.FrameTimer.TextStar:SetTextColor(0.40, 0.70, 0.95);
		else
			a_Frame.FrameTimer.TextTime:SetTextColor(0.50, 0.85, 1.00);
			a_Frame.FrameTimer.TextStar:SetTextColor(0.50, 0.85, 1.00);
		end
	else
		if (a_IsCombo) then
			a_Frame.FrameTimer.TextTime:SetTextColor(0.90, 0.70, 0.00);
			a_Frame.FrameTimer.TextStar:SetTextColor(0.90, 0.70, 0.00);
		else
			a_Frame.FrameTimer.TextTime:SetTextColor(1.00, 1.00, 0.00);
			a_Frame.FrameTimer.TextStar:SetTextColor(1.00, 1.00, 0.00);
		end
	end
end

function g_Addon.FrameDrawInvisible(a_Frame)
	a_Frame.IconSpell:SetVertexColor(0.00, 0.00, 0.00, 0.00);
end

function g_Addon.FrameDrawFaded(a_Frame)
	a_Frame.IconSpell:SetVertexColor(0.35, 0.35, 0.35, 0.70);
end

function g_Addon.FrameDrawActive(a_Frame)
	a_Frame.IconSpell:SetVertexColor(1.00, 1.00, 1.00, 1.00);
end

local function MathRound(a_Value, a_Digits)
	local multiplier = 10^a_Digits;
	local overflow   = 0.5; if (a_Value < 0) then overflow = -0.5 end;
	local integer, _ = math.modf(multiplier*a_Value + overflow);
	return integer / multiplier;
end

local function RotateVector(a_X, a_Y, a_Angle)
	local radius  = math.sqrt(a_X*a_X + a_Y*a_Y);
	local angle   = math.atan2(a_Y, a_X);

	local newX    = radius * math.cos(angle + a_Angle);
	local newY    = radius * math.sin(angle + a_Angle);

	return newX, newY;
end

-- \param a_FrameX		- Frame's X coord expressed in frames (growing right)
-- \param a_FramesCX	- Total number of frames along X
-- \param a_FrameY		- Frame's Y coord expressed in frames (growing down)
-- \param a_FramesCY	- Total number of frames along Y
-- \param a_Angle		- Angle, in radians
-- \return X,Y			- Frame's CENTER point coords, expressed in WoW units
local function GetFrameCoords(a_FrameX, a_FramesCX, a_FrameY, a_FramesCY, a_Angle)
	local wowFrameOff = g_Consts.UI_SIZE_FRAME + g_Consts.UI_SIZE_FRAME_MARGIN;

	local cxTotal2 = wowFrameOff * (a_FramesCX-1) / 2;
	local cyTotal2 = wowFrameOff * (a_FramesCY-1) / 2;

	local x_0deg   =  ((a_FrameX * wowFrameOff) - cxTotal2);
	local y_0deg   = -((a_FrameY * wowFrameOff) - cyTotal2);

	local x_angle, y_angle = RotateVector(x_0deg, y_0deg, a_Angle);
	return x_angle, y_angle;
end

-- \param a_FramesCX	- Total number of frames along X
-- \param a_FramesCY	- Total number of frames along Y
-- \param a_Angle		- Angle, in radians
local function BoxSetPosition(a_Box, a_FramesCX, a_FramesCY, a_Angle)
	local x_0deg  = a_FramesCX*g_Consts.UI_SIZE_FRAME + (a_FramesCX+1)*g_Consts.UI_SIZE_FRAME_MARGIN;
	local y_0deg  = a_FramesCY*g_Consts.UI_SIZE_FRAME + (a_FramesCY+1)*g_Consts.UI_SIZE_FRAME_MARGIN;

	local cx, cy = RotateVector(x_0deg, y_0deg, a_Angle);
	cx = MathRound(math.abs(cx), 0);
	cy = MathRound(math.abs(cy), 0);

	a_Box:SetWidth (cx);
	a_Box:SetHeight(cy);
end

-- \param a_Frames		- Frame list to reposition
-- \param a_Box			- Group box for frames. Affects group position.
-- \param a_Angle		- Angle, in degrees (0deg = 3hours, 90deg = 0hours, 180deg = 9hours, 270deg = 6hours)
function g_Addon.FramesSetPosition(a_Frames, a_Box, a_Angle)
	a_Angle = math.rad(a_Angle);

	local framesCX = #a_Frames;
	local framesCY = 1;

	-- Set group size
	BoxSetPosition(a_Box, framesCX, framesCY, a_Angle);

	-- Set frame positions
	for i=1, #a_Frames do
		local frame  = a_Frames[i];

		local frameAlongX = i - 1;
		local frameAlongY = 0;

		local x, y = GetFrameCoords(frameAlongX, framesCX, frameAlongY, framesCY, a_Angle);
		x = MathRound(x, 0);
		y = MathRound(y, 0);

		frame:ClearAllPoints();
		frame:SetPoint("CENTER", a_Box, "CENTER", x, y);
	end
end

function g_Addon.FrameBox_LoadSettings(a_FrameBox)
	local settings = g_Addon.Settings.Frames[a_FrameBox.m_Index];
	local frameList = g_Addon.FrameLists[a_FrameBox.m_Index];

	-- Location
	a_FrameBox:ClearAllPoints();
	a_FrameBox:SetPoint(settings.LocationFrmPoint, UIParent, settings.LocationScrPoint, settings.LocationX, settings.LocationY);

	-- Angle
	g_Addon.FramesSetPosition(frameList, a_FrameBox, settings.Angle);

	-- Scale
	for _, frame in pairs(frameList) do
		frame:SetScale(settings.Scale);
	end

	a_FrameBox:SetScale(settings.Scale);
end

function g_Addon.FrameBox_SaveSettings(a_FrameBox)
	local settings = g_Addon.Settings.Frames[a_FrameBox.m_Index];

	local locationFrmPoint, _, locationScrPoint, locationX, locationY = a_FrameBox:GetPoint();
	settings.LocationX = locationX;
	settings.LocationY = locationY;
	settings.LocationFrmPoint = locationFrmPoint;
	settings.LocationScrPoint = locationScrPoint;
end

function g_Addon.FrameBoxes_LoadSettings()
	for _, frameBox in pairs(g_Addon.FrameBoxes) do
		g_Addon.FrameBox_LoadSettings(frameBox);
	end
end

function g_Addon.FrameBox_OnClick(a_FrameBox)
	local settings = g_Addon.Settings.Frames[a_FrameBox.m_Index];

	settings.Angle = (settings.Angle + 90) % 360;
	g_Addon.FrameBox_LoadSettings(a_FrameBox);
end

function g_Addon.FrameBox_OnDragStop(a_FrameBox)
	a_FrameBox:StopMovingOrSizing();
	g_Addon.FrameBox_SaveSettings(a_FrameBox);
end

function g_Addon.FrameTimer_FormatTime(a_Time)
	if (a_Time >= 60) then
		return ceil(a_Time / 60) .. "m";
	elseif (a_Time >= 1) then
		return floor(a_Time);
	else
		return "." .. floor(a_Time * 10);
	end
end

function g_Addon.FrameTimer_OnUpdate(a_FrameTimer)
	local remainingTime = a_FrameTimer.endTime - GetTime();

	if (remainingTime <= 0) then
		g_Addon.FrameSetStatus(a_FrameTimer:GetParent(), g_Consts.STATUS_READY, nil, true);
	elseif (remainingTime <= g_Consts.MAX_TIMER_SECS) then
		a_FrameTimer.TextTime:SetText(g_Addon.FrameTimer_FormatTime(remainingTime));
		a_FrameTimer.TextTime:Show();
		a_FrameTimer.TextStar:Hide();
	else
		a_FrameTimer.TextTime:Hide();
		a_FrameTimer.TextStar:Show();
	end
end

function g_Addon.FrameShowTimer(a_Frame, a_Expiration)
	a_Frame.FrameTimer.endTime = a_Expiration;
	g_Addon.FrameTimer_OnUpdate(a_Frame.FrameTimer);
	a_Frame.FrameTimer:SetScript("OnUpdate", g_Addon.FrameTimer_OnUpdate);
	a_Frame.FrameTimer:Show();
end

function g_Addon.FrameShowText(a_Frame, a_Text)
	a_Frame.FrameTimer.TextTime:SetText(a_Text);
	a_Frame.FrameTimer.TextTime:Show();
	a_Frame.FrameTimer:SetScript("OnUpdate", nil);
	a_Frame.FrameTimer:Show();
end

function g_Addon.FrameSetStatus(a_Frame, a_Status, a_Expiration, a_ShowEffects)
	local logic = a_Frame.m_CrhLogic;
	if (nil == logic.Type) then
		-- Empty frame
		return;
	end

	if ((a_Frame.LastStatus == a_Status) and (a_Frame.LastExpiration == a_Expiration)) then
		return;
	end

	if (g_Consts.STATUS_READY == a_Status) then
		g_Addon.FrameDrawFaded(a_Frame);
		a_Frame.FrameTimer:Hide();

		if (a_ShowEffects) then
			a_Frame.FrameOverlay.animOut:Play();
		end
	elseif (g_Consts.STATUS_COUNTING == a_Status) then
		g_Addon.FrameDrawActive(a_Frame);
		g_Addon.FrameShowTimer(a_Frame, a_Expiration);

		if (a_ShowEffects) then
			a_Frame.FrameOverlay.animIn:Play();
		end
	elseif (g_Consts.STATUS_BURSTING == a_Status) then
		g_Addon.FrameDrawFaded(a_Frame);
		g_Addon.FrameShowTimer(a_Frame, a_Expiration);

		if (a_ShowEffects) then
			a_Frame.FrameOverlay.animIn:Play();
		end
	elseif (g_Consts.STATUS_WAITING == a_Status) then
		g_Addon.FrameDrawActive(a_Frame);
		g_Addon.FrameShowText(a_Frame, "?");
	elseif (g_Consts.STATUS_PROC == a_Status) then
		g_Addon.FrameDrawFaded(a_Frame);
		g_Addon.FrameShowTimer(a_Frame, a_Expiration);

		if (a_ShowEffects) then
			a_Frame.FrameOverlay.animIn:Play();
		end
	end

	a_Frame.LastStatus = a_Status;
	a_Frame.LastExpiration = a_Expiration;
end
