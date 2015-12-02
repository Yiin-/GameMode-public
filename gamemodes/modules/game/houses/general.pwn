#include <YSI\y_hooks>

#define MAX_HOUSES 1000

// Namø tipai
enum {
	E_HOUSE_TYPE_ONE_FLOOR_SMALL, // nëra
	E_HOUSE_TYPE_ONE_FLOOR_MEDIUM, // MAP_House_1f_medium.pwn
	E_HOUSE_TYPE_ONE_FLOOR_LARGE, // nëra 

	E_HOUSE_TYPE_TWO_FLOORS_SMALL, // nëra
	E_HOUSE_TYPE_TWO_FLOORS_MEDIUM, // nëra
	E_HOUSE_TYPE_TWO_FLOORS_LARGE, // nëra

	E_HOUSE_TYPE_BUSSINESS_SMALL, // nëra
	E_HOUSE_TYPE_BUSSINESS_MEDIUM, // nëra
	E_HOUSE_TYPE_BUSSINESS_LARGE, // nëra

	E_HOUSE_TYPE_COUNT
};

// Namo bûsena
enum {
	E_HOUSE_STATE_FORSALE,
	E_HOUSE_STATE_OCCUPIED,
	E_HOUSE_STATE_FORRENT,
	E_HOUSE_STATE_RENTED
};

static
	Iterator:house_Iterator<MAX_HOUSES>,
	house_Entrance[MAX_HOUSES],
	house_Tenant[MAX_HOUSES],
	house_Owner[MAX_HOUSES],
	house_RentPrice[MAX_HOUSES],
	house_Price[MAX_HOUSES],
	house_Locked[MAX_HOUSES],
	house_Type[MAX_HOUSES],
	house_State[MAX_HOUSES],

	Float:house_Exit_X[MAX_PLAYERS],
	Float:house_Exit_Y[MAX_PLAYERS],
	Float:house_Exit_Z[MAX_PLAYERS],

	current_house[MAX_PLAYERS] = {NONE, ...}
;

GetCurrentHouse(playerid) {
	return current_house[playerid];
}

hook OnPlayerDataLoaded(playerid) {
	new houseid = GetCurrentHouse(playerid);
	if(houseid != NONE) {
		KickPlayerFromHouse(playerid);
	}
}

hook OnCreatePlayerORM(ORM:ormid, playerid) {
	orm_addvar_float(ormid, house_Exit_X[playerid], "exit_x");
	orm_addvar_float(ormid, house_Exit_Y[playerid], "exit_y");
	orm_addvar_float(ormid, house_Exit_Z[playerid], "exit_z");

	orm_addvar_int(ormid, current_house[playerid], "current_house");
}

hook OnResetPlayerVars(playerid) {
	current_house[playerid] = NONE;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(current_house[playerid] != NONE) {
		new houseid = current_house[playerid];

		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && PRESSED(KEY_FIRE)) {
			if(HasPermission(playerid, "House", "lock", .id = houseid)) {
				if(house_Locked[houseid] ^= 1) {
					M:P:G(playerid, "Uþrakinai duris.");
				}
				else {
					M:P:G(playerid, "Atrakinai duris.");
				}
				ShowHouseLockText(playerid, houseid);
			}
		}
	}
}

hook OnPlayerLeaveEntrance(playerid, entranceid) {
	new x = current_house[playerid];
	if(x != NONE) {
		if(house_Entrance[x] == entranceid) {
			current_house[playerid] = NONE;
		}
	}
}

