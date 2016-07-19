local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

function g_Module.SettingsUI_Initialize()
	CatRotationHelper_DlgOptions.name = "CatRotationHelper"
	InterfaceOptions_AddCategory(CatRotationHelper_DlgOptions);

	------------------------------------------------------------

	CatRotationHelper_ChkOptionsCatText:SetText("Enable Cat Frames");
	CatRotationHelper_ChkOptionsCat:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsCat_OnClick);

	CatRotationHelper_ChkOptionsClearcastText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsClearcastText:SetText("Show Clearcast procs");
	CatRotationHelper_ChkOptionsClearcast:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsClearcast_OnClick);
	CatRotationHelper_ChkOptionsClearcast.tooltipText = "Icons turn blue during a Clearcast proc";

	CatRotationHelper_ChkOptionsCatComboText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsCatComboText:SetText("Show Combo Points");
	CatRotationHelper_ChkOptionsCatCombo:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsCatCombo_OnClick);

	CatRotationHelper_ChkOptionsCatBerserkText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsCatBerserkText:SetText("Berserk reminder");
	CatRotationHelper_ChkOptionsCatBerserk.tooltipText = "Shows an icon in the Notification Frame when Berserk is ready";
	CatRotationHelper_ChkOptionsCatBerserk:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsCatBerserk_OnClick);

	CatRotationHelper_ChkOptionsCatPredatorsText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsCatPredatorsText:SetText("Show Predator's Swiftness");
	CatRotationHelper_ChkOptionsCatPredators.tooltipText = "Shows an icon in the Notification Frame during a Predator's Swiftness proc";
	CatRotationHelper_ChkOptionsCatPredators:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsCatPredators_OnClick);

	CatRotationHelper_ChkOptionsCatChargeText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsCatChargeText:SetText("Wild Charge reminder");
	CatRotationHelper_ChkOptionsCatCharge.tooltipText = "Shows an icon in the Notification Frame when Wild Charge is ready";
	CatRotationHelper_ChkOptionsCatCharge:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsCatCharge_OnClick);

	CatRotationHelper_ChkOptionsCatSurvivalText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsCatSurvivalText:SetText("Show Survival Frame");
	CatRotationHelper_ChkOptionsCatSurvival.tooltipText = "Show Survival Frame in Cat Form";
	CatRotationHelper_ChkOptionsCatSurvival:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsCatSurvival_OnClick);

	------------------------------------------------------------

	CatRotationHelper_ChkOptionsBearText:SetText("Enable Bear Frames");
	CatRotationHelper_ChkOptionsBear:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsBear_OnClick);

	CatRotationHelper_ChkOptionsBearLacerateText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsBearLacerateText:SetText("Show Lacerate counter");
	CatRotationHelper_ChkOptionsBearLacerate:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsBearLacerate_OnClick);

	CatRotationHelper_ChkOptionsBearBerserkText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsBearBerserkText:SetText("Berserk reminder");
	CatRotationHelper_ChkOptionsBearBerserk.tooltipText = "Shows an icon in the Notification Frame when Berserk is ready";
	CatRotationHelper_ChkOptionsBearBerserk:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsBearBerserk_OnClick);

	CatRotationHelper_ChkOptionsBearSurvivalText:SetTextColor(1,1,1);
	CatRotationHelper_ChkOptionsBearSurvivalText:SetText("Show Survival Frame");
	CatRotationHelper_ChkOptionsBearSurvival.tooltipText = "Show Survival Frame in Bear Form";
	CatRotationHelper_ChkOptionsBearSurvival:SetScript("OnClick", g_Module.SettingsUI_ChkOptionsBearSurvival_OnClick);

	------------------------------------------------------------

	CatRotationHelper_SldOptionsMainScaleText:SetText("Main Frame scale");
	CatRotationHelper_SldOptionsMainScale:SetScript("OnValueChanged", g_Module.SettingsUI_SldOptionsMainScale_OnValueChanged);

	CatRotationHelper_SldOptionsEvntScaleText:SetText("Notification Frame scale");
	CatRotationHelper_SldOptionsEvntScale:SetScript("OnValueChanged", g_Module.SettingsUI_SldOptionsEvntScale_OnValueChanged);

	CatRotationHelper_SldOptionsSurvScaleText:SetText("Survival Frame scale");
	CatRotationHelper_SldOptionsSurvScale:SetScript("OnValueChanged", g_Module.SettingsUI_SldOptionsSurvScale_OnValueChanged);
