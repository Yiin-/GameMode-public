#include <YSI_Coding\y_hooks>

#define MAX_VEHICLE_TIRE_DAMAGE 6000.0
#define MAX_VEHICLE_BRAKES_DAMAGE 10000.0
#define MAX_UPGRADE_LEVEL 10

#define KEY_BRAKE (32)
#define KEY_ACCELERATE (8)

// The speed will be multiplied by this value
#define SPEED_MULTIPLIER 1.05

// The speed will only be increased if velocity is larger than this value
#define SPEED_THRESHOLD  0.4

new const
	KEY_VEHICLE_FORWARD  = 0b001000,
	KEY_VEHICLE_BACKWARD = 0b100000
;

forward Float:vehicle_RealMaxSpeed(vehicleid);

enum _:eVehicleErrorStates
{
	eVehicleErrorState_Brakes, // PERFECTLY
	eVehicleErrorState_Fuel,
	eVehicleErrorState_Plug,
	eVehicleErrorState_Tire[4] // PERFECTLY
};

enum _:eVehicleUpgrades
{
	eVehicleUpgrade_Engine, // PERFECTLY
	eVehicleUpgrade_Brakes, // PERFECTLY
	eVehicleUpgrade_Fuel,
	eVehicleUpgrade_Body, // PERFECTLY
	eVehicleUpgrade_Acc // PERFECTLY
};

new
	// Maðinos gedimai, kurie yra iðsaugojami
	vehicle_ErrorState[MAX_VEHICLES][eVehicleErrorStates],

	// Maðinos patobulinimai
	vehicle_Upgrades[MAX_VEHICLES][eVehicleUpgrades],

	// Maðinos suduþusios dalys
	vehicle_DamageStatus[MAX_VEHICLES][4],

	// Ar maðina driftina?
	vehicle_Drifting[MAX_VEHICLES]
;

IsVehicleDrifting(vehicleid) {
	return vehicle_Drifting[vehicleid];
}

hook OnCreateVehicleORM(ORM:ormid, vehicleid) {
	orm_addvar_int(ormid, vehicle_Upgrades[vehicleid][eVehicleUpgrade_Engine], "upgrdEngine");
	orm_addvar_int(ormid, vehicle_Upgrades[vehicleid][eVehicleUpgrade_Brakes], "upgrdBrakes");
	orm_addvar_int(ormid, vehicle_Upgrades[vehicleid][eVehicleUpgrade_Fuel], "upgrdFuel");
	orm_addvar_int(ormid, vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body], "upgrdBody");
	orm_addvar_int(ormid, vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc], "upgrdAcc");

	orm_addvar_int(ormid, vehicle_ErrorState[vehicleid][eVehicleErrorState_Brakes], "errBrakes");
	orm_addvar_int(ormid, vehicle_ErrorState[vehicleid][eVehicleErrorState_Fuel], "errFuel");
	orm_addvar_int(ormid, vehicle_ErrorState[vehicleid][eVehicleErrorState_Plug], "errPlug");
	orm_addvar_int(ormid, vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0], "errTire0");
	orm_addvar_int(ormid, vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][1], "errTire1");
	orm_addvar_int(ormid, vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2], "errTire2");
	orm_addvar_int(ormid, vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][3], "errTire3");
}

GetPlayerLastVehicle(playerid) {
	return player_LastVehicle[playerid];
}

CMD:getmaxspeed(playerid, params[]) {
	return M:P:X(playerid, "Maðinos maksimalus greitis: %f", vehicle_RealMaxSpeed(GetPlayerVehicleID(playerid)));
}

