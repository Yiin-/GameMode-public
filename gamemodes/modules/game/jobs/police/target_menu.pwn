#include <YSI_Coding\y_hooks>

static player_CuffAnimStart[MAX_PLAYERS];
static selectingVehicle[MAX_PLAYERS];
static cachedName[MAX_PLAYERS][MAX_PLAYER_NAME];

tryToGiveWantedLvl(playerid, targetid, is_uid = false) {
	getJobJsonFile:file<JOB_POLICE>;

	format(g_DialogText, sizeof g_DialogText, "Prie�astis\tIe�komumo lygis");


	inline GiveWantedLvl(re, li) {
		if(re) {
			new amount = djInt(file, F:0("reasons/%i/value", li));

			// �aid�jas prisijung�s
			if(IsPlayerConnected(targetid) || IsPlayerNPC(targetid)) {
				player_AddWanted(targetid, amount);

				job_MessageToMembers(JOB_POLICE, "[name]%s[] �taria [name]%s[] d�l \"%s\"[].", 
					player_Name[playerid], player_Name[targetid], dialog_Input);
				job_MessageToMembers(JOB_POLICE, "[name]%s[] ie�komumo lygis: [number]%i[].",
					player_Name[targetid], player_GetWanted(targetid));

				M:P:I(targetid, "[name]%s[] tave �tar� u� \"[highlight]%s[]\"", player_Name[playerid], dialog_Input);
				M:P:X(targetid, "Tavo ie�komumo lygis yra [highlight]%c[] ([number]%i[]).", police_TypeByWanted(player_GetWanted(targetid)), player_GetWanted(targetid));
			}
			else { // atsijung�s 
				format_query("SELECT wanted FROM chars WHERE uid = %i", cachedTargetID[playerid]);
				new Cache:cache = mysql_query(database, query);

				if(cache_num_rows()) {
					new wanted = cache_get_field_content_int(0, "wanted");
					cache_delete(cache);

					format_query("UPDATE chars SET `wanted` = %i WHERE uid = %i", wanted + amount, cachedTargetID[playerid]);
					mysql_tquery(database, query);

					job_MessageToMembers(JOB_POLICE, "[name]%s[] �taria [name]%s[] (off) d�l \"%s\".", 
						player_Name[playerid], cachedName[playerid], dialog_Input);
					job_MessageToMembers(JOB_POLICE, "[name]%s[] ie�komumo lygis: [number]%i[].",
						cachedName[playerid], wanted + amount);
				}
				else {
					cache_delete(cache);
					M:P:E(playerid, "Tokio �aid�jo neb�ra duomen� baz�je O.o");
				}
			}
		}
	}

	if(is_uid || ! IsPlayerConnected(targetid)) {
		format_query("SELECT name FROM chars WHERE uid = '%i'", cachedTargetID[playerid]);
		new Cache:cache = mysql_query(database, query);
		if(cache_num_rows()) {
			cache_get_row(0, 0, cachedName[playerid]);
			M:P:G(playerid, "Pasirink u� k� nori �tarti %s", cachedName[playerid]);

			for(new i, j = djCount(file, "reasons"); i < j; ++i) {
				static value; value = djInt(file, F:0("reasons/%i/value", i));
				dialogAddLine("%s\t%i", dj(file, F:0("reasons/%i/reason", i)), value);
			}
			if(!djCount(file, "reasons")) {
				dialogAddLine("?\t0");
			}
			dialogShow(playerid, using inline GiveWantedLvl, DIALOG_STYLE_TABLIST_HEADERS, "Pasirink nusikaltim�", g_DialogText, "Rinktis", "At�aukti");
		}
		else {
			M:P:E(playerid, "Toks �aid�jas nebeegzistuoja O.o");
		}
		cache_delete(cache);
	}
	else {
		M:P:G(playerid, "Pasirink u� k� nori �tarti %s", player_Name[targetid]);

		format(cachedName[playerid], MAX_PLAYER_NAME, player_Name[targetid]);

		for(new i, j = djCount(file, "reasons"); i < j; ++i) {
			static value; value = djInt(file, F:0("reasons/%i/value", i));
			dialogAddLine("%s\t%i", dj(file, F:0("reasons/%i/reason", i)), value);
		}
		if(!djCount(file, "reasons")) {
			dialogAddLine("?\t0");
		}
		dialogShow(playerid, using inline GiveWantedLvl, DIALOG_STYLE_TABLIST_HEADERS, "Pasirink nusikaltim�", g_DialogText, "Rinktis", "At�aukti");
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
				M:P:I(playerid, "bandai i�silaisvinti");
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
			M:P:G(playerid, "At�aukei pasirinkim� � kuri� ma�in� nori �sodinti �aid�j�.");
		}
	}
	if(PRESSED(KEY_WALK)) {
		if(selectingVehicle[playerid]) {
			if( ! IsPlayerConnected(cachedTargetID[playerid])) {
				M:P:E(playerid, "Pasirinkto �aid�jo �aidime neb�ra.");
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
						M:P:I(targetid, "[name]%s[] isodino tave � ma�in�.", player_Name[playerid]);
						M:P:G(playerid, "�sodinai [name]%s[] � ma�in�.", player_Name[ targetid ]);

						cachedTargetID[playerid] = INVALID_PLAYER_ID;
						selectingVehicle[playerid] = false;
						CanPlayerTargetVehicle(playerid, false);
					}
					else {
						M:P:E(playerid, "Ma�ina yra per toli.");
					}
				}
				else {
					M:P:E(playerid, "Ma�inoje n�ra laisvos vietos.");
				}
			}
			else {
				M:P:E(playerid, "Ne�i�ri � joki� ma�in�.");
			}
		}
	}
}

