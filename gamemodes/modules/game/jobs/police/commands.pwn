// Duoti �tarim� �mogui
CMD:ita(playerid, params[]) {
	if(player_Job[playerid] != JOB_POLICE) {
		M:P:E(playerid, "�tarimus dalinti gali tik teis�saugos pareig�nai.");
	}
	else {
		extract params -> new player:targetid;
		if(targetid == INVALID_PLAYER_ID) {
			if(!isnull(params)) {
				format_query("SELECT * FROM chars WHERE name = '%s'", params);
				new Cache:cache = mysql_query(database, query);

				if(cache_num_rows()) {
					cachedTargetID[playerid] = cache_get_field_content_int(0, "uid");
					tryToGiveWantedLvl(playerid, targetid, true);

					cache_delete(cache);

					return true;
				}
				cache_delete(cache);
			}
			M:P:E(playerid, "Tokio �aid�jo n�ra.");
			return true;
		}
		tryToGiveWantedLvl(playerid, targetid);
	}

	return true;
}

CMD:bauda(playerid, params[]) {
	extract params -> new player:targetid;
	if(IsPlayerConnected(targetid)) {
		if(player_GetWanted(targetid)) {
			new amount = police_CashForWantedLevel() * player_GetWanted(targetid);
			inline response(re, li) {
				#pragma unused li
				if(re) {
					if(GetPlayerCash(playerid) < amount) {
						M:P:E(playerid, "[name]%s[] neturi pakankamai pinig� baudai sumok�ti.", player_Name[targetid]);
						M:P:E(targetid, "Tau tr�ksta [number]%i[]�, kad gal�tum susimok�ti baud�.", amount - GetPlayerCash(targetid));
					}
					else {
						player_SetWanted(targetid, 0);
						M:P:G(playerid, "[name]%s[] sumok�jo [number]%i[]� baud�.", player_Name[targetid], amount);
						job_MessageToMembers(JOB_POLICE, "[name]%s[] sumok�jo [number]%i[]� baud�, kuri� skyr� [name]%s[].", player_Name[targetid], amount, player_Name[playerid]);
						M:P:G(playerid, "Sumok�jai [number]%i[]� baud�, kuri� skyr� [name]%s[], esi laisvas.", amount, player_Name[playerid]);
					}
				}
				else {
					M:P:E(playerid, "[name]%s[] atsisak� mok�ti baud�.", player_Name[targetid]);
				}
			}
			dialogSetHeader("%s tau si�lo sumok�ti baud�.", player_Name[playerid]);
			dialogAddOption("Suma: %i�", amount);
			dialogShow(targetid, using inline response, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Mok�ti", "Atsisakyti");
		}
	}
	return true;
}

CMD:sodinti(playerid, targetname[]) {
	new targetid;

	if(player_Job[playerid] != JOB_POLICE) {
		M:P:E(playerid, "Tu nesi policininkas.");
	}
	else {
		if( ! IsPlayerNearJail(playerid)) {
			M:P:E(playerid, "Nesi �alia kal�jimo ��jimo.");
		}
		else if(sscanf(targetname, "u", targetid)) {
			M:P:E(playerid, "Komandos naudojimas: [highlight]/sodinti [Vardas_Pavarde]");
		}
		else {
			if( ! IsPlayerConnected(targetid)) {
				M:P:E(playerid, "�aid�jo tokiu vardu �iuo metu serveryje n�ra.");
			}
			else {
				if(player_GetWanted(targetid) <= 0) {
					M:P:E(playerid, "�aid�jas n�ra d�l nieko �tariamas.");
				}
				else {
					new Float:X, Float:Y, Float:Z;
					GetPlayerPos(targetid, X, Y, Z);

					if(GetPlayerDistanceFromPoint(playerid, X, Y, Z) > 5.0) {
						M:P:E(playerid, "�aid�jas yra per toli.");
					}
					else {
						new total_time = jailPlayer(targetid, jail_Small); //player_GetWanted(targetid) > police_WantedByType('B') ? jail_Big : jail_Small);
						new h,m,s;

						SecToTime(total_time, h,m,s);

						M:P:G(playerid, "[name]%s[] s�kmingai pasodintas � kal�jim�. Iki paleidimo liko: [number]%i[]:[number]%i[]:[number]%i[].", player_Name[targetid], h,m,s);
					}
				}
			}
		}
	}
	return true;
}