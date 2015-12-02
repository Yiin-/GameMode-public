// player/class-selection
#if defined UNDEFINED

TODO:
	

#endif


#include <YSI_Coding\y_hooks>

#define MAX_CHARACTERS (sizeof selectCharacter_Positions)

new Text:TD_LoadingSkin;

new lastTimeInFight[MAX_PLAYERS];

static createCharacter_ClassModels[14] = {58, 190, 202, 151, 101, 12, 35, 55, 168, 298, 37, 41, 249, 152};
static Float:selectCharacter_Positions[][4] = {
	{-564.5436,2369.6616,77.7350,114.7205},
	{-562.2312,2363.0566,77.5467,133.5208},
	{-554.6909,2360.1243,76.2686,206.0059},
	{-550.1262,2363.6936,75.9591,216.8682}/*,
	{-543.7626,2358.2278,75.1132,221.9860},
	{-549.1489,2358.9683,75.4656,204.7525},
	{-553.1791,2356.3665,76.1099,181.6701},
	{-543.2001,2355.3569,74.8150,212.6092},
	{-574.2022,2370.3555,79.1887,121.9506}
	*/
};
new isInClassSelection[MAX_PLAYERS char];

new selectCharacter_Actors[MAX_PLAYERS][MAX_CHARACTERS];
new Text3D:selectCharacter_ActorInfo[MAX_PLAYERS][MAX_CHARACTERS];
new selectCharacter_ActorName[MAX_PLAYERS][MAX_CHARACTERS][MAX_PLAYER_NAME];
new selectCharacter_ActorsCount[MAX_PLAYERS];

new creatingNewCharacter[MAX_PLAYERS char];
new selectingCharacterSkin[MAX_PLAYERS char];
new selectingCharacter[MAX_PLAYERS char];
new selectingCharacter_CurrentSkin[MAX_PLAYERS char];
new selectingCharacter_CurrentChar[MAX_PLAYERS char];
new selectingCharacter_CameraCut[MAX_PLAYERS char];

CMD:veikejai(playerid, params[]) {
	if(lastTimeInFight[playerid] + 10 < gettime()) {
		cleanResetToClassSelection(playerid, .update_pos = true);
	}
	else {
		M:P:E(playerid, "Turi palaukti nekovodamas dar [number]%i[] sec.", lastTimeInFight[playerid] + 10 - gettime());
	}
	return 1;
}

CMD:info(playerid, params[]) {
	if(isInClassSelection{playerid}) {
		if(selectingCharacter{playerid} && selectingCharacter_CurrentChar{playerid} != 255) {
			// ToDo: parodyti daugiau info apie veikëjà kai jos bus
		}
	}
	return 1;
}

CMD:zaisti(playerid, params[]) {
	if(isInClassSelection{playerid}) {
		if(selectingCharacter{playerid} && selectingCharacter_CurrentChar{playerid} != 255) {
			SetPlayerName(playerid, selectCharacter_ActorName[playerid][ selectingCharacter_CurrentChar{playerid} ]);
			selectingCharacter{playerid} = false;
			playerData_LoadChar(playerid);
		}
		else {
			M:P:E(playerid, "Nesirenki veikëjo.");
		}
	}
	else {
		M:P:E(playerid, "Tu jau esi þaidime.");
	}
	return 1;
}

CMD:trinti(playerid, params[]) {
	if(isInClassSelection{playerid}) {
		if(selectingCharacter{playerid} && selectingCharacter_CurrentChar{playerid} != 255) {
			M:P:G(playerid, "Veikëjas \"[name]%s[]\" iðtrintas!", selectCharacter_ActorName[playerid][ selectingCharacter_CurrentChar{playerid} ]);
			format_query("DELETE FROM chars WHERE name = '%s'", selectCharacter_ActorName[playerid][ selectingCharacter_CurrentChar{playerid} ]);
			cache_delete(mysql_query(database, query));
			classSelection_ResetActors(playerid);
			classSelection_Show(playerid);
		}
	}
	return 1;
}

