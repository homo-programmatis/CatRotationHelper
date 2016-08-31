local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

function g_Addon.SettingsUI_Initialize()
	local pageRoot = g_Addon.SettingsUI_PageRoot_Create();
	g_Addon.SettingsUI_PageFrames_Create(pageRoot);
	g_Addon.SettingsUI_PageIcons_Create(pageRoot);
end

function g_Addon.SettingsUI_PageRoot_Create()
	local frmPage   = CreateFrame("Frame", "CatRotationHelper_DlgOptions", UIParent)
	frmPage.name    = THIS_ADDON_NAME;
	InterfaceOptions_AddCategory(frmPage);
	
	frmPage.m_LblHint = frmPage:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge');
	frmPage.m_LblHint:SetPoint('TOPLEFT', 20, -100);
	frmPage.m_LblHint:SetText("<<< See settings subcategories");
	
	return frmPage;
end

function g_Addon.SettingsUI_PageFrames_Create(a_FrmParent)
	local frmPage   = CreateFrame("Frame", a_FrmParent:GetName() .. "_PageFrames", a_FrmParent)
	frmPage.name    = "Frames";
	frmPage.parent  = a_FrmParent.name;
	frmPage.refresh = g_Addon.SettingsUI_PageFrames_Refresh;
	InterfaceOptions_AddCategory(frmPage);
	
	frmPage.m_LblPageTitle = frmPage:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge');
	frmPage.m_LblPageTitle:SetPoint('TOPLEFT', 16, -16);
	frmPage.m_LblPageTitle:SetText(frmPage.name);

	frmPage.m_LblPageDesc = frmPage:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall');
	frmPage.m_LblPageDesc:SetPoint('TOPLEFT', frmPage.m_LblPageTitle, 'BOTTOMLEFT', 0, -8);
	frmPage.m_LblPageDesc:SetText("You can set sizes and positions for your frames here.");
	
	frmPage.m_BtnMoveFrames = CreateFrame("Button", frmPage:GetName() .. "_BtnMoveFrames", frmPage, "OptionsButtonTemplate");
	frmPage.m_BtnMoveFrames:SetText("Move/Rotate Frames");
	frmPage.m_BtnMoveFrames:SetPoint('TOPLEFT', frmPage.m_LblPageDesc, 'BOTTOMLEFT', 0, -20);
	frmPage.m_BtnMoveFrames:SetSize(150, 20);
	frmPage.m_BtnMoveFrames:SetScript("OnClick", CatRotationHelperUnlock);
	
	frmPage.m_SldMainScale = g_Addon.SettingsUI_PageFrames_SldScale_Create(frmPage, 1, "Main Frame scale");
	frmPage.m_SldMainScale:SetPoint('TOPLEFT', frmPage.m_BtnMoveFrames, 'BOTTOMLEFT', 0, -40);
	
	frmPage.m_SldEvntScale = g_Addon.SettingsUI_PageFrames_SldScale_Create(frmPage, 2, "Notification Frame scale");
	frmPage.m_SldEvntScale:SetPoint('TOPLEFT', frmPage.m_SldMainScale, 'BOTTOMLEFT', 0, -40);

	frmPage.m_SldSurvScale = g_Addon.SettingsUI_PageFrames_SldScale_Create(frmPage, 3, "Survival Frame scale");
	frmPage.m_SldSurvScale:SetPoint('TOPLEFT', frmPage.m_SldEvntScale, 'BOTTOMLEFT', 0, -40);
end

function g_Addon.SettingsUI_PageFrames_SldScale_Create(a_FrmPage, a_FrameBox, a_Label)
	local minValue = 0.5;
	local maxValue = 3;
	
	local sldScale = CreateFrame("Slider", a_FrmPage:GetName() .. "_SldScale_" .. a_FrameBox, a_FrmPage, "OptionsSliderTemplate");
	sldScale:SetMinMaxValues(minValue, maxValue);
	sldScale:SetValueStep(0.05);
	sldScale:SetObeyStepOnDrag(true);
	_G[sldScale:GetName() .. "Text"]:SetText(a_Label);
	_G[sldScale:GetName() .. "Low"]:SetText(minValue);
	_G[sldScale:GetName() .. "High"]:SetText(maxValue);
	sldScale:SetScript("OnValueChanged", g_Addon.SettingsUI_PageFrames_SldScale_OnValueChanged);
	
	sldScale.Value = sldScale:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall');
	sldScale.Value:SetPoint('TOP', sldScale, 'BOTTOM', 0, 3);
	
	sldScale.m_FrameBox = a_FrameBox;
	
	return sldScale;
end

local function RoundScaleValue(a_Value)
	return math.floor(a_Value*100 + 0.5) / 100;
end

function g_Addon.SettingsUI_PageFrames_SldScale_OnValueChanged(a_SldScale)
	local frameBox = g_Addon.FrameBoxes[a_SldScale.m_FrameBox];
	local settings = g_Addon.Settings.Frames[frameBox.m_Index];

	settings.Scale = RoundScaleValue(a_SldScale:GetValue());
	a_SldScale.Value:SetText(settings.Scale);
	
	g_Addon.FrameBox_LoadSettings(frameBox);
end

function g_Addon.SettingsUI_PageFrames_SldScale_Refresh(a_SldScale)
	local frameBox = g_Addon.FrameBoxes[a_SldScale.m_FrameBox];
	local settings = g_Addon.Settings.Frames[frameBox.m_Index];

	local sliderValue = RoundScaleValue(settings.Scale);
	a_SldScale:SetValue(sliderValue);
	a_SldScale.Value:SetText(sliderValue);
