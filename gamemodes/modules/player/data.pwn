/*
 * player/data
 *
 * Þaidëjo informacija
 */

#include <YSI_Coding\y_hooks>

forward ORM:GetPlayerORM(playerid);

enum {
	PLAYER_STATE_INHOSPITAL = 1,
	PLAYER_STATE_DYING1, // katik mirë
	PLAYER_STATE_DYING2 // laukia medikø
};

new // temp data 
	player_Teleporting[MAX_PLAYERS char]
;

enum { // admin lygiai
	YIIN = 255
};

new 
	player_AccountName[MAX_PLAYERS][MAX_PLAYER_NAME],
	player_Name[MAX_PLAYERS][MAX_PLAYER_NAME],

	player_Admin[MAX_PLAYERS],

	player_LastVehicle[MAX_PLAYERS],
	
	player_CreationTimestamp[MAX_PLAYERS],

	player_AccountID[MAX_PLAYERS],
	ORM:player_ORM[MAX_PLAYERS],
	char_ID[MAX_PLAYERS],

	Float:player_Health[MAX_PLAYERS],
	Float:player_MaxHealth[MAX_PLAYERS],

	player_DefaultSkin[MAX_PLAYERS],
	player_AvailableSkins[MAX_PLAYERS][300 char],
	player_CurrentSkin[MAX_PLAYERS],

	player_Cash[MAX_PLAYERS],
	player_Bank[MAX_PLAYERS],
	player_BankPin[MAX_PLAYERS],
	player_JobSalary[MAX_PLAYERS],

	player_Wanted[MAX_PLAYERS],

	player_State[MAX_PLAYERS],

	// game/jobs/police
	player_IsInJail[MAX_PLAYERS],
	player_JailTime_Wait[MAX_PLAYERS],
	player_JailTime_Start[MAX_PLAYERS],
	player_JailType[MAX_PLAYERS],
	player_JailRoom[MAX_PLAYERS],

	// game/jobs
	player_Job[MAX_PLAYERS],
	player_JobRank[MAX_PLAYERS],
	player_JobExp[MAX_PLAYERS][JOB_COUNT],
	player_JobExpString[MAX_PLAYERS][200],

	Float:player_PosX[MAX_PLAYERS],
	Float:player_PosY[MAX_PLAYERS],
	Float:player_PosZ[MAX_PLAYERS],
	Float:player_PosA[MAX_PLAYERS]
;

playerData_ApplyData(playerid) {
	SetPlayerVirtualWorld(playerid, VW_DEFAULT);
	SetPlayerPos(playerid, 
		player_PosX[playerid], 
		player_PosY[playerid], 
		player_PosZ[playerid]);
	SetPlayerFacingAngle(playerid, 
		player_PosA[playerid]);
	SetCameraBehindPlayer(playerid);
	SetPlayerSkin(playerid, player_CurrentSkin[playerid]);

	SetPlayerCash(playerid, player_Cash[playerid]);

	UpdatePlayerHealth(playerid);
	player_SetWanted(playerid, player_Wanted[playerid]);
}

playerData_LoadChar(playerid) {
	GetPlayerName(playerid, player_Name[playerid], MAX_PLAYER_NAME);
	new ORM:ormid = player_ORM[playerid] = orm_create("chars");

	orm_addvar_int(ormid, char_ID[playerid], "uid");
	orm_addvar_int(ormid, player_AccountID[playerid], "user_id");
	orm_addvar_int(ormid, player_Admin[playerid], "admin");
	orm_addvar_string(ormid, player_Name[playerid], MAX_PLAYER_NAME + 1, "name");

	orm_addvar_float(ormid, player_Health[playerid], "health");
	orm_addvar_float(ormid, player_MaxHealth[playerid], "max_health");

	orm_addvar_int(ormid, player_DefaultSkin[playerid], "default_skin");
	orm_addvar_int(ormid, player_CurrentSkin[playerid], "current_skin");
	orm_addvar_string(ormid, player_AvailableSkins[playerid], 301, "available_skins");

	orm_addvar_int(ormid, player_Cash[playerid], "cash");
	orm_addvar_int(ormid, player_Bank[playerid], "bank");
	orm_addvar_int(ormid, player_BankPin[playerid], "bank_pin");
	orm_addvar_int(ormid, player_JobSalary[playerid], "salary");

	orm_addvar_int(ormid, player_Wanted[playerid], "wanted");

	orm_addvar_int(ormid, player_State[playerid], "state");

	orm_addvar_int(ormid, player_IsInJail[playerid], "jailed");
	orm_addvar_int(ormid, player_JailTime_Wait[playerid], "jail_time_wait");
	orm_addvar_int(ormid, player_JailTime_Start[playerid], "jail_time_start");
	orm_addvar_int(ormid, player_JailType[playerid], "jail_type");
	orm_addvar_int(ormid, player_JailRoom[playerid], "jail_room");

	orm_addvar_int(ormid, player_Job[playerid], "job");
	orm_addvar_int(ormid, player_JobRank[playerid], "job_rank");
	orm_addvar_string(ormid, player_JobExpString[playerid], 200, "job_exp");

	orm_addvar_float(ormid, player_PosX[playerid], "posX");
	orm_addvar_float(ormid, player_PosY[playerid], "posY");
	orm_addvar_float(ormid, player_PosZ[playerid], "posZ");
	orm_addvar_float(ormid, player_PosA[playerid], "angle");

	orm_addvar_int(ormid, player_CreationTimestamp[playerid], "creation_timestamp");

	CallLocalFunction("OnCreatePlayerORM", "ii", _:ormid, playerid);
	
	orm_setkey(ormid, "name");
	orm_select(ormid, "OnPlayerDataLoad", "d", playerid);
}

