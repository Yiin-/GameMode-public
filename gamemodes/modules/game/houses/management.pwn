#include <YSI\y_hooks>

// development

CMD:h(playerid, type[]) {
	if(player_Admin[playerid] != YIIN) {
		return false;
	}
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	new houseid;

	if((houseid = CreateHouse(strval(type), x, y, z) != NONE)) {
		M:P:G(playerid, "Namas (id: %i) sëkmingai sukurtas!", houseid);
	}
	else {
		M:P:E(playerid, "Namo sukurti nepavyko.");
	}
	return true;
}

CMD:d(playerid, id[]) {
	if(player_Admin[playerid] != YIIN) {
		return false;
	}
	DeleteHouse(strval(id));
	M:P:G(playerid, "Namas (id: %s) panaikintas.", id);
	
	return true;
}