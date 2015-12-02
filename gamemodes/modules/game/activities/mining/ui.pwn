#include <YSI\y_hooks>

new Text:TD_Mining[6];
new PlayerText:PlayerTD_Mining[MAX_PLAYERS][2];

hook OnGameModeInit() {
	TD_Mining[0] = TextDrawCreate(470.000000, 200.000000, "LD_SPAC:white");
	TextDrawLetterSize(TD_Mining[0], 0.000000, 0.000000);
	TextDrawTextSize(TD_Mining[0], 13.000000, 200.000000);
	TextDrawAlignment(TD_Mining[0], 1);
	TextDrawColor(TD_Mining[0], 255);
	TextDrawSetShadow(TD_Mining[0], 0);
	TextDrawSetOutline(TD_Mining[0], 0);
	TextDrawBackgroundColor(TD_Mining[0], 255);
	TextDrawFont(TD_Mining[0], 4);
	TextDrawSetProportional(TD_Mining[0], 0);
	TextDrawSetShadow(TD_Mining[0], 0);

	TD_Mining[1] = TextDrawCreate(471.000000, 201.000000, "LD_SPAC:white");
	TextDrawLetterSize(TD_Mining[1], 0.000000, 0.000000);
	TextDrawTextSize(TD_Mining[1], 11.000000, 198.000000);
	TextDrawAlignment(TD_Mining[1], 1);
	TextDrawColor(TD_Mining[1], -2147483393);
	TextDrawSetShadow(TD_Mining[1], 0);
	TextDrawSetOutline(TD_Mining[1], 0);
	TextDrawBackgroundColor(TD_Mining[1], 255);
	TextDrawFont(TD_Mining[1], 4);
	TextDrawSetProportional(TD_Mining[1], 0);
	TextDrawSetShadow(TD_Mining[1], 0);

	TD_Mining[2] = TextDrawCreate(488.000000, 199.000000, "0%");
	TextDrawLetterSize(TD_Mining[2], 0.286617, 1.489166);
	TextDrawAlignment(TD_Mining[2], 1);
	TextDrawColor(TD_Mining[2], -1);
	TextDrawSetShadow(TD_Mining[2], 0);
	TextDrawSetOutline(TD_Mining[2], -1);
	TextDrawBackgroundColor(TD_Mining[2], 255);
	TextDrawFont(TD_Mining[2], 2);
	TextDrawSetProportional(TD_Mining[2], 1);
	TextDrawSetShadow(TD_Mining[2], 0);

	TD_Mining[3] = TextDrawCreate(488.000000, 388.000000, "100%");
	TextDrawLetterSize(TD_Mining[3], 0.286617, 1.489166);
	TextDrawAlignment(TD_Mining[3], 1);
	TextDrawColor(TD_Mining[3], -1);
	TextDrawSetShadow(TD_Mining[3], 0);
	TextDrawSetOutline(TD_Mining[3], -1);
	TextDrawBackgroundColor(TD_Mining[3], 255);
	TextDrawFont(TD_Mining[3], 2);
	TextDrawSetProportional(TD_Mining[3], 1);
	TextDrawSetShadow(TD_Mining[3], 0);

	TD_Mining[4] = TextDrawCreate(488.000000, 248.000000, "p~n~r~n~o~n~g~n~r~n~e~n~s~n~a~n~s");
	TextDrawLetterSize(TD_Mining[4], 0.200878, 1.366667);
	TextDrawAlignment(TD_Mining[4], 2);
	TextDrawColor(TD_Mining[4], -1);
	TextDrawSetShadow(TD_Mining[4], 0);
	TextDrawSetOutline(TD_Mining[4], 1);
	TextDrawBackgroundColor(TD_Mining[4], 255);
	TextDrawFont(TD_Mining[4], 2);
	TextDrawSetProportional(TD_Mining[4], 1);
	TextDrawSetShadow(TD_Mining[4], 0);

	TD_Mining[5] = TextDrawCreate(162.000000, 410.000000, "Progresas_kyla_laikant_paspausta_peles_mygtuka.");
	TextDrawLetterSize(TD_Mining[5], 0.234143, 1.541666);
	TextDrawAlignment(TD_Mining[5], 1);
	TextDrawColor(TD_Mining[5], -1);
	TextDrawSetShadow(TD_Mining[5], 0);
	TextDrawSetOutline(TD_Mining[5], 1);
	TextDrawBackgroundColor(TD_Mining[5], 255);
	TextDrawFont(TD_Mining[5], 2);
	TextDrawSetProportional(TD_Mining[5], 1);
	TextDrawSetShadow(TD_Mining[5], 0);
}

hook OnPlayerConnect(playerid) {
	PlayerTD_Mining[playerid][0] = CreatePlayerTextDraw(playerid, 471.000000, 201.000000, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Mining[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTD_Mining[playerid][0], 11.000000, 198.000000);
	PlayerTextDrawAlignment(playerid, PlayerTD_Mining[playerid][0], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Mining[playerid][0], -1523963137);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Mining[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Mining[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Mining[playerid][0], 255);
	PlayerTextDrawFont(playerid, PlayerTD_Mining[playerid][0], 4);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Mining[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Mining[playerid][0], 0);

	PlayerTD_Mining[playerid][1] = CreatePlayerTextDraw(playerid, 320.000000, 360.000000, "Anglis");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Mining[playerid][1], 0.598652, 2.819166);
	PlayerTextDrawAlignment(playerid, PlayerTD_Mining[playerid][1], 2);
	PlayerTextDrawColor(playerid, PlayerTD_Mining[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Mining[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Mining[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Mining[playerid][1], 255);
	PlayerTextDrawFont(playerid, PlayerTD_Mining[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Mining[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Mining[playerid][1], 0);
}