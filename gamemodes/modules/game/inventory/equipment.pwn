#include <YSI\y_hooks>

forward OnPlayerEquipItem(playerid, item_name[], Item:uiid);
forward Item:Equipment_GetItemInSlot(playerid, slot);

new Equipment = UNIQUE_SYMBOL;

new Item:EquipmentSlots[MAX_PLAYERS][E_EQUIPMENT_SLOTS];

hook OnResetPlayerVars(playerid) {
	memset(_:EquipmentSlots[playerid], NONE);
}

hook OnInventoryLoaded(playerid) {
	new filename[32];
	format(filename, _, "%i_%s", GetPlayerCharID(playerid), player_Name[playerid]);
	Container_Load(Equipment, playerid, "scriptfiles/equipment", filename);
}

hook OnPlayerDeathFinished(playerid, bool:cancelable) {
	if( ! cancelable) {
		TakeOffItems(playerid);
	}
}

hook OnPlayerSpawn(playerid) {
	ReEquipItems(playerid);
}

hook OnCharacterDespawn(playerid) {
	new filename[32];
	format(filename, _, "%i_%s", GetPlayerCharID(playerid), player_Name[playerid]);
	Container_Save(Equipment, playerid, "scriptfiles/equipment", filename);

	TakeOffItems(playerid);

	Container_Clear(Equipment, playerid);
}

hook OnPlayerUseItem(playerid, item_name[], Item:uiid) {
	M:P:X(playerid, "OnPlayerUseItem: %i, %s, %i", playerid, item_name, _:uiid);
	
	if( ! IsSearchingForItem(playerid)) {
		if(IsItemOnPlayer(playerid, uiid)) {
			TakeOffItem(playerid, uiid);
		}
		else {
			EquipItem(playerid, uiid);
		}
	}
}

Item:Equipment_GetItemInSlot(playerid, slot) {
	return EquipmentSlots[playerid][slot];
}

static GetDefaultSlot(Item:item) {
	static item_name[32];
	GetItemName(item, item_name);
	return GetItemDefaultEquipmentSlot(item_name);
}

ReEquipItems(playerid) {
	foreach(new i : Container(Equipment, playerid)) {
		EquipItem(playerid, Item:i, .already_equiped = true);
	}
}

HasItemEquiped(playerid, item_name[]) {
	return Container_HasItem(Equipment, playerid, item_name);
}

IsItemOnPlayer(playerid, Item:uiid) {
	return Container_GetItemSlot(Equipment, playerid, uiid) != NONE;
}

EquipItem(playerid, Item:item, slot = NONE, bool:already_equiped = false) {
	if(slot == NONE) {
		slot = GetDefaultSlot(item);
	}
	if(slot == Slot_None) {
		return;
	}

	M:P:X(playerid, "EquipItem: playerid %i, item %i, slot %i, already_equiped %i", playerid, _:item, slot, _:already_equiped);

	new Item:prev_item;

	if( ! already_equiped) {
		TakeOffItem(playerid, (prev_item = Equipment_GetItemInSlot(playerid, slot)));

		Container_AddItem(Equipment, playerid, item);
		
		SetItemInfo(item, "equipment_slot", slot);
	}

	new item_name[32];
	GetItemName(item, item_name);

	if(call OnPlayerEquipItem(playerid, item_name, _:item)) {
		EquipmentSlots[playerid][slot] = item;
	}
	else {
		if(prev_item != Item:NONE && prev_item) {
			EquipItem(playerid, prev_item, slot);
		}
		else {
			TakeOffItem(playerid, item);
		}
	}

	if(IsInventoryOpen(playerid)) {
		Inv_Update(playerid);
	}
}

TakeOffItems(playerid) {
	foreach(new i : Container(Equipment, playerid)) {
		TakeOffItem(playerid, Item:i, .just_call = true);
	}
}

TakeOffItem(playerid, Item:item = Item:NONE, slot = NONE, just_call = false) {
	M:P:X(playerid, "TakeOffItem: playerid %i, item %i, slot %i, just_call %i", playerid, _:item, slot, just_call);

	new item_name[32];
	if(slot != NONE) {
		item = Equipment_GetItemInSlot(playerid, slot);
	}
	if(item != Item:NONE && item) {
		if(IsItemOnPlayer(playerid, item)) {
			GetItemName(item, item_name);

			if(slot == NONE) {
				slot = GetItemDefaultEquipmentSlot(item_name);
			}
			if( ! just_call) {
				Container_RemoveItem(Equipment, playerid, item);
				Container_AddItem(Player, playerid, item);
				DeleteItemInfo(item, "equipment_slot");
				EquipmentSlots[playerid][slot] = Item:NONE;
			}

			call OnPlayerTakeOffItem(playerid, item_name, _:item);
		}
	}
	if(IsInventoryOpen(playerid)) {
		Inv_Update(playerid);
	}
}

hook OnPlayerEquipItem(playerid, item_name[], Item:item) {
	M:P:X(playerid, "OnPlayerEquipItem: %i, %s, %i", playerid, item_name, _:item);
	return false;
}
hook OnPlayerTakeOffItem(playerid, item_name[], Item:item) {
	M:P:X(playerid, "OnPlayerTakeOffItem: %i, %s, %i", playerid, item_name, _:item);
	return false;
}