hook OnPlayerEnterEntrance(playerid, entranceid) {
	foreach(new i : house_Iterator) {
		if(house_Entrance[i] == entranceid) {
			current_house[playerid] = i;

			ShowEntranceText_Type(playerid, entranceid);

			if( ! HasPermission(playerid, "House", "enter", .id = i)) {
				return false;
			}
			if(HasPermission(playerid, "House", "lock", .id = i)) {
				ShowHouseLockText(playerid, i);
			}
			ShowEntranceText_HowTo(playerid, entranceid);
			ShowEntranceText_Action(playerid, entranceid);
		}
	}
	return true;
}
hook OnPlayerUseEntrance(playerid, entranceid) {
	foreach(new i : house_Iterator) {
		if(house_Entrance[i] == entranceid) {
			switch(GetHouseState(i)) {
				case E_HOUSE_STATE_FORSALE: {
					M:P:I(playerid, "Patalpos yra parduodamos, todël turi galimybæ apþiûrëti vidø.");
				}
				case E_HOUSE_STATE_OCCUPIED: {
					if(house_Locked[i]) {
						return false;
					}
				}
				case E_HOUSE_STATE_FORRENT: {
					M:P:I(playerid, "Patalpos yra iðnuomojamos, todël turi galimybæ apþiûrëti vidø.");
				}
				case E_HOUSE_STATE_RENTED: {
					if(house_Locked[i]) {
						return false;
					}
				}
			}
			call OnPlayerEnterHouse(playerid, i);
		}
		else {
			if(GetEntranceDestination(entranceid) == house_Entrance[i]) {
				call OnPlayerLeftHouse(playerid, i);
			}
		}
	}
	return true;
}

hook OnPlayerEnterHouse(playerid, houseid) {
	M:P:X(playerid, "Áëjai á namà.");

	switch(GetHouseState(houseid)) {
		case E_HOUSE_STATE_FORSALE: {
			M:P:I(playerid, "Nusipirkæs namà gali jo interjerà keisti kaip tik nori - pirkti/parduoti baldus, keisti sienø ir lubø spalvas.");
		}
		case E_HOUSE_STATE_FORRENT: {
			M:P:I(playerid, "Iðsinuomavæs namà gali keisti jo interjerà - pirkti/parduoti naujus baldus, taèiau parduoti jau esanèiø baldø negali.");
		}
	}

	GetEntrancePosition(house_Entrance[houseid], 
		house_Exit_X[playerid],
		house_Exit_Y[playerid],
		house_Exit_Z[playerid]
	);
}

hook OnPlayerLeftHouse(playerid, houseid) {
	M:P:X(playerid, "Iðëjai ið namo.");
	current_house[playerid] = NONE;
}

ShowHouseLockText(playerid, i) {
	new entranceid = house_Entrance[i];

	if(house_Locked[i]) {
		SetEntranceText_Lock(entranceid, "Atrakinti nama gali paspaudes ~r~k. peles mygtuka.");
	}
	else {
		SetEntranceText_Lock(entranceid, "Uzrakinti nama gali paspaudes ~r~k. peles mygtuka.");
	}
	ShowEntranceText_Lock(playerid, entranceid);
}

GetPlayerCurrentHouseInterior(playerid) {
	static Float:x, Float:y, Float:z;
	foreach(new i : Limit(E_HOUSE_TYPE_COUNT)) {
		GetInteriorPosition(i, x, y, z);

		if(IsPlayerInRangeOfPoint(playerid, 50.0, x, y, z)) {
			return i;
		}
	}
	return NONE;
}

IsPlayerInAnyHouse(playerid) {
	return GetCurrentHouse(playerid) != NONE;
}

IsPlayerInHouse(playerid, houseid) {
	if(GetPlayerVirtualWorld(playerid) == houseid) {
		static Float:x, Float:y, Float:z;
		GetInteriorPosition(house_Type[houseid], x, y, z);

		if(IsPlayerInRangeOfPoint(playerid, 50.0, x, y, z)) {
			return true;
		}
	}
	return false;
}

IsPlayerInHisHouse(playerid) {
	new houseid = GetPlayerVirtualWorld(playerid);

	if(houseid >= 0 && houseid < MAX_HOUSES) {
		if(house_Owner[houseid] == GetPlayerCharID(playerid)) {
			static Float:x, Float:y, Float:z;
			GetInteriorPosition(house_Type[houseid], x, y, z);

			if(IsPlayerInRangeOfPoint(playerid, 50.0, x, y, z)) {
				return true;
			}
		}
	}
	return false;
}

KickPlayerFromHouse(playerid) {
	player_Teleport(playerid, house_Exit_X[playerid], house_Exit_Y[playerid], house_Exit_Z[playerid]);
	current_house[playerid] = NONE;
}

