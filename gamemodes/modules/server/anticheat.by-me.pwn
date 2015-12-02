#include <YSI_Coding\y_hooks>

static Float:max_dist[MAX_PLAYERS];
static onFoot_Warnings[MAX_PLAYERS char];

hook OnPlayerConnect(playerid) {
	onFoot_Warnings{playerid} = 0;
}

static showDebug[MAX_PLAYERS char];

CMD:debug(playerid, p[]) {
	M:P:G(playerid, "Debug rodymas: %i", showDebug{playerid} ^= 1);
	return true;
}

CMD:to(playerid, p[]) {
	if(IsPlayerAdmin(playerid)) {
		extract p -> new player:target;
		if(target == INVALID_PLAYER_ID) {
			return M:P:E(playerid, "Tokio þaidëjo nëra");
		}
		new Float:pos[3];
		GetPlayerPos(target, XYZ0(pos));
		player_Teleport(playerid, XYZ0(pos));
	}
	return true;
}

CMD:get(playerid, p[]) {
	if(IsPlayerAdmin(playerid)) {
		extract p -> new player:target;
		if(target == INVALID_PLAYER_ID) {
			return M:P:E(playerid, "Tokio þaidëjo nëra");
		}
		new Float:pos[3];
		GetPlayerPos(playerid, XYZ0(pos));
		player_Teleport(target, XYZ0(pos));
	}
	return true;
}

CMD:resetdist(playerid, p[]) {
	max_dist[playerid] = 0.0;
	return true;
}

hook OnPlayerUpdate(playerid) {
	new Float:unused, Float:z;
	GetPlayerVelocity(playerid, unused, unused, z);

	if(z < 5.0 && z > 5.0) {
		static msg[100];
		format(msg, 100, "AntiCheat: Kick(%s)", player_Name[playerid]);
		SendClientMessageToAll(0xFF0000, msg);
	}
	if(showDebug{playerid}) {
		M:P:X(playerid, "vZ: %f", z);
	}

	return true;
}

ptask updatePlayerLocation[100](playerid) {
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT 
		&& ! player_Teleporting{playerid}
		&& ! isInClassSelection{playerid}
		&& ! dontCheckPos{playerid}
		&& ! IsPlayerAdmin(playerid)) 
	{
		if(lastPlayerPosition[playerid][0]) {
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			new Float:lpp[3]; lpp = lastPlayerPosition[playerid];

			new Float:dist = (x - lpp[0]) * (x - lpp[0]) + (y - lpp[1]) * (y - lpp[1]);
			
			if(dist > 6.0) {
				SetPlayerPos(playerid, XYZ0(lastPlayerPosition[playerid]));
				if(++onFoot_Warnings{playerid} == 5) {
					static msg[100];
					format(msg, 100, "AntiCheat: Kick(%s)", player_Name[playerid]);
					SendClientMessageToAll(0xFF0000, msg);
					onFoot_Warnings{playerid} = 0;
				}
				M:P:X(playerid, "AntiCheat warning: %i/5", onFoot_Warnings{playerid});
				return true;
			}
		}
	}
	GetPlayerPos(playerid, XYZ0(lastPlayerPosition[playerid]));
	return true;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if(newstate == oldstate && oldstate == PLAYER_STATE_DRIVER) {
		Kick(playerid);
		return;
	}
	static state_changed_at[MAX_PLAYERS];

	if(newstate == PLAYER_STATE_DRIVER) {
		if(state_changed_at[playerid] + 1 >= gettime()) {
			Kick(playerid);
		}
		state_changed_at[playerid] = gettime();
	}
}