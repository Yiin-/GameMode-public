#include <YSI_Coding\y_hooks>

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	static targetid;
	if(PRESSED(KEY_WALK) && (targetid = GetPlayerTargetPlayer(playerid)) != INVALID_PLAYER_ID) {
		new Float:targetPosition[3];
		GetPlayerPos(targetid, XYZ0(targetPosition));

		if( ! IsPlayerInRangeOfPoint(playerid, 10.0, XYZ0(targetPosition))) {
			M:P:E(playerid, "Þaidëjas yra per toli.");
		}
		else {
			ShowTargetPlayerMenu(playerid, targetid);
		}
	}
}

ShowTargetPlayerMenu(playerid, targetid) {
	inline response(re, li) {
		#pragma unused li
		if(re) {
			CallLocalFunction("OnPlSelectTargetMenu", "ii", playerid, targetid);
		}
	}
	if(IsPlayerNPC(targetid)) {
		GetPlayerName(targetid, player_Name[targetid], MAX_PLAYER_NAME);
	}
	dialogSetHeader("%s:", player_Name[targetid]);
	CallLocalFunction("OnPlayerOpenTargetMenu", "ii", playerid, targetid);
	dialogShow(playerid, using inline response, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Uþdaryti");
}