#include <YSI_Coding\y_hooks>

vehicle_TryToBuy(vehicleid, playerid, forjob = false) {
	if(forjob) {
		new job = player_Job[playerid];
		if(job == JOB_NONE) return;

		if(job_Cash[job] < GetVehiclePrice(vehicleid)) {
			M:P:E(playerid, "Darbo fonde trûksta [number]%i[]eur, kad galëtum nupirkti ðià maðinà.",
				GetVehiclePrice(vehicleid) - job_Cash[job]
			);
		}
		else {
			new prev_owner = INVALID_PLAYER_ID;
			new prev_owner_sql;
			if(vehicle_OwnerType[vehicleid] == VEHICLE_OWNER_TYPE_PLAYER) {
				prev_owner_sql = vehicle_Owner[vehicleid];
				prev_owner = player_SQL_ID_TO_PLAYER_ID(prev_owner_sql);
			}
			job_Cash[job] -= GetVehiclePrice(vehicleid);

			switch(vehicle_OwnerType[vehicleid]) {
				case VEHICLE_OWNER_TYPE_SHOP: {
					vehicle_Status[vehicleid] = VEHICLE_STATUS_TRANSPORT_STATE1;
					vehicle_OwnerType[vehicleid] = VEHICLE_OWNER_TYPE_JOB;
					vehicle_Owner[vehicleid] = job;

					M:P:G(playerid, "Sëkmingai nupirkai [highlight]%s[] ([number]%s[]).",
						vehicle_Name[GetVehicleModel(vehicleid) - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "Uþ tr. priemonæ sumokëjai [number]%i[]eur. Maðinà á darbo bazæ pristatys fûristai.",
						GetVehiclePrice(vehicleid));

					SaveVehicle(vehicleid, .update_pos = false, .remove = true);
				}
				case VEHICLE_OWNER_TYPE_PLAYER: {
					vehicle_Status[vehicleid] = VEHICLE_STATUS_GARAGE;
					vehicle_OwnerType[vehicleid] = VEHICLE_OWNER_TYPE_JOB;
					vehicle_Owner[vehicleid] = job;
					job_AddVehicle(job, vehicleid);

					new model = GetVehicleModel(vehicleid);
					
					M:P:G(playerid, "Sëkmingai nupirkai [highlight]%s[] (%s).",
						vehicle_Name[model - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "Uþ tr. priemonæ sumokëjai [number]%i[] eur. Maðinà gali rasti darbo bazëje.",
						GetVehiclePrice(vehicleid));
					if(prev_owner != INVALID_PLAYER_ID) {
						AdjustPlayerCash(prev_owner, GetVehiclePrice(vehicleid));
						M:P:G(prev_owner, "Tavo parduodama maðina ([highlight]%s[] ([number]%s[])) sëkmingai parduota.", 
							vehicle_Name[model - 400], vehicle_Plate[vehicleid]);
						M:P:G(prev_owner, "[highlight]%s[] uþ jà sumokëjo [number]%i[]eur.",
							GetJobName(job), GetVehiclePrice(vehicleid));
					}
					else if(prev_owner_sql) {
						format_query("UPDATE chars SET `cash` = `cash` + %i WHERE uid = %i", GetVehiclePrice(vehicleid), prev_owner_sql);
						mysql_query(database, query, false);
					}
					SaveVehicle(vehicleid, .update_pos = false, .remove = true);
				}
			}
		}
	}
	else {
		if(GetPlayerCash(playerid) < GetVehiclePrice(vehicleid)) {
			M:P:E(playerid, "Tau trûksta [number]%i[]eur, kad galëtum nusipirkti ðià maðinà.",
				GetVehiclePrice(vehicleid) - GetPlayerCash(playerid)
			);
		}
		else {
			new prev_owner = INVALID_PLAYER_ID;
			new prev_owner_sql;
			if(vehicle_OwnerType[vehicleid] == VEHICLE_OWNER_TYPE_PLAYER) {
				prev_owner_sql = vehicle_Owner[vehicleid];
				prev_owner = player_SQL_ID_TO_PLAYER_ID(prev_owner_sql);
			}
			AdjustPlayerCash(playerid, -GetVehiclePrice(vehicleid));
			switch(vehicle_OwnerType[vehicleid]) {
				case VEHICLE_OWNER_TYPE_SHOP: {
					vehicle_Status[vehicleid] = VEHICLE_STATUS_TRANSPORT_STATE1;
					vehicle_OwnerType[vehicleid] = VEHICLE_OWNER_TYPE_PLAYER;
					vehicle_Owner[vehicleid] = char_ID[playerid];

					M:P:G(playerid, "Sëkmingai nusipirkai [highlight]%s[] ([number]%s[]).",
						vehicle_Name[GetVehicleModel(vehicleid) - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "Uþ tr. priemonæ sumokëjai [number]%i[]eur. Maðinà á garaþà pristatys fûristai.",
						GetVehiclePrice(vehicleid));

					SaveVehicle(vehicleid, .update_pos = false, .remove = true);
				}
				case VEHICLE_OWNER_TYPE_PLAYER: {
					vehicle_Status[vehicleid] = VEHICLE_STATUS_GARAGE;
					vehicle_OwnerType[vehicleid] = VEHICLE_OWNER_TYPE_PLAYER;
					vehicle_Owner[vehicleid] = char_ID[playerid];

					new model = GetVehicleModel(vehicleid);

					M:P:G(playerid, "Sëkmingai nusipirkai [highlight]%s[] (%s).",
						vehicle_Name[model - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "Uþ tr. priemonæ sumokëjai [number]%i[] eur. Maðinà gali rasti savo garaþe.",
						GetVehiclePrice(vehicleid));

					if(prev_owner != INVALID_PLAYER_ID) {
						AdjustPlayerCash(prev_owner, GetVehiclePrice(vehicleid));
						M:P:G(prev_owner, "Tavo parduodama tr. priemonë ([highlight]%s[] ([number]%s[])) sëkmingai parduota.", 
							vehicle_Name[GetVehicleModel(vehicleid) - 400], vehicle_Plate[vehicleid]);
						M:P:G(prev_owner, "Þaidëjas [name]%s[] uþ jà sumokëjo [number]%i[]eur.",
							player_Name[playerid], GetVehiclePrice(vehicleid));
					}
					else if(prev_owner_sql) {
						format_query("UPDATE chars SET `cash` = `cash` + %i WHERE uid = %i", GetVehiclePrice(vehicleid), prev_owner_sql);
						mysql_query(database, query, false);
					}
					SaveVehicle(vehicleid, .update_pos = false, .remove = true);
				}
			}
		}
	}
}

hook OnPlOpenTargetVehMenu(playerid, vehicleid) {
	if(vehicle_Status[vehicleid] == VEHICLE_STATUS_FORSALE) {
		dialogAddOption("Pirkti maðinà (asmeninæ)");
	}
}

hook OnPlSelectTargetVehMenu(playerid, vehicleid, li) {
	if(vehicle_Status[vehicleid] == VEHICLE_STATUS_FORSALE) {
		dialog_Row("Pirkti maðinà (asmeninæ)") {
			vehicle_TryToBuy(vehicleid, playerid);
		}
	}
}