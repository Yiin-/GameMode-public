#include <YSI_Coding\y_hooks>

static Float:taxi_TraveledDistance[MAX_PLAYERS];
static isInTaxi[MAX_PLAYERS char];

static PlayerText:PlayerTD_TaxiDriver[MAX_PLAYERS];
static PlayerText:PlayerTD_Taxi[MAX_PLAYERS][2];

forward Float:taxi_GetFullDistance(playerid);

hook OnGameModeInit() {
	#if defined ADD_VEHICLES
	AddVehicle(438, VEHICLE_OWNER_TYPE_JOB, 2273.2,-47.0,26.1549,359.3274, .owner = JOB_TAXI);
	AddVehicle(438, VEHICLE_OWNER_TYPE_JOB, 2268.9,-47.0,26.1568,359.1658, .owner = JOB_TAXI);
	AddVehicle(438, VEHICLE_OWNER_TYPE_JOB, 2264.6,-47.0,26.1568,359.1658, .owner = JOB_TAXI);
	AddVehicle(438, VEHICLE_OWNER_TYPE_JOB, 2260.3,-47.0,26.1568,359.1658, .owner = JOB_TAXI);
	AddVehicle(420, VEHICLE_OWNER_TYPE_JOB, 2256.0,-47.0,26.1568,359.1658, .owner = JOB_TAXI);
	AddVehicle(420, VEHICLE_OWNER_TYPE_JOB, 2273.5,-54.1409,26.1592,180.0183, .owner = JOB_TAXI);
	AddVehicle(420, VEHICLE_OWNER_TYPE_JOB, 2269.2,-54.1409,26.1592,180.0183, .owner = JOB_TAXI);
	AddVehicle(420, VEHICLE_OWNER_TYPE_JOB, 2264.9,-54.1409,26.1592,180.0183, .owner = JOB_TAXI);
	AddVehicle(420, VEHICLE_OWNER_TYPE_JOB, 2260.6,-54.1409,26.1592,180.0183, .owner = JOB_TAXI);
	AddVehicle(420, VEHICLE_OWNER_TYPE_JOB, 2256.3,-54.1409,26.1592,180.0183, .owner = JOB_TAXI);
	#endif
}

