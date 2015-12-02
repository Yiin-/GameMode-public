#include <YSI_Coding\y_hooks>

hook OnPlayerConnect(playerid) {
	static username[MAX_PLAYER_NAME];
	GetPlayerName(playerid, username, MAX_PLAYER_NAME);

	format_query("SELECT * FROM users WHERE username = '%s'", username);
	new Cache:cache = mysql_query(database, query);

	if(cache_get_row_count()) {
		login(playerid, cache_save());
	}
	else {
		cache_delete(cache);
		register(playerid);
	}
}

static login(playerid, Cache:cache, fails = 0) {
	if(fails) {
		M:P:E(playerid, "Slaptaþodis neteisingas! ([number]%i[]/[number]3[])", fails);
		if(fails == 3) {
			cache_delete(cache);
			print("kick1");
			Kick(playerid);
		}
	}
	inline login_response(response, li) {
		#pragma unused li
		if(response) {
			static input_password[129];
			WP_Hash(input_password, sizeof input_password, dialog_Input);

			static real_password[129];
			cache_get_field_content(0, "password", real_password);

			if( ! strcmp(input_password, real_password)) {
				player_AccountID[playerid] = cache_get_field_content_int(0, "uid");
				
				cache_delete(cache);

				classSelection_Show(playerid);
			}
			else {
				login(playerid, cache, fails + 1);
			}
		}
		else {
			cache_delete(cache);
			Kick(playerid);
		}
	}
	dialogSetHeader("Norëdamas prisijungti ávesk savo slaptaþodá.");
	dialogShow(playerid, using inline login_response, DIALOG_STYLE_PASSWORD, "Prisijungimas", g_DialogText, "Prisijungti", "");
}

static register(playerid) {
	inline register_reponse(response, li) {
		#pragma unused li
		if(response) {
			static username[MAX_PLAYER_NAME];
			GetPlayerName(playerid, username, MAX_PLAYER_NAME);

			static password[129];
			WP_Hash(password, sizeof password, dialog_Input);

			static serial[128];
			gpci(playerid, serial, sizeof serial);

			format_query("INSERT INTO users (username, password, last_gpci, last_ip) VALUES ('%s', '%s', '%s', %i)", username, password, serial, compressPlayerIP(playerid));
			new Cache:cache = mysql_query(database, query);
			
			player_AccountID[playerid] = cache_insert_id();
			cache_delete(cache);

			classSelection_Show(playerid, .new_account = true);
		}
		else {
			register(playerid);
		}
	}
	dialogSetHeader("Norëdamas uþsiregistruoti, ávesk naujà slaptaþodá");
	dialogShow(playerid, using inline register_reponse, DIALOG_STYLE_PASSWORD, "Registracija", g_DialogText, "Registruotis", "");
}

static compressPlayerIP(playerid) {
	static ip_address[16];
	GetPlayerIp(playerid, ip_address, 16);

	static ip[4];
	sscanf(ip_address, "p<.>a<i>[4]", ip);

	return (ip[0] * 16777216) + (ip[1] * 65536) + (ip[2] * 256) + (ip[3]);
}