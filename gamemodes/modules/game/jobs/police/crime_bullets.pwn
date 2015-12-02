#include <YSI_Coding\y_hooks>

#define BULLET_OBJ_MODEL 19185
new const Bullets = UNIQUE_SYMBOL;

static Item:createBullet(Float:x, Float:y, Float:z, Float:max_offset, ownerid, weapon, hit = false) {
	x += floatrandom(max_offset) - floatrandom(max_offset);
	y += floatrandom(max_offset) - floatrandom(max_offset);

	new label_text[100];
	new Y, M, D, h, m, s;
	getdate(Y, M, D);
	gettime(h, m, s);
	format(label_text, sizeof label_text, 
		"[ %s ]\nIððovë: %s\nGinklas: %s\nLaikas: %i:%i:%i\n{aaaaaa}%i.%i.%i", 
		hit?("Iððauta kulka"):("Kulkos tûtelë"), player_Name[ownerid], ReturnWeaponName(weapon), h,m,s,Y,M,D);

	new Item:bullet = CreateItem(hit?("Issauta kulka"):("Kulkos likutis"));
	new object = CreateDynamicObjectEx(BULLET_OBJ_MODEL, x,y,z, 0,0,0, 20.0, 30.0, .maxplayers = 0);
	new Text3D:label = CreateDynamic3DTextLabelEx(label_text, -1, x, y, z, 10.0, .streamdistance = 15.0, .maxplayers = 0);

	SetItemInfo(bullet, "time_created", gettime());
	SetItemInfo(bullet, "unique_owner_id", char_ID[ownerid]);
	SetItemInfo(bullet, "object", object);
	SetItemInfo(bullet, "label", _:label);
	SetItemInfo(bullet, "weapon", weapon);

	Container_AddItem(World, Bullets, bullet);

	// rodom ðià kulkà visiems policininkams
	foreach(new i : Player) {
		if(player_Job[i] == JOB_POLICE) {
			Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, object, E_STREAMER_PLAYER_ID, i);
			Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, label, E_STREAMER_PLAYER_ID, i);
		}
	}

	return bullet;
}

static destroyBullet(Item:uiid, item_too = true) {
	DestroyDynamicObject(GetItemInfo(uiid, "object"));
	DestroyDynamic3DTextLabel(Text3D:GetItemInfo(uiid, "label"));

	if(item_too) {
		DeleteItem(uiid);
	}
}

CMD:isvalyti(playerid, params[]) {
	new cleanUp = false;
	
	for(new i, j = Container_CountItems(World, Bullets); i < j; ++i) {
		static Item:item; item = Container_GetItemAt(World, Bullets, i);
		static label; label = GetItemInfo(item, "label");
		if(Streamer_IsItemVisible(playerid, STREAMER_TYPE_3D_TEXT_LABEL, label)) {
			SetItemInfo(item, "time_created", 0);
			cleanUp = true;
		}
	}
	cleanUp && CleanUpBullets();
	return true;
}

task CleanUpBullets[2000]() {
	for(new i, j = Container_CountItems(World, Bullets); i < j; ++i) {
		static Item:item;
		if(GetItemInfo((item = Container_GetItemAt(World, Bullets, i)), 
			"time_created") + DURATION(15 minutes) < gettime()) 
		{
			destroyBullet(item);
		}
	}	
	foreach(new i : Player) {
		if(player_Job[i] == JOB_POLICE) {
			Streamer_Update(i, STREAMER_TYPE_OBJECT);
			Streamer_Update(i, STREAMER_TYPE_3D_TEXT_LABEL);
		}
	}
}

// kai þaidëjas ðauna á þaidëjà, paliekam kulkø likuèius abiejø þaidëjø vietose
hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart) {
	if(damagedid == INVALID_PLAYER_ID || (playerid == damagedid)) {
		return true;
	}
	#if defined _FCNPC_included
	if(Iter_Contains(Guardians, damagedid)) {
		return true;
	}
	#endif
	if( ! IsBulletWeapon(weaponid)) {
		return true;
	}
	// 25% tikimybë palikti ðûviø ákalèius
	new Float:x, Float:y, Float:z;
	if( ! random(4)) {
		GetPlayerPos(playerid, x, y, z);
		createBullet(x, y, z - 0.9, 2.0, playerid, weaponid);
	}
	if( ! random(4)) {
		GetPlayerPos(damagedid, x, y, z);
		createBullet(x, y, z - 0.9, 1.6, playerid, weaponid, true);
	}
	return true;
}

hook OnCharacterDespawn(playerid) {
	if(player_Job[playerid] == JOB_POLICE) {
		updateBullets(.remove = playerid);
	}
}

hook OnPlayerSpawn(playerid) {
	if(player_Job[playerid] == JOB_POLICE) {
		// jeigu jau yra pridëtas niekas nepasikeis
		updateBullets(.insert = playerid);
	}
}

hook OnPlayerLeftJob(playerid, job) {
	if(job == JOB_POLICE) {
		updateBullets(.remove = playerid);
	}
}

hook OnPlayerJoinJob(playerid, job) {
	if(job == JOB_POLICE) {
		updateBullets(.insert = playerid);
	}
}

updateBullets(insert = INVALID_PLAYER_ID, remove = INVALID_PLAYER_ID) {
	for(new x, n = Container_CountItems(World, Bullets); x < n; ++x) {
		static Item:item; item = Container_GetItemAt(World, Bullets, x);
		static object, label;
		object = GetItemInfo(item, "object");
		label = GetItemInfo(item, "label");
		if(insert != INVALID_PLAYER_ID) {
			Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, object, E_STREAMER_PLAYER_ID, insert);
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, label, E_STREAMER_PLAYER_ID, insert);
			Streamer_Update(insert, STREAMER_TYPE_OBJECT);
			Streamer_Update(insert, STREAMER_TYPE_3D_TEXT_LABEL);
		}
		if(remove != INVALID_PLAYER_ID) {
			Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, object, E_STREAMER_PLAYER_ID, remove);
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, label, E_STREAMER_PLAYER_ID, remove);
			Streamer_Update(remove, STREAMER_TYPE_OBJECT);
			Streamer_Update(remove, STREAMER_TYPE_3D_TEXT_LABEL);
		}
		if(insert == remove && remove == INVALID_PLAYER_ID) {
			foreach(new i : Player) {
				if(player_Job[i] == JOB_POLICE) {
					if( ! Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, object, E_STREAMER_PLAYER_ID, i)) {
						Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, object, E_STREAMER_PLAYER_ID, i);
						Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, label, E_STREAMER_PLAYER_ID, i);
						Streamer_Update(i, STREAMER_TYPE_OBJECT);
						Streamer_Update(i, STREAMER_TYPE_3D_TEXT_LABEL);
					}
				}
				else {
					if(Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, object, E_STREAMER_PLAYER_ID, i)) {
						Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, object, E_STREAMER_PLAYER_ID, i);
						Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, label, E_STREAMER_PLAYER_ID, i);
						Streamer_Update(i, STREAMER_TYPE_OBJECT);
						Streamer_Update(i, STREAMER_TYPE_3D_TEXT_LABEL);
					}
				}
			}
		}
	}
}