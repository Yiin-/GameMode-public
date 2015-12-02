#include <YSI_Coding\y_hooks>

#define MIN_HP_FOR_DISCHARGE (player_MaxHealth[playerid] * 0.4)

new const Float:hospitalSpots[][4] = {
	{1272.49902, 302.95114, 3004.60986, -113.90000},
	{1266.21399, 305.73544, 3004.60986, -113.90000},
	{1271.00513, 299.59833, 3004.60986, -113.90000},
	{1269.62183, 296.40826, 3004.60986, -113.90000},
	{1264.72729, 302.38080, 3004.60986, -113.90000},
	{1263.31982, 299.20294, 3004.60986, -113.90000},
	{1257.41235, 309.63446, 3004.60986, -113.90000},
	{1263.78577, 306.81000, 3004.60986, -113.90000},
	{1255.89795, 306.29584, 3004.60986, -113.90000},
	{1262.30164, 303.45428, 3004.60986, -114.08000},
	{1254.50659, 303.10831, 3004.60986, -113.90000},
	{1260.88525, 300.28287, 3004.60986, -113.90000},
	{1249.11243, 313.31259, 3004.60986, -113.90000},
	{1242.69568, 316.15604, 3004.60986, -113.90000},
	{1247.60254, 309.97244, 3004.60986, -113.90000},
	{1241.21619, 312.80176, 3004.60986, -113.90000},
	{1239.80322, 309.62592, 3004.60986, -113.90000},
	{1246.21509, 306.78333, 3004.60986, -113.90000}
};

new const Float:hospitalSpots_onFloorZ = 3005.1611;
new Float:hospitalSpots_onFloor[][2] = {
	{1271.0931,304.3421},
	{1269.9808,302.3428},
	{1268.9133,300.0005},
	{1269.9249,298.3039},
	{1268.1292,297.8521},
	{1267.5876,297.1794},
	{1268.4749,295.3857},
	{1265.6539,296.4767},
	{1264.6454,297.6486},
	{1262.9619,297.5924},
	{1265.4833,299.1752},
	{1264.5742,300.2295},
	{1266.9063,301.0797},
	{1266.7858,302.3030},
	{1265.9141,303.8437},
	{1266.6803,303.0189},
	{1268.2893,302.7199},
	{1267.9600,301.1206},
	{1267.3276,300.0429},
	{1268.1423,305.2299},
	{1263.1572,308.1956},
	{1260.7847,307.8979},
	{1261.1095,306.4859},
	{1261.7909,306.0376},
	{1262.8842,305.1419},
	{1261.4630,305.4030},
	{1260.4425,303.5838},
	{1260.8539,302.7053},
	{1261.0142,301.4485},
	{1259.5115,301.7880},
	{1258.8976,300.7289},
	{1258.9573,299.5566},
	{1257.4628,300.5345},
	{1257.4508,301.1971},
	{1256.1471,301.4087},
	{1254.5660,301.2015},
	{1256.7574,303.5875},
	{1255.5894,304.2935},
	{1255.8186,305.0239},
	{1257.4344,304.5681},
	{1258.0150,306.0671},
	{1257.2513,307.0517},
	{1257.9525,307.8304},
	{1259.3739,309.4701},
	{1248.0016,314.9186},
	{1247.0460,313.5601},
	{1247.3037,312.5980},
	{1248.1183,311.7824},
	{1246.7799,311.9341},
	{1245.9174,311.1002},
	{1245.7313,310.2890},
	{1245.3905,309.7338},
	{1246.4313,309.2857},
	{1246.9385,308.9565},
	{1246.8004,307.8717},
	{1245.9412,307.8986},
	{1244.7214,308.2466},
	{1244.4071,307.4533},
	{1244.1702,306.7630},
	{1244.7970,305.8148},
	{1242.9502,306.3615},
	{1242.3580,307.1842},
	{1241.3173,307.6387},
	{1239.2791,308.0852},
	{1241.3026,309.0095},
	{1241.1965,310.3092},
	{1241.0297,311.1263},
	{1242.7227,312.1114},
	{1243.2213,313.4952},
	{1242.1719,314.5699},
	{1243.8228,314.5044},
	{1244.1487,315.2631},
	{1245.3989,314.1566},
	{1246.6660,313.9013},
	{1246.3573,312.6131},
	{1245.6881,311.9921},
	{1245.2343,310.8726},
	{1244.4733,309.7455},
	{1244.0737,308.3389},
	{1243.3304,307.2384},
	{1242.1692,308.7789},
	{1243.0688,310.4377},
	{1243.6261,312.2241},
	{1244.7922,314.0101},
	{1245.3457,315.4016},
	{1246.4198,314.7189}
};
// pomirinis pasirinkimas, kà nori daryti. 
// Gráþti á ligoninæ ar laukti medikø ar pan
new Text:TD_AfterDeath[4];

