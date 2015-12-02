#include <YSI_Coding\y_hooks>

vehicle_TryToBuy(vehicleid, playerid, forjob = false) {
	if(forjob) {
		new job = player_Job[playerid];
		if(job == JOB_NONE) return;

		if(job_Cash[job] < GetVehiclePrice(vehicleid)) {
			M:P:E(playerid, "Darbo fonde tr�ksta [number]%i[]eur, kad gal�tum nupirkti �i� ma�in�.",
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

					M:P:G(playerid, "S�kmingai nupirkai [highlight]%s[] ([number]%s[]).",
						vehicle_Name[GetVehicleModel(vehicleid) - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "U� tr. priemon� sumok�jai [number]%i[]eur. Ma�in� � darbo baz� pristatys f�ristai.",
						GetVehiclePrice(vehicleid));

					SaveVehicle(vehicleid, .update_pos = false, .remove = true);
				}
				case VEHICLE_OWNER_TYPE_PLAYER: {
					vehicle_Status[vehicleid] = VEHICLE_STATUS_GARAGE;
					vehicle_OwnerType[vehicleid] = VEHICLE_OWNER_TYPE_JOB;
					vehicle_Owner[vehicleid] = job;
					job_AddVehicle(job, vehicleid);

					new model = GetVehicleModel(vehicleid);
					
					M:P:G(playerid, "S�kmingai nupirkai [highlight]%s[] (%s).",
						vehicle_Name[model - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "U� tr. priemon� sumok�jai [number]%i[] eur. Ma�in� gali rasti darbo baz�je.",
						GetVehiclePrice(vehicleid));
					if(prev_owner != INVALID_PLAYER_ID) {
						AdjustPlayerCash(prev_owner, GetVehiclePrice(vehicleid));
						M:P:G(prev_owner, "Tavo parduodama ma�ina ([highlight]%s[] ([number]%s[])) s�kmingai parduota.", 
							vehicle_Name[model - 400], vehicle_Plate[vehicleid]);
						M:P:G(prev_owner, "[highlight]%s[] u� j� sumok�jo [number]%i[]eur.",
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
			M:P:E(playerid, "Tau tr�ksta [number]%i[]eur, kad gal�tum nusipirkti �i� ma�in�.",
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

					M:P:G(playerid, "S�kmingai nusipirkai [highlight]%s[] ([number]%s[]).",
						vehicle_Name[GetVehicleModel(vehicleid) - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "U� tr. priemon� sumok�jai [number]%i[]eur. Ma�in� � gara�� pristatys f�ristai.",
						GetVehiclePrice(vehicleid));

					SaveVehicle(vehicleid, .update_pos = false, .remove = true);
				}
				case VEHICLE_OWNER_TYPE_PLAYER: {
					vehicle_Status[vehicleid] = VEHICLE_STATUS_GARAGE;
					vehicle_OwnerType[vehicleid] = VEHICLE_OWNER_TYPE_PLAYER;
					vehicle_Owner[vehicleid] = char_ID[playerid];

					new model = GetVehicleModel(vehicleid);

					M:P:G(playerid, "S�kmingai nusipirkai [highlight]%s[] (%s).",
						vehicle_Name[model - 400], vehicle_Plate[vehicleid]);
					M:P:G(playerid, "U� tr. priemon� sumok�jai [number]%i[] eur. Ma�in� gali rasti savo gara�e.",
						GetVehiclePrice(vehicleid));

					if(prev_owner != INVALID_PLAYER_ID) {
						AdjustPlayerCash(prev_owner, GetVehiclePrice(vehicleid));
						M:P:G(prev_owner, "Tavo parduodama tr. priemon� ([highlight]%s[] ([number]%s[])) s�kmingai parduota.", 
							vehicle_Name[GetVehicleModel(vehicleid) - 400], vehicle_Plate[vehicleid]);
						M:P:G(prev_owner, "�aid�jas [name]%s[] u� j� sumok�jo [number]%i[]eur.",
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
		dialogAddOption("Pirkti ma�in� (asmenin�)");
	}
}

hook OnPlSelectTargetVehMenu(playerid, vehicleid, li) {
	if(vehicle_Status[vehicleid] == VEHICLE_STATUS_FORSALE) {
		dialog_Row("Pirkti ma�in� (asmenin�)") {
			vehicle_TryToBuy(vehicleid, playerid);
		}
	}
}