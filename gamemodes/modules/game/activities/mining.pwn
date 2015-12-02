#include "mining\ui.pwn"

#include <YSI\y_hooks>

#define MAX_ORES 1000

enum {
	OBJ_MINABLE,
	OBJ_ALREADY_IN_USE,
	OBJ_ON_COOLDOWN
};

static       mining_xp       [MAX_PLAYERS];
static       mining_lvl      [MAX_PLAYERS];
static       is_mining       [MAX_PLAYERS char];
static       current_ore     [MAX_PLAYERS];
static Timer:mining_timer    [MAX_PLAYERS];
static Float:mining_progress [MAX_PLAYERS];

enum e_ORE_DATA { 
	Float:ore_x, 
    Float:ore_y, 
    Float:ore_z,
    ore_state, 
    ore_obj
};
new ores[MAX_ORES][6];

hook OnGameModeInit() {
	CreateOres();
}

hook OnCreatePlayerORM(ORM:ormid, playerid) {
	orm_addvar_int(ormid, mining_xp[playerid], "mining_xp");
	orm_addvar_int(ormid, mining_lvl[playerid], "mining_lvl");
}

hook OnResetPlayerVars(playerid) {
	if(IsPlayerMining(playerid)) {
		StopMining(playerid);
	}
	mining_xp[playerid] = 0;
	mining_lvl[playerid] = 0;
	current_ore[playerid] = 0;
}

SetOreState(ore, _state, player = NONE) {
	ores[ore][ore_state] = _state;
	switch(_state) {
		case OBJ_MINABLE: {
			SetDynamicObjectMaterial(ores[ore][ore_obj], 0, 3931, "d_rock02", "rocktb128", 0);
		}
		case OBJ_ALREADY_IN_USE: {
			SetDynamicObjectMaterial(ores[ore][ore_obj], 0, 18646, "matcolours", "white", 0xFF7AAAA00);
		}
		case OBJ_ON_COOLDOWN: {
			SetDynamicObjectMaterial(ores[ore][ore_obj], 0, 18646, "matcolours", "white", 0xFFAA0000);
		}
	}

	foreach(new i : Player) {
		Streamer_Update(i, STREAMER_TYPE_OBJECT);
	}
}

GetPlayerMiningLevel(playerid) {
	return mining_lvl[playerid];
}

IsPlayerMining(playerid) {
	return is_mining{playerid};
}

StartMiningAnimation(playerid) {
	ApplyAnimation(playerid, "CHAINSAW", "CSAW_1", 4.1, 1, 0, 0, 0, 0, 1);
}

timer ResetOre[10000](ore) {
	SetOreState(ore, OBJ_MINABLE);
	foreach(new i : Player) {
		Streamer_Update(i, STREAMER_TYPE_OBJECT);
	}
}

HitOre(playerid) {
	M:P:X(playerid, "Mining: hit an ore");

	//new Item:mined_ore = CreateItem()

	new ore = current_ore[playerid];
		
	SetOreState(ore, OBJ_ON_COOLDOWN, playerid);

	defer ResetOre(ore);
}

timer mining_update[100](playerid) {
	static keys, unused;
	GetPlayerKeys(playerid, keys, unused, unused);
	if(keys & KEY_FIRE) {
		if((mining_progress[playerid] += 5.0) >= 200.0) {
			mining_progress[playerid] = 198.0;

			HitOre(playerid);
			StopMining(playerid);
		}
		else {
			PlayerTextDrawTextSize(playerid, PlayerTD_Mining[playerid][0], 11.0, mining_progress[playerid]);
			PlayerTextDrawShow(playerid, PlayerTD_Mining[playerid][0]);
		}
	}
	else {
		SetOreState(current_ore[playerid], OBJ_MINABLE, playerid);

		StopMining(playerid);
	}
}

StartMiningProgress(playerid, ore_name[]) {

	PlayerTextDrawTextSize(playerid, PlayerTD_Mining[playerid][0], 11.0, 0.0);
	PlayerTextDrawSetString(playerid, PlayerTD_Mining[playerid][1], ore_name);

	foreach(new i : Array(TD_Mining)) {
		TextDrawShowForPlayer(playerid, Text:i);
	}
	foreach(new i : Array(PlayerTD_Mining[playerid])) {
		PlayerTextDrawShow(playerid, PlayerText:i);
	}
	mining_progress[playerid] = 0.0;
	mining_timer[playerid] = repeat mining_update(playerid);
}

timer hideMiningTextDraws[1000](playerid) {
	foreach(new i : Array(TD_Mining)) {
		TextDrawHideForPlayer(playerid, Text:i);
	}
	foreach(new i : Array(PlayerTD_Mining[playerid])) {
		PlayerTextDrawHide(playerid, PlayerText:i);
	}
}

StopMiningProgress(playerid) {
	stop mining_timer[playerid];

	defer hideMiningTextDraws(playerid);
}

StartMining(playerid, ore) {
	if(IsPlayerMining(playerid)) {
		StopMining(playerid);
	}
	is_mining{playerid} = true;

	StartMiningAnimation(playerid);

	StartMiningProgress(playerid, "Akmuo");

	current_ore[playerid] = ore;
	SetOreState(ore, OBJ_ALREADY_IN_USE, playerid);
}

