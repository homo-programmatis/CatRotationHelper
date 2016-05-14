local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

-----------------------------------
-- Cat
-----------------------------------
g_Module.LogicDruidCatTigersFury =
{
	Texture			= g_Module.GetMyImage("TigersFury.tga"),
	TextureSpecial	= g_Module.GetMyImage("TigersFury-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 5217,
};

g_Module.LogicDruidCatSavageRoar =
{
	Texture			= g_Module.GetMyImage("SavageRoar.tga"),
	TextureSpecial	= g_Module.GetMyImage("SavageRoar-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_BUFF,
	SpellID			= 52610,
};

g_Module.LogicDruidCatThrash =
{
	Texture			= g_Module.GetMyImage("Thrash.tga"),
	TextureSpecial	= g_Module.GetMyImage("Thrash-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 106830,
	SkillID 		= 77758,
	CastByMe		= true,
};

g_Module.LogicDruidCatRake =
{
	Texture			= g_Module.GetMyImage("Rake.tga"),
	TextureSpecial	= g_Module.GetMyImage("Rake-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 59881,
	SkillID			= 1822,
	CastByMe		= true,
};

g_Module.LogicDruidCatRip =
{
	Texture			= g_Module.GetMyImage("Rip.tga"),
	TextureSpecial	= g_Module.GetMyImage("Rip-Blue.tga"),
	Type			= g_Consts.LOGIC_TYPE_DEBUFF,
	SpellID			= 1079,
	CastByMe		= true,
};

g_Module.LogicDruidCatPredatorySwiftness =
{
	Texture			= g_Module.GetMyImage("PredatoryStrikes.tga"),
	Type			= g_Consts.LOGIC_TYPE_PROC,
	SpellID			= 69369,
	SkillID			= 16974,
};

-----------------------------------
-- Bear
-----------------------------------
g_Module.LogicDruidBearMangle =
{
	Texture			= g_Module.GetMyImage("Mangle.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 33917,
};

g_Module.LogicDruidBearThrash =
{
	Texture			= g_Module.GetMyImage("Thrash.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 77758,
	SkillID			= 106832,
};

g_Module.LogicDruidBearBarkskin =
{
	Texture			= g_Module.GetMyImage("Barkskin.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 22812,
};

-----------------------------------
-- Cat & Bear
-----------------------------------
g_Module.LogicDruidSurvivalInstincts =
{
	Texture			= g_Module.GetMyImage("SurvivalInstincts.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 61336,
};

g_Module.LogicDruidBerserk =
{
	Texture			= g_Module.GetMyImage("Berserk.tga"),
	Type			= g_Consts.LOGIC_TYPE_BURST,
	SpellID			= 106952,
};

g_Module.LogicDruidWildCharge =
{
	Texture			= g_Module.GetMyImage("FeralCharge.tga"),
	Type			= g_Consts.LOGIC_TYPE_SKILL,
	SpellID			= 102401,
};
