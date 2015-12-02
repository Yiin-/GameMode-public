#include <YSI_Coding\y_hooks>

static Item:currentSelectedItem[MAX_PLAYERS];
static searchingForAmmo[MAX_PLAYERS char];
static searchingForWeapon[MAX_PLAYERS char];

IsSearchingForItem(playerid) {
	return searchingForAmmo{playerid} || searchingForWeapon{playerid};
}

hook OnResetPlayerVars(playerid) {
	searchingForAmmo{playerid} = false;
	searchingForWeapon{playerid} = false;
	currentSelectedItem[playerid] = Item:0;
}

hook OnInventoryClose(playerid) {
	searchingForAmmo{playerid} = false;
	searchingForWeapon{playerid} = false;
	currentSelectedItem[playerid] = Item:0;
}

hook OnGenerateItemInfo(Item:item) {
	new item_name[32];
	GetItemName(item, item_name);

	switch(GetItemDefaultType(item_name)) {
		case Ammo: {
			new Item:weapon;
			if((weapon = GetItemInfo_OtherItem(item, "weapon"))) {
				new weapon_name[32];
				GetItemName(weapon, weapon_name);
				dialogAddLine("Uþtaisytos ginkle\t%s", weapon_name);
			}
		}
		case Weapon: {
			new Item:ammo;
			if((ammo = GetItemInfo_OtherItem(item, "ammo"))) {
				new ammo_name[32];
				GetItemName(ammo, ammo_name);
				dialogAddLine("Uþtaisytos kulkos\t%s (%i)", ammo_name, GetItemInfo(ammo, "count"));
			}
		}
	}
}

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {
	static Item:weapon, Item:ammo;

	weapon = Equipment_GetItemInSlot(playerid, Slot_RightHand);

	if(weapon != Item:NONE && weapon) {
		ammo = GetItemInfo_OtherItem(weapon, "ammo");
		if(ammo) {
			if(AdjustItemInfo(ammo, "count", -1) <= 0) {
				DeleteItem(ammo);
				SetItemInfo_OtherItem(weapon, "ammo", Item:0);
				ResetPlayerWeapons(playerid);
			}
		}
		else {
			M:P:E(playerid, "Neturi ammo, kick");
		}
	}
	else {
		M:P:E(playerid, "Neturi ginklo, kick");
	}
	return true;
}

hook OnPlayerSelectItem(playerid, item_name[], Item:uiid) {
	switch(GetItemDefaultType(item_name)) {
		case Weapon: {
			return true;
		}
		case Ammo: {
			if(searchingForAmmo{playerid}) {
				return true;
			}
		}
	}
	return false;
}

hook OnPlayerUseItem(playerid, item_name[], Item:uiid) {
	switch(GetItemDefaultType(item_name)) {
		// pasirinkom ginklà
		case Weapon: {
			if(searchingForWeapon{playerid}) {
				M:P:D(playerid, "OnPlayerUseItem: Weapon");

				searchingForWeapon{playerid} = false;

				// kulkos kurias norim dëti á ðá ginklà
				new Item:ammo = currentSelectedItem[playerid];

				// kulkos galbût jau esanèios ginkle
				new Item:other_ammo = GetItemInfo_OtherItem(uiid, "ammo");

				M:P:D(playerid, "searchingForWeapon: weapon: %i, ammo: %i, old_ammo: %i", _:uiid, _:ammo, _:other_ammo);

				if(other_ammo) {
					// iðimam senas kulkas lauk
					SetItemInfo_OtherItem(other_ammo, "weapon", Item:0);
				}
				// ádedam naujas
				SetItemInfo_OtherItem(uiid, "ammo", ammo);
				SetItemInfo_OtherItem(ammo, "weapon", uiid);

				M:P:G(playerid, "Kulkos sëkmingai ádëtos á ginklà!");

				if(IsItemOnPlayer(playerid, uiid)) {
					ResetPlayerWeapons(playerid);
					GivePlayerWeapon(playerid, GetWeaponByModel(GetItemDefaultModel(item_name)), GetItemInfo(ammo, "count"));
				}
			}
			return true;
		}
		// pasirinkom kulkas
		case Ammo: {
			if(searchingForAmmo{playerid}) {
				M:P:D(playerid, "OnPlayerUseItem: Ammo");

				searchingForAmmo{playerid} = false;

				// ginklas á kurá norim dëti pasirinktas kulkas
				new Item:weapon = currentSelectedItem[playerid];

				// kulkos galbût jau esanèios ginkle
				new Item:ammo = GetItemInfo_OtherItem(weapon, "ammo");

				M:P:D(playerid, "searchingForAmmo: ammo: %i, weapon: %i, current_ammo: %i", _:uiid, _:weapon, _:ammo);

				if(ammo) {
					// iðimam senas kulkas
					SetItemInfo_OtherItem(ammo, "weapon", Item:0);
				}
				// ádedam naujas
				SetItemInfo_OtherItem(weapon, "ammo", uiid);
				SetItemInfo_OtherItem(uiid, "weapon", weapon);

				M:P:G(playerid, "Kulkos sëkmingai pakeistos!");

				if(IsItemOnPlayer(playerid, weapon)) {
					ResetPlayerWeapons(playerid);

					new weapon_name[32];
					GetItemName(weapon, weapon_name);
					GivePlayerWeapon(playerid, GetWeaponByModel(GetItemDefaultModel(weapon_name)), GetItemInfo(uiid, "count"));
				}

				Inv_Update(playerid);

				return true;
			}
		}
	}
	return false;
}