CMD:debugcar(playerid, params[]) {
	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid == INVALID_VEHICLE_ID) return true;

	M:P:G(playerid, "Upgrades");
	M:P:X(playerid, "eVehicleUpgrade_Engine = %i", vehicle_Upgrades[vehicleid][eVehicleUpgrade_Engine]);
	M:P:X(playerid, "eVehicleUpgrade_Brakes = %i", vehicle_Upgrades[vehicleid][eVehicleUpgrade_Brakes]);
	M:P:X(playerid, "eVehicleUpgrade_Fuel = %i", vehicle_Upgrades[vehicleid][eVehicleUpgrade_Fuel]);
	M:P:X(playerid, "eVehicleUpgrade_Body = %i", vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body]);
	M:P:X(playerid, "eVehicleUpgrade_Acc = %i", vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc]);

	M:P:G(playerid, "Errors");
	M:P:X(playerid, "eVehicleErrorState_Brakes = %i", vehicle_ErrorState[vehicleid][eVehicleErrorState_Brakes]);
	M:P:X(playerid, "eVehicleErrorState_Fuel = %i", vehicle_ErrorState[vehicleid][eVehicleErrorState_Fuel]);
	M:P:X(playerid, "eVehicleErrorState_Plug = %i", vehicle_ErrorState[vehicleid][eVehicleErrorState_Plug]);
	M:P:X(playerid, "eVehicleErrorState_Tire[0] = %i", vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0]);
	M:P:X(playerid, "eVehicleErrorState_Tire[1] = %i", vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][1]);
	M:P:X(playerid, "eVehicleErrorState_Tire[2] = %i", vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2]);
	M:P:X(playerid, "eVehicleErrorState_Tire[3] = %i", vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][3]);

	return true;
}

GetVehiclePoints(vehicleid) {
	new points;
	
	points += vehicle_Upgrades[vehicleid][eVehicleUpgrade_Engine] * 3; // max 30 (10)
	points += vehicle_Upgrades[vehicleid][eVehicleUpgrade_Brakes] * 2; // max 30 (15)
	points += vehicle_Upgrades[vehicleid][eVehicleUpgrade_Fuel] * 2; // max 20 (10)
	points += vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body] * 5; // max 50 (10)
	points += vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc] * 3; // max 21 (7)

	new Float:health; GetVehicleHealth(vehicleid, health);
	points -= floatround((1000.0 - health) / 20); // max -30
	points -= vehicle_ErrorState[vehicleid][eVehicleErrorState_Brakes] / 500; // max -20
	points -= vehicle_ErrorState[vehicleid][eVehicleErrorState_Fuel];
	points -= vehicle_ErrorState[vehicleid][eVehicleErrorState_Plug];
	points -= vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0] / 1000; // max -6
	points -= vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][1] / 1000; // max -6
	points -= vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2] / 1000; // max -6
	points -= vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][3] / 1000; // max -6 // total - 24

	return points;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if(newstate == PLAYER_STATE_DRIVER) {
		player_LastVehicle[playerid] = GetPlayerVehicleID(playerid);
	}
}

