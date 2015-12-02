
gangMenu_ShowLeaderMenu(playerid, gang) {
	inline response(re, li) {
		#pragma unused li
		if(re) {
			dialog_Row("Pavadinimas") {
				gangMenu_ChangeName(playerid);
			}
			dialog_Row("Prisijungæ nariai") {
				gangMenu_ManageMembers(playerid);
			}
			dialog_Row("Gaujos karai") {
				gangMenu_ManageWars(playerid);
			}
			dialog_Row("Gaujos teritorijos") {
				gangMenu_ManageTerritories(playerid);
			}
			dialog_Row("Gauja ákurta") {
				gangMenu_DeleteGang(playerid);
			}
		}
	}
	format(g_DialogText, _, "Gaujos Informacija\tValdymas");
	dialogAddOption("Pavadinimas %s\tPakeisti pavadinimà", GetGangName(gang));
	dialogAddOption("Prisijungæ nariai: %i/%i\tTvarkyti narius", GetGangMembers(gang, .online = true), GetGangMembers(gang));
	dialogAddOption("Gaujos karai: %i\tPerþiûrëti karus", GetGangMembers(gang, .online = true), GetGangMembers(gang));
	dialogAddOption("Gaujos teritorijos: %i\tTeritorijø informacija", CountGangTerritories(gang));
	dialogAddOption("Gaujos taðkai: %i\tNaudoti taðkus", GetGangPoints(gang));

	dialogAddOption("Gauja ákurta: %s\tPanaikinti gaujà", GetGangCreatedAt(gang));

	dialogShow(playerid, using inline response, DIALOG_STYLE_TABLIST_HEADERS, "Gaujos meniu", "Rinktis", "Uþdaryti");
}

