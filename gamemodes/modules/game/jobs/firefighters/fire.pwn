#include <YSI\y_hooks>

#define MAX_FIRES 100

new fire_Obj[MAX_FIRES];
new Text3D:fire_Text[MAX_FIRES];
new fire_Health[MAX_FIRES];
new fire_Area[MAX_FIRES];

new Float:fire_X[MAX_FIRES];
new Float:fire_Y[MAX_FIRES];
new Float:fire_Z[MAX_FIRES];

new fire_Counter[MAX_FIRES];
new fire_Evolve[MAX_FIRES];

new Iterator:fire_Iter<MAX_FIRES>;

static check[MAX_PLAYERS char];
static onfire[MAX_PLAYERS char];

#define fire       18691
#define fire_med   18688
#define fire_large 18692

CMD:fire(playerid, health[]) {
	static Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return CreateFire(x,y,z, strval(health));
}

GetFireModel(fireid) {
	switch(fire_Health[fireid]) {
		case 0..200: {
			return fire;
		}
		case 201..500: {
			return fire_med;
		}
	}
	return fire_large;
}

GetFireName(fireid) {
	new name[32];
	switch(GetFireModel(fireid)) {
		case fire: name = "Silpna";
		case fire_med: name = "Vidutinë";
		case fire_large: name = "Stipri";
	}
	return name;
}

CreateFire(Float:x, Float:y, Float:z, health = 300) {
	new fireid = Iter_Free(fire_Iter);

	if(fireid < 0) {
		return false;
	}

	z -= 1.0;

	fire_X[fireid] = x;
	fire_Y[fireid] = y;
	fire_Z[fireid] = z;

	fire_Health[fireid] = health;

	fire_Counter[fireid] = 0;
	fire_Evolve[fireid] = 0;

	fire_Area[fireid] = CreateDynamicSphere(x, y, z, 5);

	new model = GetFireModel(fireid);

	fire_Obj[fireid] = CreateObject(model, x, y, z, 0, 0, 0, 200.0);

	new text[100];
	format(text, _, "{ff0000}%s {ff9932}ugnis\nUgnies stiprumas: {ff0000}%i", GetFireName(fireid), fire_Health[fireid]);
	fire_Text[fireid] = CreateDynamic3DTextLabel(text, 0xFF0000FF, x, y, z + 1.2, 30.0, .testlos = 1, .streamdistance = 50.0);

	Iter_Add(fire_Iter, fireid);

	return true;
}

DeleteFire(fireid, saferemove = false) {
	DestroyObject(fire_Obj[fireid]);
	DestroyDynamic3DTextLabel(fire_Text[fireid]);
	DestroyDynamicArea(fire_Area[fireid]);

	static next;
	if(saferemove) {
		Iter_SafeRemove(fire_Iter, fireid, next);
	}
	else {
		Iter_Remove(fire_Iter, fireid);
	}
	return next;
}

AimingAtFire(playerid, fireid) {
	if(GetPlayerCameraTargetObject(playerid) == fire_Obj[fireid]) {
		return true;
	}
	else { // Just to be sure
		new Float:x, Float:y, Float:z;
		GetPlayerCameraPos(playerid, x, y, z);

	    new Float:length = VectorSize(x-fire_X[fireid], y-fire_Y[fireid], z-fire_Z[fireid]);

	    new Float:vx, Float:vy, Float:vz;
	    GetPlayerCameraFrontVector(playerid, vx, vy, vz);

	    new Float:tx, Float:ty, Float:tz;
	    tx = x + vx * length;
	    ty = y + vy * length;
	    tz = z + vz * length;

	    return VectorSize(tx - fire_X[fireid], ty - fire_Y[fireid], tz - fire_Z[fireid]) < 2.0;
	}
}

UpdateFire(fireid) {
	new text[100];
	format(text, _, "{ff0000}%s {ff9932}ugnis\nUgnies stiprumas: {ff0000}%i", GetFireName(fireid), fire_Health[fireid]);

	UpdateDynamic3DTextLabelText(fire_Text[fireid], 0xFF0000FF, text);
}