GenerateHousePrice(type) {
	if(type == E_HOUSE_TYPE_ONE_FLOOR_SMALL) {
		return random(3000) + 8000;
	}
	else {
		return GenerateHousePrice(type - 1) + random(type * 1000);
	}
}

GenerateBussinessText(houseid, text[], len = sizeof text) {
	strcat(text, "{ffffff}Tipas: ", len);
	switch(house_Type[houseid]) {
		case E_HOUSE_TYPE_BUSSINESS_SMALL: {
			strcat(text, "{f1c40f}Patalpos verslui (maþos)", len);
		}
		case E_HOUSE_TYPE_BUSSINESS_MEDIUM: {
			strcat(text, "{f1c40f}Patalpos verslui (vidutinës)", len);
		}
		case E_HOUSE_TYPE_BUSSINESS_LARGE: {
			strcat(text, "{f1c40f}Patalpos verslui (didelës)", len);
		}
	}
}

GenerateHouseText(houseid) {
	new text[500];

	switch(house_Type[houseid]) {
		case E_HOUSE_TYPE_BUSSINESS_SMALL, E_HOUSE_TYPE_BUSSINESS_MEDIUM, E_HOUSE_TYPE_BUSSINESS_LARGE: {
			GenerateBussinessText(houseid, text);
		}
		default: {
			strcat(text, "{ffffff}Tipas: ");
			strcat(text, GetHouseTypeText(houseid));
			strcat(text, "\n");

			strcat(text, "{ffffff}Durys: ");
			strcat(text, house_Locked[houseid] ? ("{e74c3c}Uþrakintos") : ("{2ecc71}Atrakintos"));
			strcat(text, "\n");

			strcat(text, "{ffffff}Patalpø bûsena: ");
			switch(house_State[houseid]) {
				case E_HOUSE_STATE_FORSALE: {
					strcat(text, "{1abc9c}Parduodamos");
				}
				case E_HOUSE_STATE_OCCUPIED: {
					strcat(text, "{e74c3c}Uþimtos");
				}
				case E_HOUSE_STATE_FORRENT: {
					strcat(text, "{1abc9c}Nuomojamos");
				}
				case E_HOUSE_STATE_RENTED: {
					strcat(text, "{e74c3c}Uþimtos (iðnuomota)");
				}
			}
			strcat(text, "\n");

			switch(house_State[houseid]) {
				case E_HOUSE_STATE_FORSALE: {
					strcat(text, "{ffffff}Kaina: ");
					strcat(text, F:0("{2ecc71}%i{ffffff}€", house_Price[houseid]));
					strcat(text, "\n");
				}
				case E_HOUSE_STATE_FORRENT, E_HOUSE_STATE_OCCUPIED, E_HOUSE_STATE_RENTED: {
					strcat(text, "{ffffff}Savininkas: ");

					new owner_name[MAX_PLAYER_NAME];

					format_query("SELECT name FROM chars WHERE uid = %i", house_Owner[houseid]);
					new Cache:cache = mysql_query(database, query);

					if(cache_get_row_count()) {
						cache_get_field_content(0, "name", owner_name);
					}
					else {
						strset(owner_name, "Neþinomas");
					}
					strcat(text, F:0("{e74c3c}%s", owner_name));
					strcat(text, "\n");

					cache_delete(cache);

					if(house_State[houseid] == E_HOUSE_STATE_FORRENT) {
						strcat(text, "{ffffff}Nuomos kaina: ");
						strcat(text, F:0("{2ecc71}%i{ffffff}€", house_RentPrice[houseid]));
						strcat(text, "\n");
					}
					else if(house_State[houseid] == E_HOUSE_STATE_RENTED) {
						strcat(text, "{ffffff}Nuomininkas: ");

						new tenant_name[MAX_PLAYER_NAME];

						format_query("SELECT name FROM chars WHERE uid = %i", house_Tenant[houseid]);
						cache = mysql_query(database, query);

						if(cache_get_row_count()) {
							cache_get_field_content(0, "name", tenant_name);
						}
						else {
							strset(tenant_name, "Neþinomas");
						}
						strcat(text, F:0("{e74c3c}%s", tenant_name));
						strcat(text, "\n");

						cache_delete(cache);
					}
				}
			}
		}
	}

	return text;
}

