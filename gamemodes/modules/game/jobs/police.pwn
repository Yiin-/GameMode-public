#include <cuffs>
#include <YSI_Coding\y_hooks>

enum {
	jail_Small,
	jail_Big
};

new Text:TD_Wanted;
new PlayerText:PlayerTD_Wanted[MAX_PLAYERS];
new PlayerText:PlayerTD_Jail[MAX_PLAYERS];

new cachedTargetID[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};

hook OnGameModeInit() {
	SetTimer("police_JailCountDown", 250, true);

	TD_Wanted = TextDrawCreate(549.176269, 24.499998, "~r~~h~-~b~~h~-");
	TextDrawLetterSize(TD_Wanted, 1.280705, 4.181666);
	TextDrawAlignment(TD_Wanted, 1);
	TextDrawColor(TD_Wanted, -65281);
	TextDrawSetShadow(TD_Wanted, 0);
	TextDrawSetOutline(TD_Wanted, 1);
	TextDrawBackgroundColor(TD_Wanted, 0x000000FF);
	TextDrawFont(TD_Wanted, 2);
	TextDrawSetProportional(TD_Wanted, 1);

	#if defined ADD_VEHICLES
	AddVehicle(598, VEHICLE_OWNER_TYPE_JOB, 612.3608,-596.8831,16.9377,90.1743, .owner = JOB_POLICE);
	AddVehicle(598, VEHICLE_OWNER_TYPE_JOB, 614.1414,-601.3254,16.9353,90.6612, .owner = JOB_POLICE);
	AddVehicle(598, VEHICLE_OWNER_TYPE_JOB, 637.6381,-609.8079,16.0414,180.5046, .owner = JOB_POLICE);
	AddVehicle(598, VEHICLE_OWNER_TYPE_JOB, 632.9031,-609.8875,16.0404,184.0279, .owner = JOB_POLICE);
	AddVehicle(598, VEHICLE_OWNER_TYPE_JOB, 627.1943,-609.6891,16.3461,177.0517, .owner = JOB_POLICE);
	#endif
}

task wantedFlashing[200]() {
	static status;
	if((status ^= 1)) {
		TextDrawSetString(TD_Wanted, "~r~~h~-~b~~h~-");
	}
	else {
		TextDrawSetString(TD_Wanted, "~b~~h~-~r~~h~-");
	}
}

hook OnCharacterDespawn(playerid) {
	resetPoliceData(playerid);
}

hook OnPlayerConnect(playerid) {
	PlayerTD_Jail[playerid] = CreatePlayerTextDraw(playerid, 324.235107, 379.166809, "Esi ikalintas.~n~~y~5~w~h ~y~28~w~min.");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Jail[playerid], 0.241058, 1.454164);
	PlayerTextDrawAlignment(playerid, PlayerTD_Jail[playerid], 2);
	PlayerTextDrawColor(playerid, PlayerTD_Jail[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Jail[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Jail[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Jail[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Jail[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Jail[playerid], 1);

	PlayerTD_Wanted[playerid] = CreatePlayerTextDraw(playerid, 555.294189, 19.833311, "A");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Wanted[playerid], 0.687176, 2.154168);
	PlayerTextDrawAlignment(playerid, PlayerTD_Wanted[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Wanted[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Wanted[playerid], 1);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Wanted[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Wanted[playerid], 0x000000FF);
	PlayerTextDrawFont(playerid, PlayerTD_Wanted[playerid], 0);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Wanted[playerid], 1);
}

hook OnPlayerSpawn(playerid) {
	ApplyAnimation(playerid, "SMOKING", "null", 0.0, 0, 0, 0, 0, 0);
}

timer uncuff_End[6000](playerid) {
	TogglePlayerControllable(playerid, true);
	M:P:E(playerid, "Iðsilaisvinti nepavyko.");
}

timer uncuff_StartAnimation[300](playerid) {
	ApplyAnimation(playerid, "SMOKING", "M_smk_in", 4.1, 0, 1, 1, 0, 0, 1);
}

police_TypeByWanted(wanted)
{
	switch(wanted)
	{
		case 0: return ' ';
		case 1..15: return 'D';
		case 16..40: return 'C';
		case 41..70: return 'B';
		case 71..100: return 'A';
	}
	return 'S';
}

police_WantedByType(type)
{
	switch(type)
	{
		case 'S': return 100;
		case 'A': return 70;
		case 'B': return 40;
		case 'C': return 15;
		case 'D': return 0;
	}
	return 0xFFFF;
}

police_CashForWantedLevel() {
	return 12;
}

resetPoliceData(playerid) {
	player_SetWanted(playerid, 0);
	PlayerTextDrawHide(playerid, PlayerTD_Jail[playerid]);
	EnablePlayerCameraTarget(playerid, false);
}

player_GetWanted(playerid) {
	return player_Wanted[playerid];
}
player_SetWanted(playerid, val) {
	player_Wanted[playerid] = val;

	if(val > 0) {
		static text[2]; format(text, 2, "%c", police_TypeByWanted(val));
		PlayerTextDrawSetString(playerid, PlayerTD_Wanted[playerid], text);
		PlayerTextDrawShow(playerid, PlayerTD_Wanted[playerid]);
		TextDrawShowForPlayer(playerid, TD_Wanted);
	}
	else {
		PlayerTextDrawHide(playerid, PlayerTD_Wanted[playerid]);
		TextDrawHideForPlayer(playerid, TD_Wanted);
	}
}
player_ResetWanted(playerid) {
	player_SetWanted(playerid, 0);
}
player_AddWanted(playerid, val) {
	player_SetWanted(playerid, player_Wanted[playerid] += val);
}