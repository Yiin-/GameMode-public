#include <YSI_Coding\y_hooks>

// Players Move Speed
#define MOVE_SPEED              100.0
#define ACCEL_RATE              0.03

// Players Mode
#define CAMERA_MODE_NONE    	0
#define CAMERA_MODE_FLY     	1

// Key state definitions
#define MOVE_FORWARD    		1
#define MOVE_BACK       		2
#define MOVE_LEFT       		3
#define MOVE_RIGHT      		4
#define MOVE_FORWARD_LEFT       5
#define MOVE_FORWARD_RIGHT      6
#define MOVE_BACK_LEFT          7
#define MOVE_BACK_RIGHT         8


new Text:TD_Tutorial_line;
new PlayerText:PlayerTD_Tutorial_title[MAX_PLAYERS];
new PlayerText:PlayerTD_Tutorial_description[MAX_PLAYERS];

enum noclipenum
{
	cameramode,
	flyobject,
	fly__mode,
	lrold,
	udold,
	lastmove,
	Float:accelmul
}
new noclipdata[MAX_PLAYERS][noclipenum];

new const tutorialTitle[][32] = {
	"Turgus",
	"Garazas",
	"Valytojai",
	"Taksi",
	"Gaujos baze",
	"Gaujos baze",
	"Gaujos baze",
	"Uostas",
	"Gaisrine",
	"Naftotiekis",
	"Ligonine",
	"Spawnas",
	"Policija"
};

new const tutorialDescription[][256] = {
	"Turgus yra pagrindine susirinkimu vieta, kur zaidejai perka bei parduoda ivairius daiktus.",
	"Garaze yra laikomos visos tavo transporto priemones. Ju kiekis nera ribojamas. Nusipirkus masina, ja atves i garaza.",
	"Valytojai yra vienas paprasciausiu, bet ir idomiausiu darbu. Sesk i pirma pasitaikiusia valytoju masina ir naikink visus nesvarumus.",
	"Taksi gali rasti taksistu kurie vezioja keleivius.",
	"Gaujos aprasymas",
	"Gaujos aprasymas",
	"Gaujos aprasymas",
	"Uosto aprasymas",
	"Gaisrines aprasymas",
	"Naftotiekio aprasymas",
	"Ligonines aprasymas",
	"Spawno aprasymas",
	"Policijos ir kalëjimo aprasymas"
};

new const Float:tutorialPosition[][3] = {
	{756.9077,-561.5975,26.5258}, // turgus
	{103.4139,-175.6115,1.5912}, // garaþas
	{700.5961,-626.3253,16.3861}, // valytojai
	{2260.4543,-65.9258,26.7834}, // taxi
	{2355.3921,-652.0391,128.9705}, // gang
	{507.7240,1112.7412,14.8612}, // gang
	{748.8752,275.0923,27.1999}, // gang
	{2110.6709,-89.1605,3.4354}, // uostas
	{1317.020,394.019,23.076}, // gaisrine
	{1396.77,-260.18,-2.43}, // naftotiekis
	{1241.7106,327.0409,19.7555}, // ligonine
	{691.7983,-456.3943,21.1520}, // spawnas
	{627.6007,-571.7365,17.6317} // policija
};

forward Float:GetDistanceBetweenPoints(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);

hook OnPlayerSpawn(playerid) {
	if(GetPVarInt(playerid, "spectating")) {
		DeletePVar(playerid, "spectating");
		playerData_ApplyData(playerid);
	}	// ???????????????????????????????????
	else {
		playerData_ApplyData(playerid);
	}
}

CMD:apmokymai(pid, p[]) {
	if(player_CreationTimestamp[pid] + DURATION(15 minutes) > gettime()) {
		if(noclipdata[pid][cameramode] == CAMERA_MODE_FLY) {
			CancelFlyMode(pid);
			TextDrawHideForPlayer(pid, TD_Tutorial_line);
			PlayerTextDrawHide(pid, PlayerTD_Tutorial_title[pid]);
			PlayerTextDrawHide(pid, PlayerTD_Tutorial_description[pid]);
		}
		else {
			playerData_SaveChar(pid);
			SetPVarInt(pid, "spectating", 1);
			FlyMode(pid);
		}
	}
	else {
		M:P:E(pid, "Apmokymus galima perþiûrëti tik per pirmas [number]15[] minuèiø nuo veikëjo sukûrimo.");
	}
	return true;
}