hook OnPlayerUpdate(playerid) {
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		new vehicleid = player_LastVehicle[playerid];

		if(vehicleid != INVALID_VEHICLE_ID) {
			static keys, ud, lr;
			GetPlayerKeys(playerid, keys, ud, lr);

			if(keys & KEY_FIRE) {
				return true;
			}

			static Float:old_vel[MAX_PLAYERS] = {-1000.0, ...};

			static HP_VEHICLE[MAX_PLAYERS];
			static Float:HP_OLD[MAX_PLAYERS] = {-FLOAT_INFINITY, ...};

			if(HP_VEHICLE[playerid] == vehicleid) {
				if(vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body]) {
					vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body] = clamp(vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body], 0, 10);
					new Float:HP_NEW; GetVehicleHealth(vehicleid, HP_NEW);
					if(HP_OLD[playerid] > HP_NEW) {
						new Float:HP_DIFF = HP_OLD[playerid] - HP_NEW;
						new Float:LVL = float(vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body]);
						new Float:repaired = LVL * HP_DIFF * 0.09;

						// IT'S SCIENCE, BITCH!
						HP_OLD[playerid] = HP_NEW + repaired;

						// M:P:X(playerid, "Þala: [number]%f[], nauja þala: [number]%f[], hp: [number]%f", HP_DIFF, HP_DIFF - repaired, HP_OLD[playerid]);

						SetVehicleHealth(vehicleid, HP_OLD[playerid]);
					
					} else {

						HP_OLD[playerid] = HP_NEW;
					}
				}
			
			} else {

				HP_VEHICLE[playerid] = vehicleid;
				GetVehicleHealth(vehicleid, HP_OLD[playerid]);
			}

			new const Float:current_vel = GetPlayerSpeed(playerid);
			
			static panels, doors, lights, tires;
			GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

			if(tires != 0b1111)
			{
				if(current_vel > 50)
				{
					if(keys & KEY_HANDBRAKE || keys & KEY_BRAKE)
					{
						if( ! (tires & 1))
						{
							if(++vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0] >= MAX_VEHICLE_TIRE_DAMAGE)
							{
								tires |= 1;
								UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
							}
						
						} else {

							if(vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0] < MAX_VEHICLE_TIRE_DAMAGE)
							{
								vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0] = floatround(MAX_VEHICLE_TIRE_DAMAGE);
							}
						}
						if( ! (tires & 4))
						{
							if(++vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2] >= MAX_VEHICLE_TIRE_DAMAGE)
							{
								tires |= 4;
								UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
							}

						} else {

							if(vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2] < MAX_VEHICLE_TIRE_DAMAGE)
							{
								vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2] = floatround(MAX_VEHICLE_TIRE_DAMAGE);
							}
						}
					}
				}
				static Float:vX, Float:vY, Float:vZ; GetVehicleVelocity(vehicleid, vX, vY, vZ);

				//new Float:nvY = vY / VectorSize(vX, vY, vZ);

				new Float:velocity_direction;

				if( ! vX)
					velocity_direction = 0.0;
				else
					velocity_direction = atan(vY / vX) + 90.0;

				if(velocity_direction < 0.0) velocity_direction += 90.0;

				if(vX > 0)
				{
					velocity_direction += 180.0;
				}

				static Float:vehicle_direction; GetVehicleZAngle(vehicleid, vehicle_direction);

				if(floatabs(velocity_direction - vehicle_direction) < 180.0)
				{
					// GADINASI KAIRËS PADANGOS
					if(velocity_direction + 5 < vehicle_direction)
					{
						if( ! (tires & 4))
						{
							if(++vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2] >= MAX_VEHICLE_TIRE_DAMAGE)
							{
								tires |= 4;
								UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
							}
						}
						if( ! (tires & 8))
						{
							if((vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][3] += 2) >= MAX_VEHICLE_TIRE_DAMAGE)
							{
								tires |= 8;
								UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
							}
						}
					}
					// GADINASI DEÐINËS PADANGOS
					if(velocity_direction - 5 > vehicle_direction)
					{
						if( ! (tires & 1))
						{
							if(++vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0] >= MAX_VEHICLE_TIRE_DAMAGE)
							{
								tires |= 1;
								UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
							}
						}
						if( ! (tires & 2))
						{
							if((vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][1] += 2) >= MAX_VEHICLE_TIRE_DAMAGE)
							{
								tires |= 2;
								UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
							}
						}
					}
				}
				#if defined GAL_KADANORS_PRIREIKS

				@	new lol[4];
				@	lol[0] = vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][0];
				@	lol[1] = vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][1];
				@	lol[2] = vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][2];
				@	lol[3] = vehicle_ErrorState[vehicleid][eVehicleErrorState_Tire][3];
				
				@	M:P:X(playerid, "tires: front: %i-%i rear: %i-%i", lol[3], lol[1], lol[2], lol[0]);


				#endif

				new Float:abs = floatabs(vehicle_direction - velocity_direction);
				
				if( ! IsFloatNan(velocity_direction) 
					&& (7.0 < abs && abs < 180.0 )
					&& !IsVehicleDrivingBackwards(vehicleid)
					&& current_vel > 15.0
				) {
				    //InsertDebugLine("Drift's on! Velocity direction diff: %.3f, speed: %.1f", abs, current_vel);
				    vehicle_Drifting[vehicleid] = true;
				
				} else {
				
					if(vehicle_Drifting[vehicleid]) {
					    //InsertDebugLine("-----");
					    vehicle_Drifting[vehicleid] = false;
					}
				}
			}

			if(old_vel[playerid] != -1000.0)
			{
				if(old_vel[playerid] > current_vel)
				{
					if(keys & KEY_HANDBRAKE || (keys & KEY_BRAKE && ! IsVehicleDrivingBackwards(vehicleid)))// && !(keys & KEY_ACCELERATE))
					{
						new Float:speed = 
						(
							current_vel + 
							(
								(
									old_vel[playerid] - current_vel

								) * (

									vehicle_ErrorState[vehicleid][eVehicleErrorState_Brakes] / 15000.0
								)

							) + (

								(
									(
										1

									) - (

										0.008 * vehicle_Upgrades[vehicleid][eVehicleUpgrade_Brakes]
									)

								) * (

									current_vel
								)
							)

						) / 2;

						if( ! IsFloatNan(speed))
						{
							if(! lr) { // dël samp sync, trûkèioja maðina vos vos, bet labai jauèiasi jeigu maðina sukasi
								SetPlayerSpeed(playerid, speed);
							}
						
						} else {

							M:P:E(playerid, "SERVER MATH ERROR: Blogas greièio apskaièiavimas. Praneðti adminstracijai, turëti nuotraukà!");
						}

						if(vehicle_ErrorState[vehicleid][eVehicleErrorState_Brakes] < MAX_VEHICLE_BRAKES_DAMAGE)
						{
							enum tick_data
							{
								tick_count,
								tick_amount
							};
							static last_tick[MAX_VEHICLES][tick_data];

							if(last_tick[vehicleid][tick_count] + 150 > GetTickCount())
							{
								if(GetPlayerSpeed(playerid) > 30)
								{
									if(last_tick[vehicleid][tick_amount] < 15)
									{
										last_tick[vehicleid][tick_amount]++;
									}
									vehicle_ErrorState[vehicleid][eVehicleErrorState_Brakes] += last_tick[vehicleid][tick_amount];
								}
							
							} else {

								last_tick[vehicleid][tick_amount] = 0;
							}
							last_tick[vehicleid][tick_count] = GetTickCount();
						}
					}
				}
			}
			old_vel[playerid] = current_vel;

			if(keys & KEY_VEHICLE_FORWARD 
				&& ! vehicle_InAir(vehicleid) 
				&& ! IsVehicleDrivingBackwards(vehicleid)
				&& vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc]) 
			{
				new	Float:vx, Float:vy, Float:vz, Float:velocity_direction;
				GetVehicleVelocity(vehicleid, vx, vy, vz);

				// Get velocity_direction (angle by degrees)
				if(vx) {
					velocity_direction = atan(vy / vx) + 90.0;
					if(vx > 0) {
						velocity_direction += 180.0;
					}
					if(velocity_direction < 0.0) {
						velocity_direction += 90.0;
					}
				}
				
				new Float:z_angle;
				GetVehicleZAngle(vehicleid, z_angle);

				z_angle += 90.0;

				if(5 < floatabs(z_angle - velocity_direction) < 70) {
					new Float:size = VectorSize(vx, vy, 0.0);

					if(size >= 1) {
						new Float:front_vx = floatcos(z_angle, degrees) * size * (1 + vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc] * 0.0021);
						new Float:front_vy = floatsin(z_angle, degrees) * size * (1 + vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc] * 0.0021);

						vx += front_vx;
						vy += front_vy;

						new Float:mult_result = VectorSize(vx, vy, 0.0);

						vx *= size / mult_result * 0.7;
						vy *= size / mult_result * 0.7;

						// new Float:new_vx = floatcos(velocity_direction, degrees) * size;
						// new Float:new_vy = floatsin(velocity_direction, degrees) * size;

						SetVehicleVelocity(vehicleid, vx, vy, (vz > 0.04 || vz < -0.04) ? (vz - 0.02) : vz);
					}
				}
			}
		}
	}
	return true;
}

