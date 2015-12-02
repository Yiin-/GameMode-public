#include <YSI_Coding\y_hooks>

static 
	Timer:player_FadeTimer[MAX_PLAYERS],
	player_Fade[MAX_PLAYERS],
	player_FadeType[MAX_PLAYERS],
	Text:TD_Fade
;
enum {
	fade_none,
	fade_in,
	fade_out
};

hook OnPlayerConnect(playerid) {
	player_FadeTimer[playerid] = Timer:0;
	player_Fade[playerid] = 0;
	player_FadeType[playerid] = 0;
}

hook OnCharacterDespawn(playerid) {
	if(player_FadeType[playerid] != fade_none) {
		stop player_FadeTimer[playerid];
	}
	TextDrawHideForPlayer(playerid, TD_Fade);
}

hook OnGameModeInit() {
	TD_Fade = TextDrawCreate(683.882263, -8.416665, "usebox");
	TextDrawLetterSize(TD_Fade, 0.000000, 53.039443);
	TextDrawTextSize(TD_Fade, -7.647057, 0.000000);
	TextDrawAlignment(TD_Fade, 1);
	TextDrawColor(TD_Fade, 0);
	TextDrawUseBox(TD_Fade, true);
	TextDrawBoxColor(TD_Fade, 85);
	TextDrawSetShadow(TD_Fade, 0);
	TextDrawSetOutline(TD_Fade, 0);
	TextDrawBackgroundColor(TD_Fade, 0);
	TextDrawFont(TD_Fade, 0);
}

timer fadein[7](playerid) {
	// Jeigu u�temd�m pilnai
	if((player_Fade[playerid] += 5) >= 255) {
		// nebetemdom toliau, nes prad�s keitin�tis spalvos
		stop player_FadeTimer[playerid];

		player_OnFadeIn(playerid);
	}
	// Nustatom spalv�
	TextDrawBoxColor(TD_Fade, player_Fade[playerid]);
	// Ir parodom �aid�jui
	TextDrawShowForPlayer(playerid, TD_Fade);
}

timer fadeout[12](playerid) {
	// Jeigu atitemd�m pilnai
	if((player_Fade[playerid] -= 5) <= 0) {
		// nebeatitemdom toliau, nes prad�s keitin�tis spalvos
		stop player_FadeTimer[playerid];
		player_OnFadeOut(playerid);
	}
	// Nustatom spalv�
	TextDrawBoxColor(TD_Fade, player_Fade[playerid]);
	// Ir parodom �aid�jui
	TextDrawShowForPlayer(playerid, TD_Fade);
}

// U�temdom �aid�jui ekran�
player_FadeIn(playerid) {
	// Jeigu �aid�jui ekranas n�ra temdomas arba u�temdytas
	if(player_FadeType[playerid] == fade_none) {
		// pradedam nuo nulio
		player_Fade[playerid] = 0;
	}
	else {
		// sustabom dabartin� taimer�
		stop player_FadeTimer[playerid];
	}
	// Nustatom nauj� fade'inimo tip�
	player_FadeType[playerid] = fade_in;

	// paleid�iam taimer�
	player_FadeTimer[playerid] = repeat fadein(playerid);
}

player_FadeOut(playerid) {
	// Jeigu �aid�jui ekranas n�ra temdomas arba u�temdytas
	if(player_FadeType[playerid] == fade_none) {
		// pradedam nuo max
		player_Fade[playerid] = 255;
	}
	else {
		// sustabom dabartin� taimer�
		stop player_FadeTimer[playerid];
	}
	// Nustatom nauj� fade'inimo tip�
	player_FadeType[playerid] = fade_out;

	// paleid�iam taimer�
	player_FadeTimer[playerid] = repeat fadeout(playerid);
}

// �aid�jui baig�si fadeinimas
player_OnFadeIn(playerid) {
	player_FadeType[playerid] = fade_none;

	// jeigu �aid�jas yra perkeliamas
	if(player_Teleporting{playerid}) {
		// Su�aldom j�
		TogglePlayerControllable(playerid, false);

		// Nustatom jo naj� pozicij�
		SetPlayerPos(playerid, 
			player_PosX[playerid],
			player_PosY[playerid],
			player_PosZ[playerid]
		);

		// Atnaujinam objektus
		Streamer_UpdateEx(playerid, 
			player_PosX[playerid],
			player_PosY[playerid],
			player_PosZ[playerid]
		);

		// Atitamsinam ekran�
		player_FadeOut(playerid);
	}
}

player_OnFadeOut(playerid)
{
	player_FadeType[playerid] = fade_none;
	TextDrawHideForPlayer(playerid, TD_Fade);

	if(player_Teleporting{playerid})
	{
		// �aid�jas yra perkeltas, tod�l atfreezinam j�
		TogglePlayerControllable(playerid, true);

		// Pasi�ymim, kad �aid�jas neb�ra perkeliamas
		player_Teleporting{playerid} = 0;
	}
}