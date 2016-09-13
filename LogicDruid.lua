local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

g_Addon.Logics.Druid_AshamanesFrenzy =
{
	ID				= "Druid|Ashamane's Frenzy",
	Texture			= g_Addon.GetMyImage("AshamanesFrenzy.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 210722,
};

g_Addon.Logics.Druid_Barkskin =
{
	ID				= "Druid|Barkskin",
	Texture			= g_Addon.GetMyImage("Barkskin.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 22812,
};

g_Addon.Logics.Druid_Berserk =
{
	ID				= "Druid|Berserk",
	Texture			= g_Addon.GetMyImage("Berserk.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 106951,
};

g_Addon.Logics.Druid_Bloodtalons =
{
	ID				= "Druid|Bloodtalons",
	Texture			= g_Addon.GetMyImage("Bloodtalons.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Bloodtalons-blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_PROC,
	SpellID			= 145152,
	TalentID		= 21649,
};

g_Addon.Logics.Druid_BristlingFur =
{
	ID				= "Druid|Bristling Fur",
	Texture			= g_Addon.GetMyImage("BristlingFur.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 155835,
	TalentID		= 22418,
};

g_Addon.Logics.Druid_BrutalSlash =
{
	ID				= "Druid|Brutal Slash",
	Texture			= g_Addon.GetMyImage("BrutalSlash.tga"),
	TextureSpecial	= g_Addon.GetMyImage("BrutalSlash-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 202028,
	TalentID		= 21646,
};

g_Addon.Logics.Druid_ElunesGuidance =
{
	ID				= "Druid|Elune's Guidance",
	Texture			= g_Addon.GetMyImage("ElunesGuidance.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 202060,
	TalentID		= 22370,
};
g_Addon.Logics.Druid_GalacticGuardian =
{
	ID				= "Druid|Galactic Guardian",
	Texture			= g_Addon.GetMyImage("Moonfire.tga"),
	Type			= g_Consts.LOGIC_TYPE_PROC,
	SpellID			= 213708,
	TalentID		= 22421,
};

g_Addon.Logics.Druid_Incarnation_Bear =
{
	ID				= "Druid|Incarnation: Guardian of Ursoc",
	Texture			= g_Addon.GetMyImage("Incarnation.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 102558,
	TalentID		= 21706,
};

g_Addon.Logics.Druid_Incarnation_Cat =
{
	ID				= "Druid|Incarnation: King of the Jungle",
	Texture			= g_Addon.GetMyImage("Incarnation.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 102543,
	TalentID		= 21705,
};

g_Addon.Logics.Druid_LunarBeam =
{
	ID				= "Druid|Lunar Beam",
	Texture			= g_Addon.GetMyImage("LunarBeam.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 204066,
	TalentID		= 22427,
};

g_Addon.Logics.Druid_LunarInspiration =
{
	ID				= "Druid|Lunar Inspiration",
	Texture			= g_Addon.GetMyImage("Moonfire.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Moonfire-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 155625,
	TalentID		= 22365,
	CastByMe		= true,
};

g_Addon.Logics.Druid_Mangle_Bear =
{
	ID				= "Druid|Mangle (bear)",
	Texture			= g_Addon.GetMyImage("Mangle.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 33917,
};

g_Addon.Logics.Druid_PredatorySwiftness =
{
	ID				= "Druid|Predatory Swiftness",
	Texture			= g_Addon.GetMyImage("PredatorySwiftness.tga"),
	Type			= g_Consts.LOGIC_TYPE_PROC,
	SpellID			= 69369,
	SkillID			= 16974,
	IsAvailable		= function() return not g_Addon.IsTalentTaken(21649); end,
};

g_Addon.Logics.Druid_PredatorySwiftness_Bloodtalons =
{
	ID				= "Druid|Predatory Swiftness (Bloodtalons)",
	Texture			= g_Addon.GetMyImage("PredatorySwiftness.tga"),
	TextureSpecial	= g_Addon.GetMyImage("PredatorySwiftness-blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_PROC,
	SpellID			= 69369,
	TalentID		= 21649,
};

g_Addon.Logics.Druid_Pulverize =
{
	ID				= "Druid|Pulverize",
	Texture			= g_Addon.GetMyImage("Pulverize.tga"),
	Type			= g_Consts.LOGIC_TYPE_BUFF,
	SpellID			= 158792,
};

g_Addon.Logics.Druid_RageOfTheSleeper =
{
	ID				= "Druid|Rage of the Sleeper",
	Texture			= g_Addon.GetMyImage("RageOfTheSleeper.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 200851,
};

g_Addon.Logics.Druid_Rake =
{
	ID				= "Druid|Rake",
	Texture			= g_Addon.GetMyImage("Rake.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Rake-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 59881,
	SkillID			= 1822,
	CastByMe		= true,
};

g_Addon.Logics.Druid_Renewal =
{
	ID				= "Druid|Renewal",
	Texture			= g_Addon.GetMyImage("Renewal.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 108238,
	TalentID		= 19283,
};

g_Addon.Logics.Druid_Rip =
{
	ID				= "Druid|Rip",
	Texture			= g_Addon.GetMyImage("Rip.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Rip-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 1079,
	CastByMe		= true,
};

g_Addon.Logics.Druid_SavageRoar =
{
	ID				= "Druid|Savage Roar",
	Texture			= g_Addon.GetMyImage("SavageRoar.tga"),
	TextureSpecial	= g_Addon.GetMyImage("SavageRoar-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_BUFF,
	SpellID			= 52610,
};

g_Addon.Logics.Druid_SurvivalInstincts =
{
	ID				= "Druid|Survival Instincts",
	Texture			= g_Addon.GetMyImage("SurvivalInstincts.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 61336,
};

g_Addon.Logics.Druid_TigersFury =
{
	ID				= "Druid|Tiger's Fury",
	Texture			= g_Addon.GetMyImage("TigersFury.tga"),
	TextureSpecial	= g_Addon.GetMyImage("TigersFury-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 5217,
};

g_Addon.Logics.Druid_Thrash_Bear =
{
	ID				= "Druid|Thrash (bear)",
	Texture			= g_Addon.GetMyImage("Thrash.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 77758,
	SkillID			= 106832,
};

g_Addon.Logics.Druid_Thrash_Cat =
{
	ID				= "Druid|Thrash (cat)",
	Texture			= g_Addon.GetMyImage("Thrash.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Thrash-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 106830,
	SkillID 		= 106832,
	CastByMe		= true,
};

g_Addon.Logics.Druid_WildCharge =
{
	ID				= "Druid|Wild Charge",
	Texture			= g_Addon.GetMyImage("FeralCharge.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 102401,
};
