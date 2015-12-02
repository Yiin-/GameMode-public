#include <YSI_Coding\y_hooks>

new Text:TD_CurrentHealth[2];
new PlayerText:PlayerTD_CurrentHealth[MAX_PLAYERS][3];

UI_UpdatePlayerHealth(playerid) {
	new Float:hp = player_Health[playerid];
	new Float:maxhp = player_MaxHealth[playerid];

	PlayerTextDrawTextSize(playerid, PlayerTD_CurrentHealth[playerid][0], hp / maxhp * 76.0, 8.0);
	PlayerTextDrawSetString(playerid, PlayerTD_CurrentHealth[playerid][1], F:0("%.0f%%", hp / maxhp * 100.0));
	PlayerTextDrawSetString(playerid, PlayerTD_CurrentHealth[playerid][2], F:0("%.0f", hp));

	for(new i; i < sizeof TD_CurrentHealth; ++i) {
		TextDrawShowForPlayer(playerid, TD_CurrentHealth[i]);
	}
	for(new i; i < sizeof PlayerTD_CurrentHealth[]; ++i) {
		PlayerTextDrawShow(playerid, PlayerTD_CurrentHealth[playerid][i]);
	}
}

hook OnGameModeInit() {
// 5a0c0e - background hp
	TD_CurrentHealth[0] = TextDrawCreate(546.0, 63.0, "LD_SPAC:white");
	TextDrawLetterSize(TD_CurrentHealth[0], 0.000000, 0.000000);
	TextDrawTextSize(TD_CurrentHealth[0], 80.0, 12.0);
	TextDrawAlignment(TD_CurrentHealth[0], 1);
	TextDrawColor(TD_CurrentHealth[0], 255);
	TextDrawSetShadow(TD_CurrentHealth[0], 0);
	TextDrawSetOutline(TD_CurrentHealth[0], 0);
	TextDrawBackgroundColor(TD_CurrentHealth[0], 255);
	TextDrawFont(TD_CurrentHealth[0], 4);
	TextDrawSetProportional(TD_CurrentHealth[0], 0);
	TextDrawSetShadow(TD_CurrentHealth[0], 0);

	TD_CurrentHealth[1] = TextDrawCreate(548.0, 65.0, "LD_SPAC:white");
	TextDrawLetterSize(TD_CurrentHealth[1], 0.000000, 0.000000);
	TextDrawTextSize(TD_CurrentHealth[1], 76.0, 8.0);
	TextDrawAlignment(TD_CurrentHealth[1], 1);
	TextDrawColor(TD_CurrentHealth[1], 0x5A0C0EFF);
	TextDrawSetShadow(TD_CurrentHealth[1], 0);
	TextDrawSetOutline(TD_CurrentHealth[1], 0);
	TextDrawBackgroundColor(TD_CurrentHealth[1], 255);
	TextDrawFont(TD_CurrentHealth[1], 4);
	TextDrawSetProportional(TD_CurrentHealth[1], 0);
	TextDrawSetShadow(TD_CurrentHealth[1], 0);
	return true;
}

hook OnPlayerConnect(playerid) {
// b4191d - current hp
	PlayerTD_CurrentHealth[playerid][0] = CreatePlayerTextDraw(playerid, 548.0, 65.0, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, PlayerTD_CurrentHealth[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTD_CurrentHealth[playerid][0], 76.0, 8.0);
	PlayerTextDrawAlignment(playerid, PlayerTD_CurrentHealth[playerid][0], 1);
	PlayerTextDrawColor(playerid, PlayerTD_CurrentHealth[playerid][0], 0xB4191DFF);
	PlayerTextDrawSetShadow(playerid, PlayerTD_CurrentHealth[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_CurrentHealth[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_CurrentHealth[playerid][0], 255);
	PlayerTextDrawFont(playerid, PlayerTD_CurrentHealth[playerid][0], 4);
	PlayerTextDrawSetProportional(playerid, PlayerTD_CurrentHealth[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, PlayerTD_CurrentHealth[playerid][0], 0);

	PlayerTD_CurrentHealth[playerid][1] = CreatePlayerTextDraw(playerid, 551.903503, 65.0, "83%");
	PlayerTextDrawLetterSize(playerid, PlayerTD_CurrentHealth[playerid][1], 0.206499, 0.859163);
	PlayerTextDrawAlignment(playerid, PlayerTD_CurrentHealth[playerid][1], 1);
	PlayerTextDrawColor(playerid, PlayerTD_CurrentHealth[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_CurrentHealth[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_CurrentHealth[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_CurrentHealth[playerid][1], 255);
	PlayerTextDrawFont(playerid, PlayerTD_CurrentHealth[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_CurrentHealth[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_CurrentHealth[playerid][1], 0);

	PlayerTD_CurrentHealth[playerid][2] = CreatePlayerTextDraw(playerid, 584.292175, 56.393306, "236");
	PlayerTextDrawLetterSize(playerid, PlayerTD_CurrentHealth[playerid][2], 0.221493, 1.255831);
	PlayerTextDrawAlignment(playerid, PlayerTD_CurrentHealth[playerid][2], 2);
	PlayerTextDrawColor(playerid, PlayerTD_CurrentHealth[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_CurrentHealth[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_CurrentHealth[playerid][2], -1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_CurrentHealth[playerid][2], 52);
	PlayerTextDrawFont(playerid, PlayerTD_CurrentHealth[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_CurrentHealth[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_CurrentHealth[playerid][2], 0);
	return true;
}