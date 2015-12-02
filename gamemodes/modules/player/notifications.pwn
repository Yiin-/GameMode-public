#include <YSI_Coding\y_hooks>

new PlayerText:PlayerTD_InfoText[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
	PlayerTD_InfoText[playerid] = CreatePlayerTextDraw(playerid, 143.999877, 288.166717, " ");
	PlayerTextDrawLetterSize(playerid, PlayerTD_InfoText[playerid], 0.322940, 1.617500);
	PlayerTextDrawTextSize(playerid, PlayerTD_InfoText[playerid], 500.234802, 4.666665);
	PlayerTextDrawAlignment(playerid, PlayerTD_InfoText[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_InfoText[playerid], -1);
	PlayerTextDrawUseBox(playerid, PlayerTD_InfoText[playerid], true);
	PlayerTextDrawBoxColor(playerid, PlayerTD_InfoText[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PlayerTD_InfoText[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_InfoText[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_InfoText[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_InfoText[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_InfoText[playerid], 1);
}

hook OnCharacterDespawn(playerid) {
	player_HideInfoText(playerid);
}

player_ShowInfoText(playerid, text[], va_args<>) {
	static buffer[200];

	va_formatex(buffer, _, text, va_start<2>);

	PlayerTextDrawSetString(playerid, PlayerTD_InfoText[playerid], buffer);
	PlayerTextDrawShow(playerid, PlayerTD_InfoText[playerid]);
}

player_HideInfoText(playerid) {
	PlayerTextDrawHide(playerid, PlayerTD_InfoText[playerid]);
}