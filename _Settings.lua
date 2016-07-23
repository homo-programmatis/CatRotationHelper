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

	defaultSettings.Version = 1;
	
	defaultSettings.Frames =
	{
		g_Addon.Settings_Frame_ComposeDefault("TOP",   "CENTER",    0,  -70,   0),
		g_Addon.Settings_Frame_ComposeDefault("RIGHT", "CENTER", -100,    0, 270),
		g_Addon.Settings_Frame_ComposeDefault("LEFT",  "CENTER",  100,    0, 270),
	};

	return defaultSettings;
end

function g_Addon.Settings_Repair(a_Settings)
	if (a_Settings.Version ~= 1) then
		return false;
	end
	
	return true;
end

function g_Addon.Settings_Load()
	-- Create defaults if user has bad settings (or doesn't have any at all)
	if (not g_Addon.Settings_Repair(CatRotationHelperSettings)) then
		g_Addon.PrintToChat("Creating default settings");
		CatRotationHelperSettings = g_Addon.Settings_ComposeDefaults();
	end

	-- Store a reference to loaded settings
	g_Addon.Settings = CatRotationHelperSettings;
end