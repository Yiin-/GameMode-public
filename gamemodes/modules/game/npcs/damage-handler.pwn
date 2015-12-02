#include <YSI_Coding\y_hooks>

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart) {
	InsertDebugLine("OnPlayerGiveDamage: %i, %i, %f, %i, %i", playerid, damagedid, amount, weaponid, bodypart);
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {
	InsertDebugLine("OnPlayerTakeDamage: %i, %i, %f, %i, %i", playerid, issuerid, amount, weaponid, bodypart);
}

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {
	if(hittype == BULLET_HIT_TYPE_PLAYER) {
		if(IsPlayerNPC(hitid)) {
			//InsertDebugLine("OnNpcTakeDamge2: %i, %i, %i, %f", hitid, playerid, weaponid, GetWeaponDamage(weaponid));
			//UpdatePlayerHealth(hitid, -GetWeaponDamage(weaponid));
		}
	}
	return true;
}

hook OnNpcTakeDamage(npcid, damagerid, weaponid, bodypart, Float:health_loss) {
	P:1("damage-handler.pwn: OnNpcTakeDamage: %i, %i, %i, %i, %f", npcid, damagerid, weaponid, bodypart, health_loss);

	UpdatePlayerHealth(npcid, -health_loss);
	return true;
}

hook OnPlayerDeath(playerid) {
	if( ! IsPlayerNPC(playerid)) {
		return 0;
	}

	InsertDebugLine("OnPlayerDeath: NPC");
	return 1;
}