#include <YSI_Coding\y_hooks>

static const const_playerUpdateIgnoreLimit = 5;

enum ac_BitList {
	bit_CheckSetPosition,
	bit_SetPositionFindZ,
	bit_CheckSpawnPosition
};

static
	BitArray:ac_Bits[MAX_PLAYERS]<ac_BitList>,

	ac_playerUpdateIgnoreCount[MAX_PLAYERS],

	ac_LastCheckTime[MAX_PLAYERS],

	ac_lastPosX[MAX_PLAYERS],
	ac_lastPosY[MAX_PLAYERS],
	ac_lastPosZ[MAX_PLAYERS],

	ac_oldPosX[MAX_PLAYERS],
	ac_oldPosY[MAX_PLAYERS],
	ac_oldPosZ[MAX_PLAYERS],

	ac_setPosX[MAX_PLAYERS],
	ac_setPosY[MAX_PLAYERS],
	ac_setPosZ[MAX_PLAYERS]
;

ac_TogglePlayerSpectate(playerid, toggle) {
	if( ! toggle) {
		GetPlayerPos(playerid, 
			ac_oldPosX[playerid],
			ac_oldPosY[playerid],
			ac_oldPosZ[playerid]
		);

		ac_setPosX[playerid] = x;
		ac_setPosY[playerid] = y;
		ac_setPosZ[playerid] = z;

		Bit_Set(ac_Bits[playerid], bit_CheckSpawnPosition, true);
	}

	return TogglePlayerSpectate(playerid, toggle);
}
#if defined _ALS_TogglePlayerSpectate
	#undef TogglePlayerSpectate
#else
	#define _ALS_TogglePlayerSpectate
#endif
#define TogglePlayerSpectate ac_TogglePlayerSpectate

ac_SpawnPlayer(playerid) {
	GetPlayerPos(playerid, 
		ac_oldPosX[playerid],
		ac_oldPosY[playerid],
		ac_oldPosZ[playerid]
	);

	ac_setPosX[playerid] = x;
	ac_setPosY[playerid] = y;
	ac_setPosZ[playerid] = z;

	Bit_Set(ac_Bits[playerid], bit_CheckSpawnPosition, true);

	return SpawnPlayer(playerid);
}
#if defined _ALS_SpawnPlayer
	#undef SpawnPlayer
#else
	#define _ALS_SpawnPlayer
#endif
#define SpawnPlayer ac_SpawnPlayer

ac_SetPlayerPos(playerid, Float:x, Float:y, Float:z) {
	GetPlayerPos(playerid, 
		ac_oldPosX[playerid],
		ac_oldPosY[playerid],
		ac_oldPosZ[playerid]
	);

	ac_setPosX[playerid] = x;
	ac_setPosY[playerid] = y;
	ac_setPosZ[playerid] = z;

	Bit_Set(ac_Bits[playerid], bit_CheckSetPosition, true);

	return SetPlayerPos(playerid, x, y, z);
}
#if defined _ALS_SetPlayerPos
	#undef SetPlayerPos
#else
	#define _ALS_SetPlayerPos
#endif
#define SetPlayerPos ac_SetPlayerPos

ac_SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z) {
	GetPlayerPos(playerid, 
		ac_oldPosX[playerid],
		ac_oldPosY[playerid],
		ac_oldPosZ[playerid]
	);

	ac_setPosX[playerid] = x;
	ac_setPosY[playerid] = y;
	ac_setPosZ[playerid] = FLOAT_INFINITY;

	Bit_Set(ac_Bits[playerid], bit_CheckSetPosition, true);
	Bit_Set(ac_Bits[playerid], bit_SetPositionFindZ, true);

	return SetPlayerPosFindZ(playerid, x, y, z);
}

#if defined _ALS_SetPlayerPosFindZ
	#undef SetPlayerPosFindZ
#else
	#define _ALS_SetPlayerPosFindZ
#endif
#define SetPlayerPosFindZ ac_SetPlayerPosFindZ

