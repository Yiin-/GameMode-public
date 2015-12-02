new 
	cached_passengers[MAX_PLAYERS][9],
	cached_passengers_uid[MAX_PLAYERS][9]
;

hook OnPlOpenTargetVehMenu(playerid, vehicleid) {
	if(player_Job[playerid] != JOB_POLICE) {
		return true;
	}
	dialogAddOption("Per�i�r�ti keleivius.");
	return true;
}

hook OnPlSelectTargetVehMenu(playerid, vehicleid, li) {
	if(player_Job[playerid] != JOB_POLICE) {
		return true;
	}
	dialog_Row("Per�i�r�ti keleivius") {
		dialog_ShowPassengers(playerid, vehicleid);
	}
	return true;
}

police_GeneratePassengers(playerid, vehicleid, &criminals = 0) {
	new criminals_count, total_count;
	g_DialogText[0] = EOS;

	foreach(new i : Character) {
		if(GetPlayerState(i) == PLAYER_STATE_PASSENGER
			&& GetPlayerVehicleID(i) == vehicleid
		) {
			cached_passengers_uid[playerid][total_count] = char_ID[i];
			cached_passengers[playerid][total_count++] = i;

			if(player_GetWanted(i)) {
				++criminals_count;
				dialogAddOption("{aa2222}%s {ffffff}%c (%i)", player_Name[i], police_TypeByWanted(player_GetWanted(i)), player_GetWanted(i));
			}
			else {
				dialogAddOption("{aaaaaa}%s", player_Name[i]);
			}
		}
	}
	criminals = criminals_count;
	return total_count;
}

dialog_ShowPassengers(playerid, vehicleid) {
	if( ! police_GeneratePassengers(playerid, vehicleid)) {
		return false;
	}
	else {
		inline response(re, li) {
			if(re) {
				dialog_SelectPassenger(playerid, vehicleid, li);
			}
		}
		dialogShow(playerid, using inline response, DIALOG_STYLE_LIST, "Ma�inoje s�dintys keleiviai", g_DialogText, "Sodinti", "At�aukti");
	}
	return true;
}

timer ForceRemoveIfStillInVehicle[3500](playerid) {
	if(IsPlayerInAnyVehicle(playerid)) {
		ClearAnimations(playerid, 1);
	}
}

dialog_SelectPassenger(playerid, vehicleid, li) {
	new targetid = cached_passengers[playerid][li];

	if( ! IsPlayerConnected(targetid)) {
		return false;
	}
	inline actions(re1, li1) {
		#pragma unused li1
		if(re1) {
			if(IsPlayerConnected(targetid)) {
				dialog_Row("Sodinti � kal�jim�") {
					if(player_GetWanted(targetid)) {
						new seconds = jailPlayer(targetid, jail_Small);
						new h,m,s; SecToTime(seconds, h,m,s);

						job_MessageToMembers(JOB_POLICE, "[name]%s[] pasodino [name]%s[] � kal�jim�. Bausm�s trukm� [number]%i[]:[number]%i[]:[number]%i[].", h,m,s);
					}
					else {
						dialog_ShowPassengers(playerid, vehicleid);
						M:P:E(playerid, "�is �aid�jas n�ra nusikalt�lis.");
					}
				}
				dialog_Row("I�mesti i� ma�inos") {
					M:P:G(playerid, "I�metei [name]%s[] i� ma�inos.", player_Name[targetid]);
					M:P:I(targetid, "[name]%s[] i�met� tave i� ma�inos.", player_Name[playerid]);
					RemovePlayerFromVehicle(targetid);
					defer ForceRemoveIfStillInVehicle(targetid);
				}
			}
			else {
				M:P:E(playerid, "�aid�jas n�ra prisijung�s.");
				dialog_ShowPassengers(playerid, vehicleid);
			}
		}
		else {
			dialog_ShowPassengers(playerid, vehicleid);
		}
	}
	dialogSetHeader("Keleivis: %s", player_Name[targetid]);
	if(IsPlayerNearJail(playerid) && player_GetWanted(targetid)) {
		dialogAddOption("Sodinti � kal�jim�.");
	}
	dialogAddOption("I�mesti i� ma�inos.");
	dialogShow(playerid, using inline actions, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");

	return true;
}