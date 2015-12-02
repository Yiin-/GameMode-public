#include <YSI_Coding\y_hooks>

hook OnGameModeInit() {
	FCNPC_InitZMap("SAfull.hmap");
}

/*
 *	Guardians
 */
 
 // Create
CMD:cg(playerid, params[]) {
	extract params -> new type, skin, weapon;
	new Float:x, Float:y, Float:z, gid;
	GetPlayerPos(playerid, x, y, z);

	if((gid = CreateGuardian(type, x, y, z, skin, weapon))) {
		M:P:G(playerid, "Sargybinis (id:[number]%i[]) sukurtas.", gid);
	}
	else {
		M:P:E(playerid, "Sargybinio sukurti nepavyko.");
	}

	return true;
}

 // Destroy
CMD:dg(playerid, params[]) {
	RemoveGuardian(strval(params));
	M:P:G(playerid, "Sargybinis panaikintas.");
	return true;
}

// Set Point
CMD:spg(playerid, params[]) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	SetGuardianPoint(strval(params), x, y, z);
	return true;
}

/*
 * NPCs
 */

CMD:create(playerid, npcname[]) {
	return M:P:X(playerid, "FCNPC_Create(%s) : %i", npcname, FCNPC_Create(npcname));
}

CMD:destroy(playerid, npcid[]) {
	return M:P:X(playerid, "FCNPC_Destroy(%i) : %i", strval(npcid), FCNPC_Destroy(strval(npcid)));
}

CMD:spawn(playerid, params[]) {
	new npcid, skinid, Float:x, Float:y, Float:z, Float:a;
	sscanf(params, "I(-1)I(-1)ffff", npcid, skinid, x, y, z, a);

	if(npcid == -1 || ! IsPlayerNPC(npcid)) {
		return M:P:E(playerid, "NPC neeagzisutoja");
	}
	if(skinid == -1) {
		skinid = random(311) + 1;
	}
	if( ! (x && y && z)) {
		GetPlayerPos(playerid, x, y, z);
	}
	if( ! a) {
		GetPlayerFacingAngle(playerid, a);
	}
	return M:P:X(playerid, "FCNPC_Spawn(%i, %i, %f, %f, %f)", npcid, skinid, x, y, z, FCNPC_Spawn(npcid, skinid, x, y, z));
}

CMD:respawn(playerid, npcid[]) {
	return M:P:X(playerid, "FCNPC_Respawn(%i) : %i", strval(npcid), FCNPC_Respawn(strval(npcid)));
}

CMD:isspawned(playerid, npcid[]) {
	return M:P:X(playerid, "FCNPC_IsSpawned(%i) : %i", strval(npcid), FCNPC_IsSpawned(strval(npcid)));
}

CMD:kill(playerid, npcid[]) {
	return M:P:X(playerid, "FCNPC_Kill(%i) : %i", strval(npcid), FCNPC_Kill(strval(npcid)));
}

CMD:isdead(playerid, npcid[]) {
	return M:P:X(playerid, "FCNPC_IsDead(%i) : %i", strval(npcid), FCNPC_IsDead(strval(npcid)));
}

CMD:givegun(playerid, params[]) {
	extract params -> new npcid, wepid, ammo;
	if(IsPlayerNPC(npcid)) {
		FCNPC_SetWeapon(npcid, wepid);
		FCNPC_SetAmmo(npcid, ammo);
	}
	else {
		GivePlayerWeapon(npcid, wepid, ammo);
	}
	return true;
}

new Timer:shootingNpcTimer[MAX_PLAYERS];

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart) {
	if(IsPlayerNPC(damagedid) && ! FCNPC_IsDead(damagedid)) {
		new Float:new_health = FCNPC_GetHealth(damagedid) - amount;
		FCNPC_SetHealth(damagedid, new_health);
		if(new_health <= 0.0) {
			FCNPC_Kill(damagedid);
			M:P:X(playerid, "Nuþudei NPC");
		}
	}
	return true;
}

