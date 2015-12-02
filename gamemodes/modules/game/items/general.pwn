#include <YSI_Coding\y_hooks>

enum E_ITEM {
	E_ITEM_NAME[32 char] = 0,
	E_ITEM_HASH_MAP[HASH_MAP_DATA]
};

enum E_ITEM_DATA {
	E_ITEM_NAME[32 char] = 0,
	E_ITEM_DATA_WEIGHT,
	E_ITEM_DATA_PRICE,
	E_ITEM_DATA_MODEL,
	E_ITEM_DATA_TYPE,
	E_ITEM_DATA_SLOT,
	E_ITEM_DATA_FLAGS
};

// graþiau atrodo yolo
#define g
#define eur

// daiktø tipai
enum {
	None,
	Weapon,
	Ammo,
	Food,
	Key,
	Quest
};
// equipment slots
enum _:E_EQUIPMENT_SLOTS {
	Slot_None,
	Slot_Head,
	Slot_RightHand,
	Slot_LeftHand,
	Slot_Body
};
// flags
enum (<<= 1) {
	DefaultFlags,
	Requires_Ammo = 1,
	Two_Handed,
	Explosive
};

static s_Item[][E_ITEM_DATA] = {
	{!"Kastetas",                100 g, 60 eur,    331, Weapon, Slot_RightHand, DefaultFlags},
	{!"Golfo lazda",            1100 g, 120 eur,   333, Weapon, Slot_RightHand, DefaultFlags},
	{!"Policijos lazda",         800 g, 300 eur,   334, Weapon, Slot_RightHand, DefaultFlags},
	{!"Peilis",                  250 g, 200 eur,   335, Weapon, Slot_RightHand, DefaultFlags},
	{!"Beisbolo lazda",         1800 g, 80 eur,    336, Weapon, Slot_RightHand, DefaultFlags},
	{!"Kastuvas",               2800 g, 100 eur,   337, Weapon, Slot_RightHand, DefaultFlags},
	{!"Bilijardo lazda",         400 g, 160 eur,   338, Weapon, Slot_RightHand, DefaultFlags},
	{!"Katana",                 1000 g, 24000 eur, 339, Weapon, Slot_RightHand, DefaultFlags},
	{!"Benzininis pjuklas",     6000 g, 500 eur,   341, Weapon, Slot_RightHand, DefaultFlags},
	{!"Geles",                   100 g, 30 eur,    325, Weapon, Slot_RightHand, DefaultFlags},
	{!"Lazda",                   300 g, 60 eur,    326, Weapon, Slot_RightHand, DefaultFlags},
	{!"Granata",                 300 g, 300 eur,   342, Weapon, Slot_RightHand, Explosive},
	{!"Dujines granatos",        300 g, 100 eur,   343, Weapon, Slot_RightHand, Explosive},
	{!"Molotovo kokteilis",      300 g, 300 eur,   344, Weapon, Slot_RightHand, Explosive},
	{!"Colt 45",                1200 g, 1200 eur,  346, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Tazeris",                1200 g, 1500 eur,  347, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Revolveris",             2000 g, 6000 eur,  348, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Sratinis sautuvas",      4000 g, 3000 eur,  349, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Sawn-off",               2000 g, 0 eur,     350, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Spas-12",                3000 g, 50000 eur, 351, Weapon, Slot_RightHand, Requires_Ammo},
	{!"UZI",                    2000 g, 10000 eur, 352, Weapon, Slot_RightHand, Requires_Ammo},
	{!"MP5",                    2900 g, 12000 eur, 353, Weapon, Slot_RightHand, Requires_Ammo},
	{!"AK-47",                  4000 g, 15000 eur, 355, Weapon, Slot_RightHand, Requires_Ammo},
	{!"M4A1",                   3900 g, 17500 eur, 356, Weapon, Slot_RightHand, Requires_Ammo},
	{!"TEC-9",                  2500 g, 12900 eur, 372, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Medzioklinis sautuvas",  4700 g, 8000 eur,  357, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Snaiperis",              6000 g, 30000 eur, 358, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Raketsvaidis",          10000 g, 0 eur,     359, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Termo-raketsvaidis",    11000 g, 0 eur,     360, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Ugniasvaidis",          10000 g, 0 eur,     361, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Minigun",               15000 g, 0 eur,     362, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Flakonelis",              500 g, 40 eur,    365, Weapon, Slot_RightHand, Requires_Ammo},
	{!"Gesintuvas",             6000 g, 120 eur,   366, Weapon, Slot_RightHand, DefaultFlags},
	{!"Kamera",                  300 g, 200 eur,   367, Weapon, Slot_RightHand, DefaultFlags},
	
	{!"Kulku paketas",             0 g, 100 eur,  3014, Ammo, Slot_None, DefaultFlags},

	{!"Senas dienorastis",       250 g, 0 eur, 0, Quest, Slot_None, DefaultFlags}
};
static HashMap:m_Item<>, m_ItemData[sizeof s_Item][E_ITEM];

hook OnScriptInit() {
	HashMap_Init(m_Item, m_ItemData, E_ITEM_HASH_MAP);

	for(new i; i < sizeof s_Item; ++i) {
		HashMap_Add(m_Item, s_Item[i][E_ITEM_NAME], i);
	}
}

SetItemDefaultWeight(name[], weight) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return false;
	}
	s_Item[idx][E_ITEM_DATA_WEIGHT] = weight;

	return true;
}