hook OnSelectManagedItemMenu(playerid, item_name[], Item:uiid) {
	currentSelectedItem[playerid] = uiid;

	switch(GetItemDefaultType(item_name)) {
		case Ammo: {
			dialog_Row("Iðimti ið ginklo") {
				new Item:weapon = GetItemInfo_OtherItem(uiid, "weapon");

				if(weapon) {
					SetItemInfo_OtherItem(uiid, "weapon", Item:0);
					SetItemInfo_OtherItem(weapon, "ammo", Item:0);
					M:P:G(playerid, "Kulkos iðimtos ið ginklo sëkmingai!");
				}
				if(IsItemOnPlayer(playerid, weapon)) {
					ResetPlayerWeapons(playerid);
				}
				Inv_Update(playerid);
			}
			dialog_Row("Ádëti á ginklà") {
				searchingForWeapon{playerid} = true;
				Inv_UnselectCurrentRow(playerid);

				M:P:I(playerid, "Pasirink á koká ginklà nori ádëti kulkas.");
			}
		}
		case Weapon: {
			dialog_Row("Pakeisti kulkas") {
				searchingForAmmo{playerid} = true;
				Inv_UnselectCurrentRow(playerid);

				M:P:I(playerid, "Pasirink kokias naujas kulkas nori ádëti á ginklà.");
			}
			dialog_Row("Iðimti kulkas") {
				new Item:ammo = GetItemInfo_OtherItem(uiid, "ammo");
				SetItemInfo_OtherItem(uiid, "ammo", Item:0);

				if(ammo) {
					SetItemInfo_OtherItem(ammo, "weapon", Item:0);
					M:P:G(playerid, "Kulkos iðimtos ið ginklo sëkmingai!");
				}
				if(IsItemOnPlayer(playerid, uiid)) {
					ResetPlayerWeapons(playerid);
				}
				Inv_Update(playerid);
			}
			dialog_Row("Ádëti kulkas") {
				searchingForAmmo{playerid} = true;
				Inv_UnselectCurrentRow(playerid);

				M:P:I(playerid, "Pasirink kokias kulkas nori ádëti á ginklà.");
			}
		}
	}
}
hook OnOpenManagedItemMenu(playerid, item_name[], Item:uiid) {
	switch(GetItemDefaultType(item_name)) {
		case Ammo: {
			new Item:weapon;
			if((weapon = GetItemInfo_OtherItem(uiid, "weapon"))) {
				new weapon_name[32];
				GetItemName(weapon, weapon_name);

				dialogAddOption("Iðimti ið ginklo (%s).", weapon_name);
			}
			else {
				dialogAddOption("Ádëti á ginklà.");
			}
		}
		case Weapon: {
			if(GetItemInfo_OtherItem(uiid, "ammo")) {
				dialogAddOption("Pakeisti kulkas.");
				dialogAddOption("Iðimti kulkas.");
			}
			else {
				dialogAddOption("Ádëti kulkas.");
			}
		}
	}
}