CMD:kurti(playerid, params[]) {
	if(isInClassSelection{playerid}) {
		if(selectingCharacterSkin{playerid} && selectingCharacter_CurrentSkin{playerid} < sizeof createCharacter_ClassModels) {
			player_CurrentSkin[playerid] = player_DefaultSkin[playerid] = createCharacter_ClassModels[selectingCharacter_CurrentSkin{playerid}];

			player_AvailableSkins[playerid]{ player_DefaultSkin[playerid] } = true;
			selectingCharacterSkin{playerid} = false;

			playerData_LoadChar(playerid);  // char'o neranda, insertina ir tada iðkvieèia OnCharacterCreated
		}
		else {
			classSelection_ResetActors(playerid);
			classSelection_CreateCharacter(playerid);
		}
	}
	return 1;
}

forward OnCharacterCreated(playerid);
public OnCharacterCreated(playerid) {
	new spawn_idx = random(sizeof Position_Spawn);
	player_PosX[playerid] = Position_Spawn[spawn_idx][0];
	player_PosY[playerid] = Position_Spawn[spawn_idx][1];
	player_PosZ[playerid] = Position_Spawn[spawn_idx][2];
	player_PosA[playerid] = Position_Spawn[spawn_idx][3];

	M:P:G(playerid, "Veikëjas \"[name]%s[]\" sëkmingai sukurtas!", player_Name[playerid]);

	if( ! player_CreationTimestamp[playerid]) {
		player_CreationTimestamp[playerid] = gettime();
	}
	
	cleanResetToClassSelection(playerid);
}

cleanResetToClassSelection(playerid, update_pos = false) {
	playerData_SaveChar(playerid, .update_pos = update_pos); // iðsaugom veikëjo pradinæ informacijà

	orm_destroy(GetPlayerORM(playerid));
	
	resetPlayerVars(playerid);

	SetPlayerName(playerid, player_AccountName[playerid]); // pakeièiam vardà á accounto, o ne veikëjo

	classSelection_ResetActors(playerid); // Resetinam veikëjus po naujo sukûrimo, pakrausim vëliau ið naujo
	classSelection_Show(playerid); // rodom ið naujo classSelection lyg niekur nieko
}

classSelection_Show(playerid, new_account = false) {
	selectingCharacter_CameraCut{playerid} = !isInClassSelection{playerid};
	isInClassSelection{playerid} = true;

	if(GetPlayerVirtualWorld(playerid) != playerid + VW_OFFSET_CHARSELECT) {
		SetPlayerVirtualWorld(playerid, playerid + VW_OFFSET_CHARSELECT);
	}
	if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
		TogglePlayerSpectating(playerid, true);
	}

	if(new_account) {
		classSelection_CreateCharacter(playerid);
	}
	else {
		if(selectCharacter_Actors[playerid][0] == INVALID_ACTOR_ID) {
			if(classSelection_PopulateActors(playerid) == 0) {
				classSelection_CreateCharacter(playerid);
				return;
			}
		}
		classSelection_SelectChar(playerid);
	}
}

classSelection_SelectChar(playerid) {
	selectingCharacter{playerid} = true;
	selectingCharacter_CurrentChar{playerid} = 255;
	if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
		TogglePlayerSpectating(playerid, true);
	}

	TextDrawShowForPlayer(playerid, TD_LoadingSkin);

	ClearChat(playerid);
	
	M:P:X(playerid, "Pasirinkus norimà veikëjà, raðyk arba spausk");
	M:P:X(playerid, "[highlight]/zaisti[] (arba [highlight]ENTER[] arba [highlight]SPACE[]) norëdamas pradëti þaidimà,");
	M:P:X(playerid, "[highlight]/kurti[] (arba [highlight]ALT[]) norëdamas kurti naujà veikëjà,");
	M:P:X(playerid, "[highlight]/trinti[] iðtrinti pasirinktà veikëjà.");
}

classSelection_SelectSkin(playerid) {
	selectingCharacterSkin{playerid} = true;
	selectingCharacter_CurrentSkin{playerid} = 255;
	if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
		TogglePlayerSpectating(playerid, true);
	}

	TextDrawShowForPlayer(playerid, TD_LoadingSkin);

	M:P:I(playerid, "Pasirinkus norimà iðvaizdà, raðyk [highlight]/kurti[] arba spausk [highlight]ENTER[] arba [highlight]SPACE[].");
}

