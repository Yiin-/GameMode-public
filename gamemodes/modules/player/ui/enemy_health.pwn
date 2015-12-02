#include <YSI_Coding\y_hooks>

static Text:TD_EnemyHealthIndicator[2];
static PlayerText:PlayerTD_EnemyHealthIndicator[MAX_PLAYERS][2];
static lastShot[MAX_PLAYERS];

static hideTD(playerid) {
	for(new i; i < 2; ++i) {
		TextDrawHideForPlayer(playerid, TD_EnemyHealthIndicator[i]);
		PlayerTextDrawHide(playerid, PlayerTD_EnemyHealthIndicator[playerid][i]);
	}
}

static showTD(playerid, name[], Float:healthPercent) {
	PlayerTextDrawSetString(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], name);
	PlayerTextDrawTextSize(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], healthPercent * 258.0, 5.0);

	for(new i; i < 2; ++i) {
		TextDrawShowForPlayer(playerid, TD_EnemyHealthIndicator[i]);
		PlayerTextDrawShow(playerid, PlayerTD_EnemyHealthIndicator[playerid][i]);
	}
}

#if defined _FCNPC_included

hook OnNpcTakeDamage(npcid, damagerid, weaponid, bodypart, Float:health_loss) {
	P:1("ui/enemy_health.pwn: OnNpcTakeDamage: %i, %i, %i, %i, %f", npcid, damagerid, weaponid, bodypart, health_loss);
	new 
		name[MAX_PLAYER_NAME],
		Float:healthPercent
	;
	if(Iter_Contains(Guardians, npcid)) {
		format(name, _, "Sargybinis (%i lvl)", GetGuardianLevel(npcid));
		healthPercent = player_GetHealth(npcid) / GetPlayerMaxHealth(npcid);
		M:P:X(damagerid, "guardian healthPercent: %f", healthPercent);
	}
	else {
		format(name, _, "NPC: %s (%i)", player_Name[npcid], npcid);
		healthPercent = FCNPC_GetHealth(npcid) / 100.0;
	}
	lastShot[damagerid] = gettime();

	showTD(damagerid, name, healthPercent);

	return true;
}

#endif

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart) {
	new 
		name[MAX_PLAYER_NAME],
		Float:healthPercent,
		isGuardian
	;
	#if defined _FCNPC_included
		isGuardian = Iter_Contains(Guardians, damagedid);
	#endif
		
	if(isGuardian || IsPlayerNPC(damagedid) || IsPlayerNPC(playerid) || (amount == 0.0 && bodypart == 4 && weaponid == 0)) {
		return;
	}
	else {
		strcat(name, player_Name[damagedid]);
		healthPercent = player_GetHealth(damagedid) / GetPlayerMaxHealth(damagedid);
	}
	lastShot[playerid] = gettime();

	showTD(playerid, name, healthPercent);
}

hook OnCharacterDespawn(playerid) {
	hideTD(playerid);
}

hook OnPlayerUpdate(playerid) {
	if(lastShot[playerid]) {
		if(lastShot[playerid] + 3 < gettime()) {
			hideTD(playerid);
		}
	}
	return true;
}

hook OnGameModeInit() {
	TD_EnemyHealthIndicator[0] = TextDrawCreate(186.0, 431.0, "LD_SPAC:white");
	TextDrawLetterSize(TD_EnemyHealthIndicator[0], 0.000000, 0.000000);
	TextDrawTextSize(TD_EnemyHealthIndicator[0], 260.000000, 7.000000);
	TextDrawAlignment(TD_EnemyHealthIndicator[0], 1);
	TextDrawColor(TD_EnemyHealthIndicator[0], 255);
	TextDrawSetShadow(TD_EnemyHealthIndicator[0], 0);
	TextDrawSetOutline(TD_EnemyHealthIndicator[0], 0);
	TextDrawFont(TD_EnemyHealthIndicator[0], 4);

	TD_EnemyHealthIndicator[1] = TextDrawCreate(187.0, 432.0, "LD_SPAC:white");
	TextDrawLetterSize(TD_EnemyHealthIndicator[1], 0.000000, 0.000000);
	TextDrawTextSize(TD_EnemyHealthIndicator[1], 258.0, 5.0);
	TextDrawAlignment(TD_EnemyHealthIndicator[1], 1);
	TextDrawColor(TD_EnemyHealthIndicator[1], -2147483393);
	TextDrawSetShadow(TD_EnemyHealthIndicator[1], 0);
	TextDrawSetOutline(TD_EnemyHealthIndicator[1], 0);
	TextDrawFont(TD_EnemyHealthIndicator[1], 4);
}

hook OnPlayerConnect(playerid) {
	PlayerTD_EnemyHealthIndicator[playerid][0] = CreatePlayerTextDraw(playerid, 187.0, 432.0, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], 258.0, 5.0);
	PlayerTextDrawAlignment(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], 1);
	PlayerTextDrawColor(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], -16776961);
	PlayerTextDrawSetShadow(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], 0);
	PlayerTextDrawFont(playerid, PlayerTD_EnemyHealthIndicator[playerid][0], 4);

	PlayerTD_EnemyHealthIndicator[playerid][1] = CreatePlayerTextDraw(playerid, 317.657623, 420.583068, "Sargybinis (5 lvl)");
	PlayerTextDrawLetterSize(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], 0.2, 1.156666);
	PlayerTextDrawAlignment(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], 2);
	PlayerTextDrawColor(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], 51);
	PlayerTextDrawFont(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_EnemyHealthIndicator[playerid][1], 1);
}



