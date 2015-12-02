#include <YSI_Coding\y_hooks>

enum _:CGarage {
	Cache:garage_r, // Sql result pagal kurá paimame þaidëjo maðinø informacijà
	garage_Count, // kiek maðinø turim ið viso?
	garage_CurrentFrame, // kokioje skaidrëje esam?
	garage_CurrentID, // kurià maðinà perþiûrim?
	// ---- random fuck ----
	garage_diff,
	garage_pause
};

new Text:TD_Garage[44];
new PlayerText:PlayerTD_Garage[23][MAX_PLAYERS];

new Garage[MAX_PLAYERS][CGarage];

new garage_ActiveVehicle[MAX_PLAYERS];
new isInGarage[MAX_PLAYERS char];

// Skaidrëse rodomø maðinø server id
new GarageList[MAX_PLAYERS][4];

// Garaþo vieta
new garage_area;

enum
{
	status_pavadinimas,
	status_title,
	status_page,
	status_image,
	status_bukle,
	status_greitis,
	status_degalai,
	status_bagazine,
	Text:status_line = 13
};

CMD:gshow(playerid, p[]) {
	garage_Show(playerid);
	return true;
}

CMD:ghide(playerid, p[]) {
	garage_Hide(playerid);
	return true;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	/*
	 * Patikrinam ar þaidëjas yra prie garaþo su savo maðina.
	 * Jeigu taip, atidarom jam garaþà ir leidþiam pasikeisti
	 * maðinà.
	 */
	if(IsPlayerInDynamicArea(playerid, garage_area)) {
		if(PRESSED(KEY_WALK)) {
			new vehicleid = GetPlayerVehicleID(playerid);
			if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
				garage_Show(playerid);
			}
			else if(GetVehicleOwnerType(vehicleid) == VEHICLE_OWNER_TYPE_PLAYER
				&& GetVehicleOwner(vehicleid) == GetPlayerCharID(playerid)) {
				garage_Show(playerid);
			}
			else {
				M:P:E(playerid, "Á garaþà gali atvaþiuoti tik su savo maðina.");
			}
		}
	}
	/*
	 * Þaidëjas jau yra garaþe, darom veiksmus priklausomai
	 * nuo þaidëjo mygtukø paspaudimø.
	 */
	if(isInGarage{playerid}) {
		if(PRESSED(KEY_SECONDARY_ATTACK)) {
			TogglePlayerSpectating(playerid, false);

			new vehicleid = garage_ActiveVehicle[playerid];

			// bus false jeigu tai pirma þaidëjo maðina
			if(vehicleid != INVALID_VEHICLE_ID)
			{
				SetVehicleStatus(vehicleid, VEHICLE_STATUS_GARAGE);
				SaveVehicle(vehicleid, .update_pos = true, .remove = true);
			}
			Garage[playerid][garage_CurrentFrame] = clamp(Garage[playerid][garage_CurrentFrame], 0, 3);
			vehicleid = garage_ActiveVehicle[playerid] = GarageList[playerid][ Garage[playerid][garage_CurrentFrame] ];
			GarageList[playerid][ Garage[playerid][garage_CurrentFrame] ] = 0;

			// teoriðkai turëtø visada bûti true
			if(vehicleid != INVALID_VEHICLE_ID)
			{
				SetVehicleStatus(vehicleid, VEHICLE_STATUS_ACTIVE);

				ApplyVehicleData(vehicleid);
				SetVehiclePos(vehicleid, Position_Garage);
				SetVehicleVirtualWorld(vehicleid, VW_DEFAULT);

				defer Fix_Z(vehicleid);

				PutPlayerInVehicle(playerid, vehicleid, 0);

				SaveVehicle(vehicleid, .update_pos = true, .remove = false);
			}
			garage_Hide(playerid);
		}
		else if(PRESSED(KEY_ACTION)) {
			garage_Hide(playerid);
		}
	}
}

timer Fix_Z[200](vehicleid) {
	SetVehicleZAngle(vehicleid, 280);
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	if(areaid == garage_area) {

	}
}
hook OnPlayerLeaveDynArea(playerid, areaid) {
	if(areaid == garage_area) {

	}
}