// þaidëjo mirties animacijos
new player_DeathAnimLib[MAX_PLAYERS][32];
new player_DeathAnimName[MAX_PLAYERS][32];

// Uþimtos lovos ligoninëje. Jeigu visos uþimtos
// guldom ant grindø
new hospitalSpot_inUse[sizeof(hospitalSpots)];

// Gyjimo timeris lol
new Timer:healingTimer[MAX_PLAYERS];

// medikø laukianèiø þmoniø map icon'os
static dyingPlayerMapIcon[MAX_PLAYERS];

// medikø map icons valdymas
updateDyingPlayers(add = INVALID_PLAYER_ID, remove = INVALID_PLAYER_ID) {
	// visiðkai atnaujinam visus medikø map icons
	if(add == remove && remove == INVALID_PLAYER_ID) {
		foreach(new playerid : Player) {
			// jeigu þaidëjas nelaukia medikø, bet medikams rodo, kad laukia
			// paðalinam ðá þaidëjà ið medikø sàraðø
			if(player_State[playerid] != PLAYER_STATE_DYING2) {
				if(IsValidDynamicMapIcon(dyingPlayerMapIcon[playerid])) {
					updateDyingPlayers(.remove = playerid);
				}
				continue;
			}
			// jeigu þaidëjas laukai medikø, ir jo vis dar nëra medikø sàraðuose,
			// áraðom já kvieèiam jam medikus.
			if( ! IsValidDynamicMapIcon(dyingPlayerMapIcon[playerid])) {
				updateDyingPlayers(.add = playerid);
			}
			// jeigu kuriam nors medikui nerodom mirðtanèio þmogaus,
			// tai praneðam jam apie tà þmogø
			foreach(new i : Player) { // jeigu þaidëjas yra medikas ir mirðta, jam savæs nerodom
				if(player_Job[i] == JOB_HEALTH && i != playerid) {
					if( ! Streamer_IsInArrayData(STREAMER_TYPE_MAP_ICON, dyingPlayerMapIcon[playerid], E_STREAMER_PLAYER_ID, i)) {
						Streamer_AppendArrayData(STREAMER_TYPE_MAP_ICON, dyingPlayerMapIcon[playerid], E_STREAMER_PLAYER_ID, i);
						Streamer_Update(i, STREAMER_TYPE_MAP_ICON);
					}
				}
			}
		}
	}
	// parodom medikams dar vienà mirðtantá þmogø
	if(IsPlayerConnected(add)) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(add, x, y, z);
		dyingPlayerMapIcon[add] = CreateDynamicMapIconEx(x, y, z, 21, 0, MAPICON_LOCAL_CHECKPOINT, 500, .maxplayers = 0);
		updateDyingPlayers();
	}
	// paðalinam þmogø ið medikø sàraðø
	if(remove != INVALID_PLAYER_ID) {
		DestroyDynamicMapIcon(dyingPlayerMapIcon[remove]);
		foreach(new i : Player) if(player_Job[i] == JOB_HEALTH) {
			Streamer_Update(i, STREAMER_TYPE_MAP_ICON);
		}
	}
}

static showAfterDeathMenu(playerid, showWaitForHelpOption = true) {
	M:P:X(playerid, "showAfterDeathMenu");
	SelectTextDraw(playerid, 0xFFFFFF55);
	TextDrawShowForPlayer(playerid, TD_AfterDeath[0]); // gydytis ligoninëje
	TextDrawShowForPlayer(playerid, TD_AfterDeath[1]); // header
	if(showWaitForHelpOption) {
		TextDrawShowForPlayer(playerid, TD_AfterDeath[2]); // laukti medikø
	}
	if(Container_HasItem(Player, playerid, "Sveikatos eliksyras")) {
		TextDrawShowForPlayer(playerid, TD_AfterDeath[3]);
	}
}