hook OnPlayerUpdate(playerid)
{
	if(noclipdata[playerid][cameramode] == CAMERA_MODE_FLY)
	{
		new i, rodom = false;

		for(; i < sizeof tutorialTitle; ++i)
		{
			if(IsPlayerLookingAt_Tutorial(playerid, tutorialPosition[i][0], tutorialPosition[i][1], tutorialPosition[i][2]))
			{
				rodom = true;
				TextDrawShowForPlayer(playerid, TD_Tutorial_line);
				PlayerTextDrawSetString(playerid, PlayerTD_Tutorial_title[playerid], tutorialTitle[i]);
				PlayerTextDrawSetString(playerid, PlayerTD_Tutorial_description[playerid], tutorialDescription[i]);
				PlayerTextDrawShow(playerid, PlayerTD_Tutorial_title[playerid]);
				PlayerTextDrawShow(playerid, PlayerTD_Tutorial_description[playerid]);
			}
		}
		if(!rodom) {
			TextDrawHideForPlayer(playerid, TD_Tutorial_line);
			PlayerTextDrawHide(playerid, PlayerTD_Tutorial_title[playerid]);
			PlayerTextDrawHide(playerid, PlayerTD_Tutorial_description[playerid]);
		}
		static keys,ud,lr;
		GetPlayerKeys(playerid,keys,ud,lr);

		if(noclipdata[playerid][fly__mode] && (GetTickCount() - noclipdata[playerid][lastmove] > 100))
		{
		    // If the last move was > 100ms ago, process moving the object the players camera is attached to
		    MoveCamera(playerid);
		}

		// Is the players current key state different than their last keystate?
		if(noclipdata[playerid][udold] != ud || noclipdata[playerid][lrold] != lr)
		{
			if((noclipdata[playerid][udold] != 0 || noclipdata[playerid][lrold] != 0) && ud == 0 && lr == 0)
			{   // All keys have been released, stop the object the camera is attached to and reset the acceleration multiplier
				StopPlayerObject(playerid, noclipdata[playerid][flyobject]);
				noclipdata[playerid][fly__mode]      = 0;
				noclipdata[playerid][accelmul]  = 0.0;
			}
			else
			{   // Indicates a new key has been pressed

			    // Get the direction the player wants to move as indicated by the keys
				noclipdata[playerid][fly__mode] = GetMoveDirectionFromKeys(ud, lr);

				// Process moving the object the players camera is attached to
				MoveCamera(playerid);
			}
		}
		noclipdata[playerid][udold] = ud; noclipdata[playerid][lrold] = lr; // Store current keys pressed for comparison next update
		return false;
	}
	return true;
}


stock GetMoveDirectionFromKeys(ud, lr)
{
	new direction = 0;

    if(lr < 0)
	{
		if(ud < 0) 		direction = MOVE_FORWARD_LEFT; 	// Up & Left key pressed
		else if(ud > 0) direction = MOVE_BACK_LEFT; 	// Back & Left key pressed
		else            direction = MOVE_LEFT;          // Left key pressed
	}
	else if(lr > 0) 	// Right pressed
	{
		if(ud < 0)      direction = MOVE_FORWARD_RIGHT;  // Up & Right key pressed
		else if(ud > 0) direction = MOVE_BACK_RIGHT;     // Back & Right key pressed
		else			direction = MOVE_RIGHT;          // Right key pressed
	}
	else if(ud < 0) 	direction = MOVE_FORWARD; 	// Up key pressed
	else if(ud > 0) 	direction = MOVE_BACK;		// Down key pressed

	return direction;
}

//--------------------------------------------------

stock MoveCamera(playerid)
{
	static Float:FV[3], Float:CP[3];
	GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);          // 	Cameras position in space
    GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);  //  Where the camera is looking at

	// Increases the acceleration multiplier the longer the key is held
	if(noclipdata[playerid][accelmul] <= 1) noclipdata[playerid][accelmul] += ACCEL_RATE;

	// Determine the speed to move the camera based on the acceleration multiplier and keys
	static keys, unused;
	GetPlayerKeys(playerid, keys, unused, unused);
	new Float:speed = MOVE_SPEED * noclipdata[playerid][accelmul];// * (keys & KEY_JUMP)?(0.5):(1.0);

	// Calculate the cameras next position based on their current position and the direction their camera is facing
	static Float:X, Float:Y, Float:Z;
	GetNextCameraPosition(noclipdata[playerid][fly__mode], CP, FV, X, Y, Z);
	MovePlayerObject(playerid, noclipdata[playerid][flyobject], X, Y, Z, speed);

	// Store the last time the camera was moved as now
	noclipdata[playerid][lastmove] = GetTickCount();
	return 1;
}

//--------------------------------------------------