end

function g_Module.SettingsUI_Load()
	if(crhShowCat) then
		CatRotationHelper_ChkOptionsCat:SetChecked(true)
	else
		CatRotationHelper_ChkOptionsClearcast:Disable()
		CatRotationHelper_ChkOptionsCatCombo:Disable()
		CatRotationHelper_ChkOptionsCatBerserk:Disable()
		CatRotationHelper_ChkOptionsCatPredators:Disable()
		CatRotationHelper_ChkOptionsCatCharge:Disable()
		CatRotationHelper_ChkOptionsCatSurvival:Disable()
	end

	if(crhShowBear) then
		CatRotationHelper_ChkOptionsBear:SetChecked(true)
	else
		CatRotationHelper_ChkOptionsBearLacerate:Disable()
		CatRotationHelper_ChkOptionsBearBerserk:Disable()
		CatRotationHelper_ChkOptionsBearSurvival:Disable()
	end
	
	CatRotationHelper_ChkOptionsClearcast:SetChecked(crhEnableClearcast)
	CatRotationHelper_ChkOptionsCatCombo:SetChecked(crhCp)
	CatRotationHelper_ChkOptionsCatBerserk:SetChecked(crhShowCatBerserk)
	CatRotationHelper_ChkOptionsCatPredators:SetChecked(crhShowPredatorsSwiftness)
	CatRotationHelper_ChkOptionsCatCharge:SetChecked(crhShowFeralCharge)
	CatRotationHelper_ChkOptionsCatSurvival:SetChecked(crhShowCatSurvival)

	CatRotationHelper_ChkOptionsBearLacerate:SetChecked(crhLacCounter)
	CatRotationHelper_ChkOptionsBearBerserk:SetChecked(crhShowBearBerserk)
	CatRotationHelper_ChkOptionsBearSurvival:SetChecked(crhShowBearSurvival)

	CatRotationHelper_SldOptionsMainScale:SetValue(g_Module.Settings.Frames[1].Scale)
	CatRotationHelper_SldOptionsMainScaleValue:SetText(math.floor(g_Module.Settings.Frames[1].Scale*100+0.5)/100)
	CatRotationHelper_SldOptionsEvntScale:SetValue(g_Module.Settings.Frames[2].Scale)
	CatRotationHelper_SldOptionsEvntScaleValue:SetText(math.floor(g_Module.Settings.Frames[2].Scale*100+0.5)/100)
	CatRotationHelper_SldOptionsSurvScale:SetValue(g_Module.Settings.Frames[3].Scale)
	CatRotationHelper_SldOptionsSurvScaleValue:SetText(math.floor(g_Module.Settings.Frames[3].Scale*100+0.5)/100)
end

function g_Module.SettingsUI_ChkOptionsCat_OnClick(self)
	if(self:GetChecked()) then
		crhShowCat = true
		CatRotationHelper_ChkOptionsClearcast:Enable()
		CatRotationHelper_ChkOptionsCatCombo:Enable()
		CatRotationHelper_ChkOptionsCatBerserk:Enable()
		CatRotationHelper_ChkOptionsCatPredators:Enable()
		CatRotationHelper_ChkOptionsCatCharge:Enable()
		CatRotationHelper_ChkOptionsCatSurvival:Enable()
	else
		crhShowCat = false
		CatRotationHelper_ChkOptionsClearcast:Disable()
		CatRotationHelper_ChkOptionsCatCombo:Disable()
		CatRotationHelper_ChkOptionsCatBerserk:Disable()
		CatRotationHelper_ChkOptionsCatPredators:Disable()
		CatRotationHelper_ChkOptionsCatCharge:Disable()
		CatRotationHelper_ChkOptionsCatSurvival:Disable()
	end

	g_Module.OnPackageChanged();
end

function g_Module.SettingsUI_ChkOptionsClearcast_OnClick(self)
	if(self:GetChecked()) then
		crhEnableClearcast = true
	else
		crhEnableClearcast = false
	end