hook OnGameModeInit() {
	
	SetTimer("SpeedUp", 220, true);
	
	// Cache this value for speed
	// This can not be done during compilation because of a limitation with float values
	//g_SpeedThreshold = SPEED_THRESHOLD * SPEED_THRESHOLD;
}

forward SpeedUp();
public SpeedUp() {
	static
		vehicleid,
		keys,
		lr,
		Float:vx,
		Float:vy,
		Float:vz
	;
	
	// Loop all players
	foreach(new playerid : Driver)
	{		
		// Store the value from GetPlayerVehicleID and continue if it's not 0
		if ((vehicleid = GetPlayerVehicleID(playerid)) != INVALID_VEHICLE_ID && vehicleid)
		{
			if(IsVehicleDrivingBackwards(vehicleid)) {
				continue;
			}
			// Get the player keys (vx is used here because we don't need updown/leftright)
			GetPlayerKeys(playerid, keys, _:vx, lr);

			if(keys & KEY_FIRE) {
				continue;
			}

			new Float:currentSpeed = GetPlayerSpeed(playerid);
			
			// If KEY_VEHICLE_FORWARD is pressed, but not KEY_VEHICLE_BACKWARD or KEY_HANDBRAKE.
			if ((keys & (KEY_VEHICLE_FORWARD | KEY_VEHICLE_BACKWARD | KEY_HANDBRAKE)) == KEY_VEHICLE_FORWARD)
			{
				// Get the velocity
				GetVehicleVelocity(vehicleid, vx, vy, vz);

				static Float:H; GetVehicleHealth(vehicleid, H);

				new model = GetVehicleModel(vehicleid);
				new bool:apply_velocity = false;

				/*
				 * Greitinam maðinà uþ jos orginaliø maksimalaus greièio ribø
				 * jeigu maðinos variklis yra patobulintas
				 */
				if (//vx * vx + vy * vy < g_SpeedThreshold ||
					vehicle_Upgrades[vehicleid][eVehicleUpgrade_Engine]
					&&
					vehicle_Speed[model - 400] - 20
						<=
					currentSpeed 
					&&
					currentSpeed
						<
					vehicle_RealMaxSpeed(vehicleid)
				){
					apply_velocity = true;
					/*
					 * Increase the X and Y velocity
					 * Jeigu þaidëjas suka maðinà á ðonà, maksimalaus greièio nedidinti, kad maðina neiðslystø ið kelio
					 * instead padidinam tik pusæ
					 */
					new const Float:mult = SPEED_MULTIPLIER - (lr ? ((SPEED_MULTIPLIER - 1.0) * 0.5) : 0.0);
					vx *= mult;
					vy *= mult;
				}
				else {
					/*
					 * Greitinam maðinà jos ásibegëjimo bûsenoje
					 * jeigu maðinoje yra patobulinta akseleracija
					 */
					if(vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc]
						&&
						! IsVehicleDrifting(vehicleid)
						&&
						1 < currentSpeed < vehicle_RealMaxSpeed(vehicleid) * 0.7 // jeigu maðina pasiekë 70% maksimalaus greièio, nebedidinam akseleracijos
						&&
						! vehicle_InAir(vehicleid)
					){
						apply_velocity = true;

						new Float:mult = SPEED_MULTIPLIER;

						new Float:pls = 1.0 + (0.0021 * vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc]);

						new Float:work = fclamp(vehicle_RealMaxSpeed(vehicleid) * 0.4 / currentSpeed, 1.0, 2.5);

						mult *= (pls * work);

						if(lr) {
							mult = 1 + (mult - 1) * 0.5;
						}
						
						vx *= mult;
						vy *= mult;
					}
					else if(currentSpeed > vehicle_RealMaxSpeed(vehicleid) + 30.0) {
						#if !defined player_HideInfoText
							player_ShowInfoText(playerid, "Virsijai maksimalu masinos greiti.");
						#endif
					}
					else if(currentSpeed > vehicle_RealMaxSpeed(vehicleid)) {
						SetPlayerSpeed(playerid, vehicle_RealMaxSpeed(vehicleid) - 2.0);
					}
				}
				if(apply_velocity) { // ............................
					// Increase the Z velocity to make up for lost gravity, if needed.
					if (vz > 0.04 || vz < -0.04)
						vz -= 0.020;

					// Now set it
					SetVehicleVelocity(vehicleid, vx, vy, vz);
				}
			}
		}
	}
}