end

function g_Addon.SettingsUI_PageFrames_Refresh(a_FrmPage)
	g_Addon.SettingsUI_PageFrames_SldScale_Refresh(a_FrmPage.m_SldMainScale);
	g_Addon.SettingsUI_PageFrames_SldScale_Refresh(a_FrmPage.m_SldEvntScale);
	g_Addon.SettingsUI_PageFrames_SldScale_Refresh(a_FrmPage.m_SldSurvScale);
end

function g_Addon.SettingsUI_PageIcons_Create(a_FrmParent)
	local frmPage   = CreateFrame("Frame", a_FrmParent:GetName() .. "_PageIcons", a_FrmParent)
	frmPage.name    = "Icons";
	frmPage.parent  = a_FrmParent.name;
	frmPage.refresh = g_Addon.SettingsUI_PageIcons_Refresh;
	InterfaceOptions_AddCategory(frmPage);
	
	frmPage.m_LblPageTitle = frmPage:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge');
	frmPage.m_LblPageTitle:SetPoint('TOPLEFT', 16, -16);
	frmPage.m_LblPageTitle:SetText(frmPage.name);

	frmPage.m_LblPageDesc = frmPage:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall');
	frmPage.m_LblPageDesc:SetPoint('TOPLEFT', frmPage.m_LblPageTitle, 'BOTTOMLEFT', 0, -8);
	frmPage.m_LblPageDesc:SetText("You can enable/disable icons here. Only icons for your current spec/talents/shape are configurable.");

	frmPage.m_ChkIcon = {};
	
	local numCols = 2;
	local numRows = 17;
	local deltaCol = 600 / numCols;
	local deltaRow = -30;
	
	for iRow = 0, numRows - 1 do
		for iCol = 0, numCols - 1 do
			local iIcon   = 1 + numCols*iRow + iCol;
			local chkName = frmPage:GetName() .. "_ChkIcon_" .. iIcon;
			local chkIcon = CreateFrame("CheckButton", chkName, frmPage, "InterfaceOptionsCheckButtonTemplate");
			chkIcon:SetPoint('TOPLEFT', frmPage.m_LblPageDesc, 'BOTTOMLEFT', iCol * deltaCol, -10 + iRow * deltaRow);
			
			chkIcon:SetScript('OnClick', g_Addon.SettingsUI_PageIcons_ChkIcon_OnClick);
			chkIcon:SetScript('OnEnter', g_Addon.SettingsUI_PageIcons_ChkIcon_OnEnter);
			chkIcon:SetScript('OnLeave', g_Addon.SettingsUI_PageIcons_ChkIcon_OnLeave);
		
			frmPage.m_ChkIcon[iIcon] = chkIcon;
		end
	end
end

function g_Addon.SettingsUI_PageIcons_ChkIcon_OnClick(a_ChkIcon)
	local iconLogic = a_ChkIcon.m_Logic;
	
	if (a_ChkIcon:GetChecked()) then
		-- set to 'nil' instead of 'false' to keep table clean
		g_Addon.Settings.DisabledIcons[iconLogic.ID] = nil;
	else
		g_Addon.Settings.DisabledIcons[iconLogic.ID] = true;
	end
	
	g_Addon.ReloadPackage();
end

function g_Addon.SettingsUI_PageIcons_ChkIcon_OnEnter(a_ChkIcon)
	local iconLogic = a_ChkIcon.m_Logic;
	
	GameTooltip:SetOwner(a_ChkIcon, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(iconLogic.SpellID);
	GameTooltip:Show();
end

function g_Addon.SettingsUI_PageIcons_ChkIcon_OnLeave(a_ChkIcon)
	GameTooltip:Hide();
end

local function GetActiveLogics()
	local playerClass = select(2, UnitClass("player"));
	local settingsPackage = g_Addon.GetPackage[playerClass]({ShowDisabled = true});
	local logics = {};
	
	for _, logicList in pairs(settingsPackage.LogicLists) do
		for _, logic in pairs(logicList) do
			if (logic.ID) then -- Not a g_Addon.LogicUnusedFrame or anything else without ID
				table.insert(logics, logic);
			end
		end
	end
	
	table.sort(
		logics,
		function(a_Lhs, a_Rhs)
			local lhsName = g_Addon.GetSpellName(a_Lhs.SpellID);
			local rhsName = g_Addon.GetSpellName(a_Rhs.SpellID);
			return lhsName < rhsName;
		end
	);
	
	return logics;
end

function g_Addon.SettingsUI_PageIcons_Refresh(a_FrmPage)
	local logics = GetActiveLogics();
	
	for iIcon = 1, #logics do
		local chkIcon = a_FrmPage.m_ChkIcon[iIcon];
		chkIcon:Show();
		
		local iconLogic = logics[iIcon];
		local iconName  = g_Addon.GetSpellName(iconLogic.SpellID);
		chkIcon.Text:SetText(iconName);
		chkIcon.m_Logic = iconLogic;
		local iconDisabled = g_Addon.Settings.DisabledIcons[iconLogic.ID];
		chkIcon:SetChecked(not iconDisabled);
	end
	
	for iIcon = #logics + 1, #a_FrmPage.m_ChkIcon do
		local chkIcon = a_FrmPage.m_ChkIcon[iIcon];
		chkIcon:Hide();
	end
end