end

function g_Module.SettingsUI_ChkOptionsCatCombo_OnClick(self)
	if(self:GetChecked()) then
		crhCp = true

		CatRotationHelper_EntryPoint:RegisterEvent("UNIT_COMBO_POINTS");
		CatRotationHelperSetCatCP(GetComboPoints("player"));
	else
		CatRotationHelperSetCatCP(0);
		CatRotationHelper_EntryPoint:UnregisterEvent("UNIT_COMBO_POINTS");

		crhCp = false
	end
end

function g_Module.SettingsUI_ChkOptionsCatBerserk_OnClick(self)
	if(self:GetChecked()) then
		crhShowCatBerserk = true
	else
		crhShowCatBerserk = false
	end
end

function g_Module.SettingsUI_ChkOptionsCatPredators_OnClick(self)
	if(self:GetChecked()) then
		crhShowPredatorsSwiftness = true
	else
		crhShowPredatorsSwiftness = false
	end
end

function g_Module.SettingsUI_ChkOptionsCatCharge_OnClick(self)
	if(self:GetChecked()) then
		crhShowFeralCharge = true
	else
		crhShowFeralCharge = false
	end
end

function g_Module.SettingsUI_ChkOptionsCatSurvival_OnClick(self)
	if(self:GetChecked()) then
		crhShowCatSurvival = true
	else
		crhShowCatSurvival = false
	end
end

function g_Module.SettingsUI_ChkOptionsBear_OnClick(self)
	if(self:GetChecked()) then
		crhShowBear = true
		CatRotationHelper_ChkOptionsBearLacerate:Enable()
		CatRotationHelper_ChkOptionsBearBerserk:Enable()
		CatRotationHelper_ChkOptionsBearSurvival:Enable()
	else
		crhShowBear = false
		CatRotationHelper_ChkOptionsBearLacerate:Disable()
		CatRotationHelper_ChkOptionsBearBerserk:Disable()
		CatRotationHelper_ChkOptionsBearSurvival:Disable()
	end

	g_Module.OnPackageChanged();
end

function g_Module.SettingsUI_ChkOptionsBearLacerate_OnClick(self)
	if(self:GetChecked()) then
		crhLacCounter = true
		CatRotationHelperCheckBearDebuffs();
	else
		CatRotationHelperSetBearCP(0);
		crhLacCounter = false
	end
end

function g_Module.SettingsUI_ChkOptionsBearBerserk_OnClick(self)
	if(self:GetChecked()) then
		crhShowBearBerserk = true
	else
		crhShowBearBerserk = false
	end
end

function g_Module.SettingsUI_ChkOptionsBearSurvival_OnClick(self)
	if(self:GetChecked()) then
		crhShowBearSurvival = true
	else
		crhShowBearSurvival = false
	end
end

function g_Module.SettingsUI_SldOptionsMainScale_OnValueChanged(self)
	local frameBox = g_Module.FrameBoxes[1];
	local settings = g_Module.Settings.Frames[frameBox.m_Index];

	settings.Scale = math.floor(self:GetValue()*100+0.5)/100;
	CatRotationHelper_SldOptionsMainScaleValue:SetText(settings.Scale);
	
	g_Module.FrameBox_LoadSettings(frameBox);
end

function g_Module.SettingsUI_SldOptionsEvntScale_OnValueChanged(self)
	local frameBox = g_Module.FrameBoxes[2];
	local settings = g_Module.Settings.Frames[frameBox.m_Index];

	settings.Scale = math.floor(self:GetValue()*100+0.5)/100;
	CatRotationHelper_SldOptionsEvntScaleValue:SetText(settings.Scale);
	
	g_Module.FrameBox_LoadSettings(frameBox);
end

function g_Module.SettingsUI_SldOptionsSurvScale_OnValueChanged(self)
	local frameBox = g_Module.FrameBoxes[3];
	local settings = g_Module.Settings.Frames[frameBox.m_Index];

	settings.Scale = math.floor(self:GetValue()*100+0.5)/100;
	CatRotationHelper_SldOptionsSurvScaleValue:SetText(settings.Scale);
	
	g_Module.FrameBox_LoadSettings(frameBox);
end
