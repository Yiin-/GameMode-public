new Float:lastPlayerPosition[MAX_PLAYERS][3];
new dontCheckPos[MAX_PLAYERS char];

timer checkPos[1000](playerid) {
	dontCheckPos{playerid} = false;
}

setPlayerPos(playerid, Float:x, Float:y, Float:z) {
	lastPlayerPosition[playerid][0] = x;
	lastPlayerPosition[playerid][1] = y;
	lastPlayerPosition[playerid][2] = z;
	dontCheckPos{playerid} = true;
	defer checkPos(playerid);
	return SetPlayerPos(playerid, x, y, z);
}
#if defined _ALS_SetPlayerPos
	#undef SetPlayerPos
#else
	#define _ALS_SetPlayerPos
#endif
#define SetPlayerPos setPlayerPos