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

function g_Module.FrameSetStatus(a_Frame, a_Status, a_Expiration)
	local logic = a_Frame.m_CrhLogic;
	if (nil == logic.Type) then
		-- Empty frame
		return;
	end
	
	if (g_Consts.STATUS_READY == a_Status) then
		if (not a_Frame.counting) then
			return;
		end

		a_Frame.counting = false
		a_Frame.countframe:Hide();
		a_Frame.countframe.endTime = nil;
		g_Module.FrameDrawFaded(a_Frame.icon);
		a_Frame.overlay.animOut:Play()
	elseif (g_Consts.STATUS_COUNTING == a_Status) then
		if (a_Frame.counting and (a_Expiration == a_Frame.countframe.endTime)) then
			return;
		end
		
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
