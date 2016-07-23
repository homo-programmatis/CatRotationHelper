local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

-- Global reference to g_Module.Settings for SavedVariables in .toc
-- Debugging: /dump CatRotationHelperSettings
CatRotationHelperSettings = {};

function g_Module.Settings_Frame_ComposeDefault(a_FrmPoint, a_ScrPoint, a_LocationX, a_LocationY, a_Angle)
	local result = {};

	result.LocationFrmPoint = a_FrmPoint;
	result.LocationScrPoint = a_ScrPoint;
	result.LocationX = a_LocationX;
	result.LocationY = a_LocationY;
	result.Angle = a_Angle;
	result.Scale = 1;

	return result;
end

function g_Module.Settings_ComposeDefaults()
	local defaultSettings = {};

	defaultSettings.Version = 1;
	
	defaultSettings.Frames =
	{
		g_Module.Settings_Frame_ComposeDefault("TOP",   "CENTER",    0,  -70,   0),
		g_Module.Settings_Frame_ComposeDefault("RIGHT", "CENTER", -100,    0, 270),
		g_Module.Settings_Frame_ComposeDefault("LEFT",  "CENTER",  100,    0, 270),
	};

	return defaultSettings;
end

function g_Module.Settings_Repair(a_Settings)
	if (a_Settings.Version ~= 1) then
		return false;
	end
	
	return true;
end

function g_Module.Settings_Load()
	-- Create defaults if user has bad settings (or doesn't have any at all)
	if (not g_Module.Settings_Repair(CatRotationHelperSettings)) then
		g_Module.PrintToChat("Creating default settings");
		CatRotationHelperSettings = g_Module.Settings_ComposeDefaults();
	end

	-- Store a reference to loaded settings
	g_Module.Settings = CatRotationHelperSettings;
end