#include <YSI_Coding\y_hooks>

static player_CuffAnimStart[MAX_PLAYERS];
static selectingVehicle[MAX_PLAYERS];
static cachedName[MAX_PLAYERS][MAX_PLAYER_NAME];

tryToGiveWantedLvl(playerid, targetid, is_uid = false) {
	getJobJsonFile:file<JOB_POLICE>;

	format(g_DialogText, sizeof g_DialogText, "Prieþastis\tIeðkomumo lygis");


	inline GiveWantedLvl(re, li) {
		if(re) {
			new amount = djInt(file, F:0("reasons/%i/value", li));

			// þaidëjas prisijungæs
			if(IsPlayerConnected(targetid) || IsPlayerNPC(targetid)) {
				player_AddWanted(targetid, amount);

				job_MessageToMembers(JOB_POLICE, "[name]%s[] átaria [name]%s[] dël \"%s\"[].", 
					player_Name[playerid], player_Name[targetid], dialog_Input);
				job_MessageToMembers(JOB_POLICE, "[name]%s[] ieðkomumo lygis: [number]%i[].",
					player_Name[targetid], player_GetWanted(targetid));

				M:P:I(targetid, "[name]%s[] tave átarë uþ \"[highlight]%s[]\"", player_Name[playerid], dialog_Input);
				M:P:X(targetid, "Tavo ieðkomumo lygis yra [highlight]%c[] ([number]%i[]).", police_TypeByWanted(player_GetWanted(targetid)), player_GetWanted(targetid));
			}
			else { // atsijungæs 
				format_query("SELECT wanted FROM chars WHERE uid = %i", cachedTargetID[playerid]);
				new Cache:cache = mysql_query(database, query);

				if(cache_num_rows()) {
					new wanted = cache_get_field_content_int(0, "wanted");
					cache_delete(cache);

					format_query("UPDATE chars SET `wanted` = %i WHERE uid = %i", wanted + amount, cachedTargetID[playerid]);
					mysql_tquery(database, query);

					job_MessageToMembers(JOB_POLICE, "[name]%s[] átaria [name]%s[] (off) dël \"%s\".", 
						player_Name[playerid], cachedName[playerid], dialog_Input);
					job_MessageToMembers(JOB_POLICE, "[name]%s[] ieðkomumo lygis: [number]%i[].",
						cachedName[playerid], wanted + amount);
				}
				else {
					cache_delete(cache);
					M:P:E(playerid, "Tokio þaidëjo nebëra duomenø bazëje O.o");
				}
			}
		}
	}

	if(is_uid || ! IsPlayerConnected(targetid)) {
		format_query("SELECT name FROM chars WHERE uid = '%i'", cachedTargetID[playerid]);
		new Cache:cache = mysql_query(database, query);
		if(cache_num_rows()) {
			cache_get_row(0, 0, cachedName[playerid]);
			M:P:G(playerid, "Pasirink uþ kà nori átarti %s", cachedName[playerid]);

			for(new i, j = djCount(file, "reasons"); i < j; ++i) {
				static value; value = djInt(file, F:0("reasons/%i/value", i));
				dialogAddLine("%s\t%i", dj(file, F:0("reasons/%i/reason", i)), value);
			}
			if(!djCount(file, "reasons")) {
				dialogAddLine("?\t0");
			}
			dialogShow(playerid, using inline GiveWantedLvl, DIALOG_STYLE_TABLIST_HEADERS, "Pasirink nusikaltimà", g_DialogText, "Rinktis", "Atðaukti");
		}
		else {
			M:P:E(playerid, "Toks þaidëjas nebeegzistuoja O.o");
		}
		cache_delete(cache);
	}
	else {
		M:P:G(playerid, "Pasirink uþ kà nori átarti %s", player_Name[targetid]);

		format(cachedName[playerid], MAX_PLAYER_NAME, player_Name[targetid]);

		for(new i, j = djCount(file, "reasons"); i < j; ++i) {
			static value; value = djInt(file, F:0("reasons/%i/value", i));
			dialogAddLine("%s\t%i", dj(file, F:0("reasons/%i/reason", i)), value);
		}
		if(!djCount(file, "reasons")) {
			dialogAddLine("?\t0");
		}
		dialogShow(playerid, using inline GiveWantedLvl, DIALOG_STYLE_TABLIST_HEADERS, "Pasirink nusikaltimà", g_DialogText, "Rinktis", "Atðaukti");
	}
}

hook OnPlayerConnect(playerid) {
	selectingVehicle[playerid] = 0;
	cachedTargetID[playerid] = INVALID_PLAYER_ID;
	return true;
}

