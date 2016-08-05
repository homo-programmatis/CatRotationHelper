local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

function g_Addon.SettingsUI_Initialize()
	CatRotationHelper_DlgOptions.name = "CatRotationHelper"
	InterfaceOptions_AddCategory(CatRotationHelper_DlgOptions);

	------------------------------------------------------------

	CatRotationHelper_SldOptionsMainScaleText:SetText("Main Frame scale");
	CatRotationHelper_SldOptionsMainScale:SetScript("OnValueChanged", g_Addon.SettingsUI_SldOptionsMainScale_OnValueChanged);

	CatRotationHelper_SldOptionsEvntScaleText:SetText("Notification Frame scale");
	CatRotationHelper_SldOptionsEvntScale:SetScript("OnValueChanged", g_Addon.SettingsUI_SldOptionsEvntScale_OnValueChanged);

	CatRotationHelper_SldOptionsSurvScaleText:SetText("Survival Frame scale");
	CatRotationHelper_SldOptionsSurvScale:SetScript("OnValueChanged", g_Addon.SettingsUI_SldOptionsSurvScale_OnValueChanged);
end

function g_Addon.SettingsUI_Load()
	CatRotationHelper_SldOptionsMainScale:SetValue(g_Addon.Settings.Frames[1].Scale)
	CatRotationHelper_SldOptionsMainScaleValue:SetText(math.floor(g_Addon.Settings.Frames[1].Scale*100+0.5)/100)
	CatRotationHelper_SldOptionsEvntScale:SetValue(g_Addon.Settings.Frames[2].Scale)
	CatRotationHelper_SldOptionsEvntScaleValue:SetText(math.floor(g_Addon.Settings.Frames[2].Scale*100+0.5)/100)
	CatRotationHelper_SldOptionsSurvScale:SetValue(g_Addon.Settings.Frames[3].Scale)
	CatRotationHelper_SldOptionsSurvScaleValue:SetText(math.floor(g_Addon.Settings.Frames[3].Scale*100+0.5)/100)
end

function g_Addon.SettingsUI_SldOptionsMainScale_OnValueChanged(self)
	local frameBox = g_Addon.FrameBoxes[1];
	local settings = g_Addon.Settings.Frames[frameBox.m_Index];

	settings.Scale = math.floor(self:GetValue()*100+0.5)/100;
	CatRotationHelper_SldOptionsMainScaleValue:SetText(settings.Scale);
	
	g_Addon.FrameBox_LoadSettings(frameBox);
end

function g_Addon.SettingsUI_SldOptionsEvntScale_OnValueChanged(self)
	local frameBox = g_Addon.FrameBoxes[2];
	local settings = g_Addon.Settings.Frames[frameBox.m_Index];

	settings.Scale = math.floor(self:GetValue()*100+0.5)/100;
	CatRotationHelper_SldOptionsEvntScaleValue:SetText(settings.Scale);
	
	g_Addon.FrameBox_LoadSettings(frameBox);
end

function g_Addon.SettingsUI_SldOptionsSurvScale_OnValueChanged(self)
	local frameBox = g_Addon.FrameBoxes[3];
	local settings = g_Addon.Settings.Frames[frameBox.m_Index];

	settings.Scale = math.floor(self:GetValue()*100+0.5)/100;
	CatRotationHelper_SldOptionsSurvScaleValue:SetText(settings.Scale);
	
	g_Addon.FrameBox_LoadSettings(frameBox);
end