static hideAfterDeathMenu(playerid, revive = false, healerid = INVALID_PLAYER_ID) {
	if(revive) {
		player_State[playerid] = PLAYER_STATE_NONE;
		player_MaxHealth[playerid] = player_Health[playerid] = max(player_MaxHealth[playerid], 50.0);
		UpdatePlayerHealth(playerid);
		WC_SpawnPlayerInPlace(playerid);

		if(IsPlayerConnected(healerid)) {
			M:P:G(healerid, "Sëkmingai pagydei mirðtantá þmogø");
			M:P:I(playerid, "Esi sëkmingai atgaivintas mediko [name]%s.", player_Name[healerid]);
		}
	}
	for(new i; i < sizeof TD_AfterDeath; ++i) {
		TextDrawHideForPlayer(playerid, TD_AfterDeath[i]);
	}
	updateDyingPlayers(.remove = playerid);
	CancelSelectTextDraw(playerid);
}

static reviveInHospital(playerid, reset_health = true) {
	M:P:X(playerid, "reviveInHospital");
	if(reset_health) {
		M:P:X(playerid, "Patekai á ligoninæ.");
		M:P:X(playerid, "Palikti jà gali, kai tavo sveikatos lygis pasieks bent [number]40%%%%[].");
		M:P:X(playerid, "Ligoninæ palikti gali paraðæs komandà [highlight]/palikti[].");
		player_Health[playerid] = player_MaxHealth[playerid] * 0.01;
		UpdatePlayerHealth(playerid);
	}
	if(healingTimer[playerid] != INVALID_TIMER_ID) {
		stop healingTimer[playerid];
		healingTimer[playerid] = INVALID_TIMER_ID;
	}

	new spot; // kaþkokia nesamonë bet turëtø veikti
	while(hospitalSpot_inUse[spot] 
		&& hospitalSpot_inUse[spot] != playerid + 1 
		&& ++spot < sizeof(hospitalSpots)) {}

	if(spot != sizeof(hospitalSpots)) {
		SetPlayerPos(playerid, XYZ0(hospitalSpots[spot]) + 0.01);
		hospitalSpot_inUse[spot] = playerid + 1;
	}
	else {
		spot = random(sizeof hospitalSpots_onFloor);

		SetPlayerFacingAngle(playerid, floatrandom(360.0));
		SetPlayerPos(playerid, 
			hospitalSpots_onFloor[spot][0], hospitalSpots_onFloor[spot][1], hospitalSpots_onFloorZ);
	}
	player_State[playerid] = PLAYER_STATE_INHOSPITAL;
	// TogglePlayerControllable(playerid, true);
	ApplyAnimation(playerid, "CRACK", "CRCKDETH2", 4.0, 1, 0, 0, 0, 0);

	healingTimer[playerid] = repeat HealingInProgess(playerid);
}

static releaseFromHospital(playerid) {
	resetHospitalData(playerid);
	player_State[playerid] = PLAYER_STATE_NONE;
	TogglePlayerControllable(playerid, true);
	ClearAnimations(playerid, 1);
}

static resetHospitalData(playerid) {
	// vdruk streameris veikia ne taip kaip að tikiuosi
	if(player_Job[playerid] == JOB_HEALTH) {
		for(new i; i < sizeof dyingPlayerMapIcon; ++i) {
			if(IsValidDynamicMapIcon(dyingPlayerMapIcon[i])) {
				Streamer_RemoveArrayData(STREAMER_TYPE_MAP_ICON, dyingPlayerMapIcon[i], E_STREAMER_PLAYER_ID, playerid);
			}
		}
	}
	if(player_State[playerid] == PLAYER_STATE_DYING2) {
		updateDyingPlayers(.remove = playerid);
	}
	if(player_State[playerid] == PLAYER_STATE_INHOSPITAL) {
		if(healingTimer[playerid] != INVALID_TIMER_ID) {
			stop healingTimer[playerid];
			healingTimer[playerid] = INVALID_TIMER_ID;
		}
		for(new i; i < sizeof hospitalSpot_inUse; ++i) {
			if(hospitalSpot_inUse[i] == playerid + 1) {
				hospitalSpot_inUse[i] = 0;
			}
		}
	}
}