hook OnPlayerConnect(playerid) {
	PlayerTD_TaxiDriver[playerid] = CreatePlayerTextDraw(playerid, 482.108489, 158.666641, "Keleiviai~n~  ~y~~h~Yiin_Yiin ~w~(2.5 km / 25EUR)~n~  ~y~~h~Yiin_Yiin ~w~(2.5 km / 25EUR)~n~  ~y~~h~Yiin_Yiin ~w~(2.5 km / 25EUR)");
	PlayerTextDrawLetterSize(playerid, PlayerTD_TaxiDriver[playerid], 0.266808, 1.308333);
	PlayerTextDrawAlignment(playerid, PlayerTD_TaxiDriver[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_TaxiDriver[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_TaxiDriver[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_TaxiDriver[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_TaxiDriver[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_TaxiDriver[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_TaxiDriver[playerid], 1);

	PlayerTD_Taxi[playerid][0] = CreatePlayerTextDraw(playerid, 483.982727, 145.833328, "Vairuotojas: ~y~Steve_Jobs");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Taxi[playerid][0], 0.258843, 1.360833);
	PlayerTextDrawAlignment(playerid, PlayerTD_Taxi[playerid][0], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Taxi[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Taxi[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Taxi[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Taxi[playerid][0], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Taxi[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Taxi[playerid][0], 1);

	PlayerTD_Taxi[playerid][1] = CreatePlayerTextDraw(playerid, 485.387939, 169.166687, "Atstumas: ~g~~h~2.5 ~w~~h~km.~n~Suma: ~g~~h~25~w~~h~ EUR.");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Taxi[playerid][1], 0.253220, 1.337499);
	PlayerTextDrawAlignment(playerid, PlayerTD_Taxi[playerid][1], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Taxi[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Taxi[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Taxi[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Taxi[playerid][1], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Taxi[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Taxi[playerid][1], 1);
}

ptask TaxiUpdate[2000](playerid) {
	if(taxi_IsPlayerInVehicle(playerid)) {
		if(isInTaxi{playerid}) {
			taxi_UpdateClient(playerid);

		} else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {

			taxi_UpdateDriver(playerid);
		}
	
	} else {

		PlayerTextDrawHide(playerid, PlayerTD_TaxiDriver[playerid]);
		PlayerTextDrawHide(playerid, PlayerTD_Taxi[playerid][0]);
		PlayerTextDrawHide(playerid, PlayerTD_Taxi[playerid][1]);
	}
}

hook OnCharacterDespawn(playerid) {
	new const vehicleid = player_LastVehicle[playerid];

	if(IsValidVehicle(vehicleid)) {
		if(IsTaxiVehicle(vehicleid)) {
			if(IsPlayerInVehicle(playerid, vehicleid)) {
				switch(GetPlayerState(playerid)) { 
					case PLAYER_STATE_DRIVER: taxi_DriverExit(playerid);
					case PLAYER_STATE_PASSENGER: taxi_ClientExit(playerid);
				}
			}
		}
	}
	return true;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	new vehicleid;

	if(oldstate == PLAYER_STATE_PASSENGER || oldstate == PLAYER_STATE_DRIVER) {
		vehicleid = player_LastVehicle[playerid];

	} else if(newstate == PLAYER_STATE_PASSENGER || newstate == PLAYER_STATE_DRIVER) {

		vehicleid = GetPlayerVehicleID(playerid);
	}
	new driver;
	if(newstate == PLAYER_STATE_DRIVER) {
		driver = playerid;
	
	} else {

		driver = vehicle_Driver[vehicleid];
	}

	if(IsTaxiVehicle(vehicleid)) {

		// Iðlipo ið maðinos
		switch(oldstate) {
			// Keleivis
			case PLAYER_STATE_PASSENGER: {
				if(isInTaxi{playerid})
				{
					taxi_ClientExit(playerid, driver);
				}
			}
			// Vairuotojas
			case PLAYER_STATE_DRIVER: {
				taxi_DriverExit(driver);
			}
		}

		// Álipo á maðinà
		switch(newstate) {
			// keleivis
			case PLAYER_STATE_PASSENGER: {
				isInTaxi{playerid} = true;
				taxi_TraveledDistance[playerid] = vehicle_Run[vehicleid];
				taxi_UpdateClient(playerid);
			}
			// vairuotojas
			case PLAYER_STATE_DRIVER: {
				taxi_UpdateDriver(playerid);
			}
		}
	}
	return true;
}

taxi_UpdateDriver(driver) {
	new const vehicleid = GetPlayerVehicleID(driver);

	if(vehicleid == INVALID_VEHICLE_ID) return;

	static buffer[256];

	format(buffer, sizeof buffer, "Keleiviai:");
	// ~n~  ~y~~h~Yiin_Yiin ~w~(2.5 km / 25EUR)

	foreach(new i : Player) {
		if(isInTaxi{i} && IsPlayerInVehicle(i, GetPlayerVehicleID(driver))) {
			static text[100]; format(text, 100, "Vairuotojas: ~y~%s", player_Name[driver]);			
			PlayerTextDrawSetString(i, PlayerTD_Taxi[i][0], text);	

			format(text, 100, "~n~  ~y~~h~%s ~w~(%.1f km, %i EUR)", player_Name[i], taxi_GetFullDistance(i), taxi_GetCost(i));
			strcat(buffer, text);
		}
	}

	PlayerTextDrawSetString(driver, PlayerTD_TaxiDriver[driver], buffer);
	PlayerTextDrawShow(driver, PlayerTD_TaxiDriver[driver]);
}

taxi_UpdateClient(playerid) {
	new const vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid == INVALID_VEHICLE_ID) return;

	new const driver = vehicle_Driver[vehicleid];

	static text[100];

	if(driver != INVALID_PLAYER_ID) {
		format(text, 100, "Vairuotojas: ~y~%s", player_Name[driver]);
		PlayerTextDrawSetString(playerid, PlayerTD_Taxi[playerid][0], text);

	} else {

		PlayerTextDrawSetString(playerid, PlayerTD_Taxi[playerid][0], "Vairuotojo nera.");
	}

	format(text, 100, "Atstumas: ~g~~h~%.1f ~w~~h~km.~n~Suma: ~g~~h~%i~w~~h~ EUR.", taxi_GetFullDistance(playerid), taxi_GetCost(playerid));
	PlayerTextDrawSetString(playerid, PlayerTD_Taxi[playerid][1], text);
	
	PlayerTextDrawShow(playerid, PlayerTD_Taxi[playerid][0]);
	PlayerTextDrawShow(playerid, PlayerTD_Taxi[playerid][1]);
}

taxi_DriverExit(driver) {
	foreach(new i : Player) {
		if(isInTaxi{i} && IsPlayerInVehicle(i, player_LastVehicle[driver])) {
			PlayerTextDrawSetString(i, PlayerTD_Taxi[i][0], "Vairuotojo nera.");
			PlayerTextDrawShow(i, PlayerTD_Taxi[i][0]);
			taxi_ClientExit(i, driver, .driver_exit = true);
		}
	}
	PlayerTextDrawHide(driver, PlayerTD_TaxiDriver[driver]);
}

taxi_ClientExit(playerid, driver = INVALID_PLAYER_ID, bool:driver_exit = false) {
	new suma = taxi_GetCost(playerid); if(suma < 0) suma *= -1;

	new const vehicleid = GetPlayerVehicleID(playerid);

	if(vehicleid == INVALID_VEHICLE_ID) return;

	if(driver == INVALID_PLAYER_ID) {
		driver = vehicle_Driver[vehicleid];

		if(driver == INVALID_PLAYER_ID) {
			PlayerTextDrawHide(playerid, PlayerTD_Taxi[playerid][0]);
			PlayerTextDrawHide(playerid, PlayerTD_Taxi[playerid][1]);
			isInTaxi{playerid} = false;
			taxi_TraveledDistance[playerid] = vehicle_Run[vehicleid];

			return;
		}
	}

	if( ! driver_exit) {
		PlayerTextDrawHide(playerid, PlayerTD_Taxi[playerid][0]);
		PlayerTextDrawHide(playerid, PlayerTD_Taxi[playerid][1]);
		isInTaxi{playerid} = false;
	}

	taxi_TraveledDistance[playerid] = vehicle_Run[vehicleid];

	if(GetPlayerCash(playerid) < suma) {
		AdjustPlayerCash(driver, GetPlayerCash(playerid));
		M:P:I(driver, "[name]%s[] uþ kelionæ sumokëti nebeuþtenka pinigø, todël sumokëjo likusiais [number]%i[] EUR", player_Name[playerid], GetPlayerCash(playerid));
		M:P:E(playerid, "Suma uþ TAXI paslaugas: [number]%i[] EUR, taèiau apmokëti gali tik [number]%i[] EUR.", suma, GetPlayerCash(playerid));
		AdjustPlayerCash(playerid, -suma);

	} else {

		AdjustPlayerCash(driver, suma);
		M:P:I(driver, "[name]%s[][] uþ kelionæ sumokëjo [number]%i[] EUR", player_Name[playerid], suma);
		M:P:G(playerid, "Suma uþ TAXI paslaugas: [number]%i[] EUR", suma);
		AdjustPlayerCash(playerid, -suma);
	}
}

taxi_GetCost(playerid) {
	return floatround(taxi_GetFullDistance(playerid) * 10.0, floatround_round);
}

Float:taxi_GetFullDistance(playerid) {
	if(isInTaxi{playerid}) {
		new id = GetPlayerVehicleID(playerid);

		if(id != INVALID_VEHICLE_ID) {
			return vehicle_Run[id] - taxi_TraveledDistance[playerid];
		}
	}
	return 0.0;
}

IsTaxiVehicle(vehicleid) {
	return vehicle_OwnerType[vehicleid] == VEHICLE_OWNER_TYPE_JOB 
			&& vehicle_Owner[vehicleid] == JOB_TAXI;
}

taxi_IsPlayerInVehicle(playerid) {
	new const vehicleid = player_LastVehicle[playerid];

	if(IsValidVehicle(vehicleid)) {
		if(IsTaxiVehicle(vehicleid)) {
			return true;
		}
	}
	return false;
}