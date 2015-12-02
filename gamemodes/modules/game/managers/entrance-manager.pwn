#include <YSI_Coding\y_hooks>

#define MAX_ENTRANCES 1000

forward OnPlayerEnterEntrance(playerid, entranceid);
forward OnPlayerUseEntrance(playerid, entranceid);

new const entrance_pickup_model_default = 19607;
new const entrance_pickup_model_locked = 19605;
new const entrance_pickup_model_unlocked = 19606;

static PlayerText:PlayerTD_EntranceType[MAX_PLAYERS];
static PlayerText:PlayerTD_EntranceHowTo[MAX_PLAYERS];
static PlayerText:PlayerTD_EntranceLock[MAX_PLAYERS];
static PlayerText:PlayerTD_EntranceAction[MAX_PLAYERS];

static howto_text_default[] = "Ieiti i vidu galima einant pro duris letai, t.y. laikant ~r~~h~~k~~SNEAK_ABOUT~ ~w~~h~mygtuka";

enum _:entrances_e_INFO {
	Float:entrance_position_x,
	Float:entrance_position_y,
	Float:entrance_position_z,
	destination_index,
	show_type_to_all,
	entrance_text_type[100],
	show_howto_to_all,
	entrance_text_howto[100],
	show_lock_to_all,
	entrance_text_lock[100],
	show_action_to_all,
	entrance_text_action[100]
};

static entrances[MAX_ENTRANCES][entrances_e_INFO];
static const default_entrances[][entrances_e_INFO] = {
	{627.6007,-571.7365,17.6317, 1, true, "Policijos nuovada: Áëjimas", true, "", false, "", false, ""}, // 0
	{627.4370,-587.4069,3000.3079, 0, true, "Policijos nuovada: Iðëjimas", true, "", false, "", false, ""}, // 1
	{627.4078,-585.7876,3000.3079, 0, true, "Policijos nuovada: Iðëjimas", true, "", false, "", false, ""},
	{1239.2123,308.6085,20.1122, 4, true, "Ligoninë: Áëjimas", true, "", false, "", false, ""}, // 3
	{1267.7073,323.6077,3001.0000, 3, true, "Ligoninë: Iðëjimas", true, "", false, "", false, ""} // 4
};

new last_entrance_id[MAX_PLAYERS];
new late_key_press[MAX_PLAYERS];

new Iterator:entrances_iter<MAX_ENTRANCES>;
new entrance_pickup_id[sizeof entrances];
new Text3D:entrance_3dtext_id[sizeof entrances];

CreateEntrance(
	Float:x, Float:y, Float:z, // pickup'p pozicija
	text_type[], // bendras pavadinimas
	index = NONE, // kur veda
	model = NONE, // pickup'o modelis
	text_howto[] = "", // kaip pasinaudoti ðiuo perëjimu
	text_lock[] = "", // kaip atrakinti/uþrakinti
	text_action[] = "", // kokius papildomus veiksmus galima atlikti?
	text_custom_label[] = "",
	_show_howto_to_all = true,
	vw = NONE // virtualworld (iðëjimams)
) {
	new i = Iter_Free(entrances_iter);
	if(i < 0) {
		return NONE;
	}
	entrances[i][entrance_position_x] = x;
	entrances[i][entrance_position_y] = y;
	entrances[i][entrance_position_z] = z;

	entrances[i][show_howto_to_all] = _show_howto_to_all;

	// todo: pakeisti entrance info textdrawus

	SetEntranceText_Type(i, FilterLetters(text_type, true));
	SetEntranceText_HowTo(i, FilterLetters((isnull(text_howto) ? howto_text_default : text_howto)));
	SetEntranceText_Lock(i, FilterLetters(text_lock));
	SetEntranceText_Action(i, FilterLetters(text_action));

	entrances[i][destination_index] = index;

	entrance_pickup_id[i] = CreateDynamicPickup(model == NONE ? entrance_pickup_model_default : model, 1, XYZ0(Float:entrances[i]) - 0.6, .worldid = vw);
	entrance_3dtext_id[i] = CreateDynamic3DTextLabel(isnull(text_custom_label) ? text_type : text_custom_label, 0xFFFFFFFF,  XYZ0(Float:entrances[i]), 50.0, .worldid = vw);

	Iter_Add(entrances_iter, i);

	return i;
}

SetEntranceDestination(entranceid, dest_index) {
	entrances[entranceid][destination_index] = dest_index;
}

GetEntranceDestination(entranceid) {
	return entrances[entranceid][destination_index];
}

GetEntrancePosition(entranceid, &Float:x, &Float:y, &Float:z) {
	x = entrances[entranceid][entrance_position_x];
	y = entrances[entranceid][entrance_position_y];
	z = entrances[entranceid][entrance_position_z];
}

