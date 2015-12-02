#include <YSI\y_hooks>

static Float:cached_player_pos[MAX_PLAYERS][3];
static Float:cached_cam_pos[MAX_PLAYERS][3];

gameStart_Spawn(playerid) {
	classSelection_ResetActors(playerid);
	isInClassSelection{playerid} = false;

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) {
		SetPVarInt(playerid, "gameStart", 1);
		TogglePlayerSpectating(playerid, false);

		player_Teleporting{playerid} = 0;

		player_FadeIn(playerid);

		SpawnPlayer(playerid);

		defer checkIfCameraBugged(playerid);
	}
}

timer checkIfCameraBugged[500](playerid) {
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) {
		TogglePlayerSpectating(playerid, false);
		SpawnPlayer(playerid);
		defer checkIfCameraBugged(playerid);
	}
}

timer startSmoothCamera[2000](playerid, step) {
	switch(step) {
		case 0: {
			if(cached_player_pos[playerid][0] == 0.0) {
				GetPlayerPos(playerid, XYZ0(cached_player_pos[playerid]));

				defer startSmoothCamera[500](playerid, step);
				return;
			}
			SetCameraBehindPlayer(playerid);

			defer startSmoothCamera[500](playerid, step + 1);
		}
		case 1: {
	        new
	            Float:fPX, Float:fPY, Float:fPZ,
	            Float:fVX, Float:fVY, Float:fVZ;

	        GetPlayerCameraPos(playerid, fPX, fPY, fPZ);

	        new
	            Float:fScale = VectorSize(cached_player_pos[playerid][0] - fPX, cached_player_pos[playerid][1] - fPY, cached_player_pos[playerid][2] - fPZ);
	 
	        GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);

	        cached_player_pos[playerid][0] = fVX * fScale + fPX;
	        cached_player_pos[playerid][1] = fVY * fScale + fPY;
	        cached_player_pos[playerid][2] = fVZ * fScale + fPZ;

			GetPlayerCameraPos(playerid, XYZ0(cached_cam_pos[playerid]));

			InterpolateCameraPos(playerid, XYZ0(cached_cam_pos[playerid]) + 20.0, XYZ0(cached_cam_pos[playerid]), 2500, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, XYZ0(cached_player_pos[playerid]) + 10.0, XYZ0(cached_player_pos[playerid]), 2500, CAMERA_MOVE);

			player_FadeOut(playerid);

			defer endSmoothCamera(playerid);
		}
	}
}

timer endSmoothCamera[2500](playerid) {
	TogglePlayerControllable(playerid, true);

	SetCameraBehindPlayer(playerid);
}

hook OnPlayerSpawn(playerid) {
	if(GetPVarInt(playerid, "gameStart")) {
		DeletePVar(playerid, "gameStart");

		// Smooth cam
		{
			TogglePlayerControllable(playerid, false);

			GetPlayerPos(playerid, XYZ0(cached_player_pos[playerid]));

			SetCameraBehindPlayer(playerid);

			defer startSmoothCamera(playerid, 0);
		}
		
		TextDrawHideForPlayer(playerid, TD_LoadingSkin);
		TextDrawHideForPlayer(playerid, TD_LoadingSkin); // just in case

		ClearChat(playerid);

		M:P:G(playerid, "Sëkmës þaidime!");
		if(player_CreationTimestamp[playerid] + DURATION(15 minutes) > gettime()) {
			// jeigu þaidëjas naujokas, nustatom max hp
			player_MaxHealth[playerid] = player_Health[playerid] = max(player_MaxHealth[playerid], 50.0);

			M:P:I(playerid, "Norëdamas paskraidyti po serverá ir jame apsiþvalgyti, raðyk [highlight]/apmokymai[].");
			M:P:X(playerid, "Apmokymus gali betkada nutraukti dar kartà paraðæs komandà [highlight]/apmokymai[].");
			M:P:X(playerid, "Komandà [highlight]/apmokymai[] naudoti galima tik pirmas [number]15[] minuèiø nuo pirmojo veikëjo sukûrimo.");
		}
		playerData_ApplyData(playerid);
	}
}