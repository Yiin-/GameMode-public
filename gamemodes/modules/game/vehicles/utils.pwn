#include <YSI_Coding\y_hooks>

hook OnCharacterDespawn(playerid) {
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		vehicle_Driver[GetPlayerVehicleID(playerid)] = INVALID_VEHICLE_ID;
		Iter_Remove(Driver, playerid);
	}
}

hook OnPlayerDeathFinished(playerid, bool:cancelable) {
	if( ! cancelable) {
		if(Iter_Contains(Driver, playerid)) {
			Iter_Remove(Driver, playerid);
		}
	}
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if(oldstate == PLAYER_STATE_DRIVER) {
		vehicle_Driver[player_LastVehicle[playerid]] = INVALID_PLAYER_ID;
		Iter_Remove(Driver, playerid);
	}
	if(newstate == PLAYER_STATE_DRIVER) {
		vehicle_Driver[GetPlayerVehicleID(playerid)] = playerid;
		Iter_Add(Driver, playerid);
	}
}

vehicle_FindEmptySeat(vehicleid) {
	if( ! IsValidVehicle(vehicleid)) {
		return false;
	}
	new const seats = vehicle_MaxSeats[GetVehicleModel(vehicleid) - 400];
	if(seats < 2) {
		return false;
	}

	new 
		its_okay = false,
		freeseat;

	while( ! its_okay) {
		its_okay = true;
		++freeseat;

		foreach(new i : Character) {
			if(IsPlayerNPC(i)) {
				#if defined _FCNPC_included
				if(FCNPC_GetVehicleID(i) == vehicleid) {
					if(FCNPC_GetVehicleSeat(i) == freeseat) {
						its_okay = false;
					}
				}
				#endif
			}
			else if(GetPlayerVehicleID(i) == vehicleid) {
				if(GetPlayerVehicleSeat(i) == freeseat) {
					its_okay = false;
				}
			}
		}
	}

	if(its_okay && freeseat < seats){
		return freeseat;
	}

	return false;
}

stock SetPlayerSpeed(playerid, Float:speed)
{
	if(speed < 6 || IsFloatNan(speed)) return;
	//  DEBUG: M:P:E(playerid, F:0("speed %f", speed));

	static Float:vX, Float:vY, Float:vZ, vehicleid;
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		vehicleid = GetPlayerLastVehicle(playerid);
		GetVehicleVelocity(vehicleid, vX, vY, vZ);

	} else {

		GetPlayerVelocity(playerid, vX, vY, vZ);
	}
	new Float:proc = speed / GetPlayerSpeed(playerid);
	//  DEBUG: M:P:E(playerid, F:0("proc %f", proc));
	if(IsFloatNan(proc)) return;

	vX *= proc;
	vY *= proc;
	vZ *= proc;
	
	//  DEBUG: M:P:E(playerid, F:0("vX %f vY %f vZ %f", vX, vY, vZ));
	
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetVehicleVelocity(vehicleid, vX, vY, vZ);

	} else {

		SetPlayerVelocity(vehicleid, vX, vY, vZ);
	}
	// DEBUG: M:P:I(playerid, F:0("Greièio skirtumas: %f", floatabs(GetPlayerSpeed(playerid, vX, vY, vZ) - speed)));
}

stock IsVehicleDrivingBackwards(vehicleid)
{
	new
		Float:Float[3]
	;
	if(GetVehicleVelocity(vehicleid, Float[1], Float[2], Float[0]))
	{
		GetVehicleZAngle(vehicleid, Float[0]);
		if(Float[0] < 90)
		{
			if(Float[1] > 0 && Float[2] < 0) return true;
		}
		else if(Float[0] < 180)
		{
			if(Float[1] > 0 && Float[2] > 0) return true;
		}
		else if(Float[0] < 270)
		{
			if(Float[1] < 0 && Float[2] > 0) return true;
		}
		else if(Float[1] < 0 && Float[2] < 0) return true;
	}
	return false;
}