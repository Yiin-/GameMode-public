
gangMenu_ShowMemberMenu(playerid, gang) {
	inline response(re, li) {
		#pragma unused li
		if(re) {
			dialog_Row("Per�i�r�ti narius") {
				gangMenu_ShowMembers(playerid);
			}
			dialog_Row("Per�i�r�ti gaujos karus") {
				gangMenu_ShowWars(playerid);
			}
			dialog_Row("Palikti gauj�") {
				gangMenu_LeaveGang(playerid);
			}
		}
	}
	dialogSetHeader("Gauja: %s", GetGangName(gang));
	dialogAddOption("Per�i�r�ti narius: %i/%i", GetGangMembers(gang, .online = true), GetGangMembers(gang));
	dialogAddOption("Per�i�r�ti gaujos karus: %i", GetGangMembers(gang, .online = true), GetGangMembers(gang));
	dialogAddOption("Gaujos teritorijos: %i", CountGangTerritories(gang));
	dialogAddOption("Gaujos ta�kai: %i", GetGangPoints(gang));
	dialogAddOption("Gauja �kurta: %s", GetGangCreatedAt(gang));
	dialogAddLine("Palikti gauj�");

	dialogShow(playerid, using inline response, DIALOG_STYLE_TABLIST_HEADERS, "Gaujos meniu", "Rinktis", "U�daryti");
}

gangMenu_ShowMembers(playerid) {
	new gang = GetPlayerGang(playerid, .local = true);

	inline show_members(re, li) {
		#pragma unused re, li
		gangMenu_ShowMemberMenu(playerid, gang);
	}
	format(g_DialogText, _, "Vardas_Pavard�\tPatirtis\tPaskutin� kart� prisijung�");
	foreach(new i : Player) {
		static Y, M, D, h, m, s;
		TimestampToDate(GetPlayerGangJoinTime(playerid), Y, M, D, h, m, s, 2);
		dialogAddLine("%s\t%i\t{aaaaaa}%i.%i.%i {ffffff}%i{aaaaaa}:{ffffff}%i", player_Name[i], GetPlayerExp(i), Y, M, D, h, m);
	}
	dialogShow(playerid, using inline show_members, DIALOG_STYLE_TABLIST_HEADERS, "Gaujos nariai", g_DialogText, "Rinktis", "Atgal");
}

gangMenu_ShowWars(playerid) {
	new gang = GetPlayerGang(playerid, .local = true);

	inline manage_wars(re, li) {
		#pragma unused re, li
		gangMenu_ShowMemberMenu(playerid, gang);
	}

	format(g_DialogText, _, "Prie�� gauja\tPrie�� ta�kai\tM�s� ta�kai");
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
	dialogShow(playerid, using inline manage_wars, DIALOG_STYLE_TABLIST_HEADERS, "Kar� s�ra�as", g_DialogText, "Atgal", "");
}

gangMenu_LeaveGang(playerid) {
	new gang = GetPlayerGang(playerid, .local = true);

	inline confirm(re, li) {
		#pragma unused li
		if(re) {
			KickFromGang(playerid);
		}
		else {
			gangMenu_ShowMemberMenu(playerid, gang);
		}
	}
	dialogSetHeader("Ar tikrai nori palikti savo gauj�?");

	dialogShow(playerid, using inline confirm, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Taip", "Atgal");
}