hook OnPlSelectTargetMenu(playerid, targetid) {
	dialog_Row("Ie�komumo lygio padidinimas") {
		tryToGiveWantedLvl(playerid, targetid);
	}
	dialog_Row("Nuimti antrankius") {
		if( ! IsPlayerCuffed(targetid)) {
			M:P:E(playerid, "[name]%s[] neb�ra surakintas.", player_Name[targetid]);
			return;
		}
		SetPlayerCuffed(targetid, false);

		M:P:G(playerid, "Atrakinai [name]%s[].", player_Name[targetid]);
		M:P:X(targetid, "Tave atrakino [name]%s[].", player_Name[playerid]);
	}
	dialog_Row("U�d�ti antrankius") {
		if(IsPlayerCuffed(targetid)) {
			M:P:E(playerid, "[name]%s[] jau yra surakintas.", player_Name[targetid]);
			return;
		}
		SetPlayerCuffed(targetid, true);

		M:P:G(playerid, "Surakinai [name]%s[].", player_Name[targetid]);
		M:P:X(targetid, "[name]%s[] tave surakino.", player_Name[playerid]);
	}
	dialog_Row("�sodinti � ma�in�") {
		// kol �aid�jas pasirinko �sodinti, kitas policininkas jau gal�jo �tariam�j� atrakinti
		// tod�l patikrinam dar kart�, kad ne�sodintum�m nesurakinto �mogaus
		if(IsPlayerCuffed(targetid)) {
			selectVehicleToPutTargetInto(playerid);
		}
	}
}

hook OnPlayerOpenTargetMenu(playerid, targetid) {
	if(player_Job[playerid] != JOB_POLICE) return;
	cachedTargetID[playerid] = targetid;

	dialogAddOption("Ie�komumo lygio padidinimas (%i).", player_GetWanted(targetid));

	if(IsPlayerCuffed(targetid)) {
		dialogAddOption("�sodinti � ma�in�.");
		dialogAddOption("Nuimti antrankius.");
	}
	else {
		dialogAddOption("U�d�ti antrankius.");
	}
}

selectVehicleToPutTargetInto(playerid) {
	M:P:X(playerid, "Pasi�i�r�k � norim� ma�in� ir spausk [highlight]ALT[].");
	M:P:I(playerid, "Nor�damas at�aukti ma�inos pasirinkim�, spausk [highlight]SPACE[].");
	selectingVehicle[playerid] = true;
	CanPlayerTargetVehicle(playerid, true);
}