static gangMenu_ChangeName(playerid) {
	new gang = GetPlayerGang(playerid, .local = true);

	inline change_name(re, li) {
		#pragma unused li
		if(re) {
			switch(SetGangName(dialog_Input, gang)) {
				case GANG_NAME_NO_NAME: {
					gangMenu_ChangeName(playerid);
				}
				case GANG_NAME_EXISTS: {
					M:P:E(playerid, "Toks gaujos pavadinimas jau yra uþimtas.");
					gangMenu_ChangeName(playerid);
				}
				case GANG_NAME_OK: {
					M:P:G(playerid, "Gaujos pavadinimas pakeistas á \"[highlight]%s[]\"", GetGangName(gang));
					gangMenu_ShowLeaderMenu(playerid, gang);
				}
			}
		}
		else {
			gangMenu_ShowLeaderMenu(playerid, gang);
		}
	}
	dialogSetHeader("Norëdamas pakeisti gaujos pavadinimà, ávesk naujà.");
	dialogAddOption("Dabartinis gaujos pavadinimas: %s", GetGangName(GetPlayerGang(playerid)));
	dialogShow(playerid, using inline change_name, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Keisti", "Atgal");
}

static gangMenu_ManageMembers(playerid) {
	new gang = GetPlayerGang(playerid, .local = true);
	new gangid = GetGangId(gang);

	inline manage_members(re, li) {
		#pragma unused li
		if(re) {
			if(isnull(dialog_Input)) {
				gangMenu_ManageMembers(playerid);
			}
			else {
				gangMenu_ManageSelectedMember(playerid, dialog_Input);
			}
		}
		else {
			gangMenu_ShowLeaderMenu(playerid, gang);
		}
	}
	format(g_DialogText, _, "Vardas_Pavardë\tPatirtis\tPaskutiná kartà prisijungë");
	foreach(new i : Player) {
		static Y, M, D, h, m, s;
		TimestampToDate(GetPlayerGangJoinTime(playerid), Y, M, D, h, m, s, 2);
		dialogAddLine("{2ecc71}%s{ffffff}\t%i\t{aaaaaa}%i.%i.%i {ffffff}%i{aaaaaa}:{ffffff}%i", player_Name[i], GetPlayerExp(i), Y, M, D, h, m);
	}
	format_query("SELECT * FROM chars WHERE gang = %i AND online = 0", gangid);
	new Cache:cache = mysql_query(database, query);
	foreach(new i : Limit(cache_num_rows())) {
		static Y, M, D, h, m, s, name[MAX_PLAYER_NAME];
		TimestampToDate(cache_get_field_content_int(i, "gang_join_time"), Y, M, D, h, m, s, 2);
		cache_get_field_content(i, "name", name);
		dialogAddLine("{95a5a6}%s\t%i\t{7f8c8d}%i.%i.%i {95a5a6}%i{7f8c8d}:{95a5a6}%i", name, cache_get_field_content_int(i, "experience"), Y, M, D, h, m);
	}
	cache_delete(cache);
	dialogShow(playerid, using inline manage_members, DIALOG_STYLE_TABLIST_HEADERS, "Gaujos nariø valdymas", g_DialogText, "Rinktis", "Atgal");
}

static gangMenu_ManageSelectedMember(playerid, targetName[]) {
	format_query("SELECT * FROM chars WHERE name = '%s'", targetName);
	new Cache:cache = mysql_query(database, query);

	if( ! cache_num_rows()) {
		cache_delete(cache);
		gangMenu_ManageMembers(playerid);
		return;
	}
	cache_delete(cache);

	inline manage_selected_member(re, li) {
		#pragma unused li
		if(re) {
			dialog_Row("Iðmesti ið gaujos") {
				inline confirm(re1, li1) {
					#pragma unused li1
					if(re1) {
						extract targetName -> new player:targetid;
						if(IsPlayerConnected(targetid)) {
							KickFromGang(targetid);
						}
						else {
							format_query("UPDATE chars SET gang = 0 WHERE name = '%s'", targetName);
							mysql_query(database, query, false);
						}
						M:P:G(playerid, "[name]%s[] sëkmingai iðmestas ið gaujos.", targetName);
						gangMenu_ManageMembers(playerid);
					}
				}
				dialogShow(playerid, using inline confirm, DIALOG_STYLE_MSGBOX, " ", "Ar tikrai nori iðmesti ðá þaidëjà ið gaujos?", "Taip", "Atgal");
			}
			else {
				gangMenu_ManageSelectedMember(playerid, targetName);
			}
		}
		else {
			gangMenu_ManageMembers(playerid);
		}
	}
	dialogSetHeader("Gaujos narys: %s", targetName);
	dialogAddOption("Iðmesti ið gaujos");
	dialogShow(playerid, using inline manage_selected_member, DIALOG_STYLE_TABLIST, g_DialogText, "Rinktis", "Atgal");
}

static gangMenu_ManageWars(playerid) {
	new gang = GetPlayerGang(playerid, .local = true);

	inline manage_wars(re, li) {
		#pragma unused re, li
		gangMenu_ShowLeaderMenu(playerid, gang);
	}

	format(g_DialogText, _, "Prieðø gauja\tPrieðø taðkai\tMûsø taðkai");
	new Cache:cache = FetchGangWarsInfo(gang);
	foreach(new i : Limit(cache_num_rows())) {
		new enemy_name[MAX_GANG_NAME];
		cache_get_field_content(i, "enemy_name", enemy_name);

		dialogAddLine("%s\t%i/%i\t%i/%i", enemy_name, 
			cache_get_field_content_int(i, "enemy_points"),
			cache_get_field_content_int(i, "enemy_req_points"),
			cache_get_field_content_int(i, "points"),
			cache_get_field_content_int(i, "required_points")
		);
	}
	cache_delete(cache);
	dialogShow(playerid, using inline manage_wars, DIALOG_STYLE_TABLIST_HEADERS, "Karø sàraðas", g_DialogText, "Atgal", "");
}

static gangMenu_ManageTerritories(playerid) {
	#pragma unused playerid
}

static gangMenu_DeleteGang(playerid) {
	new gang = GetPlayerGang(playerid, .local = true);

	inline confirm(re, li) {
		#pragma unused li
		if(re) {
			DeleteGang(.gang = gang);
		}
		else {
			gangMenu_ShowLeaderMenu(playerid, gang);
		}
	}
	dialogSetHeader("Ar tikrai nori panaikinti savo gaujà?");
	dialogAddOption("Visi nariai bus iðmesti.");
	dialogAddOption("Dings gaujos taðkai, bazës bei teritorijos.");
	dialogAddOption("Panaikinus gaujà, jos atkurti atgal nebepavyks.");

	dialogShow(playerid, using inline confirm, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Naikinti", "Atgal");
}