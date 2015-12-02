#include <YSI\y_hooks>

static Iterator:friends[MAX_PLAYERS]<MAX_PLAYERS>;

hook OnGameModeInit() {
	Iter_Init(friends);
}

hook OnPlSelectTargetMenu(playerid, targetid, li) {

}

hook OnPlayerOpenTargetMenu(playerid, targetid) {

}

ShowListOfFriends(playerid) {
	format(g_DialogText, _, "Draugas\tBûsena");

	new has_friends;

	// online
	foreach(new i : friends[playerid]) {
		dialogAddLine("%s\t%s", player_Name[i], ReturnPlayerState(i));
		has_friends++;
	}

	// offline
	format_query("               \
		SELECT                   \
			chars.*              \
		FROM                     \
			friends              \
		LEFT JOIN                \
			chars                \
		ON                       \
			online = 0           \
		AND                      \
			uid = friends.friend \
		WHERE                    \
			charid = %i          \
	", GetPlayerCharID(playerid));

	new Cache:cache = mysql_query(database, query);

	foreach(new i : Limit(cache_num_rows())) {
		static name[MAX_PLAYER_NAME];
		cache_get_field_content(i, "name", name);
		dialogAddLine("{34495e}%s\t{7f8c8d}Neprisijungæs", name);
		has_friends++;
	}

	inline response(re, li) {
		#pragma unused li
		if(re && has_friends) {
			new name[MAX_PLAYER_NAME];
			strset(name, dialog_Input);

			extract name -> new player:friend;

			ManageFriend(playerid, friend, name);
		}
	}

	if( ! has_friends) {
		dialogShow(playerid, using inline response, DIALOG_STYLE_MSGBOX, "Draugø sàraðas", "Tavo draugø sàraðas tuðèias. ha.", "...");
	}
	else {
		dialogShow(playerid, using inline response, DIALOG_STYLE_TABLIST_HEADERS, "Draugø sàraðas", g_DialogText, "Rinktis", "Uþdaryti");
	}
}

ManageFriend(playerid, friend, name[]) {
	dialogSetHeader("%s", name);

	if(IsPlayerConnected(friend)) {
		dialogAddOption("Pradëti pokalbá.");
	}
	dialogAddOption("Paðalinti ið draugø.");

	inline response(re, li) {
		#pragma unused li
		if(re) {
			dialog_Row("Pradëti pokalbá");
		}
		else {
			ShowListOfFriends(playerid);
		}
	}

	dialogShow(playerid, using inline response, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
}

AddFriend(playerid, friend) {
	Iter_Add(friends[playerid], friend);

	format_query("INSERT INTO friends (charid, friend) VALUES (%i, %i)", GetPlayerCharID(playerid), GetPlayerCharID(friend));
	M:P:G(playerid, "[name]%s[] pridëtas prie tavo draugø sàraðo.", player_Name[friend]);
}

RemoveFriend(playerid, friend = INVALID_PLAYER_ID, friend_name[] = "") {
	if(friend == INVALID_PLAYER_ID && ! isnull(friend_name)) {
		format_query("                            \
			DELETE FROM                           \
				friends                           \
			WHERE                                 \
				charid = %i                       \
			AND                                   \
				friend IN                         \
				(                                 \
					SELECT                        \
						chars.uid                 \
					AS                            \
						friend                    \
					FROM                          \
						chars                     \
					WHERE                         \
						name = '%s'               \
				)                                 \
		", GetPlayerCharID(playerid), friend_name);

		mysql_query(database, query, false);

		M:P:G(playerid, "[name]%s[] paðalintas ið draugø sàraðo.", friend_name);
	}
	else {
		Iter_Remove(friends[playerid], friend);

		format_query("DELETE FROM friends WHERE charid = %i AND friend = %i", 
			GetPlayerCharID(playerid, GetPlayerCharID(friend)));
		mysql_query(database, query, false);

		M:P:G(playerid, "[name]%s[] paðalintas ið draugø sàraðo.", player_Name[friend]);
	}
}