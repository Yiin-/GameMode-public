#include <YSI\y_hooks>

static area;

hook OnGameModeInit() {
	static Float:points[] = {
		1284.7810,211.9590,
		1327.6036,190.7218,
		1308.7396,130.5815,
		1257.4471,145.4433
	};
	area = CreateDynamicPolygon(points);

	LoadForSaleVehicles();
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	if(areaid == area) {
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
			new vehicleid = GetPlayerVehicleID(playerid);

			if(GetVehicleOwner(vehicleid) == GetPlayerCharID(playerid)) {
				player_ShowInfoText(playerid, "Esi masinu pardavimo aiksteleje.~n~Noredamas parduoti savo masina, pastatyk ja matomoje vietoje ir rasyk ~g~~h~/parduoti [kaina]");
			}
			else {
				player_ShowInfoText(playerid, "Esi masinu pardavimo aiksteleje. Turi buti savo masinoje noredamas ja parduoti.");
			}
		}
		else {
			player_ShowInfoText(playerid, "Esi masinu pardavimo aiksteleje. Turi buti savo masinoje noredamas ja parduoti.");
		}
	}
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
	if(areaid == area) {
		#if defined player_HideInfoText // vëliau pakeisti, kai sujungsiu branches
			player_HideInfoText(playerid);
		#endif
	}
}

CMD:parduoti(playerid, params[]) {
	static vehicleid;

	if( ! IsPlayerInDynamicArea(playerid, area)) {
		return M:P:E(playerid, "Nesi maðinø pardavimo aikðtelëje.");
	}
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
		return M:P:E(playerid, "Turi sedëti savo maðinoje norëdamas jà parduoti.");
	}
	if(GetVehicleOwner((vehicleid = GetPlayerVehicleID(playerid))) != GetPlayerCharID(playerid)) {
		return M:P:E(playerid, "Turi sedëti savo maðinoje norëdamas jà parduoti.");
	}

	new price = strval(params);

	if(price < 1) {
		return M:P:E(playerid, "Kaina negali bûti maþesnë negu [number]1[]€.");
	}
	inline confirm(re, li) {
		#pragma unused li
		if(re) {
			RemovePlayerFromVehicle(playerid);
			PutVehicleForSale(vehicleid, price);
			M:P:G(playerid, "Maðina parduodama.");
		}
		else {
			M:P:G(playerid, "Sëkmingai atðaukei maðinos pardavimà.");
		}
	}
	format(g_DialogText, _, "Ar tikrai nori parduoti ðià maðinà uþ %i €?", price);
	dialogShow(playerid, using inline confirm, DIALOG_STYLE_MSGBOX, "Maðinos pardavimas", g_DialogText, "Taip", "Atðaukti");

	return true;
}

static LoadForSaleVehicles() {
	format_query("SELECT * FROM vehicles WHERE status = %i", VEHICLE_STATUS_FORSALE);
	new Cache:cache = mysql_query(database, query);

	new i, count;

	if((count = cache_get_row_count())) do {
		LoadVehicle(.row = i);
	}
	while(++i < count);

	cache_delete(cache);
}

static PutVehicleForSale(vehicleid, price) {
	SetVehicleStatus(vehicleid, VEHICLE_STATUS_FORSALE);
	SetVehiclePrice(vehicleid, price);
	SaveVehicle(vehicleid);
}