hook OnPlayerUpdate(playerid) {
	if(isInGarage{playerid})
	{
		if(GetTickCount() - 200 > Garage[playerid][garage_diff] || Garage[playerid][garage_pause])
		{
			Garage[playerid][garage_diff] = GetTickCount();
			static keys, ud, lr;
			GetPlayerKeys(playerid, keys, ud, lr);

			new id = Garage[playerid][garage_CurrentID];
			new frame = Garage[playerid][garage_CurrentFrame];

			if(lr > 0) // right 
			{
				++id;
				++frame;

				if(id < Garage[playerid][garage_Count])
				{
					Garage[playerid][garage_CurrentID] = id;
					if(frame < 4)
					{
						Garage[playerid][garage_CurrentFrame] = frame;
						TextDrawHideForPlayer(playerid, TD_Garage[13 + 10 * (frame-1)]);
						TextDrawShowForPlayer(playerid, TD_Garage[13 + 10 * frame]);
					}
					garage_ShowByID(playerid, frame, -1, id);
				}

				Garage[playerid][garage_pause] = 0;

			} else if(lr) { // left

				--id;
				--frame;
				if(id > -1)
				{
					Garage[playerid][garage_CurrentID] = id;

					if(frame > -1)
					{
						Garage[playerid][garage_CurrentFrame] = frame;
						TextDrawHideForPlayer(playerid, TD_Garage[13 + 10 * (frame+1)]);
						TextDrawShowForPlayer(playerid, TD_Garage[13 + 10 * frame]);
						//showGarageByID(playerid, frame, 1, id);
					}
					garage_ShowByID(playerid, frame, 1, id);
					
				}
				Garage[playerid][garage_pause] = 0;

			} else {

				Garage[playerid][garage_pause] = 1;
			}
		}
	}
	return true;
}

