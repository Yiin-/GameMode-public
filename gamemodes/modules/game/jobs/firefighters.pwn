#include <YSI_Coding\y_hooks>

new fires_extinguished[MAX_PLAYERS];

hook OnGameModeInit() {
	#if defined ADD_VEHICLES
	AddVehicle(407, VEHICLE_OWNER_TYPE_JOB, 1306.9338,391.8403,19.7667,155.0823,3,1, .owner = JOB_FIRE);
	AddVehicle(407, VEHICLE_OWNER_TYPE_JOB, 1311.8921,389.5751,19.7660,155.8780,3,1, .owner = JOB_FIRE);
	AddVehicle(407, VEHICLE_OWNER_TYPE_JOB, 1317.0983,387.1867,19.7658,155.6298,3,1, .owner = JOB_FIRE);
	AddVehicle(407, VEHICLE_OWNER_TYPE_JOB, 1322.6145,384.8171,19.7670,155.8234,3,1, .owner = JOB_FIRE);
	#endif
}

hook OnCreatePlayerORM(ORM:ormid, playerid) {
	orm_addvar_int(ormid, fires_extinguished[playerid], "fires_extinguished");
}

hook OnResetPlayerVars(playerid) {
	fires_extinguished[playerid] = 0;
}

hook OnPlayerExtinguishFire(playerid) {
	if(IsPlayerFirefighter(playerid)) {
		GivePlayerJobExp(playerid, 20);
	}
	fires_extinguished[playerid]++;
	M:P:G(playerid, "Ugnis sëkmingai uþgæsinta.");
}

IsPlayerFirefighter(playerid) {
	return player_Job[playerid] == JOB_FIRE;
}