GetItemDefaultWeight(name[]) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return 0;
	}
	return s_Item[idx][E_ITEM_DATA_WEIGHT];
}

SetItemDefaultPrice(name[], price) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return false;
	}
	s_Item[idx][E_ITEM_DATA_PRICE] = price;

	return true;
}

GetItemDefaultPrice(name[]) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return 0;
	}
	return s_Item[idx][E_ITEM_DATA_PRICE];
}

GetItemDefaultEquipmentSlot(name[]) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return Slot_None;
	}
	return s_Item[idx][E_ITEM_DATA_SLOT];
}

GetItemDefaultFlags(name[]) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return 0;
	}
	return s_Item[idx][E_ITEM_DATA_FLAGS];
}

GetItemDefaultModel(name[]) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return 0;
	}
	return s_Item[idx][E_ITEM_DATA_MODEL];
}

SetItemDefaultType(name[], type) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return false;
	}
	s_Item[idx][E_ITEM_DATA_TYPE] = type;

	return true;
}

GetItemDefaultType(name[]) {
	new idx = HashMap_Get(m_Item, name);
	if(idx == -1) {
		return 0;
	}
	return s_Item[idx][E_ITEM_DATA_TYPE];
}

GetItemColor(Item:uiid, name_[] = "") {
	new name[32];
	if( ! isnull(name_)) {
		strset(name, name_);
	}
	GetItemName(uiid, name, 32);

	switch(GetItemDefaultType(name)) {
		case Weapon: return 0xE74C3CFF;
		case Ammo: return 0x9B59B6FF;
		case Food: return 0xF39C12FF;
	}
	return 0xFFFFFFFF;
}

GetItemTypeName(type) {
	new name[32];
	switch(type) {
		case Weapon: name = "Ginklas";
		case Ammo: name = "Kulkos";
		case Food: name = "Maistas";
	}
	return name;
}

DisplayItemInfo(playerid, Item:item) {
	new item_name[32];
	GetItemName(item, item_name);

	inline response(re, li) {
		#pragma unused re, li
	}

	format(g_DialogText, _, "Informacija\t ");

	dialogAddLine("%s\t ", item_name);
	dialogAddLine("Tipas\t%s", GetItemTypeName(GetItemDefaultType(item_name)));

	call OnGenerateItemInfo(_:item);

	dialogShow(playerid, using inline response, DIALOG_STYLE_TABLIST_HEADERS, " ", g_DialogText, "Uþdaryti", "");
}

GetItemType(type[]) {
	if( ! strcmp(type, "Weapon")) {
		return Weapon;
	}
	if( ! strcmp(type, "Ammo")) {
		return Ammo;
	}
	if( ! strcmp(type, "Food")) {
		return Food;
	}
	if( ! strcmp(type, "Key")) {
		return Key;
	}
	if( ! strcmp(type, "Quest")) {
		return Quest;
	}
	return None;
}