garage_ShowByID(playerid, frame, a, id) {
	if(Garage[playerid][garage_r]) {
		cache_set_active(Garage[playerid][garage_r]);
	}
	else return;
	/*
		old 	 0   1   2   3 
		new		[X] [0] [1] [2] -> [3]
	*/
	if(id > 3 && frame > 3 && a < 0) {
		Garage[playerid][garage_CurrentFrame] = 3;

		// Iðtrinam pirmà maðinà ið serverio atminties
		SaveVehicle(GarageList[playerid][0], .update_pos = false, .remove = true);
		for(new i; i < 3; ++i) {
			// Perkeliam likusias 3 maðinas 1 skaidre atgal
			GarageList[playerid][i] = GarageList[playerid][i + 1];
		}
		// Paskutinëje skaidrëje pakrauname naujà maðinà 
		new vehicleid = GarageList[playerid][3] = LoadVehicle(.row = id, .applydata = false);
		
		SetVehicleVirtualWorld(vehicleid, VW_GARAGE_TMP_VEHICLE);

		PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_pavadinimas ][playerid], vehicle_Name[vehicle_Model[vehicleid] - 400]);
		PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_page		 ][playerid], F:0("%i i %i", id+1, Garage[playerid][garage_Count]));
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_pavadinimas ][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_page		   ][playerid]);

		for(new i, k = id-3, j = Garage[playerid][garage_Count]; k != j && i != 4; ++i, ++k) {
			vehicleid = GarageList[playerid][i];
			new model = vehicle_Model[vehicleid];
			PlayerTextDrawSetPreviewModel (playerid, PlayerTD_Garage[ status_image + 5 * i ][playerid], model);
			PlayerTextDrawSetPreviewVehCol(playerid, PlayerTD_Garage[ status_image + 5 * i ][playerid], vehicle_Color1[vehicleid], vehicle_Color2[vehicleid]);
			PlayerTextDrawTextSize(playerid, PlayerTD_Garage[ status_bukle    + 5 * i ][playerid], vehicle_Health[vehicleid] / 1000.0 * 80.0, 4);
			PlayerTextDrawTextSize(playerid, PlayerTD_Garage[ status_greitis  + 5 * i ][playerid], float(vehicle_Speed[model - 400]) / 250.0 * 80.0, 4);
			PlayerTextDrawTextSize(playerid, PlayerTD_Garage[ status_degalai   + 5 * i ][playerid], vehicle_Fuel[vehicleid] / float(vehicle_MaxFuel[model - 400]) * 80.0, 4);
			// PlayerTextDrawTextSize(playerid, PlayerTD_Garage[ status_bagazine + 5 * i ][playerid], Storage.TotalWeight(storage.Vehicle + vehicleid) / float(vehicle_TrunkSize[model-400]) * 80.0, 4);
			
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_image 		+  5 * i ][playerid]);
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bukle 		+  5 * i ][playerid]);
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_greitis 	 	+  5 * i ][playerid]);
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_degalai 	 	+  5 * i ][playerid]);
			// PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bagazine 	+  5 * i ][playerid]);
		}
	
	}
	/*
		old 	 		0   1   2   3 
		new		[0] <- [1] [2] [3] [X]
	*/
	else if(frame < 0 && a > 0) {
		Garage[playerid][garage_CurrentFrame] = 0;

		// Iðtrinam pirmà maðinà ið serverio atminties
		SaveVehicle(GarageList[playerid][3], .update_pos = false, .remove = true);
		for(new i = 3; i > 0; --i) {
			// Perkeliam likusias 3 maðinas 1 skaidre atgal
			GarageList[playerid][i] = GarageList[playerid][i - 1];
		}
		// Paskutinëje skaidrëje pakrauname naujà maðinà 
		new vehicleid = GarageList[playerid][0] = LoadVehicle(.row = id, .applydata = false);
		
		SetVehicleVirtualWorld(vehicleid, VW_GARAGE_TMP_VEHICLE);

		PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_pavadinimas	][playerid], vehicle_Name[vehicle_Model[vehicleid] - 400]);
		PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_page			][playerid], F:0("%i i %i", id+1, Garage[playerid][garage_Count]));
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_pavadinimas			][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_page					][playerid]);

		for(new i, k = id, j = Garage[playerid][garage_Count]; k != j && i != 4; ++i, ++k) {
			vehicleid = GarageList[playerid][i];
			new model = vehicle_Model[vehicleid];
			PlayerTextDrawSetPreviewModel	(playerid, PlayerTD_Garage[ status_image		+  5 * i ][playerid], model);
			PlayerTextDrawSetPreviewVehCol(playerid, PlayerTD_Garage[ status_image		+  5 * i ][playerid], vehicle_Color1[vehicleid], vehicle_Color2[vehicleid]);
			PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_bukle		+  5 * i ][playerid], vehicle_Health[vehicleid] / 1000.0 * 80.0, 4);
			PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_greitis	+  5 * i ][playerid], float(vehicle_Speed[model-400]) / 250.0 * 80.0, 4);
			PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_degalai		+  5 * i ][playerid], vehicle_Fuel[vehicleid] / float(vehicle_MaxFuel[model - 400]) * 80.0, 4);
			// PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_bagazine	+  5 * i ][playerid], Storage.TotalWeight(storage.Vehicle + vehicleid) / float(vehicle_TrunkSize[model-400]) * 80.0, 4);
			
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_image 		 +  5 * i	][playerid]);
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bukle 		 +  5 * i	][playerid]);
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_greitis 	 +  5 * i	][playerid]);
			PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_degalai 	 +  5 * i	][playerid]);
			// PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bagazine 	 +  5 * i	][playerid]);
		}
	}
	/*
		old 	 0       1       2       3 
		new		[0] <-> [1] <-> [2] <-> [3]
	*/
	else if(frame + a >= 0) {
		new vehicleid = GarageList[playerid][frame];

		PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_pavadinimas	][playerid], vehicle_Name[vehicle_Model[vehicleid] - 400]);
		PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_page			][playerid], F:0("%i i %i", id+1, Garage[playerid][garage_Count]));
		printf("frame: %i, a: %i", frame, a);
		TextDrawColor(TD_Garage[4 + 10 * (frame + a)], 0x444444FF);
		TextDrawColor(TD_Garage[5 + 10 * (frame + a)], 0xFFFFFF44);
		TextDrawColor(TD_Garage[6 + 10 * (frame + a)], 0xFFFFFF44);
		TextDrawColor(TD_Garage[7 + 10 * (frame + a)], 0xFFFFFF44);
		TextDrawColor(TD_Garage[8 + 10 * (frame + a)], 0xFFFFFF44);
		TextDrawColor(TD_Garage[9 + 10 * (frame + a)], 0x333333FF);
		TextDrawColor(TD_Garage[10 + 10 * (frame + a)], 0x333333FF);
		TextDrawColor(TD_Garage[11 + 10 * (frame + a)], 0x333333FF);
		TextDrawColor(TD_Garage[12 + 10 * (frame + a)], 0x333333FF);
		//PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_image 	+  5 * (frame + a) ][playerid], 0x555555FF);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_bukle 	+  5 * (frame + a) ][playerid], 0x555555FF);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_greitis 	+  5 * (frame + a) ][playerid], 0x555555FF);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_degalai 	+  5 * (frame + a) ][playerid], 0x555555FF);
		// PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_bagazine +  5 * (frame + a) ][playerid], 0x555555FF);

		TextDrawShowForPlayer(playerid, TD_Garage[4 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[5 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[6 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[7 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[8 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[9 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[10 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[11 + 10 * (frame + a)]);
		TextDrawShowForPlayer(playerid, TD_Garage[12 + 10 * (frame + a)]);

		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_pavadinimas +  5 * (frame + a)	][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_title 		 +  5 * (frame + a)	][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_page 		 +  5 * (frame + a)	][playerid]);
		//PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_image 		 +  5 * (frame + a)	][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bukle 		 +  5 * (frame + a)	][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_greitis 	 +  5 * (frame + a)	][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_degalai 	 +  5 * (frame + a)	][playerid]);
		// PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bagazine 	 +  5 * (frame + a)	][playerid]);

		/* _____________________________________________________________________________________ */

		TextDrawColor(TD_Garage[4 + 10 * frame], 0xFFFFFFFF);
		TextDrawColor(TD_Garage[5 + 10 * frame], -1);
		TextDrawColor(TD_Garage[6 + 10 * frame], -1);
		TextDrawColor(TD_Garage[7 + 10 * frame], -1);
		TextDrawColor(TD_Garage[8 + 10 * frame], -1);
		TextDrawColor(TD_Garage[9 + 10 * frame], 1145324799);
		TextDrawColor(TD_Garage[10 + 10 * frame], 1145324799);
		TextDrawColor(TD_Garage[11 + 10 * frame], 1145324799);
		TextDrawColor(TD_Garage[12 + 10 * frame], 1145324799);
		//PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_image 	+  5 * frame ][playerid], 0xFFFFFFFF);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_bukle 	+  5 * frame ][playerid], -1061109505);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_greitis 	+  5 * frame ][playerid], -1061109505);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_degalai 	+  5 * frame ][playerid], -1061109505);
		// PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_bagazine +  5 * frame ][playerid], -1061109505);

		TextDrawShowForPlayer(playerid, TD_Garage[4 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[5 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[6 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[7 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[8 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[9 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[10 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[11 + 10 * frame]);
		TextDrawShowForPlayer(playerid, TD_Garage[12 + 10 * frame]);

		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_pavadinimas +  5 * frame ][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_title 		 +  5 * frame ][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_page 		 +  5 * frame ][playerid]);
		//PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_image 		 +  5 * frame ][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bukle 		 +  5 * frame ][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_greitis 	 +  5 * frame ][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_degalai 	 +  5 * frame ][playerid]);
		// PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bagazine 	 +  5 * frame ][playerid]);
	}
	else {
		M:P:E(playerid, F:0("frame: %i, a: %i", frame, a));
	}
	cache_set_active(Cache:0);
}

garage_Hide(playerid) {
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) {
		TogglePlayerSpectating(playerid, false);
	}
	if(Garage[playerid][garage_r]) {
		cache_set_active(Cache:0);
		cache_delete(Garage[playerid][garage_r]);
	}

	isInGarage{playerid} = false;

	for(new i; i < 4; ++i) {
		if(GarageList[playerid][i] && GarageList[playerid][i] != INVALID_VEHICLE_ID) {
			SaveVehicle(GarageList[playerid][i], .update_pos = false, .remove = true);
			GarageList[playerid][i] = 0;
		}
	}

	for(new i; i != sizeof TD_Garage; ++i) {
		TextDrawHideForPlayer(playerid, TD_Garage[i]);
	}
	for(new i; i != sizeof PlayerTD_Garage; ++i) {
		PlayerTextDrawHide(playerid, PlayerTD_Garage[i][playerid]);
	}
	Garage[playerid][garage_Count] = BAD_INDEX;
	Garage[playerid][garage_CurrentFrame] = BAD_INDEX;
	Garage[playerid][garage_CurrentID] = BAD_INDEX;
}

garage_Show(playerid) {
	isInGarage{playerid} = true;

	// iðsaugom posizicijà, kad turëtumëm kur gráþt
	playerData_SaveChar(playerid, .update_pos = true);

	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		TogglePlayerSpectating(playerid, true);

		new Float:X, Float:Y, Float:Z;
		GetPlayerCameraPos(playerid, X, Y, Z); // because old data
		SetPlayerCameraPos(playerid, X, Y, Z); // after spectate is enabled

		SetPlayerCameraLookAt(playerid, Position_Garage);
	}
	else {
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(playerid), SPECTATE_MODE_FIXED);

		new Float:X, Float:Y, Float:Z;
		GetPlayerCameraPos(playerid, X, Y, Z);
		SetPlayerCameraPos(playerid, X, Y, Z);
	}
	format_query("SELECT * FROM vehicles WHERE owner = %i AND owner_type = %i", char_ID[playerid], VEHICLE_OWNER_TYPE_PLAYER);
	mysql_query(database, query);
	new Cache:r = Garage[playerid][garage_r] = cache_save();
	cache_set_active(r);

	Garage[playerid][garage_Count] = 0;
	Garage[playerid][garage_CurrentID] = 0;
	Garage[playerid][garage_CurrentFrame] = 0;

	new row_count, row;

	if( ! (row_count = cache_get_row_count()) ) {
		TextDrawShowForPlayer(playerid, TD_Garage[0]); // bg
		TextDrawShowForPlayer(playerid, TD_Garage[1]); // mini bg
		TextDrawShowForPlayer(playerid, TD_Garage[3]); // iseiti

		PlayerTextDrawShow(playerid, PlayerTD_Garage[status_title][playerid]);
		PlayerTextDrawShow(playerid, PlayerTD_Garage[status_page][playerid]);

		PlayerTextDrawSetString(playerid, PlayerTD_Garage[status_title][playerid], "Neturi jokios transporto priemones");
		cache_delete(r);
		Garage[playerid][garage_r] = Cache:0;
	}
	else {
		TextDrawShowForPlayer(playerid, TD_Garage[0]); // bg
		TextDrawShowForPlayer(playerid, TD_Garage[1]); // mini bg
		TextDrawShowForPlayer(playerid, TD_Garage[2]); // rinktis
		TextDrawShowForPlayer(playerid, TD_Garage[3]); // iseiti
		TextDrawShowForPlayer(playerid, TD_Garage[status_line]); // iseiti

		new j;
		do {
			// Ar maðina yra garaþe?
			if(cache_get_field_content_int(row, "status") == VEHICLE_STATUS_GARAGE)
			{
				Garage[playerid][garage_Count]++;

				if(j < 4) {
					new vehicleid = GarageList[playerid][j] = LoadVehicle(.row = row, .applydata = false);

					new model = vehicle_Model[vehicleid];

					SetVehicleVirtualWorld(vehicleid, VW_GARAGE_TMP_VEHICLE);

					if(j) {
						TextDrawColor(TD_Garage[4 + 10 * j], 0x444444FF);

						TextDrawColor(TD_Garage[5 + 10 * j], 0xFFFFFF44);
						TextDrawColor(TD_Garage[6 + 10 * j], 0xFFFFFF44);
						TextDrawColor(TD_Garage[7 + 10 * j], 0xFFFFFF44);
						TextDrawColor(TD_Garage[8 + 10 * j], 0xFFFFFF44);

						TextDrawColor(TD_Garage[9 + 10 * j], 0x333333FF);
						TextDrawColor(TD_Garage[10 + 10 * j], 0x333333FF);
						TextDrawColor(TD_Garage[11 + 10 * j], 0x333333FF);
						TextDrawColor(TD_Garage[12 + 10 * j], 0x333333FF);
						//PlayerTextDrawColor(playerid, PlayerTD_Garage[ status_image + 5 * j ][playerid], 0x555555FF);
						PlayerTextDrawColor(playerid, PlayerTD_Garage[status_bukle + 5 * j][playerid], 0x555555FF);
						PlayerTextDrawColor(playerid, PlayerTD_Garage[status_greitis + 5 * j][playerid], 0x555555FF);
						PlayerTextDrawColor(playerid, PlayerTD_Garage[status_degalai + 5 * j][playerid], 0x555555FF);
						//PlayerTextDrawColor(playerid, PlayerTD_Garage[status_bagazine +  5 * j ][playerid], 0x555555FF);
					}
					else {
						PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_pavadinimas ][playerid], vehicle_Name[model - 400]);
						PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_title	     ][playerid], "Pasirink savo masina");					
					}

					TextDrawShowForPlayer(playerid, TD_Garage[4 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[5 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[6 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[7 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[8 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[9 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[10 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[11 + 10 * j]);
					TextDrawShowForPlayer(playerid, TD_Garage[12 + 10 * j]);
					//TextDrawShowForPlayer(playerid, TD_Garage[13 + 10 * j]);
		
					PlayerTextDrawSetPreviewVehCol 	(playerid, PlayerTD_Garage[ status_image	  +  5 * j ][playerid], vehicle_Color1[vehicleid], vehicle_Color2[vehicleid]);
					PlayerTextDrawSetPreviewModel	(playerid, PlayerTD_Garage[ status_image	  +  5 * j ][playerid], model);
					PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_bukle	  +  5 * j ][playerid], vehicle_Health[vehicleid] / 1000 * 80, 4);
					PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_greitis  +  5 * j ][playerid], float(vehicle_Speed[model-400]) / 250.0 * 80.0, 4);
					PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_degalai	  +  5 * j ][playerid], vehicle_Fuel[vehicleid] / float(vehicle_MaxFuel[model - 400]) * 80.0, 4);
					// PlayerTextDrawTextSize			(playerid, PlayerTD_Garage[ status_bagazine +  5 * j ][playerid], Storage.TotalWeight(storage.Vehicle + vehicleid) / float(vehicle_TrunkSize[model-400]) * 80.0, 4);

					PlayerTextDrawShow(playerid, PlayerTD_Garage[status_pavadinimas + 5 * j ][playerid]);
					PlayerTextDrawShow(playerid, PlayerTD_Garage[status_title + 5 * j ][playerid]);
					PlayerTextDrawShow(playerid, PlayerTD_Garage[status_page + 5 * j ][playerid]);
					PlayerTextDrawShow(playerid, PlayerTD_Garage[status_image + 5 * j ][playerid]);
					PlayerTextDrawShow(playerid, PlayerTD_Garage[status_bukle + 5 * j ][playerid]);
					PlayerTextDrawShow(playerid, PlayerTD_Garage[status_greitis + 5 * j ][playerid]);
					PlayerTextDrawShow(playerid, PlayerTD_Garage[status_degalai + 5 * j ][playerid]);
					// PlayerTextDrawShow(playerid, PlayerTD_Garage[ status_bagazine 	+ 5 * j ][playerid]);
				}
				++j;
			}
		}
		while(++row < row_count);
		if(Garage[playerid][garage_Count]) {
			PlayerTextDrawSetString	(playerid, PlayerTD_Garage[ status_page ][playerid], F:0("1 i %i", Garage[playerid][garage_Count]));
		}
	}
}



hook OnPlayerConnect(playerid) {
	PlayerTD_Garage[0][playerid] = CreatePlayerTextDraw(playerid, 38.117607, 222.483489, "Infernus");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[0][playerid], 0.446235, 2.066666);
	PlayerTextDrawAlignment(playerid, PlayerTD_Garage[0][playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Garage[0][playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[0][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Garage[0][playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Garage[0][playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Garage[0][playerid], 1);

	PlayerTD_Garage[1][playerid] = CreatePlayerTextDraw(playerid, 38.176433, 213.333450, "Pasirink savo masina");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[1][playerid], 0.251411, 1.337498);
	PlayerTextDrawAlignment(playerid, PlayerTD_Garage[1][playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Garage[1][playerid], -149);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[1][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Garage[1][playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Garage[1][playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Garage[1][playerid], 1);

	PlayerTD_Garage[2][playerid] = CreatePlayerTextDraw(playerid, 37.646938, 379.750335, "1 i 4");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[2][playerid], 0.284352, 1.553333);
	PlayerTextDrawAlignment(playerid, PlayerTD_Garage[2][playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Garage[2][playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[2][playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[2][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Garage[2][playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Garage[2][playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Garage[2][playerid], 1);

	new const Float:start = 35.764701;
	new const Float:diff = 143.117592;

	new j = 3;

	for(new i; i != 4; ++i)
	{
		PlayerTD_Garage[j][playerid] = CreatePlayerTextDraw(playerid, start+diff*i-6, 202, "Masinos_picture"); // maðinos paveiksliukas
		PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[j][playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, PlayerTD_Garage[j][playerid], 126, 126);
		PlayerTextDrawAlignment(playerid, PlayerTD_Garage[j][playerid], 1);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[j][playerid], -1);
		PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawBackgroundColor(playerid, PlayerTD_Garage[j][playerid], 0x00000000);
		PlayerTextDrawFont(playerid, PlayerTD_Garage[j][playerid], TEXT_DRAW_FONT_MODEL_PREVIEW);
		PlayerTextDrawSetPreviewModel(playerid, PlayerTD_Garage[j][playerid], 411);
		PlayerTextDrawSetPreviewRot(playerid, PlayerTD_Garage[j][playerid], -6, 5, 25, 1.0);

		++j;

		PlayerTD_Garage[j][playerid] = CreatePlayerTextDraw(playerid, 82+diff*i, 311, "LD_SPAC:white"); // status_bukle
		PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[j][playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, PlayerTD_Garage[j][playerid], 80.000000, 4.000000);
		PlayerTextDrawAlignment(playerid, PlayerTD_Garage[j][playerid], 1);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[j][playerid], -1061109505);
		PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawFont(playerid, PlayerTD_Garage[j][playerid], 4);

		++j;

		PlayerTD_Garage[j][playerid] = CreatePlayerTextDraw(playerid, 82+diff*i, 311+14, "LD_SPAC:white"); // status_greitis
		PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[j][playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, PlayerTD_Garage[j][playerid], 80.000000, 4.000000);
		PlayerTextDrawAlignment(playerid, PlayerTD_Garage[j][playerid], 1);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[j][playerid], -1061109505);
		PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawFont(playerid, PlayerTD_Garage[j][playerid], 4);

		++j;

		PlayerTD_Garage[j][playerid] = CreatePlayerTextDraw(playerid, 82+diff*i, 311+14*2, "LD_SPAC:white"); // status_svoris
		PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[j][playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, PlayerTD_Garage[j][playerid], 80.000000, 4.000000);
		PlayerTextDrawAlignment(playerid, PlayerTD_Garage[j][playerid], 1);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[j][playerid], -1061109505);
		PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawFont(playerid, PlayerTD_Garage[j][playerid], 4);

		++j;

		PlayerTD_Garage[j][playerid] = CreatePlayerTextDraw(playerid, 82+diff*i, 311+14*3, "LD_SPAC:white"); // status_bagazine
		PlayerTextDrawLetterSize(playerid, PlayerTD_Garage[j][playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, PlayerTD_Garage[j][playerid], 80.000000, 4.000000);
		PlayerTextDrawAlignment(playerid, PlayerTD_Garage[j][playerid], 1);
		PlayerTextDrawColor(playerid, PlayerTD_Garage[j][playerid], -1061109505);
		PlayerTextDrawSetShadow(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawSetOutline(playerid, PlayerTD_Garage[j][playerid], 0);
		PlayerTextDrawFont(playerid, PlayerTD_Garage[j][playerid], 4);

		++j;
	}
}

hook OnGameModeInit() {
	// garage_area = CreateDynamicCircle(1545.2665,16.7857, 5);

	TD_Garage[0] = TextDrawCreate(646.235229, 200.000000, "usebox"); // main bg
	TextDrawLetterSize(TD_Garage[0], 0.000000, 29.261322);
	TextDrawTextSize(TD_Garage[0], -2.000000, 0.000000);
	TextDrawAlignment(TD_Garage[0], 1);
	TextDrawColor(TD_Garage[0], 0);
	TextDrawUseBox(TD_Garage[0], true);
	TextDrawBoxColor(TD_Garage[0], 102);
	TextDrawSetShadow(TD_Garage[0], 0);
	TextDrawSetOutline(TD_Garage[0], 0);
	TextDrawFont(TD_Garage[0], 0);

	TD_Garage[1] = TextDrawCreate(641.058837, 399.916839, "usebox"); // apatinis bg
	TextDrawLetterSize(TD_Garage[1], 0.000000, 6.164817);
	TextDrawTextSize(TD_Garage[1], -2.470587, 0.000000);
	TextDrawAlignment(TD_Garage[1], 1);
	TextDrawColor(TD_Garage[1], 0);
	TextDrawUseBox(TD_Garage[1], true);
	TextDrawBoxColor(TD_Garage[1], 111);
	TextDrawSetShadow(TD_Garage[1], 0);
	TextDrawSetOutline(TD_Garage[1], 0);
	TextDrawFont(TD_Garage[1], 0);

	TD_Garage[2] = TextDrawCreate(53.647033, 401.916778, "~y~enter~n~~w~rinktis"); // savaime aiðku
	TextDrawLetterSize(TD_Garage[2], 0.254705, 1.524165);
	TextDrawAlignment(TD_Garage[2], 2);
	TextDrawColor(TD_Garage[2], -1);
	TextDrawSetShadow(TD_Garage[2], 0);
	TextDrawSetOutline(TD_Garage[2], 1);
	TextDrawBackgroundColor(TD_Garage[2], 51);
	TextDrawFont(TD_Garage[2], 2);
	TextDrawSetProportional(TD_Garage[2], 1);

	TD_Garage[3] = TextDrawCreate(124.764717, 401.750061, "~y~shift~n~~w~iseiti");
	TextDrawLetterSize(TD_Garage[3], 0.254705, 1.524165);
	TextDrawAlignment(TD_Garage[3], 2);
	TextDrawColor(TD_Garage[3], -1);
	TextDrawSetShadow(TD_Garage[3], 0);
	TextDrawSetOutline(TD_Garage[3], 1);
	TextDrawBackgroundColor(TD_Garage[3], 51);
	TextDrawFont(TD_Garage[3], 2);
	TextDrawSetProportional(TD_Garage[3], 1);


	new const Float:diff = 143.117592;

	new j = 4;
	for(new i; i != 4; ++i)
	{
		TD_Garage[j] = TextDrawCreate(34.764701+diff*i, 248-41, "soc:gbg");
		TextDrawLetterSize(TD_Garage[j], 0.000000, 0.000000);
		TextDrawTextSize(TD_Garage[j], 128, 128); // 126, 46
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], 0xFFFFFFFF); // -1061109505
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 0);
		TextDrawFont(TD_Garage[j], 4);

		++j;

		TD_Garage[j] = TextDrawCreate(35+diff*i, 306, "Bukle"); // 5
		TextDrawLetterSize(TD_Garage[j], 0.201998, 1.319998);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], -1);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 1);
		TextDrawBackgroundColor(TD_Garage[j], 51);
		TextDrawFont(TD_Garage[j], 2);
		TextDrawSetProportional(TD_Garage[j], 1);

		++j;

		TD_Garage[j] = TextDrawCreate(35+diff*i, 320, "Greitis"); // 6
		TextDrawLetterSize(TD_Garage[j], 0.201998, 1.319998);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], -1);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 1);
		TextDrawBackgroundColor(TD_Garage[j], 51);
		TextDrawFont(TD_Garage[j], 2);
		TextDrawSetProportional(TD_Garage[j], 1);

		++j;

		TD_Garage[j] = TextDrawCreate(35+diff*i, 320+14, "Degalai"); // 7
		TextDrawLetterSize(TD_Garage[j], 0.201998, 1.319998);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], -1);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 1);
		TextDrawBackgroundColor(TD_Garage[j], 51);
		TextDrawFont(TD_Garage[j], 2);
		TextDrawSetProportional(TD_Garage[j], 1);

		++j;

		TD_Garage[j] = TextDrawCreate(35+diff*i, 320+14*2, "Bagazine"); // 8
		TextDrawLetterSize(TD_Garage[j], 0.201998, 1.319998);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], -1);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 1);
		TextDrawBackgroundColor(TD_Garage[j], 51);
		TextDrawFont(TD_Garage[j], 2);
		TextDrawSetProportional(TD_Garage[j], 1);

		++j;

		TD_Garage[j] = TextDrawCreate(82+diff*i, 311, "LD_SPAC:white"); // 9
		TextDrawLetterSize(TD_Garage[j], 0.000000, 0.000000);
		TextDrawTextSize(TD_Garage[j], 80.000000, 4.000000);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], 1145324799);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 0);
		TextDrawFont(TD_Garage[j], 4);

		++j;

		TD_Garage[j] = TextDrawCreate(82+diff*i, 311+14, "LD_SPAC:white"); // 10
		TextDrawLetterSize(TD_Garage[j], 0.000000, 0.000000);
		TextDrawTextSize(TD_Garage[j], 80.000000, 4.000000);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], 1145324799);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 0);
		TextDrawFont(TD_Garage[j], 4);

		++j;

		TD_Garage[j] = TextDrawCreate(82+diff*i, 311+14*2, "LD_SPAC:white"); // 11
		TextDrawLetterSize(TD_Garage[j], 0.000000, 0.000000);
		TextDrawTextSize(TD_Garage[j], 80.000000, 4.000000);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], 1145324799);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 0);
		TextDrawFont(TD_Garage[j], 4);

		++j;

		TD_Garage[j] = TextDrawCreate(82+diff*i, 311+14*3, "LD_SPAC:white"); // 12
		TextDrawLetterSize(TD_Garage[j], 0.000000, 0.000000);
		TextDrawTextSize(TD_Garage[j], 80.000000, 4.000000);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], 1145324799);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 0);
		TextDrawFont(TD_Garage[j], 4);

		++j;

		TD_Garage[j] = TextDrawCreate(37+diff*i, 371.000000, "LD_SPAC:white"); // 13
		TextDrawLetterSize(TD_Garage[j], 0.000000, 0.000000);
		TextDrawTextSize(TD_Garage[j], 129.000000, 1.000000);
		TextDrawAlignment(TD_Garage[j], 1);
		TextDrawColor(TD_Garage[j], -1);
		TextDrawSetShadow(TD_Garage[j], 0);
		TextDrawSetOutline(TD_Garage[j], 0);
		TextDrawFont(TD_Garage[j], 4);

		++j;
	}
}