GenerateHouseActionText(houseid) {
	new text[100];

	switch(house_State[houseid]) {
		case E_HOUSE_STATE_FORRENT: {
			strcat(text, "Noredamas issinuomoti sias patalpas, rasyk ~g~~h~/nuomotis");
		}
		case E_HOUSE_STATE_FORSALE: {
			strcat(text, "Noredamas nusipirkti sias patalpas, rasyk ~g~~h~/pirkti");
		}
	}

	return text;
}

UpdateHouseLabel(houseid) {
	static text[500];

	format(text, _, "%s", GenerateHouseText(houseid));

	SetEntranceText(house_Entrance[houseid], text);
}

CreateHouseEntrance(houseid, Float:x, Float:y, Float:z) {
	M:G:I("CreateHouseEntrance called: %i, %f, %f, %f", houseid, x, y, z);

	new model = house_Locked[houseid] ? entrance_pickup_model_locked : entrance_pickup_model_unlocked;
	new outside = CreateEntrance
	(
		x, y, z, 
		.model = model, 
		.text_type = GetHouseTypeText(houseid, false),
		.text_custom_label = GenerateHouseText(houseid), 
		.text_action = GenerateHouseActionText(houseid),
		._show_howto_to_all = false
	);

	if(outside != NONE) {
		new Float:ix, Float:iy, Float:iz;
		GetInteriorPosition(house_Type[houseid], ix, iy, iz);

		new inside = CreateEntrance(
			ix, iy, iz, 
			"Iðëjimas", 
			outside,
			.vw = houseid
		);
		M:G:I("inside: %i", inside);
		
		if(inside != NONE) {
			SetEntranceDestination(outside, inside);
		}
	}

	house_Entrance[houseid] = outside;
}

SetupHouse(
	index,
	type, 
	price = NONE, 
	rent_price = NONE, 
	owner = NONE, 
	tenant = NONE, 
	locked = true,
	house_state = E_HOUSE_STATE_FORSALE,
	Float:x, 
	Float:y, 
	Float:z
) {
	house_Tenant[index] = tenant;
	house_Owner[index] = owner;
	house_RentPrice[index] = rent_price;
	house_Price[index] = price;
	house_Locked[index] = locked;
	house_Type[index] = type;
	house_State[index] = house_state;

	CreateHouseEntrance(index, x, y, z);

	Iter_Add(house_Iterator, index);
}

CreateHouse(type, Float:x, Float:y, Float:z, price = NONE, owner = NONE) {
	if(Iter_Count(house_Iterator) == MAX_HOUSES) {
		return NONE;
	}
	if(price == NONE) {
		price = GenerateHousePrice(type);
	}

	format_query("INSERT INTO houses (type, price, x, y, z, locked) VALUES (%i, %i, %f, %f, %f, 1)",
		type, price, x, y, z);

	new Cache:cache = mysql_query(database, query);

	new index = cache_insert_id();

	cache_delete(cache);

	SetupHouse(
		.index = index,
		.type = type, 
		.price = price,
		.owner = owner,
		.locked = true,
		.x = x,
		.y = y,
		.z = z
	);

	return index;
}

DeleteHouse(houseid) {
	format_query("DELETE FROM houses WHERE uid = %i", houseid);
	mysql_query(database, query, false);

	Iter_Remove(house_Iterator, houseid);

	DeleteEntrance(house_Entrance[houseid], true);
}

