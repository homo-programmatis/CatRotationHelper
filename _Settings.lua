local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

-- Global reference to g_Addon.Settings for SavedVariables in .toc
-- Debugging: /dump CatRotationHelperSettings
CatRotationHelperSettings = {};

function g_Addon.Settings_Frame_ComposeDefault(a_FrmPoint, a_ScrPoint, a_LocationX, a_LocationY, a_Angle)
	local result = {};

	result.LocationFrmPoint = a_FrmPoint;
	result.LocationScrPoint = a_ScrPoint;
	result.LocationX = a_LocationX;
	result.LocationY = a_LocationY;
	result.Angle = a_Angle;
	result.Scale = 1;

	return result;
end

function g_Addon.Settings_ComposeDefaults()
	local defaultSettings = {};

	defaultSettings.Version = 3;

	defaultSettings.Frames =
	{
		g_Addon.Settings_Frame_ComposeDefault("TOP",   "CENTER",    0,  -70,   0),
		g_Addon.Settings_Frame_ComposeDefault("RIGHT", "CENTER", -100,    0, 270),
		g_Addon.Settings_Frame_ComposeDefault("LEFT",  "CENTER",  100,    0, 270),
	};

	defaultSettings.DisabledIcons = {};
	defaultSettings.ShowWhen = g_Consts.UI_SHOWWHEN_COMBAT_OR_TARGET;

	return defaultSettings;
end

function g_Addon.Settings_Repair(a_Settings)
	if (nil == a_Settings.Version) then
		return false;
	end

	if (1 == a_Settings.Version) then
		a_Settings.DisabledIcons = {};
		a_Settings.Version = 2;
	end

	if (2 == a_Settings.Version) then
		-- If user already had addon, keep the old behavior
		a_Settings.ShowWhen = g_Consts.UI_SHOWWHEN_TARGET;
		a_Settings.Version = 3;
	end

	if (("number" ~= type(a_Settings.ShowWhen)) or (a_Settings.ShowWhen < g_Consts.UI_SHOWWHEN_FIRST) or (a_Settings.ShowWhen > g_Consts.UI_SHOWWHEN_LAST)) then
		a_Settings.ShowWhen = g_Consts.UI_SHOWWHEN_COMBAT_OR_TARGET;
	end

	return true;
end

function g_Addon.Settings_Load(a_Settings)
	a_Settings = a_Settings or CatRotationHelperSettings;

	-- Create defaults if user has bad settings (or doesn't have any at all)
	if (not g_Addon.Settings_Repair(a_Settings)) then
		g_Addon.PrintToChat("Creating default settings");
		a_Settings = g_Addon.Settings_ComposeDefaults();
	end

	-- Store references to loaded settings
	CatRotationHelperSettings = a_Settings;
	g_Addon.Settings = a_Settings;
end

function g_Addon.Settings_Reset()
	g_Addon.SettingsBackup = g_Addon.Settings;
	g_Addon.Settings_Load(g_Addon.Settings_ComposeDefaults());
	g_Addon.PrintToChat("Settings have been reset");
end

function g_Addon.Settings_UndoReset()
	if (g_Addon.SettingsBackup) then
		-- swap active and backup settings
		local backup = g_Addon.SettingsBackup;
		g_Addon.SettingsBackup = g_Addon.Settings;
		g_Addon.Settings_Load(backup);
		g_Addon.PrintToChat("Restored settings from backup");
	else
		g_Addon.PrintToChat("No settings backup to restore");
	end
end