forward OnPlayerDataLoad(playerid); 
public OnPlayerDataLoad(playerid)
{
	switch(orm_errno(GetPlayerORM(playerid))) 
	{
		case ERROR_OK: {
			sscanf(player_JobExpString[playerid], F:0("p<,>a<i>[%i]", JOB_COUNT), player_JobExp[playerid][0]);
			gameStart_Spawn(playerid);
			
			call OnPlayerDataLoaded(playerid);
		}
		case ERROR_NO_DATA: {
			// OnCharacterCreated: player\class-selection.pwn
			orm_insert(GetPlayerORM(playerid), "OnCharacterCreated", "i", playerid);
		}
	}
	orm_setkey(GetPlayerORM(playerid), "uid");

	return 1;
}

playerData_SaveChar(playerid, update_pos = true) {
	if(char_ID[playerid] != 0) {
		if(update_pos && !GetPVarInt(playerid, "spectating")) {
			GetPlayerPos(playerid, 
				player_PosX[playerid], 
				player_PosY[playerid],
				player_PosZ[playerid]);
			GetPlayerFacingAngle(playerid, 
				player_PosA[playerid]);
		}
		format(player_JobExpString[playerid], 200, "%s", Array_to_String(player_JobExp[playerid], JOB_COUNT, ','));
		orm_update(GetPlayerORM(playerid));
	}
}

@yH_OnPlayerDisconnect@900(playerid, reason);
@yH_OnPlayerDisconnect@900(playerid, reason) {
	playerData_SaveChar(playerid);

	orm_destroy(GetPlayerORM(playerid));

	resetPlayerVars(playerid);
}

ORM:GetPlayerORM(playerid) {
	return player_ORM[playerid];
}

resetPlayerVars(playerid) {
	call OnCharacterDespawn(playerid);
	call OnResetPlayerVars(playerid);
	
	player_Name           [playerid][0] = EOS;
	player_ORM            [playerid] = ORM:0;
	char_ID               [playerid] = 0;
	player_Admin          {playerid} = 0;
	player_Health         [playerid] = 50.0;
	player_MaxHealth      [playerid] = 50.0;
	player_DefaultSkin    [playerid] = 0;
	for(new i; i < sizeof player_AvailableSkins[]; ++i) {
		player_AvailableSkins [playerid]{i} = 0;
	}
	player_CurrentSkin    [playerid] = 0;
	player_Cash           [playerid] = 0;
	player_Bank           [playerid] = 0;
	player_BankPin        [playerid] = 0;
	player_JobSalary	  [playerid] = 0;
	player_State          [playerid] = 0;
	player_Job            [playerid] = JOB_NONE;
	player_JobRank        [playerid] = 0;
	player_PosX           [playerid] = 0.0;
	player_PosY           [playerid] = 0.0;
	player_PosZ           [playerid] = 0.0;
	player_PosA           [playerid] = 0.0;
	player_CreationTimestamp [playerid] = 0;

	player_Wanted         [playerid] = 0;
	player_IsInJail       [playerid] = 0;
	player_JailTime_Wait  [playerid] = 0;
	player_JailTime_Start [playerid] = 0;
	player_JailType       [playerid] = 0;
	player_JailRoom       [playerid] = 0;

	//temp data
	player_Teleporting    {playerid} = 0;
}

Float:player_GetHealth(playerid) {
	return player_Health[playerid];
}

Float:GetPlayerMaxHealth(playerid) {
	return player_MaxHealth[playerid];
}

SetPlayerMaxHealth(playerid, Float:amount) {
	player_MaxHealth[playerid] = amount;
	UpdatePlayerHealth(playerid);
}

UpdatePlayerHealth(playerid, Float:adjust = 0.0, bool:reset = false) {
	if(reset) {
		player_Health[playerid] = 0;
	}
	player_Health[playerid] += adjust;
	player_Health[playerid] = fclamp(player_Health[playerid], 0.0, player_MaxHealth[playerid]);

	new Float:amount = max(player_Health[playerid] / player_MaxHealth[playerid] * 100.0, 1.0);

	if(IsPlayerNPC(playerid)) {
		#if defined _FCNPC_included

		if(player_Health[playerid] > 0.05) {
			FCNPC_SetHealth(playerid, amount);
		}
		#endif
	}
	else {
		SetPlayerHealth(playerid, amount);
		UI_UpdatePlayerHealth(playerid);
	}
}

SetPlayerCash(playerid, value) {
	if(GetPlayerMoney(playerid) != GetPlayerCash(playerid)) {
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, value);
	}
	else {
		GivePlayerMoney(playerid, value - GetPlayerCash(playerid));
	}
	player_Cash[playerid] = value;
	// ToDo: textdraw indicator?
}

GetPlayerCash(playerid) {
	return player_Cash[playerid];
}

AdjustPlayerCash(playerid, diff = 0) {
	if(diff) {
		call OnPlayerCashUpdate(playerid, diff);
	}
	SetPlayerCash(playerid, player_Cash[playerid] + diff);
	return GetPlayerCash(playerid);
}

hook OnPlayerSpawn(playerid) {
	UpdatePlayerHealth(playerid);
}

hook OnPlayerDamageDone(playerid, Float:amount, issuerid, weapon, bodypart) {
	UpdatePlayerHealth(playerid, -amount);
	return true;
}

GetPlayerCharID(playerid) {
	return char_ID[playerid];
}

player_SqlIdToPlayerID(sqlid) return player_SQL_ID_TO_PLAYER_ID(sqlid);
player_SQL_ID_TO_PLAYER_ID(sqlid) {
	foreach(new i : Player) {
		if(char_ID[i] == sqlid) {
			return i;
		}
	}
	return INVALID_PLAYER_ID;
}