hook OnCharacterDespawn(playerid) {
	cachedTargetID[playerid] = INVALID_PLAYER_ID;
	selectingVehicle[playerid] = 0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(PRESSED(KEY_JUMP)) {
		if(IsPlayerCuffed(playerid)) {
			if(player_CuffAnimStart[playerid] + 6 < gettime()) {
				M:P:I(playerid, "bandai iðsilaisvinti");
				player_CuffAnimStart[playerid] = gettime();
				TogglePlayerControllable(playerid, false);
				ApplyAnimation(playerid, "SMOKING", "M_smk_in", 4.1, 0, 1, 1, 0, 0, 1); // fuck sa-mp sync
				defer uncuff_StartAnimation(playerid);
				defer uncuff_End(playerid);
			}
		}
	}
	if(PRESSED(KEY_SPRINT)) {
		if(selectingVehicle[playerid]) {
			CanPlayerTargetVehicle(playerid, false);
			cachedTargetID[playerid] = INVALID_PLAYER_ID;
			selectingVehicle[playerid] = false;
			M:P:G(playerid, "Atðaukei pasirinkimà á kurià maðinà nori ásodinti þaidëjà.");
		}
	}
	if(PRESSED(KEY_WALK)) {
		if(selectingVehicle[playerid]) {
			if( ! IsPlayerConnected(cachedTargetID[playerid])) {
				M:P:E(playerid, "Pasirinkto þaidëjo þaidime nebëra.");
				cachedTargetID[playerid] = INVALID_PLAYER_ID;
				selectingVehicle[playerid] = false;
				CanPlayerTargetVehicle(playerid, true);
				return;
			}
			new vehicleid = GetPlayerCameraTargetVehicle(playerid);
			if(vehicleid == INVALID_VEHICLE_ID) {
				vehicleid = GetPVarInt(playerid, "lookingAtVehicle");
			}
			if(vehicleid && vehicleid != INVALID_VEHICLE_ID) {
				new const seat = vehicle_FindEmptySeat(vehicleid);
				new const targetid = cachedTargetID[playerid];
				if(seat) {
					new Float:pos[3];
					GetVehiclePos(vehicleid, XYZ0(pos));
					if(IsPlayerInRangeOfPoint(playerid, 10, XYZ0(pos))) {
						if(IsPlayerNPC(targetid)) {
							#if defined _FCNPC_included
								FCNPC_PutInVehicle(targetid, vehicleid, seat);
							#endif
						}
						else {
							PutPlayerInVehicle(targetid, vehicleid, seat);
						}
						M:P:I(targetid, "[name]%s[] isodino tave á maðinà.", player_Name[playerid]);
						M:P:G(playerid, "Ásodinai [name]%s[] á maðinà.", player_Name[ targetid ]);

						cachedTargetID[playerid] = INVALID_PLAYER_ID;
						selectingVehicle[playerid] = false;
						CanPlayerTargetVehicle(playerid, false);
					}
					else {
						M:P:E(playerid, "Maðina yra per toli.");
					}
				}
				else {
					M:P:E(playerid, "Maðinoje nëra laisvos vietos.");
				}
			}
			else {
				M:P:E(playerid, "Neþiûri á jokià maðinà.");
			}
		}
	}
}

hook OnPlSelectTargetMenu(playerid, targetid) {
	dialog_Row("Ieðkomumo lygio padidinimas") {
		tryToGiveWantedLvl(playerid, targetid);
	}
	dialog_Row("Nuimti antrankius") {
		if( ! IsPlayerCuffed(targetid)) {
			M:P:E(playerid, "[name]%s[] nebëra surakintas.", player_Name[targetid]);
			return;
		}
		SetPlayerCuffed(targetid, false);

		M:P:G(playerid, "Atrakinai [name]%s[].", player_Name[targetid]);
		M:P:X(targetid, "Tave atrakino [name]%s[].", player_Name[playerid]);
	}
	dialog_Row("Uþdëti antrankius") {
		if(IsPlayerCuffed(targetid)) {
			M:P:E(playerid, "[name]%s[] jau yra surakintas.", player_Name[targetid]);
			return;
		}
		SetPlayerCuffed(targetid, true);

		M:P:G(playerid, "Surakinai [name]%s[].", player_Name[targetid]);
		M:P:X(targetid, "[name]%s[] tave surakino.", player_Name[playerid]);
	}
	dialog_Row("Ásodinti á maðinà") {
		// kol þaidëjas pasirinko ásodinti, kitas policininkas jau galëjo átariamàjá atrakinti
		// todël patikrinam dar kartà, kad neásodintumëm nesurakinto þmogaus
		if(IsPlayerCuffed(targetid)) {
			selectVehicleToPutTargetInto(playerid);
		}
	}
}

hook OnPlayerOpenTargetMenu(playerid, targetid) {
	if(player_Job[playerid] != JOB_POLICE) return;
	cachedTargetID[playerid] = targetid;

	dialogAddOption("Ieðkomumo lygio padidinimas (%i).", player_GetWanted(targetid));

	if(IsPlayerCuffed(targetid)) {
		dialogAddOption("Ásodinti á maðinà.");
		dialogAddOption("Nuimti antrankius.");
	}
	else {
		dialogAddOption("Uþdëti antrankius.");
	}
}

selectVehicleToPutTargetInto(playerid) {
	M:P:X(playerid, "Pasiþiûrëk á norimà maðinà ir spausk [highlight]ALT[].");
	M:P:I(playerid, "Norëdamas atðaukti maðinos pasirinkimà, spausk [highlight]SPACE[].");
	selectingVehicle[playerid] = true;
	CanPlayerTargetVehicle(playerid, true);
}