CMD:palikti(playerid, p[]) {
	if(player_State[playerid] != PLAYER_STATE_INHOSPITAL) {
		M:P:E(playerid, "Tu nesi ligoninëje.");
	}
	else {
		if(player_Health[playerid] < MIN_HP_FOR_DISCHARGE) {
			new Float:currentPercent = player_Health[playerid] / player_MaxHealth[playerid] * 100.0;
			new value = floatround(40.0 - currentPercent);
			M:P:E(playerid, "Tau trûksta dar [number]%i%%%%[] sveikatos, kad galëtum palikti ligoninæ.", value);
		}
		else {
			M:P:G(playerid, "Esi paleidþiamas ið ligoninës, linkime èia nebesugráþti.");
			releaseFromHospital(playerid);
		}
	}
	return true;
}

public OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time) {
	M:P:X(playerid, "OnPlayerPrepareDeath");
	player_DeathAnimLib[playerid][0] = EOS; strcat(player_DeathAnimLib[playerid], animlib);
	player_DeathAnimName[playerid][0] = EOS; strcat(player_DeathAnimName[playerid], animname);
	return true;
}

hook OnPlayerOpenTargetMenu(playerid, targetid) {
	if(player_Job[playerid] == JOB_HEALTH
		&& ( player_State[targetid] == PLAYER_STATE_DYING2
			|| player_State[targetid] == PLAYER_STATE_DYING1
		)
	) {
		dialogAddOption("Gaivinti (+3xp)");
	}
}

timer RevivePlayer[6000](playerid, healerid) {
	hideAfterDeathMenu(playerid, true, healerid);

	GivePlayerJobExp(playerid, 3);
}

hook OnPlSelectTargetMenu(playerid, targetid) {
	if(player_Job[playerid] == JOB_HEALTH
		&& ( player_State[targetid] == PLAYER_STATE_DYING2
			|| player_State[targetid] == PLAYER_STATE_DYING1
		)
	) {
		dialog_Row("Gaivinti") {
			new Float:x, Float:y, Float:z;
			GetPlayerPos(targetid, x, y, z);

			if(IsPlayerInRangeOfPoint(playerid, 1.5, x, y, z)) {
				if(Container_HasItem(Player, playerid, "Elektrosokas") || true) {
					if(SetPlayerFacePlayer(playerid, targetid)) {
						M:P:I(targetid, "[name]%s pradeda tave gaivinti.", player_Name[playerid]);
						M:P:G(playerid, "Pradedi gaivinti [name]%s[].", player_Name[targetid]);
						
						ApplyAnimation(playerid, "MEDIC", "CPR", 4.0, 0, 0, 0, 0, 0, 1);
						defer RevivePlayer(targetid, playerid);
					}
				}
				else {
					M:P:E(playerid, "Neturi elektroðoko, kad galëtum gaivinti.");
				}
			}
			else {
				M:P:E(playerid, "Þaidëjas kurá nori gaivinti yra per toli.");
			}
		}
	}
}

hook OnPlayerDeathFinished(playerid, bool:cancelable) {
	M:P:X(playerid, "OnPlayerDeathFinished: cancelable %i", cancelable);

	new Float:deathPosition[3];
	GetPlayerPos(playerid, XYZ0(deathPosition));

	if(cancelable) {
		showAfterDeathMenu(playerid);
		player_State[playerid] = PLAYER_STATE_DYING1;
	}
	else {
		SetPVarInt(playerid, "force_revive_in_hospital", 1);
	}
}

