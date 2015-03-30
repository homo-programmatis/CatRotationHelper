local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];

function g_Module.FrameSetTexture(a_Frame, a_Texture)
	if (not a_Texture) then
		return
	end

	local testID = 3;
	
	if (0 == testID) then
		-- default texture
		a_Frame:SetTexture(a_Texture)
	elseif (1 == testID) then
		-- working
		a_Frame:SetTexture("Interface\\ICONS\\Ability_Druid_Berserk");
		a_Frame:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMaskSmall.blp");
	elseif (2 == testID) then
		-- not working
		-- also not working even if you add this line to TOC: Images\TempPortraitAlphaMaskSmall.blp
		a_Frame:SetTexture("Interface\\ICONS\\Ability_Druid_Berserk");
		a_Frame:SetMask(g_Module.GetMyImage("TempPortraitAlphaMaskSmall.blp"));
	elseif (3 == testID) then
		-- crashes (invalid usage of Texture:SetMask)
		a_Frame:SetTexture("Interface\\ICONS\\Ability_Druid_Berserk");

		local maskTexture = a_Frame:GetParent():CreateTexture();
		maskTexture:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMaskSmall.blp");

		a_Frame:SetMask(maskTexture);
	end
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