classSelection_ResetActors(playerid) {
	for(new i; i < MAX_CHARACTERS; ++i) {
		if(IsValidActor(selectCharacter_Actors[playerid][i])) {
			DestroyActor(selectCharacter_Actors[playerid][i]);
			selectCharacter_Actors[playerid][i] = INVALID_ACTOR_ID;

			DestroyDynamic3DTextLabel(selectCharacter_ActorInfo[playerid][i]);
			selectCharacter_ActorInfo[playerid][i] = Text3D:INVALID_3DTEXT_ID;
		}
	}
}

classSelection_PopulateActors(playerid) {
	format_query("SELECT * FROM chars WHERE user_id = %i", player_AccountID[playerid]);

	new Cache:cache = mysql_query(database, query);
	selectCharacter_ActorsCount[playerid] = cache_get_row_count();

	new i = 0;
	if(selectCharacter_ActorsCount[playerid]) do {
		static text[500], name[MAX_PLAYER_NAME];
		cache_get_field_content(i, "name", name);
		if( ! isnull(name)) {
			selectCharacter_ActorName[playerid][i][0] = EOS;
			strcat(selectCharacter_ActorName[playerid][i], name);
		}
		static characterexp =: cache_get_field_content_int(i, "exp");
		static charactermoney =: cache_get_field_content_int(i, "cash");
		static charactermodel =: cache_get_field_content_int(i, "current_skin");
		static characterjob =: cache_get_field_content_int(i, "job");
		static characterjobrank =: cache_get_field_content_int(i, "job_rank");
		static characterwanted =: cache_get_field_content_int(i, "wanted");

		format(text, 500, "\
			{00FF00}%s\n\
			{ffffff}Darbas: {33ff33}%s (%s)\n\
			{ffffff}Patirtis: {33ff33}%i\n\
			{ffffff}Pinigai: {33ff33}%i\n\
			{ffffff}Ieðkomumo lygis: {33ff33}%c (%i)\
		", selectCharacter_ActorName[playerid][i], GetJobName(characterjob), job_GetRankName(characterjobrank, characterjob), characterexp, charactermoney, police_TypeByWanted(characterwanted), characterwanted);
		
		selectCharacter_ActorInfo[playerid][i] = CreateDynamic3DTextLabel(text, 0xFFFFFFFF, 
			selectCharacter_Positions[i][0],
			selectCharacter_Positions[i][1],
			selectCharacter_Positions[i][2] + 1.2, 30, .playerid = playerid
		);

		new current_actor = selectCharacter_Actors[playerid][i] = CreateActor(charactermodel, 
			selectCharacter_Positions[i][0],
			selectCharacter_Positions[i][1],
			selectCharacter_Positions[i][2],
			selectCharacter_Positions[i][3]
		);
		SetActorVirtualWorld(current_actor, playerid + VW_OFFSET_CHARSELECT);
		SetActorInvulnerable(current_actor);
	}
	while(++i < selectCharacter_ActorsCount[playerid] && i < MAX_CHARACTERS);

	Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);

	cache_delete(cache);
	return selectCharacter_ActorsCount[playerid];
}