ShowEntranceText_Type(playerid, entranceid = NONE) {
	if(entranceid != NONE) {
		PlayerTextDrawSetString(playerid, PlayerTD_EntranceType[playerid], entrances[entranceid][entrance_text_type]);
		M:P:X(playerid, "%s", entrances[entranceid][entrance_text_type]);
	}
	PlayerTextDrawShow(playerid, PlayerTD_EntranceType[playerid]);
}
ShowEntranceText_HowTo(playerid, entranceid = NONE) {
	if(entranceid != NONE) {
		PlayerTextDrawSetString(playerid, PlayerTD_EntranceHowTo[playerid], entrances[entranceid][entrance_text_howto]);
	}
	PlayerTextDrawShow(playerid, PlayerTD_EntranceHowTo[playerid]);
}
ShowEntranceText_Lock(playerid, entranceid = NONE) {
	if(entranceid != NONE) {
		PlayerTextDrawSetString(playerid, PlayerTD_EntranceLock[playerid], entrances[entranceid][entrance_text_lock]);
	}
	PlayerTextDrawShow(playerid, PlayerTD_EntranceLock[playerid]);
}
ShowEntranceText_Action(playerid, entranceid = NONE) {
	if(entranceid != NONE) {
		PlayerTextDrawSetString(playerid, PlayerTD_EntranceAction[playerid], entrances[entranceid][entrance_text_action]);
	}
	PlayerTextDrawShow(playerid, PlayerTD_EntranceAction[playerid]);
}

HideEntraceText(playerid) {
	PlayerTextDrawHide(playerid, PlayerTD_EntranceType[playerid]);
	PlayerTextDrawHide(playerid, PlayerTD_EntranceHowTo[playerid]);
	PlayerTextDrawHide(playerid, PlayerTD_EntranceLock[playerid]);
	PlayerTextDrawHide(playerid, PlayerTD_EntranceAction[playerid]);
}
//MAC4437E676752C
SetEntranceText_Type(entranceid, text[]) {
	strset(entrances[entranceid][entrance_text_type], text, 100);
}
SetEntranceText_HowTo(entranceid, text[]) {
	strset(entrances[entranceid][entrance_text_howto], text, 100);
}
SetEntranceText_Lock(entranceid, text[]) {
	strset(entrances[entranceid][entrance_text_lock], text, 100);
}
SetEntranceText_Action(entranceid, text[]) {
	strset(entrances[entranceid][entrance_text_action], text, 100);
}
SetEntranceText(entranceid, newtext[]) {
	UpdateDynamic3DTextLabelText(entrance_3dtext_id[entranceid], 0xFFFFFFFF, newtext);
}

DeleteEntrance(index, recursive = false) {
	Iter_Remove(entrances_iter, index);
	
	if(recursive) {
		new destination = GetEntranceDestination(index);
		SetEntranceDestination(index, NONE);

		if(destination != NONE) {
			DeleteEntrance(destination, true);
		}
	}
}

hook OnGameModeInit() {
	for(new i; i < sizeof default_entrances; ++i) {
		new x = CreateEntrance(
			XYZ0(Float:default_entrances[i]), 
			default_entrances[i][entrance_text_type], 
			default_entrances[i][destination_index]
		);
		static entr[entrances_e_INFO];
		entr = default_entrances[i];
		entr[destination_index] = entrances[x][destination_index];
		entr[show_howto_to_all] = entrances[x][show_howto_to_all];
		format(entr[entrance_text_type], 100, "%s", entrances[x][entrance_text_type]);
		format(entr[entrance_text_howto], 100, "%s", entrances[x][entrance_text_howto]);
		entrances[x] = entr;

		printf("Created entrance: %s", entrances[x][entrance_text_type]);
	}
}

task check_if_still_on_pickup[1000]() {
	foreach(new i : Player) {
		if(last_entrance_id[i] != NONE) {
			new x = last_entrance_id[i];

			if( ! IsPlayerInRangeOfPoint(i, 2, XYZ0(Float:entrances[x]))) {
				call OnPlayerLeaveEntrance(i, x);
			}
		}
	}
}

hook OnPlayerLeaveEntrance(playerid, entranceid) {
	late_key_press[playerid] = false;
	last_entrance_id[playerid] = NONE;
	HideEntraceText(playerid);
}

hook OnPlayerUpdate(playerid) {
	if(late_key_press[playerid]) {
		if(last_entrance_id[playerid] != NONE) {
			static keys, lr, ud;
			GetPlayerKeys(playerid, keys, ud, lr);

			if(keys & KEY_WALK && (ud || lr)) {
				UseEntrance(playerid, last_entrance_id[playerid]);
			}
		}
	}
}