stock GetNextCameraPosition(move_mode, Float:CP[3], Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    // Calculate the cameras next position based on their current position and the direction their camera is facing
    #define OFFSET_X (FV[0]*6000.0)
	#define OFFSET_Y (FV[1]*6000.0)
	#define OFFSET_Z (FV[2]*6000.0)
	switch(move_mode)
	{
		case MOVE_FORWARD:
		{
			X = CP[0]+OFFSET_X;
			Y = CP[1]+OFFSET_Y;
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_BACK:
		{
			X = CP[0]-OFFSET_X;
			Y = CP[1]-OFFSET_Y;
			Z = CP[2]-OFFSET_Z;
		}
		case MOVE_LEFT:
		{
			X = CP[0]-OFFSET_Y;
			Y = CP[1]+OFFSET_X;
			Z = CP[2];
		}
		case MOVE_RIGHT:
		{
			X = CP[0]+OFFSET_Y;
			Y = CP[1]-OFFSET_X;
			Z = CP[2];
		}
		case MOVE_BACK_LEFT:
		{
			X = CP[0]+(-OFFSET_X - OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y + OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_BACK_RIGHT:
		{
			X = CP[0]+(-OFFSET_X + OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y - OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_FORWARD_LEFT:
		{
			X = CP[0]+(OFFSET_X  - OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  + OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_FORWARD_RIGHT:
		{
			X = CP[0]+(OFFSET_X  + OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  - OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
	}
}

stock FlyMode(playerid)
{
	// Create an invisible object for the players camera to be attached to
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	noclipdata[playerid][flyobject] = CreatePlayerObject(playerid, 19300, X, Y, Z, 0.0, 0.0, 0.0);

	// Place the player in spectating mode so objects will be streamed based on camera location
	TogglePlayerSpectating(playerid, true);
	// Attach the players camera to the created object
	AttachCameraToPlayerObject(playerid, noclipdata[playerid][flyobject]);

	SetPVarInt(playerid, "FlyMode", 1);
	noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;
	return 1;
}

stock CancelFlyMode(playerid)
{
	DeletePVar(playerid, "FlyMode");
	CancelEdit(playerid);

	TogglePlayerSpectating(playerid, false);

	DestroyPlayerObject(playerid, noclipdata[playerid][flyobject]);
	noclipdata[playerid][cameramode] = CAMERA_MODE_NONE;
	return 1;
}

stock Float:GetDistanceBetweenPoints(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
    return VectorSize(x1-x2, y1-y2, z1-z2);
}

stock IsPlayerLookingAt_Tutorial(playerid, Float:X, Float:Y, Float:Z, Float:range = 20.0)
{
	new Float:cX, Float:cY, Float:cZ;
	GetPlayerCameraPos(playerid, cX, cY, cZ);

	new const Float:dist = GetDistanceBetweenPoints(cX, cY, cZ, X, Y, Z);

	if(dist > 200) return false;

	new Float:lX, Float:lY, Float:lZ;
	GetPlayerCameraLookAt(playerid, lX, lY, lZ, dist);

	return GetDistanceBetweenPoints(lX, lY, lZ, X, Y, Z) <= range;
}

stock GetPlayerCameraLookAt(playerid, &Float:X, &Float:Y, &Float:Z, Float:fScale = 10.0)
{
	new
		Float:fPX, Float:fPY, Float:fPZ,
		Float:fVX, Float:fVY, Float:fVZ;

	// Change me to change the scale you want. A larger scale increases the distance from the camera.
	// A negative scale will inverse the vectors and make them face in the opposite direction.

	GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
	GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);

	X = fPX + floatmul(fVX, fScale);
	Y = fPY + floatmul(fVY, fScale);
	Z = fPZ + floatmul(fVZ, fScale);
	return 0;
}

hook OnGameModeInit() {
	TD_Tutorial_line = TextDrawCreate(131.764739, 358.166748, ".");
	TextDrawLetterSize(TD_Tutorial_line, 43.338047, -0.185000);
	TextDrawAlignment(TD_Tutorial_line, 1);
	TextDrawColor(TD_Tutorial_line, -1);
	TextDrawSetShadow(TD_Tutorial_line, 0);
	TextDrawSetOutline(TD_Tutorial_line, 1);
	TextDrawBackgroundColor(TD_Tutorial_line, 51);
	TextDrawFont(TD_Tutorial_line, 1);
	TextDrawSetProportional(TD_Tutorial_line, 1);
}

hook OnPlayerConnect(playerid) {
	// Reset the data belonging to this player slot
	noclipdata[playerid][cameramode] 	= CAMERA_MODE_NONE;
	noclipdata[playerid][lrold]	   	 	= 0;
	noclipdata[playerid][udold]   		= 0;
	noclipdata[playerid][fly__mode]   		= 0;
	noclipdata[playerid][lastmove]   	= 0;
	noclipdata[playerid][accelmul]   	= 0.0;

	PlayerTD_Tutorial_title[playerid] = CreatePlayerTextDraw(playerid, 167.529434, 335.416656, "Turgus");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Tutorial_title[playerid], 0.4, 1.9);
	PlayerTextDrawAlignment(playerid, PlayerTD_Tutorial_title[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Tutorial_title[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Tutorial_title[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Tutorial_title[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Tutorial_title[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Tutorial_title[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Tutorial_title[playerid], 1);

	PlayerTD_Tutorial_description[playerid] = CreatePlayerTextDraw(playerid, 168.941253, 364.583282, "Turgus yra vieta kur blabla bla bla wow  so much text");
	PlayerTextDrawLetterSize(playerid, PlayerTD_Tutorial_description[playerid], 0.3, 1.425);
	PlayerTextDrawTextSize(playerid, PlayerTD_Tutorial_description[playerid], 551.529174, 55.999988);
	PlayerTextDrawAlignment(playerid, PlayerTD_Tutorial_description[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_Tutorial_description[playerid], -1);
	PlayerTextDrawUseBox(playerid, PlayerTD_Tutorial_description[playerid], true);
	PlayerTextDrawBoxColor(playerid, PlayerTD_Tutorial_description[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PlayerTD_Tutorial_description[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_Tutorial_description[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_Tutorial_description[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_Tutorial_description[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTD_Tutorial_description[playerid], 1);
}