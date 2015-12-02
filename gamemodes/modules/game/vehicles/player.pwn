#include <YSI\y_hooks>

hook OnCharacterDespawn(playerid) {
	new charid = GetPlayerCharID(playerid);

	foreach(new i : Vehicle) {
		if(GetVehicleStatus(i) == VEHICLE_STATUS_ACTIVE) {
			if(GetVehicleOwnerType(i) == VEHICLE_OWNER_TYPE_PLAYER) {
				if(GetVehicleOwner(i) == charid) {
					SaveVehicle(i, .update_pos = true, .remove = true);
					M:P:X(playerid, "Iðsaugoma tavo maðina, id: [number]%i", i);
				}
			}
		}
	}
}

hook OnPlayerDataLoaded(playerid) {
	new vehicleid = LoadPlayerVehicle(playerid);

	if(vehicleid && vehicleid != INVALID_VEHICLE_ID) {
		M:P:X(playerid, "Maðinos ID: [number]%i[].", vehicleid);
	}
	else {
		M:P:X(playerid, "Neturi maðinos.");
	}
}

LoadPlayerVehicle(playerid) {
	format_query("SELECT * FROM vehicles WHERE owner_type = %i AND owner = %i AND status = %i",
		VEHICLE_OWNER_TYPE_PLAYER, GetPlayerCharID(playerid), VEHICLE_STATUS_ACTIVE);
	new Cache:cache = mysql_query(database, query);

	new ret = LoadVehicle();
	cache_delete(cache);

	return ret;
}