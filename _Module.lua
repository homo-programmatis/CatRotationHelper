local THIS_ADDON_NAME=...;
local g_Addon = {};
getfenv(0)[THIS_ADDON_NAME] = g_Addon;

g_Addon.GetPackage = {};
g_Addon.FrameLists = {{}, {}, {}};
