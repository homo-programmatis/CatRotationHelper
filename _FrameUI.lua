local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

function g_Module.FrameSetTexture(a_Frame, a_Texture)
	if (not a_Texture) then
		return
	end

	a_Frame:SetTexture(a_Texture)
end

function g_Module.FrameDrawFaded(a_Frame)
	a_Frame:SetVertexColor(0.35, 0.35, 0.35, 0.70);
end

function g_Module.FrameDrawActive(a_Frame)
	a_Frame:SetVertexColor(1.00, 1.00, 1.00, 1.00);
end

function g_Module.FrameStopTimer(a_Frame)
	if (not a_Frame.counting) then
		return;
	end

	a_Frame.counting = false
	a_Frame.countframe:Hide();
	a_Frame.countframe.endTime = nil;
	g_Module.FrameDrawFaded(a_Frame.icon);
	a_Frame.overlay.animOut:Play()
end

function g_Module.FrameSetExpiration(a_Frame, a_Expiration)
	if (a_Expiration == 0) then
		g_Module.FrameStopTimer(a_Frame);
		return;
	end
	
    if (not a_Frame.counting or a_Expiration ~= a_Frame.countframe.endTime) then
    	-- new buff applied
		if(not a_Frame.counting or a_Frame.countframe.endTime - GetTime() < 11) then
			a_Frame.overlay.animIn:Play()
		end
		
		a_Frame.counting = true
		g_Module.FrameDrawActive(a_Frame.icon);

    	a_Frame.countframe.endTime = a_Expiration
    	a_Frame.countframe:Show()
		a_Frame.countframe.dur2text:Show();
		a_Frame.countframe.durtext:SetText("");
	end
end
