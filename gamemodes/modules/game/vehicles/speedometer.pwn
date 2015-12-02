#include <YSI_Coding\y_hooks>

new Text:TD_Speed[8];
new PlayerText:PlayerTD_Speed[MAX_PLAYERS][6];

new speedometer_ShowingForPlayer[MAX_PLAYERS char];

hook OnGameModeInit() {
	TD_Speed[0] = TextDrawCreate(400.000000, 390.000000, ".");
	TextDrawLetterSize(TD_Speed[0], 17.000000, 0.500000);
	TextDrawAlignment(TD_Speed[0], 1);
	TextDrawColor(TD_Speed[0], 255);
	TextDrawSetShadow(TD_Speed[0], 0);
	TextDrawSetOutline(TD_Speed[0], 0);
	TextDrawFont(TD_Speed[0], 1);
	TextDrawSetProportional(TD_Speed[0], 1);

	TD_Speed[1] = TextDrawCreate(400.000000, 393.000000, ".");
	TextDrawLetterSize(TD_Speed[1], 17.000000, 0.500000);
	TextDrawAlignment(TD_Speed[1], 1);
	TextDrawColor(TD_Speed[1], 255);
	TextDrawSetShadow(TD_Speed[1], 0);
	TextDrawSetOutline(TD_Speed[1], 0);
	TextDrawFont(TD_Speed[1], 1);
	TextDrawSetProportional(TD_Speed[1], 1);

	TD_Speed[2] = TextDrawCreate(400.000000, 396.000000, ".");
	TextDrawLetterSize(TD_Speed[2], 17.000000, 0.500000);
	TextDrawAlignment(TD_Speed[2], 1);
	TextDrawColor(TD_Speed[2], 255);
	TextDrawSetShadow(TD_Speed[2], 0);
	TextDrawSetOutline(TD_Speed[2], 0);
	TextDrawFont(TD_Speed[2], 1);
	TextDrawSetProportional(TD_Speed[2], 1);

	TD_Speed[3] = TextDrawCreate(474.786590, 373.333282, "km/h");
	TextDrawLetterSize(TD_Speed[3], 0.234940, 1.261664);
	TextDrawAlignment(TD_Speed[3], 1);
	TextDrawColor(TD_Speed[3], -1);
	TextDrawSetShadow(TD_Speed[3], 0);
	TextDrawSetOutline(TD_Speed[3], 1);
	TextDrawBackgroundColor(TD_Speed[3], 51);
	TextDrawFont(TD_Speed[3], 1);
	TextDrawSetProportional(TD_Speed[3], 1);

	TD_Speed[4] = TextDrawCreate(501.000000, 411.000000, "LD_SPAC:white");
	TextDrawLetterSize(TD_Speed[4], 0.000000, 0.000000);
	TextDrawTextSize(TD_Speed[4], 20.000000, 4.000000);
	TextDrawAlignment(TD_Speed[4], 1);
	TextDrawColor(TD_Speed[4], -1191182081);
	TextDrawSetShadow(TD_Speed[4], 0);
	TextDrawSetOutline(TD_Speed[4], 0);
	TextDrawFont(TD_Speed[4], 4);

	TD_Speed[5] = TextDrawCreate(501.000000, 419.000000, "LD_SPAC:white");
	TextDrawLetterSize(TD_Speed[5], 0.000000, 0.000000);
	TextDrawTextSize(TD_Speed[5], 20.000000, 4.000000);
	TextDrawAlignment(TD_Speed[5], 1);
	TextDrawColor(TD_Speed[5], 14578175);
	TextDrawSetShadow(TD_Speed[5], 0);
	TextDrawSetOutline(TD_Speed[5], 0);
	TextDrawFont(TD_Speed[5], 4);

	TD_Speed[6] = TextDrawCreate(530.776184, 407.224945, "- bukle");
	TextDrawLetterSize(TD_Speed[6], 0.195880, 1.150832);
	TextDrawAlignment(TD_Speed[6], 1);
	TextDrawColor(TD_Speed[6], -1);
	TextDrawSetShadow(TD_Speed[6], 0);
	TextDrawSetOutline(TD_Speed[6], 1);
	TextDrawBackgroundColor(TD_Speed[6], 51);
	TextDrawFont(TD_Speed[6], 2);
	TextDrawSetProportional(TD_Speed[6], 1);

	TD_Speed[7] = TextDrawCreate(530.787963, 416.624603, "- degalai");
	TextDrawLetterSize(TD_Speed[7], 0.195880, 1.150832);
	TextDrawAlignment(TD_Speed[7], 1);
	TextDrawColor(TD_Speed[7], -1);
	TextDrawSetShadow(TD_Speed[7], 0);
	TextDrawSetOutline(TD_Speed[7], 1);
	TextDrawBackgroundColor(TD_Speed[7], 51);
	TextDrawFont(TD_Speed[7], 2);
	TextDrawSetProportional(TD_Speed[7], 1);
}

