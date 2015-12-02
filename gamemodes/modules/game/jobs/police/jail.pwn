#include <YSI_Coding\y_hooks>

static sendToJailSphere;
static player_JailEscapeWarnings[MAX_PLAYERS];

hook OnGameModeInit() {
	sendToJailSphere = CreateDynamicSphereEx(611.6665,-587.0615,16.8860, 5.0, .maxplayers = 0);
	return true;
}

hook OnPlayerConnect(playerid) {
	player_JailEscapeWarnings[playerid] = 0;
	return true;
}

hook OnCharacterDespawn(playerid) {
	if(player_Job[playerid] == JOB_POLICE) {
		Streamer_RemoveArrayData(STREAMER_TYPE_AREA, sendToJailSphere, E_STREAMER_PLAYER_ID, playerid);
	}
}

hook OnPlayerSpawn(playerid) {
	if(player_Job[playerid] == JOB_POLICE) {
		Streamer_AppendArrayData(STREAMER_TYPE_AREA, sendToJailSphere, E_STREAMER_PLAYER_ID, playerid);
		Streamer_Update(playerid, STREAMER_TYPE_AREA);
	}
}

hook OnPlayerJoinJob(playerid, job) {
	if(job == JOB_POLICE) {
		Streamer_AppendArrayData(STREAMER_TYPE_AREA, sendToJailSphere, E_STREAMER_PLAYER_ID, playerid);
		Streamer_Update(playerid, STREAMER_TYPE_AREA);
	}
}

hook OnPlayerLeaveJob(playerid, job) {
	if(job == JOB_POLICE) {
		Streamer_RemoveArrayData(STREAMER_TYPE_AREA, sendToJailSphere, E_STREAMER_PLAYER_ID, playerid);
		Streamer_Update(playerid, STREAMER_TYPE_AREA);
	}
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	if(player_Job[playerid] != JOB_POLICE) {
		Streamer_RemoveArrayData(STREAMER_TYPE_AREA, sendToJailSphere, E_STREAMER_PLAYER_ID, playerid);
		Streamer_Update(playerid, STREAMER_TYPE_AREA);
		return true;
	}
	if(areaid == sendToJailSphere) {
		player_ShowInfoText(playerid, "Pasodinti nusikalteli i kalejima gali paspaudes ~y~ALT~w~~h~.");
	}
	return true;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(player_Job[playerid] != JOB_POLICE) {
		return true;
	}
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
		return true;
	}
	if(!IsPlayerInDynamicArea(playerid, sendToJailSphere, 1)) {
		return true;
	}
	if(PRESSED(KEY_FIRE)) {
		if(dialog_ShowPassengers(playerid, GetPlayerVehicleID(playerid))) {
			M:P:G(playerid, "Pasirink kurá nusikaltëlá nori pasodinti á kalëjimà.");
		}
		else {
			M:P:E(playerid, "Maðinoje nëra nei vieno nusikaltëlio.");
		}
	}
	return true;
}

jailPlayer(playerid, jail_type = jail_Small, bool:surrender = false)
{
	new time_in_jail;
	if(surrender)
		time_in_jail = floatround(Float:(player_GetWanted(playerid) * 6 * 2 * 0.7));
	else
		time_in_jail = player_GetWanted(playerid) * 6 * 2;

	if(player_IsInJail[playerid])
	{
		// þaidëjas jailintas, todël tiesiog pakeièiam jo pozicijà á vienà ið kamerø
		switch(player_JailType[playerid])
		{
			case jail_Big:
				player_Teleport(playerid, XYZ0(Position_BigJailSpawn[player_JailRoom[playerid]]));

			case jail_Small:
				player_Teleport(playerid, XYZ0(Position_SmallJailSpawn[player_JailRoom[playerid]]));
		}

	} else {

		player_IsInJail[playerid] = true;
		player_JailEscapeWarnings[playerid] = 0;

		player_ResetWanted(playerid);

		player_JailTime_Wait[playerid] = time_in_jail;
		player_JailTime_Start[playerid] = gettime();
		player_JailType[playerid] = jail_type;

		switch(jail_type)
		{
			case jail_Big:
			{
				new const k = random(sizeof Position_BigJailSpawn);
				player_JailRoom[playerid] = k;
				player_Teleport(playerid, XYZ0(Position_BigJailSpawn[k]));
			}
			case jail_Small:
			{
				new const k = random(sizeof Position_SmallJailSpawn);
				player_JailRoom[playerid] = k;
				player_Teleport(playerid, XYZ0(Position_SmallJailSpawn[k]));
			}
		}
	}

	return time_in_jail;
}

police_UnjailPlayer(playerid)
{
	PlayerTextDrawHide(playerid, PlayerTD_Jail[playerid]);
	player_IsInJail[playerid] = 0;

	player_Teleport(playerid, Position_JailExit);

	M:P:X(playerid, "Tavo kalëjimo laikas baigësi. Esi laisvas.");
}

IsPlayerNearJail(playerid) {
	return IsPlayerInDynamicArea(playerid, sendToJailSphere, 1);
}

forward police_JailCountDown();
public police_JailCountDown()
{
	foreach(new i : Player)
	{
		if(player_IsInJail[i])
		{
			if(player_JailTime_Start[i] + player_JailTime_Wait[i] >= gettime())
			{
				// jeigu þaidëjas nebëra savo kameroje
				if( ! IsPlayerInRangeOfPoint(i, 5, XYZ0(Position_SmallJailSpawn[ player_JailRoom[i] ]))
					&& player_State[i] != PLAYER_STATE_INHOSPITAL
					&& ! player_Teleporting{i}
				){
					if(++player_JailEscapeWarnings[i] > 1) {
						M:P:E(i, "Kick");
						// Kick(i);
					}
					// perkeliam ten kur jam vieta
					jailPlayer(i);
				}
				new h,m,s;
				SecToTime(player_JailTime_Start[i] + player_JailTime_Wait[i] - gettime(),h,m,s);

				new text[100]; format(text, sizeof text, "Esi ikalintas.~n~~y~%i~w~:~y~%i~w~.~y~%i", h,m,s);
				PlayerTextDrawSetString(i, PlayerTD_Jail[i], text);
				PlayerTextDrawShow(i, PlayerTD_Jail[i]);
			
			} else {

				police_UnjailPlayer(i);
			}
		
		} else {

			if(player_JailRoom[i] != -1) {
				if( ! IsPlayerInRangeOfPoint(i, 5, XYZ0(Position_SmallJailSpawn[ player_JailRoom[i] ]))) {
					player_JailRoom[i] = -1;
				}
			}
		}
	}
}