classSelection_CreateCharacter(playerid) {
	creatingNewCharacter{playerid} = true;
	selectingCharacter{playerid} = false;

	format_query("SELECT * FROM chars where user_id = %i", player_AccountID[playerid]);

	static Cache:cache; cache = mysql_query(database, query);
	static row_count =: cache_get_row_count();
	cache_delete(cache);

	if(row_count >= MAX_CHARACTERS) {
		M:P:E(playerid, "Pasiektas maksimalus veikëjø skaièius - [number]%i[].", MAX_CHARACTERS);
		classSelection_Show(playerid);
		return;
	}

	inline create_char(re, li) {
		#pragma unused li
		if(! re) {
			if( ! selectCharacter_ActorsCount[playerid]) {
				Kick(playerid);
			}
			else {
				classSelection_ResetActors(playerid);
				classSelection_Show(playerid);
			}
		}
		else {
			if(InvalidNick(playerid, dialog_Input)) {
				classSelection_CreateCharacter(playerid);
			}
			else {
				format_query("SELECT * FROM chars WHERE name='%s'", dialog_Input);
				cache = mysql_query(database, query);
				if(cache_get_row_count()) {
					cache_delete(cache);
					ClearChat(playerid, false);
					M:P:E(playerid, "Ðis vardas jau uþimtas.");
					classSelection_CreateCharacter(playerid);
					return;
				}
				cache_delete(cache);

				ClearChat(playerid, false);
				M:P:G(playerid, "Vardas \"[name]%s[]\" yra laisvas! Dabar iðsirink savo veikëjo iðvaizdà.", dialog_Input);
				SetPlayerName(playerid, dialog_Input);
				selectCharacter_ActorName[playerid][row_count][0] = EOS;
				strcat(selectCharacter_ActorName[playerid][row_count], dialog_Input);
				classSelection_SelectSkin(playerid);
			}
		}
	}
	dialogShow(playerid, using inline create_char, DIALOG_STYLE_INPUT, "Áraðyk veikëjo vardà bei pavardæ", "Vardà ir pavardæ gali sudaryti maþiausiai 3 simboliai.\nVardà ir pavardæ reikia atskirti simboliu {ffffff}_", "Kurti");
}

SetCameraInFrontOfActor(playerid, i, update_skin = true) {
	if(update_skin) {
		DestroyActor(selectCharacter_Actors[playerid][i]);
		selectCharacter_Actors[playerid][i] = CreateActor(createCharacter_ClassModels[selectingCharacter_CurrentSkin{playerid}],
			selectCharacter_Positions[i][0], selectCharacter_Positions[i][1], selectCharacter_Positions[i][2], selectCharacter_Positions[i][3]);
		SetActorVirtualWorld(selectCharacter_Actors[playerid][i], VW_OFFSET_CHARSELECT + playerid);

		TextDrawShowForPlayer(playerid, TD_LoadingSkin);
	}

	static Float:cameraPosition[4];
	cameraPosition = selectCharacter_Positions[i];

	GetXYInFrontOfPoint(
		cameraPosition[0], cameraPosition[1], cameraPosition[2], cameraPosition[3], update_skin ? 3.2 : 4.5);
	SetPlayerCameraPos(playerid,
		cameraPosition[0], cameraPosition[1], cameraPosition[2] + 1.3);
	SetPlayerCameraLookAt(playerid, 
		selectCharacter_Positions[i][0], selectCharacter_Positions[i][1], selectCharacter_Positions[i][2], selectingCharacter_CameraCut{playerid} ? CAMERA_CUT : CAMERA_MOVE);
	selectingCharacter_CameraCut{playerid} = false;
}

hook OnActorStreamIn(actorid, forplayerid) {
	if(selectCharacter_ActorsCount[forplayerid] < MAX_CHARACTERS) {
		if(actorid == selectCharacter_Actors[forplayerid][ selectCharacter_ActorsCount[forplayerid] ]) {
			TextDrawHideForPlayer(forplayerid, TD_LoadingSkin);
		}
	}
	return true;
}

hook OnGameModeInit() {
	TD_LoadingSkin = TextDrawCreate(320.000000, 215.250000, "Palaukite...");
	TextDrawLetterSize(TD_LoadingSkin, 0.298000, 1.640832);
	TextDrawAlignment(TD_LoadingSkin, 2);
	TextDrawColor(TD_LoadingSkin, -1);
	TextDrawSetShadow(TD_LoadingSkin, 0);
	TextDrawSetOutline(TD_LoadingSkin, 1);
	TextDrawBackgroundColor(TD_LoadingSkin, 51);
	TextDrawFont(TD_LoadingSkin, 2);
	TextDrawSetProportional(TD_LoadingSkin, 1);
}

hook OnPlayerConnect(playerid) {
	GetPlayerName(playerid, player_AccountName[playerid], MAX_PLAYER_NAME);
	for(new i; i < MAX_CHARACTERS; ++i) {
		selectCharacter_Actors[playerid][i] = INVALID_ACTOR_ID;
		selectCharacter_ActorInfo[playerid][i] = Text3D:INVALID_3DTEXT_ID;
	}
	defer SetCamera(playerid);
}

