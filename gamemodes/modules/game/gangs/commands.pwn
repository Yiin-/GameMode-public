CMD:gauja(playerid, params[]) {
	new gang = FindGang(GetPlayerGang(playerid));
	if(gang == NONE) {
		gangMenu_CreateGang(playerid);
		return true;
	}
	if(IsGangLeader(playerid, gang)) {
		gangMenu_ShowLeaderMenu(playerid, gang);
		return true;
	}
	else {
		gangMenu_ShowMemberMenu(playerid, gang);
	}
	return true;
}