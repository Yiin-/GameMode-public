#include <YSI\y_hooks>

hook OnPermissionCheck(playerid, entity[], node[], child_node[], entity_id) {
	if(strcmp(entity, "House")) {
		return true;
	}
	if(isnull(node)) {
		if(GetHouseOwner(entity_id) == GetPlayerCharID(playerid)) {
			return true;
		}
		if(GetHouseTenant(entity_id) == GetPlayerCharID(playerid)) {
			return true;
		}
	}
	else {
		if( ! strcmp(node, "lock")) {
			switch(GetHouseState(entity_id)) {
				case E_HOUSE_STATE_FORRENT: {
					return false;
				}
				case E_HOUSE_STATE_FORSALE: {
					return false;
				}
				case E_HOUSE_STATE_OCCUPIED: {
					if(GetHouseOwner(entity_id) == GetPlayerCharID(playerid)) {
						return true;
					}
				}
				case E_HOUSE_STATE_RENTED: {
					if(GetHouseOwner(entity_id) == GetPlayerCharID(playerid)) {
						return true;
					}
					if(GetHouseTenant(entity_id) == GetPlayerCharID(playerid)) {
						return true;
					}
				}
			}
		}
		if( ! strcmp(node, "enter")) {
			switch(GetHouseState(entity_id)) {
				case E_HOUSE_STATE_FORRENT: {
					return true;
				}
				case E_HOUSE_STATE_FORSALE: {
					return true;
				}
				case E_HOUSE_STATE_OCCUPIED: {
					if(GetHouseOwner(entity_id) == GetPlayerCharID(playerid)) {
						return true;
					}
				}
				case E_HOUSE_STATE_RENTED: {
					if(GetHouseOwner(entity_id) == GetPlayerCharID(playerid)) {
						return true;
					}
					if(GetHouseTenant(entity_id) == GetPlayerCharID(playerid)) {
						return true;
					}
				}
			}
		}
	}
	return false;
}