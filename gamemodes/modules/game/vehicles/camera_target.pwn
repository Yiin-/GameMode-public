#include <YSI_Coding\y_hooks>

new Text:TD_TargetVehicle_MoreInfo;

new PlayerText:PlayerTD_TargetVehicle_Name[MAX_PLAYERS];
new PlayerText:PlayerTD_TargetVehicle_Job[MAX_PLAYERS];
new PlayerText:PlayerTD_TargetVehicle_Age[MAX_PLAYERS];
new PlayerText:PlayerTD_TargetVehicle_Points[MAX_PLAYERS];

static canTarget[MAX_PLAYERS char];
static informationIsShowing[MAX_PLAYERS char];

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys & KEY_AIM) {
		if( ! canTarget{playerid}) {
			EnablePlayerCameraTarget(playerid, true);
			canTarget{playerid} = true;
		}
	}
	else {
		if(canTarget{playerid}) {
			EnablePlayerCameraTarget(playerid, false);
			canTarget{playerid} = false;
		}
	}
	if(newkeys & KEY_SPRINT) {
		if(canTarget{playerid} && informationIsShowing{playerid}) {
			ShowPlayerTargetVehicleMenu(playerid, GetPlayerCameraTargetVehicle(playerid));
		}
	}
}

CanPlayerTargetVehicle(playerid, toggle = -1) {
	if(toggle == -1) {
		return canTarget{playerid};
	}
	else {
		EnablePlayerCameraTarget(playerid, toggle);
		canTarget{playerid} = toggle;
	}
	return toggle;
}

hook OnPlayerUpdate(playerid) {
	static vehicleid;

	if(canTarget{playerid} && (vehicleid = GetPlayerCameraTargetVehicle(playerid)) != INVALID_VEHICLE_ID && vehicleid) {
		ShowVehicleInformation(playerid, vehicleid);
	}
	else if(informationIsShowing{playerid}) {
		HideVehicleInformation(playerid);
	}
	return true;
}

