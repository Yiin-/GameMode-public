#include <YSI_Coding\y_hooks>

#define MAX_STEPS 30

enum {
	GUARDIAN_TYPE_MARK_WAYNE,
	GUARDIAN_TYPE_VERY_WEAK,
	GUARDIAN_TYPE_WEAK,
	GUARDIAN_TYPE_NORMAL,
	GUARDIAN_TYPE_STRONG,
	GUARDIAN_TYPE_VERY_STRONG
};
enum {
	GUARDIAN_STATE_NONE,
	GUARDIAN_STATE_AFK,
	GUARDIAN_STATE_WALKING,
	GUARDIAN_STATE_SHOOTING,
	GUARDIAN_STATE_DEAD
};
enum _:Guardian_e_DATA {
	guardLevel,

	currentState, // kà darom?
	currentTarget, // á kà ðaudom?

	latestState, // kà darëm prieð tai?

	shootingRate, // kokiu greièiu ðaudom?

	Float:securedPoint[3], // koká taðkà saugom?
	currentNode,
	nodesCount,

	Timer:shootingTimer
};
static Guardian[MAX_PLAYERS][Guardian_e_DATA];
static Float:node[MAX_PLAYERS][MAX_STEPS][3];
new Iterator:Guardians<MAX_PLAYERS>;

hook OnGameModeInit() {
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
	PathFinder_Init(MapAndreas_GetAddress());

	repeat CheckGuardians();
}

hook OnPlayerDeath(playerid) {
	if(IsPlayerNPC(playerid)) {
		if(GetState(playerid) == GUARDIAN_STATE_SHOOTING) {
			SetShootingTimer(playerid, Timer:NONE);
			FCNPC_StopAim(playerid);
		}
		SetState(playerid, GUARDIAN_STATE_DEAD);

		defer RemoveBody(playerid);
	}
}

CreateGuardian(type, Float:x, Float:y, Float:z, skin, weapon) {
	new Float:health;
	new Float:shootRate_mult;
	GetGuardianStats(type, health, shootRate_mult);

	static uid = 1;	
	new gid = FCNPC_Create(F:0("%i:????", uid++));

	if(gid == INVALID_PLAYER_ID) {
		return 0;
	}

	FCNPC_Spawn(gid, skin, x, y, z);
	FCNPC_SetWeapon(gid, weapon);
	FCNPC_SetAmmo(gid, 1000);
	FCNPC_ToggleInfiniteAmmo(gid, true);

	SetPlayerMaxHealth(gid, health);
	UpdatePlayerHealth(gid, health, true);

	Guardian[gid][guardLevel] = type;
	Guardian[gid][currentState] = GUARDIAN_STATE_AFK;
	Guardian[gid][currentTarget] = INVALID_PLAYER_ID;
	Guardian[gid][latestState] = GUARDIAN_STATE_NONE;
	Guardian[gid][securedPoint][0] = 0.0;
	Guardian[gid][securedPoint][1] = 0.0;
	Guardian[gid][securedPoint][2] = 0.0;
	Guardian[gid][shootingTimer] = Timer:NONE;
	Guardian[gid][shootingRate] = floatround(shootRate_mult * GetWeaponShootRate(weapon));

	Iter_Add(Guardians, gid);

	return gid;
}

RemoveGuardian(gid) {
	ResetToLastState(gid);
	Iter_Remove(Guardians, gid);
	FCNPC_Destroy(gid);
}

GetGuardianLevel(gid) {
	return Guardian[gid][guardLevel];
}

SetGuardianPoint(gid, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0) {
	if(x || y || z) {
		Guardian[gid][securedPoint][0] = x;
		Guardian[gid][securedPoint][1] = y;
		Guardian[gid][securedPoint][2] = z;
	}
	else {
		x = Guardian[gid][securedPoint][0];
		y = Guardian[gid][securedPoint][1];
		z = Guardian[gid][securedPoint][2];
	}
	new Float:offsetX = floatrandom(15) - floatrandom(15);
	new Float:offsetY = floatrandom(15) - floatrandom(15);

	static Float:X, Float:Y, Float:Z;
	FCNPC_GetPosition(gid, X, Y, Z);
	PathFinder_FindWay(gid, X, Y, x + offsetX, y + offsetY, .stepLimit = MAX_STEPS);
}

public OnPathCalculated(routeid, success, Float:nodesX[], Float:nodesY[], Float:nodesZ[], nodesSize) {
	if(success && nodesSize) {
		for(new i; i < nodesSize && i < MAX_STEPS; ++i) {
			node[routeid][i][0] = nodesX[i];
			node[routeid][i][1] = nodesY[i];
			node[routeid][i][2] = nodesZ[i];
		}
		SetCurrentNode(routeid, 0);
		SetNodesCount(routeid, nodesSize);
		SetState(routeid, GUARDIAN_STATE_WALKING);
	}
	else {
		// calculate again
		SetGuardianPoint(routeid);
	}
	return 1;
}

static gotoNextNode(gid) {
	new nodeid = GetCurrentNode(gid);
	if(nodeid < GetNodesCount(gid)) {
		new Float:x, Float:y, Float:z;
		GetPoint(gid, x, y, z);
		FCNPC_GoTo(gid, x, y, z + 0.5, MOVE_TYPE_WALK, 0.0, false);
		SetCurrentNode(gid, nodeid + 1);
	}
	else {
		SetGuardianPoint(gid);
	}
}

timer RemoveBody[3000](gid) {
	Iter_Remove(Guardians, gid);
	FCNPC_Destroy(gid);
	// todo: drop loot
}