public Float:vehicle_RealMaxSpeed(vehicleid) {
	new Float:H; GetVehicleHealth(vehicleid, H);
	return vehicle_Speed[GetVehicleModel(vehicleid) - 400] * min(H / 770.0, 1.0) + vehicle_Upgrades[vehicleid][eVehicleUpgrade_Engine] * 12;
}

stock vehicle_GetInfo(vehicleid, infotype, &Float:X, &Float:Y, &Float:Z, moreinfo = 0, bool:sampid = true)
{
	if(! sampid) vehicleid = vehicleid;

	if( ! IsValidVehicle(vehicleid)) return 0;

	new Float:x2, Float:y2, Float:z2, Float:a;

	GetVehicleModelInfo(GetVehicleModel(vehicleid), infotype, x2, y2 ,z2);
	/*
		switch(moreinfo)
		{
			case VEHICLE_MODEL_INFO_REAR:
			{
				y2 *= -1/2;
			}
			case VEHICLE_MODEL_INFO_FRONT:
			{
				y2 *= 1/2;
			}
		}
	*/
	GetVehiclePos(vehicleid, X, Z, Z);  
	GetVehicleZAngle(vehicleid,a);

	Z += z2;

	X += (y2 * floatsin(-a, degrees));
	Y += (y2 * floatcos(-a, degrees));

	a += 270.0;
	X += (x2 * floatsin(-a, degrees));
	Y += (x2 * floatcos(-a, degrees));
	a -= 270.0;

	return 1;
}

