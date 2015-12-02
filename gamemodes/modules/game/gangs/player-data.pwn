#include <YSI_Coding\y_hooks>

enum {
	GANG_RANK_LEADER = -1
};

static 
	player_Gang[MAX_PLAYERS],
	player_GangRank[MAX_PLAYERS],
	player_GangJoinTime[MAX_PLAYERS]
;

hook ResetPlayerVars(playerid) {
	player_Gang[playerid] = 0;
	player_GangRank[playerid] = 0;
}

hook OnCreatePlayerORM(ORM:ormid, playerid) {
	orm_addvar_int(ormid, player_Gang[playerid], "gang");
	orm_addvar_int(ormid, player_GangRank[playerid], "gang_rank");
	orm_addvar_int(ormid, player_GangJoinTime[playerid], "gang_join_time");
}

hook OnPlayerDataLoaded(playerid) {
	LoadGang(GetPlayerGang(playerid));
}

GetPlayerGangJoinTime(playerid) {
	return player_GangJoinTime[playerid];
}

GetPlayerGang(playerid, local = false) {
	if(local) {
		return FindGang(GetPlayerGang(playerid));
	}
	return player_Gang[playerid];
}

SetPlayerGang(playerid, gangid) {
	player_Gang[playerid] = gangid;
	player_GangJoinTime[playerid] = gettime();
	orm_update(GetPlayerORM(playerid));
}

GetPlayerGangRank(playerid) {
	return player_GangRank[playerid];
}

SetPlayerGangRank(playerid, rank) {
	player_GangRank[playerid] = rank;
}

InviteToGang(playerid, targetid, gang) {
	inline invite(re,li) {
		#pragma unused li
		if(re) {
			M:P:G(playerid, "[name]%s[] sutiko prisijungti prie gaujos.", player_Name[targetid]);
			foreach(new i : Player) {
				if(GetPlayerGang(i) == GetGangId(gang)) {
					M:P:I(i, "Naujas gaujos narys: [name]%s[].", player_Name[targetid]);
				}
			}
			SetPlayerGang(targetid, GetGangId(gang));
			M:P:G(targetid, "Sëkmingai ástojai á gaujà [highlight]%s[]!", GetGangName(gang));
		}
		else {
			ShowTargetPlayerMenu(playerid, targetid);
		}
	}
	dialogSetHeader("%s kvieèia tave prisijungti prie gaujos %s!", player_Name[playerid], GetGangName(gang));
	dialogAddOption("%s", player_Name[targetid]);
	dialogShow(playerid, using inline invite, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Taip", "Atðaukti");
}

KickFromGang(playerid, gang_was_deleted = false, by_choice = false) {
	SetPlayerGang(playerid, 0);

	if(gang_was_deleted) {
		M:P:I(playerid, "Gauja buvo panaikinta.");
	}
	else if(by_choice) {
		M:P:G(playerid, "Palikai gaujà.");
	}
	else {
		M:P:I(playerid, "Esi iðmestas ið gaujos.");
	}
}

GetGangMembers(gang, online = false) {
	new ret;

	if(online) {
		foreach(new i : Player) {
			if(GetPlayerGang(i) == GetGangId(gang)) {
				++ret;
			}
		}
		return ret;
	}
	format_query("SELECT uid FROM users where gang = %i", GetGangId(gang));
	new Cache:cache = mysql_query(database, query);

	ret = cache_num_rows();
	cache_delete(cache);

	return ret;
}

hook OnPlSelectTargetMenu(playerid, targetid, li) {
	if( ! IsGangLeader(playerid)) {
		ShowTargetPlayerMenu(playerid, targetid);
		return;
	}
	new gang = GetPlayerGang(playerid, .local = true);
	if(gang == NONE) {
		ShowTargetPlayerMenu(playerid, targetid);
		return;
	}

	dialog_Row("Iðmesti ið gaujos") {
		inline confirm(re,li1) {
			#pragma unused li1
			if(re) {
				KickFromGang(targetid);
				M:P:G(playerid, "[name]%s[] iðmestas ið gaujos.", player_Name[targetid]);
			}
			else {
				ShowTargetPlayerMenu(playerid, targetid);
			}
		}
		dialogSetHeader("Ar tikrai nori iðmesti ðá þaidëjà ið gaujos?");
		dialogAddOption("%s", player_Name[targetid]);
		dialogShow(playerid, using inline confirm, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Taip", "Atðaukti");
	}
	dialog_Row("Pakviesti á gaujà") {
		InviteToGang(playerid, targetid, gang);
	}
	dialog_Row("Siûlyti taikà tarp gaujø") {

	}
	dialog_Row("Skelbti gaujø karà") {

	}
}

hook OnPlayerOpenTargetMenu(playerid, targetid) {
	if(IsGangLeader(playerid)) {
		if(GetPlayerGang(targetid) == GetPlayerGang(playerid)) {
			dialogAddOption("Iðmesti ið gaujos.");
		}
		else if( ! GetPlayerGang(targetid)) {
			dialogAddOption("Pakviesti á gaujà.");
		}
	}
}