hook OnPlayerPickUpDynPickup(playerid, pickupid) {
	if(last_entrance_id[playerid] != NONE) {
		return;
	}
	foreach(new i : entrances_iter) {
		if(entrance_pickup_id[i] == pickupid) {
			last_entrance_id[playerid] = i;

			if(call OnPlayerEnterEntrance(playerid, i)) {
				new keys, unused;
				GetPlayerKeys(playerid, keys, unused, unused);
				if( ! (keys & KEY_WALK)) {
					late_key_press[playerid] = true;

					if(entrances[i][show_type_to_all]) {
						ShowEntranceText_Type(playerid, i);
					}
					if(entrances[i][show_howto_to_all]) {
						ShowEntranceText_HowTo(playerid, i);
					}
					if(entrances[i][show_lock_to_all]) {
						ShowEntranceText_Lock(playerid, i);
					}
					if(entrances[i][show_action_to_all]) {
						ShowEntranceText_Action(playerid, i);
					}
				}
				else {
					UseEntrance(playerid, i);
				}
			}
			break;
		}
	}
}

UseEntrance(playerid, entranceid) {
	if(call OnPlayerUseEntrance(playerid, entranceid)) {
		new destination = entrances[entranceid][destination_index];
		player_Teleport(playerid, XYZ0(Float:entrances[destination]));

		new pickupid = entrance_pickup_id[destination];
		new vw;
		if((vw = Streamer_GetIntData(STREAMER_TYPE_PICKUP, pickupid, E_STREAMER_WORLD_ID)) != NONE) {
			SetPlayerVirtualWorld(playerid, vw);
		}
		else {
			if(GetPlayerVirtualWorld(playerid) != VW_DEFAULT) {
				SetPlayerVirtualWorld(playerid, VW_DEFAULT);
			}
		}

		late_key_press[playerid] = false;
		last_entrance_id[playerid] = NONE;
		HideEntraceText(playerid);
	}
}

// Perkelia þaidëjas á nurodytà vietà
player_Teleport(playerid, Float:x, Float:y, Float:z) {
	// Jeigu þaidëjas nëra niekur perkeliamas
	if( ! player_Teleporting{playerid}) {
		// Pasiþymim, kad þaidëjas yra perkeliamas
		player_Teleporting{playerid} = 1;
		// Nustatom þaidëjo bûsimà pozicijà
		player_PosX[playerid] = x;
		player_PosY[playerid] = y;
		player_PosZ[playerid] = z;

		// Pradedam uþtemsinimà
		player_FadeIn(playerid);
	}
}

hook OnPlayerConnect(playerid) {
	PlayerTD_EntranceType[playerid] = CreatePlayerTextDraw(playerid, 169.604461, 337.749908, "GYVENAMOS PATALPOS (1 A., VIDUTINES)");
	PlayerTextDrawLetterSize(playerid, PlayerTD_EntranceType[playerid], 0.271961, 1.220831);
	PlayerTextDrawTextSize(playerid, PlayerTD_EntranceType[playerid], 616.105651, 32.083332);
	PlayerTextDrawAlignment(playerid, PlayerTD_EntranceType[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_EntranceType[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, PlayerTD_EntranceType[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_EntranceType[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_EntranceType[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_EntranceType[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_EntranceType[playerid], 1);

	PlayerTD_EntranceHowTo[playerid] = CreatePlayerTextDraw(playerid, 170.262145, 363.500061, "Ieiti i vidu galima einant pro duris letai, t.y. laikant ~r~~h~~k~~SNEAK_ABOUT~ ~w~~h~mygtuka");
	PlayerTextDrawLetterSize(playerid, PlayerTD_EntranceHowTo[playerid], 0.229794, 1.277416);
	PlayerTextDrawAlignment(playerid, PlayerTD_EntranceHowTo[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_EntranceHowTo[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_EntranceHowTo[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_EntranceHowTo[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_EntranceHowTo[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_EntranceHowTo[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_EntranceHowTo[playerid], 1);

	PlayerTD_EntranceLock[playerid] = CreatePlayerTextDraw(playerid, 170.136230, 383.666717, "Atrakinti nama gali paspaudes ~y~~h~k. peles mygtuka.");
	PlayerTextDrawLetterSize(playerid, PlayerTD_EntranceLock[playerid], 0.229794, 1.277416);
	PlayerTextDrawAlignment(playerid, PlayerTD_EntranceLock[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_EntranceLock[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_EntranceLock[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_EntranceLock[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_EntranceLock[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_EntranceLock[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_EntranceLock[playerid], 1);

	PlayerTD_EntranceAction[playerid] = CreatePlayerTextDraw(playerid, 170.667709, 403.333465, "Noredamas issinuomuoti sias patalpas, rasyk ~g~~h~/nuomotis");
	PlayerTextDrawLetterSize(playerid, PlayerTD_EntranceAction[playerid], 0.229794, 1.277416);
	PlayerTextDrawAlignment(playerid, PlayerTD_EntranceAction[playerid], 1);
	PlayerTextDrawColor(playerid, PlayerTD_EntranceAction[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTD_EntranceAction[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTD_EntranceAction[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTD_EntranceAction[playerid], 51);
	PlayerTextDrawFont(playerid, PlayerTD_EntranceAction[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTD_EntranceAction[playerid], 1);
}