hook OnGameModeInit() {
	TD_AfterDeath[0] = TextDrawCreate(255.016052, 273.583221, "Gydytis ligonineje (~g~250~w~~h~eur)");
	TextDrawLetterSize(TD_AfterDeath[0], 0.449999, 1.600000);
	TextDrawTextSize(TD_AfterDeath[0], 519.589965, 22.0);
	TextDrawAlignment(TD_AfterDeath[0], 1);
	TextDrawColor(TD_AfterDeath[0], -1);
	TextDrawUseBox(TD_AfterDeath[0], true);
	TextDrawBoxColor(TD_AfterDeath[0], 0);
	TextDrawSetShadow(TD_AfterDeath[0], 0);
	TextDrawSetOutline(TD_AfterDeath[0], 1);
	TextDrawBackgroundColor(TD_AfterDeath[0], 255);
	TextDrawFont(TD_AfterDeath[0], 1);
	TextDrawSetProportional(TD_AfterDeath[0], 1);
	TextDrawSetSelectable(TD_AfterDeath[0], true);

	TD_AfterDeath[1] = TextDrawCreate(223.484573, 186.083267, "Beveik mirei...");
	TextDrawLetterSize(TD_AfterDeath[1], 0.971931, 2.988335);
	TextDrawAlignment(TD_AfterDeath[1], 1);
	TextDrawColor(TD_AfterDeath[1], -16776961);
	TextDrawSetShadow(TD_AfterDeath[1], 0);
	TextDrawSetOutline(TD_AfterDeath[1], 1);
	TextDrawBackgroundColor(TD_AfterDeath[1], 255);
	TextDrawFont(TD_AfterDeath[1], 0);
	TextDrawSetProportional(TD_AfterDeath[1], 1);

	TD_AfterDeath[2] = TextDrawCreate(255.032379, 248.450164, "Laukti greitosios pagalbos");
	TextDrawLetterSize(TD_AfterDeath[2], 0.449999, 1.600000);
	TextDrawTextSize(TD_AfterDeath[2], 519.589965, 22.0);
	TextDrawAlignment(TD_AfterDeath[2], 1);
	TextDrawColor(TD_AfterDeath[2], -1);
	TextDrawUseBox(TD_AfterDeath[2], true);
	TextDrawBoxColor(TD_AfterDeath[2], 0);
	TextDrawSetShadow(TD_AfterDeath[2], 0);
	TextDrawSetOutline(TD_AfterDeath[2], 1);
	TextDrawBackgroundColor(TD_AfterDeath[2], 255);
	TextDrawFont(TD_AfterDeath[2], 1);
	TextDrawSetProportional(TD_AfterDeath[2], 1);
	TextDrawSetSelectable(TD_AfterDeath[2], true);

	TD_AfterDeath[3] = TextDrawCreate(255.032150, 298.208343, "Panaudoti sveikatos eliksyra");
	TextDrawLetterSize(TD_AfterDeath[3], 0.449999, 1.600000);
	TextDrawTextSize(TD_AfterDeath[3], 519.589965, 22.0);
	TextDrawAlignment(TD_AfterDeath[3], 1);
	TextDrawColor(TD_AfterDeath[3], -4325121);
	TextDrawUseBox(TD_AfterDeath[3], true);
	TextDrawBoxColor(TD_AfterDeath[3], 0);
	TextDrawSetShadow(TD_AfterDeath[3], 0);
	TextDrawSetOutline(TD_AfterDeath[3], 1);
	TextDrawBackgroundColor(TD_AfterDeath[3], 255);
	TextDrawFont(TD_AfterDeath[3], 1);
	TextDrawSetProportional(TD_AfterDeath[3], 1);
	TextDrawSetSelectable(TD_AfterDeath[3], true);
}

hook OnCreatePlayerORM(ORM:ormid, playerid) {
	orm_addvar_string(ormid, player_DeathAnimLib[playerid], 32, "death_anim_lib");
	orm_addvar_string(ormid, player_DeathAnimName[playerid], 32, "death_anim_name");
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if(clickedid == Text:INVALID_TEXT_DRAW) {
		if(player_State[playerid] == PLAYER_STATE_DYING1
			|| player_State[playerid] == PLAYER_STATE_DYING2) {
			M:P:I(playerid, "Norëdamas vël ájungti kursoriø, raðyk [highlight]/pasirinkti");
		}
	}
	if(clickedid == TD_AfterDeath[0]) {
		hideAfterDeathMenu(playerid);
		reviveInHospital(playerid);
	}
	if(clickedid == TD_AfterDeath[2]) {
		M:P:G(playerid, "Medikams praneðta tavo buvimo vieta. Ekipaþui atvykstant bus praneðta.");
		TextDrawHideForPlayer(playerid, TD_AfterDeath[2]);
		player_State[playerid] = PLAYER_STATE_DYING2;
		updateDyingPlayers(.add = playerid);
	}
	if(clickedid == TD_AfterDeath[3]) {
		hideAfterDeathMenu(playerid, .revive = true);
	}
}

