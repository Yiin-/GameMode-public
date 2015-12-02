#include <YSI\y_hooks>

new player_MiniJob[MAX_PLAYERS];

hook OnCreatePlayerORM(ORM:ormid, playerid) {
	orm_addvar_int(ormid, player_MiniJob[playerid], "minijob");
}

CMD:paliktild(playerid, unused[]) {
	if(IsPlayerWorking(playerid)) {
		M:P:G(playerid, "Sëkmingai palikai savo laikinà darbà!");

		SetPlayerMiniJob(playerid, NONE);
	}
	else {
		M:P:E(playerid, "Nedirbi jokiame laikiname darbe.");
	}
	return true;
}

GetPlayerMiniJob(playerid) {
	return player_MiniJob[playerid];
}

SetPlayerMiniJob(playerid, value) {
	player_MiniJob[playerid] = value;
}

IsPlayerWorking(playerid, minijob = NONE) {
	return (minijob == NONE) ? (GetPlayerMiniJob(playerid) != NONE) : (GetPlayerMiniJob(playerid) == minijob);
}