hook OnPlayerConnect(playerid) {
	PlayerTD_Speed[playerid][0] = CreatePlayerTextDraw(playerid, 430.929260, 393.692077, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Speed[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTD_Speed[playerid][0], 126.730003, 2.000000);
	PlayerTextDrawAlignment(playerid, PlayerTD_Speed[playerid][0], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Speed[playerid][0], -1191182081);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Speed[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Speed[playerid][0], 0);
	PlayerTextDrawFont(playerid, PlayerTD_Speed[playerid][0], 4);

	PlayerTD_Speed[playerid][1] = CreatePlayerTextDraw(playerid, 430.976318, 396.683532, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Speed[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTD_Speed[playerid][1], 127.730003, 2.000000);
	PlayerTextDrawAlignment(playerid, PlayerTD_Speed[playerid][1], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Speed[playerid][1], 14578175);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Speed[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Speed[playerid][1], 0);
	PlayerTextDrawFont(playerid, PlayerTD_Speed[playerid][1], 4);

	PlayerTD_Speed[playerid][2] = CreatePlayerTextDraw(playerid, 454.610382, 355.425354, "168");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Speed[playerid][2], 0.419331, 2.976670);
	PlayerTextDrawAlignment(playerid, PlayerTD_Speed[playerid][2], 2);
	PlayerTextDrawColor(playerid, PlayerTD_Speed[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Speed[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Speed[playerid][2], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Speed[playerid][2], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Speed[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Speed[playerid][2], 1);

	PlayerTD_Speed[playerid][3] = CreatePlayerTextDraw(playerid, 504.677520, 378.641784, "Rida: ~y~598.34~w~~h~ km");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Speed[playerid][3], 0.242467, 1.279165);
	PlayerTextDrawAlignment(playerid, PlayerTD_Speed[playerid][3], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Speed[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Speed[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Speed[playerid][3], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Speed[playerid][3], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Speed[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Speed[playerid][3], 1);

	PlayerTD_Speed[playerid][4] = CreatePlayerTextDraw(playerid, 530.432006, 350.583343, "Tampa");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Speed[playerid][4], 0.569998, 2.247498);
	PlayerTextDrawTextSize(playerid, PlayerTD_Speed[playerid][4], 25.768661, 165.083267);
	PlayerTextDrawAlignment(playerid, PlayerTD_Speed[playerid][4], 2);
	PlayerTextDrawColor(playerid, PlayerTD_Speed[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, PlayerTD_Speed[playerid][4], true);
	PlayerTextDrawBoxColor(playerid, PlayerTD_Speed[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Speed[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Speed[playerid][4], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Speed[playerid][4], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Speed[playerid][4], 0);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Speed[playerid][4], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTD_Speed[playerid][4], true);

	PlayerTD_Speed[playerid][5] = CreatePlayerTextDraw(playerid, 437.130981, 379.749816, "max: ~y~175");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Speed[playerid][5], 0.182942, 1.203333);
	PlayerTextDrawAlignment(playerid, PlayerTD_Speed[playerid][5], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Speed[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Speed[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Speed[playerid][5], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Speed[playerid][5], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Speed[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Speed[playerid][5], 1);
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if(oldstate == PLAYER_STATE_DRIVER || newstate != PLAYER_STATE_DRIVER) {
		TD_Speedometer_hide(playerid);
	}
}

hook OnPlayerDeathFinished(playerid, bool:cancelable) {
	defer plsHideQQ(playerid);
	return true;
}

timer plsHideQQ[1000](playerid) {
	TD_Speedometer_hide(playerid);
}

task tSpeedometer[100]() {
	foreach(new i : Driver) {
		static vehicleid; vehicleid = GetPlayerVehicleID(i);

		/*if(Player.Bool.get(i, player.Bool_Inventory) || Player.Bool.get(i, player.Bool_Storage))
		{
			TD_Speedometer_hide(i);
			continue;
							TODO: INVENTORY
		} else */
		if( ! speedometer_ShowingForPlayer{i}) {
			TD_Speedometer_show(i);
		}
		if(vehicleid == INVALID_VEHICLE_ID) {
			TD_Speedometer_hide(i);
			continue;
		}

		new Float:MAGIC_CONST = (3600.0 * 1000.0) / 50.0; // 3600*1000 / X), kai X yra task tSpeedometer[X+X]()

		static Float:health; GetVehicleHealth(GetPlayerVehicleID(i), health);
		static Float:speed; speed = GetPlayerSpeed(i);
		vehicle_Run[vehicleid] += speed / MAGIC_CONST; 
		if( (vehicle_Fuel[vehicleid] -= (0.8 / MAGIC_CONST) * speed) <= 0 )
		{
			vehicle_ChangeParam(vehicleid, eVehicle_Param_Engine, false);
		}
		new model = GetVehicleModel(vehicleid);
		if(model < 400) continue;
		
		new text[50];
		PlayerTextDrawTextSize(i, PlayerTD_Speed[i][0], health / 1000.0 * 127.73, 2.0);
		PlayerTextDrawTextSize(i, PlayerTD_Speed[i][1], vehicle_Fuel[vehicleid] / vehicle_MaxFuel[model - 400] * 127.73, 2.0);
		PlayerTextDrawSetString(i, PlayerTD_Speed[i][3], text);

		format(text, 100, "%.0f", speed);
		PlayerTextDrawSetString(i, PlayerTD_Speed[i][2], text);

		format(text, 100, "Rida: ~y~%.2f~w~~h~ km", vehicle_Run[vehicleid]);
		PlayerTextDrawSetString(i, PlayerTD_Speed[i][4], vehicle_Name[model - 400]);

		format(text, 100, "max: ~y~%.0f", vehicle_RealMaxSpeed(vehicleid));
		PlayerTextDrawSetString(i, PlayerTD_Speed[i][5], text);

		// new Float:brakes = Vehicle[vehicleid][vehicle_ErrorState][eVehicleErrorState_Brakes] / MAX_VEHICLE_BRAKES_DAMAGE;
		// new Float:tire[4]; for(new j; j < 4; ++j) tire[j] = Vehicle[vehicleid][vehicle_ErrorState][eVehicleErrorState_Tire][j] / MAX_VEHICLE_TIRE_DAMAGE;

		// TextDrawColor(TD_Tech[0], RGBA_to_HEX(255, floatround(255 - 255 * brakes), floatround(255 - 255 * brakes), 255));
		// TextDrawShowForPlayer(i, TD_Tech[0]);

		// // STABDÞIAI
		// PlayerTextDrawSetString(i, pTD_Tech[i][0], F:0("%.1f%%", 100.0 - 100.0 * brakes));
		// // PADANGOS
		// for(new j = 1; j < 5; ++j)
		// {
		// 	PlayerTextDrawSetString(i, pTD_Tech[i][j], F:0("%.0f%%", 100.0 - 100.0 * tire[j - 1]));
		// 	TextDrawColor(TD_Tech[j], RGBA_to_HEX(255, floatround(255 - 255 * tire[j - 1]), floatround(255 - 255 * tire[j - 1]), 255));
		// 	TextDrawShowForPlayer(i, TD_Tech[j]);
		// }

		PlayerTextDrawShow(i, PlayerTD_Speed[i][0]);
		PlayerTextDrawShow(i, PlayerTD_Speed[i][1]);
	}
}

TD_Speedometer_show(playerid) {
	speedometer_ShowingForPlayer{playerid} = true;

	for(new i; i < sizeof TD_Speed; ++i) {
		TextDrawShowForPlayer(playerid, TD_Speed[i]);
	}
	for(new i; i < sizeof PlayerTD_Speed[]; ++i) {
		PlayerTextDrawShow(playerid, PlayerTD_Speed[playerid][i]);
	}
	// for(new i; i < sizeof pTD_Tech[]; ++i) {
	// 	PlayerTextDrawShow(playerid, pTD_Tech[playerid][i]);
	// }
}

TD_Speedometer_hide(playerid) {
	speedometer_ShowingForPlayer{playerid} = false;

	for(new i; i < sizeof TD_Speed; ++i) {
		TextDrawHideForPlayer(playerid, TD_Speed[i]);
	}
	for(new i; i < sizeof PlayerTD_Speed[]; ++i) {
		PlayerTextDrawHide(playerid, PlayerTD_Speed[playerid][i]);
	}
	// for(new i; i < sizeof pTD_Tech[]; ++i) {
	// 	PlayerTextDrawHide(playerid, pTD_Tech[playerid][i]);
	// }
	// for(new i; i < sizeof TD_Tech; ++i) {
	// 	TextDrawHideForPlayer(playerid, TD_Tech[i]);
	// }
}