StopMining(playerid) {
	if(IsPlayerMining(playerid)) {
		ClearAnimations(playerid, 1);
		StopMiningProgress(playerid);
		is_mining{playerid} = 0;
	}
}

IsFacingMinableOre(playerid) {
	static Float:x, Float:y, Float:z, Float:angle, Float:distance;
	GetPlayerPos(playerid, x, y, z);

	for(new i; i != MAX_ORES && ores[i][ore_obj]; ++i) {
		if(ores[i][ore_state] == OBJ_MINABLE) {
			if(Streamer_IsItemVisible(playerid, STREAMER_TYPE_OBJECT, ores[i][ore_obj])) {
				Streamer_GetDistanceToItem(x, y, z, STREAMER_TYPE_OBJECT, ores[i][ore_obj], distance);

				if(distance < 4) {
					static Float:ox, Float:oy, Float: oz;
					ox = ores[i][ore_x];
					oy = ores[i][ore_y];
					oz = ores[i][ore_z];

					// jeigu aukðèio skirtumas nëra per didelis
					if(floatabs(z - oz) < 1.5) {
						angle = floatabs(atan((oy-y)/(ox-x)));

						// dirty math
						if(ox <= x && oy >= y) angle = floatsub(180, angle);
						else if(ox < x && oy < y) angle = floatadd(angle, 180);
						else if(ox >= x && oy <= y) angle = floatsub(360.0, angle);
						angle = floatsub(angle, 90.0);
						if(angle >= 360.0) angle = floatsub(angle, 360.0);

						static Float:fa;
						GetPlayerFacingAngle(playerid, fa);

						// jeigu esam atsisukæ daug maþ link objekto
						if(floatabs(fa - angle) < 90) {
							return i;
						}
					}
				}
			}
		}
	}
	return NONE;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(PRESSED(KEY_FIRE)) {
		//if(HasItemEquiped(playerid, "Kirtiklis")) {
			new ore;
			if((ore = IsFacingMinableOre(playerid)) != NONE) {
				StartMining(playerid, ore);
			}
		//}
	}
}

CreateOres() {
	static Float:ore_pos[][3] = {
		{565.13, 83.62, 11.31},
		{562.63, 109.58, 10.89},
		{571.64, 127.79, 10.50},
		{558.13, 93.40, 12.43},
		{567.25, 100.01, 10.28},
		{567.92, 105.72, 9.89},
		{571.17, 108.10, 9.32},
		{568.21, 96.28, 10.04},
		{570.56, 93.34, 9.60},
		{633.59, 101.23, 6.43},
		{592.38, 45.53, 14.17},
		{596.03, 45.01, 14.20},
		{595.69, 49.67, 14.02},
		{602.85, 63.04, 15.86},
		{601.50, 73.08, 16.02},
		{596.62, 66.67, 15.73},
		{626.99, 59.75, 14.60},
		{620.48, 58.82, 14.60},
		{616.40, 52.67, 14.31},
		{606.21, 43.08, 14.76},
		{618.34, 42.22, 15.34},
		{602.17, 37.25, 13.51},
		{623.19, 50.58, 14.59},
		{588.34, 36.23, 14.85},
		{559.41, 46.13, 16.20},
		{564.88, 31.67, 19.47},
		{558.98, 38.92, 18.13},
		{552.56, 50.12, 16.85},
		{560.31, 51.98, 14.77},
		{563.72, 38.46, 17.89},
		{617.95, 54.81, 0.83},
		{620.94, 62.44, 1.90},
		{627.78, 61.50, 2.03},
		{622.18, 54.54, 0.77},
		{619.67, 48.95, 0.07},
		{626.77, 47.19, 0.93},
		{646.80, 115.38, 8.84},
		{639.31, 118.95, 8.65},
		{640.33, 110.38, 7.87},
		{587.48, 121.65, 7.03},
		{580.73, 129.77, 8.52},
		{585.91, 129.27, 6.98},
		{591.68, 120.06, 5.93},
		{622.51, 129.63, 8.37},
		{673.25, 126.06, 17.35},
		{668.73, 131.82, 14.72},
		{665.66, 147.68, 14.31},
		{677.59, 137.56, 17.77},
		{675.72, 126.97, 18.43},
		{676.96, 130.17, 18.52},
		{625.66, 45.98, 14.63},
		{622.04, 59.13, 1.32},
		{601.75, 47.36, 2.62},
		{605.53, 46.20, 1.11}
	};
	for(new i; i < sizeof ore_pos; ++i) {
		ores[i][ore_x] = ore_pos[i][0];
		ores[i][ore_y] = ore_pos[i][1];
		ores[i][ore_z] = ore_pos[i][2];
		ores[i][ore_obj] = CreateDynamicObject(3931, 
			ores[i][ore_x], ores[i][ore_y], ores[i][ore_z],   
			0.00, 0.00, 0.00, .streamdistance = 70.0, .drawdistance = 50.0);
	}
}