timer CheckGuardians[1000]() {
	foreach(new i : Guardians) {
		switch(GetState(i)) {
			case GUARDIAN_STATE_AFK: {
				searchForTarget(i);
			}
			case GUARDIAN_STATE_WALKING: {
				if(searchForTarget(i)) {
					gotoNextNode(i);
				}
			}
			case GUARDIAN_STATE_SHOOTING: {
				attackTarget(i);
			}
		}
	}
}


timer processShoot[300](gid) {
	static Float:x, Float:y, Float:z;
	static Float:x2, Float:y2, Float:z2;
	GetPlayerPos(GetTarget(gid), x, y, z);
	FCNPC_GetPosition(gid, x2, y2, z2);

	if(IsPlayerInRangeOfPoint(GetTarget(gid), 35.0, x2, y2, z2)) {
		if(FCNPC_AimAt(gid, x, y, z, false)) {
			if(IsPlayerInRangeOfPoint(GetTarget(gid), 20.0, x2, y2, z2)) {
				static const Float:ACCURACY = 0.8;
				SendBulletData(gid, GetTarget(gid), BULLET_HIT_TYPE_PLAYER, FCNPC_GetWeapon(gid), x2, y2, z2, x, y, z, floatrandom(ACCURACY)-floatrandom(ACCURACY), floatrandom(ACCURACY)-floatrandom(ACCURACY), floatrandom(ACCURACY)-floatrandom(ACCURACY));
			}
			else {
				searchForTarget(gid);
			}
		}
		else {
			ResetToLastState(gid);
		}
	}
	else {
		ResetToLastState(gid);
	}
}

static GetGuardianStats(type, &Float:health, &Float:shootRate_mult) {
	switch(type) {
		case GUARDIAN_TYPE_MARK_WAYNE: {
			health = 50.0;
			shootRate_mult = 3.0;
		}
		case GUARDIAN_TYPE_VERY_WEAK: {
			health = 100.0;
			shootRate_mult = 2.5;
		}
		case GUARDIAN_TYPE_WEAK: {
			health = 200.0;
			shootRate_mult = 2.0;
		}
		case GUARDIAN_TYPE_NORMAL: {
			health = 400.0;
			shootRate_mult = 1.5;
		}
		case GUARDIAN_TYPE_STRONG: {
			health = 800.0;
			shootRate_mult = 1.0;
		}
		case GUARDIAN_TYPE_VERY_STRONG: {
			health = 2000.0;
			shootRate_mult = 0.6;
		}
	}
}

static searchForTarget(gid) {
	static Float:x, Float:y, Float:z;
	FCNPC_GetPosition(gid, x, y, z);

	foreach(new i : Player) {
		if(GetTarget(gid) == i) {
			continue;
		}
		if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z)) {
			static Float:tx, Float:ty, Float:tz;
			GetPlayerPos(i, tx, ty, tz);

			if(CA_RayCastLine(x, y, z, tx, ty, tz, tx, ty, tz)) {
				continue;
			}
			if(call OnGuardianDetectTarget(gid, i)) {
				attackTarget(gid, i);
				return false;
			}
		}
	}
	return true;
}


static attackTarget(gid, target = NONE) {
	if(target != NONE) {
		if(FCNPC_IsMoving(gid)) {
			FCNPC_Stop(gid);
		}
		SetState(gid, GUARDIAN_STATE_SHOOTING);
		SetTarget(gid, target);

		new interval = GetShootingRate(gid);

		SetShootingTimer(gid, repeat processShoot[interval](gid));
	}
	else if((target = GetTarget(gid)) != INVALID_PLAYER_ID) {
		static Float:x, Float:y, Float:z;
		FCNPC_GetPosition(gid, x, y, z);

		if( ! IsPlayerInRangeOfPoint(target, 30.0, x, y, z)) {
			ResetToLastState(gid);
		}
	}
}

static GetPoint(gid, &Float:x, &Float:y, &Float:z) {
	x = node[gid][GetCurrentNode(gid)][0];
	y = node[gid][GetCurrentNode(gid)][1];
	z = node[gid][GetCurrentNode(gid)][2];
}
static ResetTarget(gid) {
	Guardian[gid][currentTarget] = INVALID_PLAYER_ID;
}
static SetTarget(gid, targetid) {
	Guardian[gid][currentTarget] = targetid;
}
static GetTarget(gid) {
	return Guardian[gid][currentTarget];
}
static GetCurrentNode(gid) {
	return Guardian[gid][currentNode];
}
static SetCurrentNode(gid, nodeid) {
	Guardian[gid][currentNode] = nodeid;
}
static GetNodesCount(gid) {
	return Guardian[gid][nodesCount];
}
static SetNodesCount(gid, count) {
	Guardian[gid][nodesCount] = count;
}
static ResetToLastState(gid) {
	if(GetState(gid) == GUARDIAN_STATE_SHOOTING) {
		SetShootingTimer(gid, Timer:NONE);
		FCNPC_StopAim(gid);
	}
	Guardian[gid][currentState] = Guardian[gid][latestState];
}
static SetState(gid, stateid) {
	Guardian[gid][latestState] = Guardian[gid][currentState];
	Guardian[gid][currentState] = stateid;
}
static GetState(gid) {
	return Guardian[gid][currentState];
}
static GetLastState(gid) {
	return Guardian[gid][latestState];
}
static GetShootingRate(gid) {
	return Guardian[gid][shootingRate];
}
static SetShootingTimer(gid, Timer:timerid) {
	if(Guardian[gid][shootingTimer] != Timer:NONE) {
		stop Guardian[gid][shootingTimer];
	}
	Guardian[gid][shootingTimer] = timerid;
}