ShowPlayerTargetVehicleMenu(playerid, vehicleid) {
	if(vehicleid == INVALID_VEHICLE_ID) return;
	if(vehicle_Status[vehicleid] == VEHICLE_STATUS_FORSALE
		&& vehicle_OwnerType[vehicleid] == VEHICLE_OWNER_TYPE_PLAYER
		&& vehicle_Owner[vehicleid] == char_ID[playerid]) {
		return; // jeigu maðina parduodama, pardavëjui meniu nerodom, jis jà gali 
				// pardavimà atðaukti per maðinos valdymo meniu /mvmeniu
	}

	new model = GetVehicleModel(vehicleid);
	dialogSetHeader("%s (%s)", vehicle_Name[model - 400], vehicle_Plate[vehicleid]);

	CallLocalFunction("OnPlOpenTargetVehMenu", "ii", playerid, vehicleid);

	inline response(re, li) {
		if(re && IsValidVehicle(vehicleid)) {
			CallLocalFunction("OnPlSelectTargetVehMenu", "iii", playerid, vehicleid, li);
		}
	}

	dialogShow(playerid, using inline response, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Uþdaryti");
}

ShowVehicleInformation(playerid, vehicleid) {
	informationIsShowing{playerid} = true;
	SetPVarInt(playerid, "lookingAtVehicle", vehicleid);

	TextDrawShowForPlayer(playerid, TD_TargetVehicle_MoreInfo);

	new model = GetVehicleModel(vehicleid);
	PlayerTextDrawSetString(playerid, PlayerTD_TargetVehicle_Name[playerid], vehicle_Name[model - 400]);

	// Jeigu darbinë maðina, rodom kokiam darbui ji priklauso
	if(vehicle_OwnerType[vehicleid] == VEHICLE_OWNER_TYPE_JOB) {
		PlayerTextDrawSetString(playerid, PlayerTD_TargetVehicle_Job[playerid], GetJobName(vehicle_Owner[vehicleid]));
		PlayerTextDrawShow(playerid, PlayerTD_TargetVehicle_Job[playerid]);
	}
	// Paraðom maðinos amþiø
	new age = gettime() - vehicle_CreationTimestamp[vehicleid];
	new d,h,m; SecToTime2(age, d,h,m);
	PlayerTextDrawSetString(playerid, PlayerTD_TargetVehicle_Age[playerid], 
		F:0("Amzius: ~g~~h~~h~%i~w~~h~d. ~g~~h~~h~%i~w~~h~h. ~g~~h~~h~%i~w~~h~mins.", d, h, m));

	// vertës taðkus
	PlayerTextDrawSetString(playerid, PlayerTD_TargetVehicle_Points[playerid], 
		F:0("Vertes taskai: ~b~~h~~h~%i", GetVehiclePoints(vehicleid)));

	PlayerTextDrawShow(playerid, PlayerTD_TargetVehicle_Name[playerid]);
	PlayerTextDrawShow(playerid, PlayerTD_TargetVehicle_Age[playerid]);
	PlayerTextDrawShow(playerid, PlayerTD_TargetVehicle_Points[playerid]);
}

HideVehicleInformation(playerid) {
	informationIsShowing{playerid} = false;
	DeletePVar(playerid, "lookingAtVehicle");

	TextDrawHideForPlayer(playerid, TD_TargetVehicle_MoreInfo);

	PlayerTextDrawHide(playerid, PlayerTD_TargetVehicle_Job[playerid]);
	PlayerTextDrawHide(playerid, PlayerTD_TargetVehicle_Name[playerid]);
	PlayerTextDrawHide(playerid, PlayerTD_TargetVehicle_Age[playerid]);
	PlayerTextDrawHide(playerid, PlayerTD_TargetVehicle_Points[playerid]);
}

hook OnGameModeInit() {
	TD_TargetVehicle_MoreInfo = TextDrawCreate(406.588165, 380.333312, "Daugiau informacijos: ~y~~k~~PED_SPRINT~");
	TextDrawLetterSize(TD_TargetVehicle_MoreInfo, 0.300352, 1.500250);
	TextDrawAlignment(TD_TargetVehicle_MoreInfo, 1);
	TextDrawColor(TD_TargetVehicle_MoreInfo, -1);
	TextDrawSetShadow(TD_TargetVehicle_MoreInfo, 0);
	TextDrawSetOutline(TD_TargetVehicle_MoreInfo, 1);
	TextDrawBackgroundColor(TD_TargetVehicle_MoreInfo, 51);
	TextDrawFont(TD_TargetVehicle_MoreInfo, 2);
	TextDrawSetProportional(TD_TargetVehicle_MoreInfo, 1);
}

hook OnPlayerConnect(playerid) {
	canTarget{playerid} = false;
	informationIsShowing{playerid} = false;

	PlayerTD_TargetVehicle_Name[playerid] = CreatePlayerTextDraw(playerid, 403.294311, 305.083404, "Buffalo");
	PlayerTextDrawLetterSize(playerid, PlayerTD_TargetVehicle_Name[playerid], 0.353058, 1.495000);
	PlayerTextDrawAlignment(playerid, PlayerTD_TargetVehicle_Name[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_TargetVehicle_Name[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_TargetVehicle_Name[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_TargetVehicle_Name[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_TargetVehicle_Name[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_TargetVehicle_Name[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_TargetVehicle_Name[playerid], 1);

	PlayerTD_TargetVehicle_Job[playerid] = CreatePlayerTextDraw(playerid, 510.176605, 306.083526, "~r~~h~~h~Policija");
	PlayerTextDrawLetterSize(playerid, PlayerTD_TargetVehicle_Job[playerid], 0.353058, 1.495000);
	PlayerTextDrawAlignment(playerid, PlayerTD_TargetVehicle_Job[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_TargetVehicle_Job[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_TargetVehicle_Job[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_TargetVehicle_Job[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_TargetVehicle_Job[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_TargetVehicle_Job[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_TargetVehicle_Job[playerid], 1);

	PlayerTD_TargetVehicle_Age[playerid] = CreatePlayerTextDraw(playerid, 403.882720, 334.500183, "Amzius: ~g~~h~~h~15~w~~h~d. ~g~~h~~h~6~w~~h~h.");
	PlayerTextDrawLetterSize(playerid, PlayerTD_TargetVehicle_Age[playerid], 0.300399, 1.500250);
	PlayerTextDrawAlignment(playerid, PlayerTD_TargetVehicle_Age[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_TargetVehicle_Age[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_TargetVehicle_Age[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_TargetVehicle_Age[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_TargetVehicle_Age[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_TargetVehicle_Age[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_TargetVehicle_Age[playerid], 1);

	PlayerTD_TargetVehicle_Points[playerid] = CreatePlayerTextDraw(playerid, 404.882720, 353.000122, "vertes taskai: ~b~~h~~h~42");
	PlayerTextDrawLetterSize(playerid, PlayerTD_TargetVehicle_Points[playerid], 0.300681, 1.500249);
	PlayerTextDrawAlignment(playerid, PlayerTD_TargetVehicle_Points[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_TargetVehicle_Points[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_TargetVehicle_Points[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_TargetVehicle_Points[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_TargetVehicle_Points[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_TargetVehicle_Points[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_TargetVehicle_Points[playerid], 1);
}