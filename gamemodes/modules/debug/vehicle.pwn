#include <YSI_Coding\y_hooks>

new soloVehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};

CMD:car(playerid, params[]) {
	extract params -> new model, owner_type;

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	new vehicleid = AddVehicle(model, owner_type, x, y, z, a, .owner = GetPlayerCharID(playerid));

	if( ! owner_type) {
		if(soloVehicle[playerid] != INVALID_VEHICLE_ID) {
			DeleteVehicle(soloVehicle[playerid]);
		}
		soloVehicle[playerid] = vehicleid;
	}
	PutPlayerInVehicle(playerid, vehicleid, 0);

	return 1;
}

hook OnVehicleDeath(vehicleid, killerid) {
	foreach(new i : Player) {
		if(soloVehicle[i] == vehicleid) {
			soloVehicle[i] = INVALID_VEHICLE_ID;
		}
	}
}

hook OnGameModeExit() {
	foreach(new i : Player) {
		if(soloVehicle[i] != INVALID_VEHICLE_ID) {
			DeleteVehicle(soloVehicle[i]);
		}
	}
}

hook OnCharacterDespawn(playerid) {
	if(soloVehicle[playerid] != INVALID_VEHICLE_ID) {
		DeleteVehicle(soloVehicle[playerid]);
	}
}