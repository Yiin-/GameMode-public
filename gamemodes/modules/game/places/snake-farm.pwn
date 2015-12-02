#include <YSI_Coding\y_hooks>

const guardians_count = 3;
static guardians[guardians_count];

static DropStuff(Float:x, Float:y, Float:z) {
	#pragma unused x, y, z
}

timer _snakeFarmNpc[1000](i) {
	new Float:x, Float:y, Float:z;
	x = -23.5921 + (floatrandom(15.0) - floatrandom(15.0));
	y = 2341.7852 + (floatrandom(15.0) - floatrandom(15.0));
	z = 24.1406;
	new gid = CreateGuardian(GUARDIAN_TYPE_STRONG, x, y, z, 33, WEAPON_SHOTGUN);
	SetGuardianPoint(gid, -23.5921,2341.7852,24.1406);

	guardians[i] = gid;
}

hook OnGameModeInit() {
	for(new i; i < guardians_count; ++i) {
		defer _snakeFarmNpc[i * 1000](i);
	}
}

hook OnPlayerDeath(playerid) {
	if(IsPlayerNPC(playerid)) {
		for(new i; i < guardians_count; ++i) {
			if(guardians[i] == playerid) {
				new Float:x, Float:y, Float:z;
				FCNPC_GetPosition(playerid, x, y, z);
				DropStuff(x, y, z);
			}
			return;
		}
	}
}