hook OnPlayerSpawn(playerid) {
	ApplyAnimation(playerid, "CRACK", "null", 0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MEDIC", "null", 0, 0, 0, 0, 0, 0);

	if(player_Job[playerid] == JOB_HEALTH) {
		for(new i; i < sizeof dyingPlayerMapIcon; ++i) {
			if(IsValidDynamicMapIcon(dyingPlayerMapIcon[i])) {
				if( ! Streamer_IsInArrayData(STREAMER_TYPE_MAP_ICON, dyingPlayerMapIcon[i], E_STREAMER_PLAYER_ID, playerid)) {
					Streamer_AppendArrayData(STREAMER_TYPE_MAP_ICON, dyingPlayerMapIcon[i], E_STREAMER_PLAYER_ID, playerid);
				}
			}
		}
	}
	// double spawn, no death/
	if(GetPVarInt(playerid, "force_revive_in_hospital")) {
		M:P:X(playerid, "force_revive_in_hospital");
		DeletePVar(playerid, "force_revive_in_hospital");
		reviveInHospital(playerid);
	}
	if(player_State[playerid] == PLAYER_STATE_INHOSPITAL) {
		M:P:X(playerid, "already_in_hospital");
		reviveInHospital(playerid);
	}
	if(player_State[playerid] == PLAYER_STATE_DYING1) {
		showAfterDeathMenu(playerid);
	}
	if(player_State[playerid] == PLAYER_STATE_DYING2) {
		showAfterDeathMenu(playerid, .showWaitForHelpOption = false);
		updateDyingPlayers(.add = playerid);
	}
}

hook OnPlayerDamage(playerid, &Float:amount, &issuerid, &weapon, &bodypart) {
	if(player_State[playerid] == PLAYER_STATE_INHOSPITAL
		|| player_State[playerid] == PLAYER_STATE_DYING1
		|| player_State[playerid] == PLAYER_STATE_DYING2
	) {
		return false;
	}
	return true;
}

hook OnPlayerUpdate(playerid) {
	// Atnaujinam ligoninëje gulinèio þaidëjo animacijas
	if(player_State[playerid] == PLAYER_STATE_INHOSPITAL) {
		static animlib[32], animname[32];
		GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, sizeof animlib, animname, sizeof animname);

		if(strcmp(animname, "CRCKDETH2")) {
			ApplyAnimation(playerid, "CRACK", "CRCKDETH2", 4.0, 1, 0, 0, 0, 0);
		}
		if( ! IsPlayerInRangeOfPoint(playerid, 150.0, XYZ0(hospitalSpots[0]))) {
			reviveInHospital(playerid, false);
		}
	}
	// Atnaujinam mirðtanèio þaidëjo animacijas, jeigu jos nëra tokios kokios buvo po mirties
	if(player_State[playerid] == PLAYER_STATE_DYING1
		|| player_State[playerid] == PLAYER_STATE_DYING2) {
		if(player_DeathAnimLib[playerid][0] && player_DeathAnimName[playerid][0]) {
			static animlib[32], animname[32], animidx;
			GetAnimationName((animidx = GetPlayerAnimationIndex(playerid)), animlib, sizeof animlib, animname, sizeof animname);

			if( strcmp(animname, player_DeathAnimName[playerid]) 
				&& strcmp(animlib, player_DeathAnimLib[playerid]) 
				&& animidx != 1242 && animidx != 1206 && animidx != 1205
			) {
				ApplyAnimation(playerid, player_DeathAnimLib[playerid], player_DeathAnimName[playerid], 4.1, 0, 1, 1, 0, 0, 1);
			}
		}
	}
	return true;
}

hook OnCharacterDespawn(playerid) {
	resetHospitalData(playerid);
}

timer HealingInProgess[1000](playerid) {
	new Float:oldHealth = player_Health[playerid];
	UpdatePlayerHealth(playerid, player_MaxHealth[playerid] * 0.01); // 1% hp kas sekundæ
	if(player_Health[playerid] >= MIN_HP_FOR_DISCHARGE
		&& oldHealth < MIN_HP_FOR_DISCHARGE) {
		M:P:G(playerid, "Tavo sveikatos lygis pasiekë [number]40%%%%[]");
		M:P:G(playerid, "Jeigu nori gali palikti ligoninæ paraðæs [highlight]/palikti[], arba gyti toliau iki [number]100%%%%");
	}
}