timer SetCamera[100](playerid) {
	// pakeièiam kameros pozicijà á pradinæ kai renkamës characterá
	SetCameraInFrontOfActor(playerid, 0, .update_skin = false);
}

hook OnPlayerDisconnect(playerid, reason) {
	classSelection_ResetActors(playerid);
	selectingCharacter_CameraCut{playerid} = false;
	creatingNewCharacter{playerid} = false;
}

hook OnPlayerUpdate(playerid) {
	if(selectingCharacter{playerid}) {
		if(selectingCharacter_CurrentChar{playerid} == 254) {
			selectingCharacter_CurrentChar{playerid} = 0;
			TextDrawHideForPlayer(playerid, TD_LoadingSkin);

			SetCameraInFrontOfActor(playerid, 0, false);
		}
		if(selectingCharacter_CurrentChar{playerid} == 255) {
			selectingCharacter_CurrentChar{playerid} = 254;
			return true;
		}
		static keys, lr, ud;
		static lastState[MAX_PLAYERS];
		GetPlayerKeys(playerid, keys, ud, lr);

		if(keys & KEY_NO || keys & KEY_WALK) {
			classSelection_ResetActors(playerid);
			classSelection_CreateCharacter(playerid);
			return true;
		}
		if(keys & KEY_SPRINT || keys & KEY_SECONDARY_ATTACK) {
			SetPlayerName(playerid, selectCharacter_ActorName[playerid][ selectingCharacter_CurrentChar{playerid} ]);
			selectingCharacter{playerid} = false;
			playerData_LoadChar(playerid);
			return true;
		}

		if(lastState[playerid] != lr) {
			if(lr) {
				if(lr > 0) { // RIGHT
					if(++selectingCharacter_CurrentChar{playerid} == selectCharacter_ActorsCount[playerid]) {
						selectingCharacter_CurrentChar{playerid} = 0;
					}
				}
				else if(lr < 0) { // LEFT
					if(--selectingCharacter_CurrentChar{playerid} == 255) {
						selectingCharacter_CurrentChar{playerid} = selectCharacter_ActorsCount[playerid] - 1;
					}
				}
				SetCameraInFrontOfActor(playerid, selectingCharacter_CurrentChar{playerid}, false);
			}
		}
		lastState[playerid] = lr;
	}
	if(selectingCharacterSkin{playerid}) {
		if(selectingCharacter_CurrentSkin{playerid} == 255) {
			selectingCharacter_CurrentSkin{playerid} = 0;
			TextDrawHideForPlayer(playerid, TD_LoadingSkin);

			SetCameraInFrontOfActor(playerid, selectCharacter_ActorsCount[playerid]);
		}
		static keys, lr, ud;
		static lastState[MAX_PLAYERS];
		GetPlayerKeys(playerid, keys, ud, lr);

		if(keys & KEY_SPRINT || keys & KEY_SECONDARY_ATTACK) {
			player_CurrentSkin[playerid] = player_DefaultSkin[playerid] = createCharacter_ClassModels[selectingCharacter_CurrentSkin{playerid}];

			player_AvailableSkins[playerid]{ player_DefaultSkin[playerid] } = true;
			selectingCharacterSkin{playerid} = false;

			playerData_LoadChar(playerid);

			return true;
		}

		if(lastState[playerid] != lr) {
			if(lr) {
				if(lr > 0) { // RIGHT
					if(++selectingCharacter_CurrentSkin{playerid} == sizeof createCharacter_ClassModels) {
						selectingCharacter_CurrentSkin{playerid} = 0;
					}
				}
				else if(lr < 0) { // LEFT
					if(--selectingCharacter_CurrentSkin{playerid} < 0 || selectingCharacter_CurrentSkin{playerid} == 255) {
						selectingCharacter_CurrentSkin{playerid} = 13;
					}
				}
				SetCameraInFrontOfActor(playerid, selectCharacter_ActorsCount[playerid]);
			}
		}
		lastState[playerid] = lr;
	}
	return true;
}

hook OnPlayerDamageDone(playerid, Float:amount, issuerid, weapon, bodypart) {
	if(issuerid != INVALID_PLAYER_ID) {
		lastTimeInFight[playerid] = gettime();
	}
	return true;
}