timer processShots[300](npcid, playerid) {
	if(!IsPlayerNPC(npcid)) {
		stop shootingNpcTimer[npcid];
	}
	new weaponid = FCNPC_GetWeapon(npcid);
	if(FCNPC_IsAiming(npcid)) {
		static Float:x, Float:y, Float:z;
		static Float:x2, Float:y2, Float:z2;
		GetPlayerPos(playerid, x, y, z);
		FCNPC_GetPosition(npcid, x2, y2, z2);

		if(FCNPC_AimAt(npcid, x, y, z, true)) {
			SendBulletData(npcid, playerid, BULLET_HIT_TYPE_PLAYER, weaponid, x2, y2, z2, x, y, z, floatrandom(0.8)-floatrandom(0.8), floatrandom(0.8)-floatrandom(0.8), floatrandom(0.8)-floatrandom(0.8));
		}
		else {
			M:P:E(playerid, "NPC can't aim there");
		}
	}
	else {
		M:P:E(playerid, "NPC isn't aiming");
	}
}

CMD:shootatme(playerid, params[]) {
	new Float:x, Float:y, Float:z, npcid = strval(params);
	GetPlayerPos(playerid, x, y, z);

	new ret = FCNPC_AimAt(npcid, x, y, z, true);
	if(ret) {
		new shootrate;
		if((shootrate = GetWeaponShootRate(FCNPC_GetWeapon(npcid)))) {
			shootingNpcTimer[npcid] = repeat processShots[shootrate](npcid, playerid);
		}
		else {
			M:P:E(playerid, "shootrate: %i, weaponid: %i", shootrate, FCNPC_GetWeapon(npcid));
		}
	}
	return M:P:X(playerid, "FCNPC_AimAt(%i, %f, %f, %f, true) : %i", npcid, x, y, z, ret);
}

CMD:stopshooting(playerid, npcid[]) {
	new ret = FCNPC_StopAim(strval(npcid));
	if(ret) {
		stop shootingNpcTimer[strval(npcid)];
	}
	return M:P:X(playerid, "FCNPC_StopAim(%i) : %i", strval(npcid), ret);
}

CMD:comehere(playerid, npcid[]) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return M:P:X(playerid, "FCNPC_GoTo(%i, %f, %f, %f, MOVE_TYPE_RUN, 0.0, true) : %i", strval(npcid), x, y, z, FCNPC_GoTo(strval(npcid), x, y, z, MOVE_TYPE_RUN, 0.0, true));
}

CMD:stopmoving(playerid, npcid[]) {
	return M:P:X(playerid, "FCNPC_Stop(%i) : %i", strval(npcid), FCNPC_Stop(strval(npcid)));
}

CMD:sithere(playerid, npcid[]) {
	new vehicleid = GetPlayerVehicleID(playerid);
	new seat = vehicle_FindEmptySeat(vehicleid);
	return M:P:X(playerid, "FCNPC_EnterVehicle(%i, %i, %i, MOVE_TYPE_WALK) : %i", strval(npcid), vehicleid, seat, MOVE_TYPE_WALK, FCNPC_EnterVehicle(strval(npcid), vehicleid, seat, MOVE_TYPE_WALK));
}

CMD:exitvehicle(playerid, npcid[]) {
	return M:P:X(playerid, "FCNPC_ExitVehicle(%i) : %i", strval(npcid), FCNPC_ExitVehicle(strval(npcid)));
}

public FCNPC_OnCreate(npcid) {
	return M:P:I(0, "FCNPC_OnCreate(%i)", npcid);
}
public FCNPC_OnSpawn(npcid) {
	FCNPC_ToggleReloading(npcid, true);
	FCNPC_ToggleInfiniteAmmo(npcid, true);
	return M:P:I(0, "FCNPC_OnSpawn(%i)", npcid);
}
public FCNPC_OnRespawn(npcid) {
	return M:P:I(0, "FCNPC_OnRespawn(%i)", npcid);
}
public FCNPC_OnDeath(npcid, killerid, weaponid) {
	return M:P:I(0, "FCNPC_OnDeath(%i, %i, %i)", npcid, killerid, weaponid);
}
public FCNPC_OnVehicleEntryComplete(npcid, vehicleid, seat) {
	return M:P:I(0, "FCNPC_OnVehicleEntryComplete(%i, %i, %i)", npcid, vehicleid, seat);
}
public FCNPC_OnVehicleExitComplete(npcid) {
	return M:P:I(0, "FCNPC_OnVehicleExitComplete(%i)", npcid);
}
public FCNPC_OnReachDestination(npcid) {
	return M:P:I(0, "FCNPC_OnReachDestination(%i)", npcid);
}
public FCNPC_OnFinishPlayback(npcid) {
	return M:P:I(0, "FCNPC_OnFinishPlayback(%i)", npcid);
}