hook OnPlayerConnect(playerid) {
	Bit_ClearAll(ac_Bits[playerid]);

	ac_playerUpdateIgnoreCount[playerid] = 0;
	ac_LastCheckTime[playerid] = 0;
}

hook OnPlayerSpawn(playerid) {
	if(Bit_Get(ac_Bits[playerid], bit_PlayerJustDied) || Bit_Get(ac_Bits[playerid], bit_CheckSpawnPosition)) {
		Bit_Set(ac_Bits[playerid], bit_PlayerJustDied, false);
		Bit_Set(ac_Bits[playerid], bit_CheckSpawnPosition, false);

		GetPlayerPos(playerid, 
			ac_oldPosX[playerid],
			ac_oldPosY[playerid],
			ac_oldPosZ[playerid]
		);
		ac_lastPosX[playerid] = ac_oldPosX[playerid];
		ac_lastPosY[playerid] = ac_oldPosY[playerid];
		ac_lastPosZ[playerid] = ac_oldPosZ[playerid];
	}
}

hook OnPlayerUpdate(playerid) {
	if(Bit_Get(ac_Bits[playerid], bit_CheckSpawnPosition)) {
		if(ac_SpawnTime[playerid] + 5 < GetTickCount()) {
			NOP_Detected(playerid);
		}
		return true;
	}

	static Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	if(Bit_Get(ac_Bits[playerid], bit_CheckSetPosition)) {
		if(IsPlayerInRangeOfPoint(playerid, 10.0, 
			ac_oldPosX[playerid],
			ac_oldPosY[playerid],
			ac_oldPosZ[playerid])
		) {
			if(++ac_playerUpdateIgnoreCount[playerid] > const_playerUpdateIgnoreLimit) {
				return NOP_Detected(playerid);
			}
		}
		else {
			if(Bit_Get(ac_Bits[playerid], bit_SetPositionFindZ)) {
				x = (x - ac_setPosX[playerid]) * (x - ac_setPosX[playerid]);
				y = (y - ac_setPosY[playerid]) * (y - ac_setPosY[playerid]);

				if(x + y > 10.0 * 10.0) {
					return Cheat_Detected(playerid);
				}
				else {
					Bit_Set(ac_Bits[playerid], bit_CheckSetPosition, false);
					Bit_Set(ac_Bits[playerid], bit_SetPositionFindZ, false);
				}
			}
			else if(IsPlayerInRangeOfPoint(playerid, 10.0, 
				ac_setPosX[playerid],
				ac_setPosY[playerid],
				ac_setPosZ[playerid])
			) {
				Bit_Set(ac_Bits[playerid], bit_CheckSetPosition, false);
				Bit_Set(ac_Bits[playerid], bit_SetPositionFindZ, false);
			}
		}
	}
	else {
		if( ! ac_LastCheckTime[playerid]) {
			ac_LastCheckTime[playerid] = GetTickCount();
		}
		else {
			if( ! IsPlayerInRangeOfPoint(playerid, 7.0, 
				ac_lastPosX[playerid],
				ac_lastPosY[playerid],
				ac_lastPosZ[playerid])
			) {
				SetPlayerPos(playerid, 
					ac_lastPosX[playerid],
					ac_lastPosY[playerid],
					ac_lastPosZ[playerid]
				);
			}
		}
	}
	ac_lastPosX[playerid] = x;
	ac_lastPosY[playerid] = y;
	ac_lastPosZ[playerid] = z;

	return true;
}

static NOP_Detected(playerid) {
	M:P:E(playerid, "Hi. NOP SetPlayerPos :p");
	defer KickPlayer(playerid);
}

static Cheat_Detected(playerid) {
	M:P:E(playerid, "Pastebëta, kad tavo pozicija keièiasi pernelyg greitai.");
	M:P:E(playerid, "Dël saugumo sumetimø, esi iðmetamas ið serverio.");
	M:P:I(playerid, "Jeigu manai, kad ávyko klaida, siûlome praneðti administracijai.");
	defer KickPlayer(playerid);
}