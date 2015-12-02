#include <YSI_Coding\y_hooks>

new CASH_COLOR[2] = {
	785150463, // +
	-414434049 // -
};

static PlayerText:PlayerTD_CashUpdate[MAX_PLAYERS];
static bool:showing[MAX_PLAYERS];
static Timer:timerid[MAX_PLAYERS];
static init[MAX_PLAYERS];

timer HideCashUpdate[3000](playerid) {
	PlayerTextDrawHide(playerid, PlayerTD_CashUpdate[playerid]);
	showing[playerid] = false;
}

hook OnPlayerConnect(playerid) {
	PlayerTD_CashUpdate[playerid] = CreatePlayerTextDraw(playerid, 550.000000, 144.000000, "+70000");
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_CashUpdate[playerid], 255);
	PlayerTextDrawFont(playerid, PlayerTD_CashUpdate[playerid], 3);
	PlayerTextDrawLetterSize(playerid, PlayerTD_CashUpdate[playerid], 0.47, 1.7);
	PlayerTextDrawSetOutline(playerid, PlayerTD_CashUpdate[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_CashUpdate[playerid], 1);

	init[playerid] = true;
}

hook OnCharacterDespawn(playerid) {
	HideCashUpdate(playerid);
	init[playerid] = true;
}

hook OnPlayerSpawn(playerid) {
	if(init[playerid]) {
		call OnPlayerCashUpdate(playerid, GetPlayerCash(playerid));
		init[playerid] = false;
	}
}

hook OnPlayerCashUpdate(playerid, difference) {
	new type = difference < 0;
	new text[13];

	if(type) {
		format(text, _, "%i", difference);
	}
	else {
		format(text, _, "+%i", difference);
	}
	PlayerTextDrawColor(playerid, PlayerTD_CashUpdate[playerid], CASH_COLOR[type]);
	PlayerTextDrawSetString(playerid, PlayerTD_CashUpdate[playerid], text);
	PlayerTextDrawShow(playerid, PlayerTD_CashUpdate[playerid]);

	if(showing[playerid]) {
		stop timerid[playerid];
	}
	showing[playerid] = true;
	timerid[playerid] = defer HideCashUpdate(playerid);
}