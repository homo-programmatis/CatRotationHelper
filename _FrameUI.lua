local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

function g_Module.FrameSetTexture(a_Frame, a_Texture, a_MakeRound)
	if (not a_Texture) then
		return
	end

	if (not a_MakeRound) then
		a_Frame.icon:SetTexture(a_Texture);
		a_Frame.overlay.icon:SetTexture(a_Texture);
	else
		SetPortraitToTexture(a_Frame.icon, a_Texture);
		SetPortraitToTexture(a_Frame.overlay.icon, a_Texture);
	end
end

function g_Module.FrameDrawFaded(a_Frame)
	a_Frame.icon:SetVertexColor(0.35, 0.35, 0.35, 0.70);
end

function g_Module.FrameDrawActive(a_Frame)
	a_Frame.icon:SetVertexColor(1.00, 1.00, 1.00, 1.00);
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
function g_Module.FramesSetPosition(a_Frames, a_Box, a_Angle)
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

function g_Module.FrameSetStatus(a_Frame, a_Status, a_Expiration, a_ShowEffects)
	local logic = a_Frame.m_CrhLogic;
	if (nil == logic.Type) then
		-- Empty frame
		return;
	end
	
	if ((a_Frame.LastStatus == a_Status) and (a_Frame.LastExpiration == a_Expiration)) then
		return;
	end

	if (g_Consts.STATUS_READY == a_Status) then
		g_Module.FrameDrawFaded(a_Frame);

		a_Frame.countframe:Hide();
		a_Frame.countframe.endTime = nil;

		if (a_ShowEffects) then
			a_Frame.overlay.animOut:Play();
		end
	elseif (g_Consts.STATUS_COUNTING == a_Status) then
		g_Module.FrameDrawActive(a_Frame);

		a_Frame.countframe.endTime = a_Expiration
		a_Frame.countframe:Show()
		a_Frame.countframe.dur2text:Show();
		a_Frame.countframe.durtext:SetText("");

		if (a_ShowEffects) then
			a_Frame.overlay.animIn:Play();
		end
	end

	a_Frame.LastStatus = a_Status;
	a_Frame.LastExpiration = a_Expiration;
end
