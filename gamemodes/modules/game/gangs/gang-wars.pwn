#define MAX_WARS_PER_GANG 10
#define GW_POINTS_FOR_KILL 6
#define GW_POINTS_FOR_DEATH 4

GetMaxWarsPerGang() {
	return MAX_WARS_PER_GANG;
}

static 
	gwEnemy[MAX_GANGS][MAX_WARS_PER_GANG],
	gwPoints[MAX_GANGS][MAX_WARS_PER_GANG],
	gwRequiredPoints[MAX_GANGS][MAX_WARS_PER_GANG]
;

hook OnPlayerDataLoad(playerid) {
	if(GetPlayerGang(playerid)) {
		UpdateWarTags(playerid);
	}
}

hook OnPlayerDespawn(playerid) {
	if(GetPlayerGang(playerid)) {
		UpdateWarTags(playerid);
	}
}

hook OnPlayerJoinGang(playerid) {
	UpdateWarTags(playerid);
}

hook OnPlayerLeaveGang(playerid) {
	UpdateWarTags(playerid);
}

hook OnPlSelectTargetMenu(playerid, targetid, li) {
	dialog_Row("Siûlyti taikà tarp gaujø") {
		inline response(re, li2) {
			#pragma unused li2
			if(re) {
				M:P:G(playerid, "[name]%s[] (gauja: [highlight]%s[]) priëmë taikos pasiûlymà.", player_Name[targetid], GetGangName(GetPlayerGang(targetid, .local = true)));
				RemoveGangWar(GetPlayerGang(playerid, .local = true), GetPlayerGang(targetid, .local = true));
			}
			else {
				M:P:I(playerid, "[name]%s[] (gauja: [highlight]%s[]) atmetë taikos pasiûlymà.", player_Name[targetid], GetGangName(GetPlayerGang(targetid, .local = true)));
			}
		}
		dialogSetHeader("%s (gauja: %s) siûlo paskelbti taikà.", player_Name[playerid], GetGangName(GetPlayerGang(playerid, .local = true)));
		dialogAddOption("Paskelbus taikà, karas pasibaigs lygiosiomis ir nei viena gauja taðkø nebegaus, o taðkai gauti iki ðiol ðiame kare bus anuliuoti.");
		dialogShow(targetid, using inline response, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Taika", "Atmesti");
	}
	dialog_Row("Skelbti gaujø karà") {
		inline response(re, li2) {
			#pragma unused li2
			if(re) {
				M:P:G(playerid, "[name]%s[] (gauja: [highlight]%s[]) priëmë karo pasiûlymà.", player_Name[targetid], GetGangName(GetPlayerGang(targetid, .local = true)));
				AddGangWar(GetPlayerGang(playerid, .local = true), GetPlayerGang(targetid, .local = true));
			}
			else {
				M:P:I(playerid, "[name]%s[] (gauja: [highlight]%s[]) atmetë karo pasiûlymà.", player_Name[targetid], GetGangName(GetPlayerGang(targetid, .local = true)));
			}
		}
		dialogSetHeader("%s (gauja: %s) siûlo paskelbti karà.", player_Name[playerid], GetGangName(GetPlayerGang(playerid, .local = true)));
		dialogAddOption("Paskelbus karà, gaujos kariaus .");
		dialogShow(targetid, using inline response, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Taika", "Atmesti");
	}
}

hook OnPlayerOpenTargetMenu(playerid, targetid) {
	new player_gang = GetPlayerGang(playerid);
	new target_gang = GetPlayerGang(targetid);

	if(IsGangLeader(playerid) && IsGangLeader(targetid)) {
		if(IsGangWarDeclared(player_gang, target_gang)) {
			dialogAddOption("Siûlyti taikà tarp gaujø.");
		}
		else {
			dialogAddOption("Skelbti gaujø karà.");
		}
	}
}

hook OnGangWarEnd(winner, loser) {
	RemoveGangWar(winner, loser);

	UpdateWarTags();

	M:G:I("Gauja [highlight]%s[] laimëjo karà prieð [highlight]%s[]!", GetGangName(winner), GetGangName(loser));
	M:G:I("Laimëjusios gaujos [highlight]%s[] taðkai: [number]%i[], nariø skaièius: [number]%i", GetGangName(winner), GetGangPoints(winner), GetGangMembers(winner));
	M:G:I("Pralaimëjusios gaujos [highlight]%s[] taðkai: [number]%i[], nariø skaièius: [number]%i", GetGangName(loser), GetGangPoints(loser), GetGangMembers(loser));
}

AddGangWar(gang, enemy, swap = true) {
	foreach(new i : Limit(MAX_WARS_PER_GANG)) {
		if(gwEnemy[gang][i]) {
			continue;
		}
		gwEnemy[gang][i] = GetGangId(enemy);
		gwPoints[gang][i] = 0;
		gwRequiredPoints[gang][i] = GetGangMembers(gang);

		if(swap) {
			if( ! AddGangWar(enemy, gang, false)) {
				RemoveGangWar(gang, .index = i);
			}
			else {
				UpdateWarTags();

				new gang_req_points = GetGangMembers(gang);
				new enemy_req_points = GetGangMembers(enemy);

				foreach(new playerid : Player) {
					if(GetPlayerGang(playerid) == GetGangId(gang)) {
						M:P:I(playerid, "Pradëtas karas su gauja [highlight]%s[]. {2ecc71}%i[] vs {e74c3c}%i[].", GetGangName(enemy), gang_req_points, enemy_req_points);
					}
					else if(GetPlayerGang(playerid) == GetGangId(enemy)) {
						M:P:I(playerid, "Pradëtas karas su gauja [highlight]%s[]. {2ecc71}%i[] vs {e74c3c}%i[].", GetGangName(gang), enemy_req_points, gang_req_points);
					}
				}
			}
		}
		else {
			format_query("INSERT INTO gangwars (gangid, enemy) VALUES (%i, %i)", GetGangId(gang), GetGangId(enemy));
			mysql_pquery(database, query);
			format_query("INSERT INTO gangwars (gangid, enemy) VALUES (%i, %i)", GetGangId(enemy), GetGangId(gang));
			mysql_pquery(database, query);
			return true;
		}
	}
	return false;
}

RemoveGangWar(gang, enemy = NONE, index = NONE, swap = true) {
	if(index != NONE) {
		format_query("DELETE FROM gangwars WHERE gangid = %i AND enemy = %i", GetGangId(gang), gwEnemy[gang][index]);
		mysql_tquery(database, query);

		gwEnemy[gang][index] = 0;
		gwPoints[gang][index] = 0;
		gwRequiredPoints[gang][index] = 0;
		return true;
	}
	if(enemy != NONE) {
		foreach(new i : Limit(MAX_WARS_PER_GANG)) {
			if(gwEnemy[gang][i] == GetGangId(enemy)) {
				RemoveGangWar(gang, .index = i);
				if(swap) {
					RemoveGangWar(enemy, gang, .swap = false);
				}
				else {
					UpdateWarTags();
				}
				return true;
			}
		}
	}
	return false;
}

Cache:FetchGangWarsInfo(gang) {
	format_query("\
		SELECT                                            \
		  gangwar.*,                                      \
		  enemy_gang.points AS enemy_points,              \
		  enemy_gang.required_points AS enemy_req_points, \
		  gangs.name AS enemy_name                        \
		FROM                                              \
		  gangwars AS gangwar                             \
		LEFT JOIN                                         \
		  gangs                                           \
		ON                                                \
		  gangwar.enemy = gangs.uid                       \
		LEFT JOIN                                         \
		  gangwars AS enemy_gang                          \
		ON                                                \
		  gangwar.enemy = enemy_gang.gangid               \
		WHERE                                             \
		  gangwar.gangid = %i                             \
		GROUP BY                                          \
		  gangs.uid", GetGangId(gang));	

	return mysql_query(database, query);
}

hook OnPlayerKillPlayer(playerid, killerid, weaponid) {
	// should never be true
	if(killerid == INVALID_PLAYER_ID) {
		return;
	}
	new player_gang = GetPlayerGang(playerid);
	new killer_gang = GetPlayerGang(killerid);
	if(IsGangWarDeclared(player_gang, killer_gang)) {
		AdjustGangPoints(killer_gang, GW_POINTS_FOR_KILL);
		AdjustGangPoints(player_gang, GW_POINTS_FOR_DEATH);

		GivePlayerExp(killerid, 3);

		new war_idx = GetGangWarEnemyIndex(killer_gang, player_gang);

		gwPoints[killer_gang][war_idx]++;

		if(gwPoints[killer_gang][war_idx] >= gwRequiredPoints[killer_gang][war_idx]) {
			call OnGangWarEnd(killer_gang, player_gang);
		}
	}
}

UpdateWarTags(playerid = INVALID_PLAYER_ID) {
	if(playerid == INVALID_PLAYER_ID) {
		foreach(new i : Player) {
			if( ! GetPlayerGang(i)) {
				continue;
			}
			DoWarTagCheck(i);
		}
	}
	else {
		DoWarTagCheck(playerid);
	}
}

DoWarTagCheck(playerid) {
	foreach(new i : Player) {
		if(playerid == i || ! GetPlayerGang(i)) {
			continue;
		}
		if(GetPlayerGang(playerid) == GetPlayerGang(i)) {
			SetPlayerMarkerForPlayer(playerid, i, 0x27AE60);
			SetPlayerMarkerForPlayer(i, playerid, 0x27AE60);
		}
		if(IsGangWarDeclared(GetPlayerGang(playerid), GetPlayerGang(i))) {
			SetPlayerMarkerForPlayer(playerid, i, 0xE74C3C);
			SetPlayerMarkerForPlayer(i, playerid, 0xE74C3C);
		}
	}
}

GetGangWarEnemyIndex(gang, enemy) {
	foreach(new i : Limit(MAX_WARS_PER_GANG)) {
		if(gwEnemy[gang][i] == enemy) {
			return i;
		}
	}
	return NONE;
}

GetGangWarEnemy(gang, index) {
	return gwEnemy[gang][index];
}

GetGangWarPoints(gang, enemy = NONE, index = NONE) {
	if(index != NONE) {
		return gwPoints[gang][index];
	}
	if(enemy != NONE) {
		new i = GetGangWarEnemyIndex(gang, enemy);
		if(i != NONE) {
			return gwPoints[gang][i];
		}
	}
	return 0;
}

IsGangWarDeclared(gang, another_gang, swap = 1) {
	foreach(new i : Limit(MAX_WARS_PER_GANG)) {
		if(GetGangWarEnemy(gang, i) == GetGangId(another_gang)) {
			return swap ? IsGangWarDeclared(another_gang, gang, 0) : 1;
		}
	}
	return 0;
}

SaveGangWars(gang) {
	foreach(new i : Limit(MAX_WARS_PER_GANG)) {
		static enemy;
		if((enemy = GetGangWarEnemy(gang, i))) {
			format_query("UPDATE gangwars SET points = %i WHERE gangid = %i AND enemy = %i", 
				GetGangWarPoints(gang, .index = i), GetGangId(gang), enemy);
			mysql_tquery(database, query);
		}
	}
}

LoadGangWars(gang) {
	format_query("SELECT * FROM gangwars WHERE gangid = %i", GetGangId(gang));
	new Cache:cache = mysql_query(database, query);

	static count;

	if( ! (count = cache_num_rows())) {
		return false;
	}
	else do {
		gwEnemy[gang][count] = cache_get_field_content_int(count, "enemy");
		gwPoints[gang][count] = cache_get_field_content_int(count, "points");
		gwRequiredPoints[gang][count] = cache_get_field_content_int(count, "required_points");
	}
	while(--count != -1);

	cache_delete(cache);

	return true;
}

hook OnGangSave(gang) {
	SaveGangWars(gang);
}

hook OnGangLoad(gang) {
	LoadGangWars(gang);
}