ptask OnFireBaby[300](playerid) {
	if(onfire{playerid} > 0) {
		M:P:X(playerid, "InflictDamage %f", -6.4 * onfire{playerid});
		InflictDamage(playerid, -6.4 * onfire{playerid}, INVALID_PLAYER_ID, WEAPON_FLAMETHROWER, 3);
		UpdatePlayerHealth(playerid);
	}
}

task MoreFire[2000]() {
	foreach(new fireid : fire_Iter) {
		if(fire_Evolve[fireid] != fire_large) {
			new old_model = GetFireModel(fireid);

			fire_Health[fireid] += 50 + random(15);
			if(GetFireModel(fireid) != fire_large || fire_Health[fireid] > 3500) {
				fire_Evolve[fireid] = GetFireModel(fireid);
			}

			if(old_model != GetFireModel(fireid)) {
				DestroyObject(fire_Obj[fireid]);
				fire_Obj[fireid] = CreateObject(GetFireModel(fireid), fire_X[fireid], fire_Y[fireid], fire_Z[fireid], 0, 0, 0, 200.0);
			}
		}
		if( ! random(20) && fire_Counter[fireid]++ < 2) {
			new Float:fx, Float:fy, Float:fz;
			fx = fire_X[fireid] + floatrandom(2.5) - floatrandom(2.5);
			fy = fire_Y[fireid] + floatrandom(2.5) - floatrandom(2.5);

			CA_FindZ_For2DCoord(fx, fy, fz);

			CreateFire(fx, fy, fz, 200);
		}
		UpdateFire(fireid);
	}
}

task CleanUp[537]() {
	foreach(new i : fire_Iter) {
		static old_model;
		old_model = GetFireModel(i);

		if(fire_Evolve[i] == fire_large && (fire_Health[i] -= 7) <= 0) {
			i = DeleteFire(i, .saferemove = true);
		}
		else {
			UpdateFire(i);

			static new_model;
			new_model = GetFireModel(i);

			if(old_model != new_model) {
				DestroyObject(fire_Obj[i]);
				fire_Obj[i] = CreateObject(new_model, fire_X[i], fire_Y[i], fire_Z[i], 0, 0, 0, 200.0);
			}
		}
	}
}

hook OnVehicleDeath(vehicleid, killerid) {
	new Float:x, Float:y, Float:z;
	GetVehiclePos(vehicleid, x, y, z);

	CA_FindZ_For2DCoord(x, y, z);

	if(z != 0.0) {
		CreateFire(x, y, z);
	}
}

hook OnResetPlayerVars(playerid) {
	check{playerid} = false;
	onfire{playerid} = false;
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	foreach(new i : fire_Iter) {
		if(fire_Area[i] == areaid) {
			onfire{playerid}++;
		}
	}
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
	foreach(new i : fire_Iter) {
		if(fire_Area[i] == areaid) {
			onfire{playerid}--;
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys & KEY_FIRE) {
		check{playerid} = true;
	}
	else {
		check{playerid} = false;
	}
}

hook OnPlayerUpdate(playerid) {
	if(check{playerid}) {
		static keys, unused, tick;
		GetPlayerKeys(playerid, keys, unused, unused);

		if(tick + 200 > GetTickCount()) {
			return;
		}
		tick = GetTickCount();

		if(keys & KEY_FIRE) {
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
				// Firetruck
				if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 407) {
					foreach(new i : fire_Iter) {
						if(AimingAtFire(playerid, i)) {
							if((fire_Health[i] -= 61) <= 0) {
								DeleteFire(i);
								call OnPlayerExtinguishFire(playerid);
							}
							else {
								fire_Evolve[i] = fire_large;
								UpdateFire(i);
								Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
							}
							// leidþiam gesinti keletà deganèiø vietø vienu metu
							// break
						}
					}
				}
			}
			else {
				if(GetPlayerWeapon(playerid) == WEAPON_FIREEXTINGUISHER) {
					foreach(new i : fire_Iter) {
						if(AimingAtFire(playerid, i)) {
							if((fire_Health[i] -= 17) <= 0) {
								DeleteFire(i);
								call OnPlayerExtinguishFire(playerid);
							}
							else {
								fire_Evolve[i] = fire_large;
								UpdateFire(i);
								Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
							}
							// leidþiam gesinti keletà deganèiø vietø vienu metu
							// break
						}
					}
				}
			}
		}
	}
}

#undef fire
#undef fire_med
#undef fire_large