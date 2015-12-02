#include <YSI_Coding\y_hooks>

static ninja[MAX_PLAYERS char];

hook OnPlayerStreamIn(playerid, forplayerid) {
	if(ninja{playerid}) {
		HidePlayerForPlayer(forplayerid, playerid);
	}
	return true;
}

CMD:ninja(playerid, params[]) {
	ninja{playerid} ^= 1;
	foreach(new i : Player) {
		if(i == playerid) continue;
		if(ninja{playerid}) {
			HidePlayerForPlayer(i, playerid);
		}
		else {
			ShowPlayerForPlayer(i, playerid);
		}
	}
	return M:P:G(playerid, "%s", ninja{playerid} ? "Nematomas" : "Matomas");
}