local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

-----------------------------------
-- Cat
-----------------------------------
g_Addon.LogicDruidCatTigersFury =
{
	Texture			= g_Addon.GetMyImage("TigersFury.tga"),
	TextureSpecial	= g_Addon.GetMyImage("TigersFury-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 5217,
};

g_Addon.LogicDruidCatSavageRoar =
{
	Texture			= g_Addon.GetMyImage("SavageRoar.tga"),
	TextureSpecial	= g_Addon.GetMyImage("SavageRoar-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_BUFF,
	SpellID			= 52610,
};

g_Addon.LogicDruidCatThrash =
{
	Texture			= g_Addon.GetMyImage("Thrash.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Thrash-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 106830,
	SkillID 		= 106832,
	CastByMe		= true,
};

g_Addon.LogicDruidCatRake =
{
	Texture			= g_Addon.GetMyImage("Rake.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Rake-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 59881,
	SkillID			= 1822,
	CastByMe		= true,
};

g_Addon.LogicDruidCatRip =
{
	Texture			= g_Addon.GetMyImage("Rip.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Rip-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 1079,
	CastByMe		= true,
};

g_Addon.LogicDruidCatPredatorySwiftness =
{
	Texture			= g_Addon.GetMyImage("PredatoryStrikes.tga"),
	Type			= g_Consts.LOGIC_TYPE_PROC,
	SpellID			= 69369,
	SkillID			= 16974,
};

g_Addon.LogicDruidCatLunarInspiration =
{
	Texture			= g_Addon.GetMyImage("Moonfire.tga"),
	TextureSpecial	= g_Addon.GetMyImage("Moonfire-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 155625,
	TalentID		= 22365,
};

g_Addon.LogicDruidCatIncarnation =
{
	Texture			= g_Addon.GetMyImage("Incarnation.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 102543,
	TalentID		= 21705,
};

g_Addon.LogicDruidCatElunesGuidance =
{
	Texture			= g_Addon.GetMyImage("ElunesGuidance.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 202060,
	TalentID		= 22370,
};

g_Addon.LogicDruidCatBrutalSlash =
{
	Texture			= g_Addon.GetMyImage("BrutalSlash.tga"),
	TextureSpecial	= g_Addon.GetMyImage("BrutalSlash-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 202028,
	TalentID		= 21646,
};

-----------------------------------
-- Bear
-----------------------------------
g_Addon.LogicDruidBearMangle =
{
	Texture			= g_Addon.GetMyImage("Mangle.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 33917,
};

g_Addon.LogicDruidBearThrash =
{
	Texture			= g_Addon.GetMyImage("Thrash.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 77758,
	SkillID			= 106832,
};

g_Addon.LogicDruidBearGalacticGuardian =
{
	Texture			= g_Addon.GetMyImage("Moonfire.tga"),
	Type			= g_Consts.LOGIC_TYPE_PROC,
	SpellID			= 213708,
	TalentID		= 22421,
};

g_Addon.LogicDruidBearPulverize =
{
	Texture			= g_Addon.GetMyImage("Pulverize.tga"),
	Type			= g_Consts.LOGIC_TYPE_BUFF,
	SpellID			= 158792,
};

g_Addon.LogicDruidBearBarkskin =
{
	Texture			= g_Addon.GetMyImage("Barkskin.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 22812,
};

g_Addon.LogicDruidBearIncarnation =
{
	Texture			= g_Addon.GetMyImage("Incarnation.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 102558,
	TalentID		= 21706,
};

g_Addon.LogicDruidBearLunarBeam =
{
	Texture			= g_Addon.GetMyImage("LunarBeam.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 204066,
	TalentID		= 22427,
};

g_Addon.LogicDruidBearBristlingFur =
{
	Texture			= g_Addon.GetMyImage("BristlingFur.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 155835,
	TalentID		= 22425,
};

-----------------------------------
-- Cat & Bear
-----------------------------------
g_Addon.LogicDruidSurvivalInstincts =
{
	Texture			= g_Addon.GetMyImage("SurvivalInstincts.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 61336,
};

g_Addon.LogicDruidBerserk =
{
	Texture			= g_Addon.GetMyImage("Berserk.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 106951,
};

g_Addon.LogicDruidWildCharge =
{
	Texture			= g_Addon.GetMyImage("FeralCharge.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 102401,
};

g_Addon.LogicDruidRenewal =
{
	Texture			= g_Addon.GetMyImage("Renewal.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 108238,
	TalentID		= 19283,
};
