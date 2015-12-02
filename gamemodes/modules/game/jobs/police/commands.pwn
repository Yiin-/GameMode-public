// Duoti átarimà þmogui
CMD:ita(playerid, params[]) {
	if(player_Job[playerid] != JOB_POLICE) {
		M:P:E(playerid, "Átarimus dalinti gali tik teisësaugos pareigûnai.");
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
			M:P:E(playerid, "Tokio þaidëjo nëra.");
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
						M:P:E(playerid, "[name]%s[] neturi pakankamai pinigø baudai sumokëti.", player_Name[targetid]);
						M:P:E(targetid, "Tau trûksta [number]%i[]€, kad galëtum susimokëti baudà.", amount - GetPlayerCash(targetid));
					}
					else {
						player_SetWanted(targetid, 0);
						M:P:G(playerid, "[name]%s[] sumokëjo [number]%i[]€ baudà.", player_Name[targetid], amount);
						job_MessageToMembers(JOB_POLICE, "[name]%s[] sumokëjo [number]%i[]€ baudà, kurià skyrë [name]%s[].", player_Name[targetid], amount, player_Name[playerid]);
						M:P:G(playerid, "Sumokëjai [number]%i[]€ baudà, kurià skyrë [name]%s[], esi laisvas.", amount, player_Name[playerid]);
					}
				}
				else {
					M:P:E(playerid, "[name]%s[] atsisakë mokëti baudà.", player_Name[targetid]);
				}
			}
			dialogSetHeader("%s tau siûlo sumokëti baudà.", player_Name[playerid]);
			dialogAddOption("Suma: %i€", amount);
			dialogShow(targetid, using inline response, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Mokëti", "Atsisakyti");
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
			M:P:E(playerid, "Nesi ðalia kalëjimo áëjimo.");
		}
		else if(sscanf(targetname, "u", targetid)) {
			M:P:E(playerid, "Komandos naudojimas: [highlight]/sodinti [Vardas_Pavarde]");
		}
		else {
			if( ! IsPlayerConnected(targetid)) {
				M:P:E(playerid, "Þaidëjo tokiu vardu ðiuo metu serveryje nëra.");
			}
			else {
				if(player_GetWanted(targetid) <= 0) {
					M:P:E(playerid, "Þaidëjas nëra dël nieko átariamas.");
				}
				else {
					new Float:X, Float:Y, Float:Z;
					GetPlayerPos(targetid, X, Y, Z);

					if(GetPlayerDistanceFromPoint(playerid, X, Y, Z) > 5.0) {
						M:P:E(playerid, "Þaidëjas yra per toli.");
					}
					else {
						new total_time = jailPlayer(targetid, jail_Small); //player_GetWanted(targetid) > police_WantedByType('B') ? jail_Big : jail_Small);
						new h,m,s;

						SecToTime(total_time, h,m,s);

						M:P:G(playerid, "[name]%s[] sëkmingai pasodintas á kalëjimà. Iki paleidimo liko: [number]%i[]:[number]%i[]:[number]%i[].", player_Name[targetid], h,m,s);
					}
				}
			}
		}
	}
	return true;
}