SaveHouse(houseid, threaded = true, reload = false) {
	format_query("\
		UPDATE                           \
			houses                       \
		SET                              \
			price = %i,                  \
			rent_price = %i,             \
			owner = %i,                  \
			tenant = %i,                 \
			locked = %i,                 \
			house_state = %i             \
		WHERE                            \
			uid = %i                     \
		",
		house_RentPrice[houseid],
		house_Price[houseid],
		house_Owner[houseid],
		house_Tenant[houseid],
		house_Locked[houseid],
		house_State[houseid],
		houseid
	);
	if(threaded) {
		if(reload) {
			mysql_tquery(database, query, "OnHouseSaved");
		}
		else {
			mysql_tquery(database, query);
		}
	}
	else {
		mysql_query(database, query, false);

		if(reload) {
			UnloadHouse(houseid);
			LoadHouse(houseid, .do_query = true);
		}
	}
}

UnloadHouse(houseid, remove_quests = false) {
	if(remove_quests) {
		foreach(new i : Player) {
			if(IsPlayerInHouse(i, houseid)) {
				KickPlayerFromHouse(i);
			}
		}
	}
	DeleteEntrance(house_Entrance[houseid], true);
}

LoadHouse(houseid = NONE, row = NONE, do_query = false) {
	new Cache:cache;
	if(do_query) {
		format_query("SELECT * FROM houses WHERE uid = %i", houseid);
		cache = mysql_query(database, query);

		if(cache_get_row_count()) {
			row = 0;
		}
	}
	if(row != NONE) {
		SetupHouse(
			.index = cache_get_field_content_int(row, "uid"),
			.type = cache_get_field_content_int(row, "type"),
			.price = cache_get_field_content_int(row, "price"),
			.rent_price = cache_get_field_content_int(row, "rent_price"),
			.owner = cache_get_field_content_int(row, "owner"),
			.tenant = cache_get_field_content_int(row, "tenant"),
			.locked = cache_get_field_content_int(row, "locked"),
			.house_state = cache_get_field_content_int(row, "state"),
			.x = cache_get_field_content_float(row, "x"),
			.y = cache_get_field_content_float(row, "y"),
			.z = cache_get_field_content_float(row, "z")
		);
	}
	if(do_query) {
		cache_delete(cache);
	}
}

LoadHouses() {
	format_query("SELECT * FROM houses WHERE 1");
	new Cache:cache = mysql_query(database, query);

	new count = cache_get_row_count();
	if(count) foreach(new row : Limit(count)) {
		LoadHouse(.row = row);
	}
	cache_delete(cache);
}

hook OnGameModeInit() {
	LoadHouses();
}

// public

GetHouseState(houseid) {
	return house_State[houseid];
}
SetHouseState(houseid, house_state) {
	house_State[houseid] = house_state;
}
GetHousePrice(houseid) {
	return house_Price[houseid];
}
GetHouseRentPrice(houseid) {
	return house_RentPrice[houseid];
}
SetHouseOwner(houseid, charid) {
	house_Owner[houseid] = charid;
}
SetHouseTenant(houseid, charid) {
	house_Tenant[houseid] = charid;
}
GetHouseOwner(houseid) {
	return house_Owner[houseid];
}
GetHouseTenant(houseid) {
	return house_Tenant[houseid];
}

GetHouseTypeText(houseid, color = true) {
	new text[100];
	if(color) {
		strcat(text, "{1abc9c}");
	}
	switch(house_Type[houseid]) {
		case E_HOUSE_TYPE_ONE_FLOOR_SMALL: {
			strcat(text, "Gyvenamos patalpos (1 a., maþos)");
		}
		case E_HOUSE_TYPE_ONE_FLOOR_MEDIUM: {
			strcat(text, "Gyvenamos patalpos (1 a., vidutinës)");
		}
		case E_HOUSE_TYPE_ONE_FLOOR_LARGE: {
			strcat(text, "Gyvenamos patalpos (1 a., didelës)");
		}
		case E_HOUSE_TYPE_TWO_FLOORS_SMALL: {
			strcat(text, "Gyvenamos patalpos (2 a., maþos)");
		}
		case E_HOUSE_TYPE_TWO_FLOORS_MEDIUM: {
			strcat(text, "Gyvenamos patalpos (2 a., vidutinës)");
		}
		case E_HOUSE_TYPE_TWO_FLOORS_LARGE: {
			strcat(text, "Gyvenamos patalpos (2 a., didelës)");
		}
	}
	return text;
}