vehicle_InAir(vehicleid) {
	static lastCheck[MAX_VEHICLES], lastResult[MAX_VEHICLES];
	if(lastCheck[vehicleid] + 1 < gettime()) {
		static Float:X, Float:Y, Float:Z, Float:getZ;
		GetVehiclePos(vehicleid, X, Y, Z);
		CA_FindZ_For2DCoord(X, Y, getZ);

		lastCheck[vehicleid] = gettime();

		return (lastResult[vehicleid] = (Z - 0.8 > getZ));
	}
	else {
		return lastResult[vehicleid];
	}
}

CMD:boostbody(pid,p[]) {
	new vehicleid = GetPlayerVehicleID(pid);
	if(vehicleid != INVALID_VEHICLE_ID) {
		vehicle_Upgrades[vehicleid][eVehicleUpgrade_Body] = strval(p);
	}
	return true;
}
CMD:boostbrakes(pid,p[]) {
	new vehicleid = GetPlayerVehicleID(pid);
	if(vehicleid != INVALID_VEHICLE_ID) {
		vehicle_Upgrades[vehicleid][eVehicleUpgrade_Brakes] = strval(p);
	}
	return true;
}
CMD:boostengine(pid,p[]) {
	new vehicleid = GetPlayerVehicleID(pid);
	if(vehicleid != INVALID_VEHICLE_ID) {
		vehicle_Upgrades[vehicleid][eVehicleUpgrade_Engine] = strval(p);
	}
	return true;
}
CMD:boostacc(pid,p[]) {
	new vehicleid = GetPlayerVehicleID(pid);
	if(vehicleid != INVALID_VEHICLE_ID) {
		vehicle_Upgrades[vehicleid][eVehicleUpgrade_Acc] = strval(p);
	}
	return true;
}

CMD:fuckmybrakes(pid, p[]) {
	new vehicleid = GetPlayerVehicleID(pid);
	if(vehicleid != INVALID_VEHICLE_ID) {
		vehicle_ErrorState[vehicleid][eVehicleErrorState_Brakes] = strval(p);
	}
	return true;
}