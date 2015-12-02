new Iterator:Driver<MAX_PLAYERS>;

forward ORM:CreateVehicleORM(vehicleid);
forward OnVehiclesLoad();
forward OnVehicleInsert(vehicleid);

enum {
	VEHICLE_STATUS_NONE,
	VEHICLE_STATUS_ACTIVE,
	VEHICLE_STATUS_GARAGE,
	VEHICLE_STATUS_FORSALE,
	VEHICLE_STATUS_TRANSPORT_STATE1, // sandëlyje
	VEHICLE_STATUS_TRANSPORT_STATE2, // fûroje
	VEHICLE_STATUS_WRECKED
};

enum {
	VEHICLE_OWNER_TYPE_NONE,
	VEHICLE_OWNER_TYPE_PLAYER,
	VEHICLE_OWNER_TYPE_JOB,
	VEHICLE_OWNER_TYPE_BUSINESS,
	VEHICLE_OWNER_TYPE_SHOP
};

enum
{
	eVehicle_Param_Engine,
	eVehicle_Param_Lights,
	eVehicle_Param_Alarm,
	eVehicle_Param_Doors,
	eVehicle_Param_Bonnet,
	eVehicle_Param_Boot,
	eVehicle_Param_Objective
};

new 
	ORM:vehicle_ORM[MAX_VEHICLES],
	vehicle_ID[MAX_VEHICLES],
	vehicle_Model[MAX_VEHICLES],
	vehicle_Driver[MAX_VEHICLES],
	vehicle_Plate[MAX_VEHICLES][8],
	vehicle_CreationTimestamp[MAX_VEHICLES],
	vehicle_Status[MAX_VEHICLES],
	vehicle_Price[MAX_VEHICLES],
	vehicle_Owner[MAX_VEHICLES],
	vehicle_OwnerType[MAX_VEHICLES],
	vehicle_FuelType[MAX_VEHICLES],
	vehicle_Color1[MAX_VEHICLES],
	vehicle_Color2[MAX_VEHICLES],
	vehicle_Params[MAX_VEHICLES],
	Float:vehicle_Health[MAX_VEHICLES],
	Float:vehicle_Fuel[MAX_VEHICLES],
	Float:vehicle_Run[MAX_VEHICLES],
	Float:vehicle_PosX[MAX_VEHICLES],
	Float:vehicle_PosY[MAX_VEHICLES],
	Float:vehicle_PosZ[MAX_VEHICLES],
	Float:vehicle_PosA[MAX_VEHICLES]
;

new const vehicle_MaxSeats[] = { // Vairuotojo vieta áskaièiuota
	4,2,2,2,4,4,1,2,2,4,2,2,2,4,2,2,4,2,4,2,4,4,2,2,2,1,4,4,4,2,1,9,1,2,2,1,2,9,4,2,
	4,1,2,2,2,4,1,2,1,6,1,2,1,1,1,2,2,2,4,4,2,2,2,2,2,2,4,4,2,2,4,2,1,1,2,2,1,2,2,4,
	2,1,4,3,1,1,1,4,2,2,4,2,4,1,2,2,2,4,4,2,2,2,2,2,2,2,2,4,2,1,1,2,1,1,2,2,4,2,2,1,
	1,2,2,2,2,2,2,2,2,4,1,1,1,2,2,2,2,0,0,1,4,2,2,2,2,2,4,4,2,2,4,4,2,1,2,2,2,2,2,2,
	4,4,2,2,1,2,4,4,1,0,0,1,1,2,1,2,2,2,2,4,4,2,4,1,1,4,2,2,2,2,6,1,2,2,2,1,4,4,4,2,
	2,2,2,2,4,2,1,1,1,4,1,1
};



new const vehicle_MaxFuel[212] = { // Ið sanFierro gm

	65,48,67,170,48,66,150,80,70,67,45,70,68,59,59,70,99,115,82,55,64,59,60,60,37,200,50,88,
	67,70,100,80,200,100,55,0,44,90,70,53,60,0,50, 112,100,50,200,110,35,0,0,70,90,90,90,83,
	66,20,60,60,115,40,30,35,0,0,65,65,30,80,57,20,100, 80,63,51,100,64,50,49,65,0,60,60,90,
	100,25,80,55,54,60,75,40,57,100, 80,90,40,80,80,70,50,0,70,70,62,60,70,40,72,0,0,100,90,
	90,90,90,41,55,55,500,300,35,40,40,80,55,60,48,60,45,20,20,50,40,45,55,60,100,100,15,40,
	70,45,80,40,45,48,100,52,50,58,55,200,47,44,90,90,58,70,70,64,70,111,0,59,55,62,40,0,90,
	20,15,80,25,57, 53,200,84,61,50,35,55,20,0,50,30,48, 65,43,0,0,200,99,0,101,65,65,65,65,
	41,78,52,66,53,47,0,0,0,64,0,0
};

new const vehicle_Name[][] =
{
	{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},{"Firetruck"},{"Trashmaster"},
	{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},{"Cheetah"},{"Mediku masina"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},
	{"Taksi"},{"Washington"},{"Bobcat"},{"Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},{"Banshee"},
	{"Predator"},{"Autobusas"},{"Tankas"},{"Barracks"},{"Hotknife"},{"Trailer"},{"Previon"},{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},
	{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer"},{"Turismo"},
	{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},{"Skimmer"},{"PCJ-600"},{"Faggio"},
	{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},
	{"Hermes"},{"Sabre"},{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},{"Baggage"},
	{"Dozer"},{"Sraigtrasparnis"},{"News Chopper"},{"Dzipas"},{"FBI Dzipas"},{"Virgo"},{"Greenwood"},{"Jetmax"},{"Hotring"},{"Sandking"},
	{"Blista Compact"},{"Policijos sraigtasparnis"},{"Boxville"},{"Benson"},{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"}, 
	{"Bloodring Banger"},{"Dzipas"},{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropduster"},{"Stunt"},
	{"Tanker"},{"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},{"Nrg500"},{"HPV1000"},{"Cement Truck"},
	{"Tempimo "},{"Fortune"},{"Cadrona"},{"FBI Truck"},{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},
	{"Slamvan"},{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},{"Gaisrine"},{"Hustler"},
	{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster"},
	{"Monster"},{"Uranus"},{"Jester"},{"Sultan"},{"Stratium"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},
	{"Bandito"},{"Freight Flat"},{"Streak Carriage"}, {"Kart"},{"Mower"},{"Dune"},{"Sweeper"},{"Broadway"},{"Tornado"},{"AT-400"},
	{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"News Van"},{"Tug"},{"Trailer"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},
	{"Freight Box"},{"Trailer"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Policijos masina"},{"Police masina"},{"Policijos masina"},
	{"Policijos dzipas"},{"Picador"},{"S.W.A.T"},{"Alpha"},{"Phoenix"},{"Glendale"},{"Sadler"},{"Luggage"},{"Luggage"},{"Stairs"},
	{"Boxville"},{"Tiller"},{"Priekaba"}
};

new const vehicle_Speed[] =
{
	150,141,176,108,128,156,108,142, 99,150,125,207,160,108,104,181,147,255,113,143,139,147,134,98,130,255,164,157,149,189,255,126,94,108,158,
	10,143,150,137,160,131,77,134,122,108,156,255,255,172,255,255,182,255,255,255,150,104, 94,150,131,255,190,115,190,255,255,141,135,174,255,
	149,108,255,255,143,164,255,176,115,134,174, 96,149,119,255,98,66,255,255,134,149,142,135,255,201,167,155,255,106,119,135,255,201,201,164,
	134,169,158,106,103,127, 255,255,255,117,136,150,150,156,255,255,200,210,182,126,153,150,143,167,143,64,72,108,158,160,150,164,255,255,99,
	146,190,156,144,142,141,143,137,255,146,138,150,118,255,138,151,108,108,149,168,160,147,168,255, 89,156,152,164,140,255,255, 93,64,108,63,
	150,150,255,126,150,146,180,131,86,255,146,185,157,106,155,255,255,255,255,64,255,166,166,166,150,144,108,160,162,141,144,255,255,255,106,
	255,255
};

new const vehicle_TrunkSize[] = { // Maðinø bagaþinës talpa kilogramais

	60,30,20,0,120,40,0,0,0,40,30,15,50,300,800,15,0,0,100,50,0,40,150,0,0,0,80,0,0,40,0,0,0,0,20,0,
	40,0,0,40,400,0,0,0,0,60,0,0,0,0,0,20,0,0,0,0,0,0,150,0,0,0,0,0,0,0,50,50,0,0,0,0,0,0,60,50,0,30,
	90,120,30,0,300,80,0,0,0,0,0,60,0,40,50,0,0,0,20,0,600,700,30,0,0,0,0,0,30,60,200,0,0,0,0,0,0,0,
	50,50,40,0,0,0,0,0,0,0,40,40,0,40,0,0,0,40,40,80,50,0,0,0,40,20,30,60,0,20,40,40,0,50,40,60,0,0,
	60,20,0,0,40,40,60,80,40,0,0,40,40,50,0,0,0,0,0,0,0,30,40,0,0,100,50,0,0,0,0,40,0,40,0,30,0,0,0,
	0,0,0,0,0,0,0,60,0,50,40,20,50,0,0,0,0,0,0
};

new const vehicle_GamePrice[] = { // Maðinø kaina þaidimo litais. Litø ~ vertë 1000:1

	30000,20000,80000,0,20000,40000,0,0,0,40000,30000,300000,30000,20000,30000,120000,0,0,25000,
	30000,0,40000,30000,0,30000,0,60000,0,0,100000,0,0,0,0,50000,0,30000,0,0,40000,30000,0,0,0,0,
	50000,0,0,0,0,0,150000,0,0,0,0,0,0,40000,0,0,0,0,0,0,0,40000,50000,0,0,0,0,0,0,30000,70000,0,
	50000,20000,40000,100000,0,25000,50000,0,0,0,0,0,40000,0,30000,60000,0,0,0,20000,0,40000,50000,
	30000,0,0,0,0,0,150000,50000,80000,0,0,0,0,0,0,0,40000,40000,40000,0,0,0,0,0,0,0,40000,40000,0,
	40000,0,0,0,50000,30000,70000,70000,0,0,0,50000,200000,30000,20000,0,40000,40000,40000,0,30000,
	30000,40000,0,0,40000,30000,0,0,50000,70000,100000,100000,150000,0,0,30000,40000,70000,0,0,0,0,
	0,0,0,30000,40000,0,0,80000,40000,0,0,0,0,40000,0,70000,0,40000,0,0,0,0,0,0,0,0,0,0,40000,0,50000,
	80000,10000,10000,0,0,0,0,0,0

};

new const vehicle_RealPrice[] = { // Maðinø kaina rubinais. Rubinø kaina 1:1 banku.
								  // Dabartinis santykis 2000:1
								  // Maðinos yra 2 kartus pigesnës negu turëtø bûti perkant uþ real litus
								  // reikia atnaujinti visas kainas *= 2

	15,10,40,0,10,20,0,0,0,20,15,150,15,10,15,60,0,0,13,15,0,20,15,0,15,0,30,0,0,50,0,0,0,0,
	25,0,15,0,0,20,15,0,0,0,0,25,0,0,0,0,0,75,0,0,0,0,0,0,20,0,0,0,0,0,0,0,20,25,0,0,0,0,0,
	0,15,35,0,25,10,20,50,0,13,25,0,0,0,0,0,20,0,15,30,0,0,0,10,0,20,25,15,0,0,0,0,0,75,25,
	40,0,0,0,0,0,0,0,20,20,20,0,0,0,0,0,0,0,20,20,0,20,0,0,0,25,15,35,35,0,0,0,25,100,15,10,
	0,20,20,20,0,15,15,20,0,0,20,15,0,0,25,35,50,50,75,0,0,15,20,35,0,0,0,0,0,0,0,15,20,0,0,
	40,20,0,0,0,0,20,0,35,0,20,0,0,0,0,0,0,0,0,0,0,20,0,25,40,5,5,0,0,0,0,0,0
};

new const vehicle_Weight[] = { // Maðinø svoris. Kilogramais

	1700,1300,1500,3800,1200,1600,20000,6500,5500,2200,1000,1400,1800,2600,3500,
	1200,2600,15000,2000,1800,1450,1850,1700,1700,1200,10000,1600,4000,7000,1400,
	2200,5500,25000,10500,1400,3800,1400,9500,1750,1600,2000,100,2500,8000,5000,
	1650,2200,3000,350,1900,3800,1400,2200,5000,2200,8500,4500,1000,2000,1900,
	5000,500,350,800,100,100,1600,1900,500,2500,2500,400,1200,800,1950,1700,
	5000,1400,1850,1500,1400,100,1900,1900,5000,1000,10000,5000,3500,2500,3500,
	1700,1600,3000,1600,2000,1000,4500,5500,3500,1300,100,1600,1600,2100,2500,
	1400,2200,3500,100,100,10000,5000,5000,3800,5000,1400,1400,1700,15000,9000,
	500,400,500,5500,3500,1700,1200,4000,1800,1000,2000,8500,1600,1800,1950,1500,
	5500,5500,1900,1800,1200,1600,1700,6500,1700,1800,1600,20000,1700,1600,1800,2600,
	25000,3000,1500,5000,5000,1400,1500,1400,1800,1500,10000,100,1400,1800,1500,1000,
	5500,5500,300,800,10000,800,1700,1700,60000,5500,2500,2200,500,1900,800,3800,
	1800,800,1400,5500,1400,5500,3800,40000,5000,100,2200,1600,1600,1600,2500,1600,
	5000,1500,1500,1600,1700,1000,1000,1000,5500,400,0
};

ORM:CreateVehicleORM(vehicleid) {
	new ORM:ormid = vehicle_ORM[vehicleid] = orm_create("vehicles");

	orm_addvar_int(ormid, vehicle_ID[vehicleid], "uid");
	orm_setkey(ormid, "uid");
	orm_addvar_int(ormid, vehicle_Owner[vehicleid], "owner");
	orm_addvar_int(ormid, vehicle_OwnerType[vehicleid], "owner_type");
	orm_addvar_int(ormid, vehicle_Model[vehicleid], "model");
	orm_addvar_int(ormid, vehicle_Status[vehicleid], "status");
	orm_addvar_int(ormid, vehicle_Price[vehicleid], "price");
	orm_addvar_int(ormid, vehicle_Color1[vehicleid], "color1");
	orm_addvar_int(ormid, vehicle_Color2[vehicleid], "color2");
	orm_addvar_int(ormid, vehicle_FuelType[vehicleid], "fuel_type");
	orm_addvar_string(ormid, vehicle_Plate[vehicleid], 8, "plate");
	orm_addvar_float(ormid, vehicle_Fuel[vehicleid], "fuel");
	orm_addvar_float(ormid, vehicle_Run[vehicleid], "run");
	orm_addvar_float(ormid, vehicle_PosX[vehicleid], "x");
	orm_addvar_float(ormid, vehicle_PosY[vehicleid], "y");
	orm_addvar_float(ormid, vehicle_PosZ[vehicleid], "z");
	orm_addvar_float(ormid, vehicle_PosA[vehicleid], "a");
	orm_addvar_int(ormid, vehicle_CreationTimestamp[vehicleid], "timestamp");

	call OnCreateVehicleORM(_:ormid, vehicleid);

	return ormid;
}

public OnVehiclesLoad() {
	new vehicleid = INVALID_VEHICLE_ID;
	new count = cache_num_rows();
	for(new r; r < count; ++r) {
		vehicleid = LoadVehicle(.row = r);
		#pragma unused vehicleid

		if(vehicle_OwnerType[vehicleid] == VEHICLE_OWNER_TYPE_JOB) {
			if( ! job_AddVehicle(vehicle_Owner[vehicleid], vehicleid)) {
				DeleteVehicle(vehicleid);
				return r;
			}
		}
	}
	return count;
}

public OnVehicleInsert(vehicleid) {
	M:P:X(0, "Maðina [id: [number]%i[], sqlid: [number]%i[], plate: [highlight]%s[]] sëkmingai áraðyta á duom. bazæ.", vehicleid, vehicle_ID[vehicleid], vehicle_Plate[vehicleid]);
}

hook OnVehicleDeath(vehicleid, killerid) {
	vehicle_Status[vehicleid] = VEHICLE_STATUS_WRECKED;

	if(vehicle_OwnerType[vehicleid] != VEHICLE_OWNER_TYPE_NONE) {
		SaveVehicle(vehicleid, .update_pos = false, .remove = true);
	}
	else {
		DeleteVehicle(vehicleid);
	}
}

ApplyVehicleData(vehicleid, setpos = true) {
	if(setpos) {
		ApplySavedVehiclePos(vehicleid);
	}
	ChangeVehicleColor(vehicleid, vehicle_Color1[vehicleid], vehicle_Color2[vehicleid]);
	SetVehicleNumberPlate(vehicleid, vehicle_Plate[vehicleid]);
}

AddVehicle(model, type, Float:x, Float:y, Float:z, Float:a, color1 = -1, color2 = -1, Float:fuel = 20.0, fuel_type = 0, plate[] = "", owner = 0) {
	new timestamp = gettime();
	new vehicleid = CreateVehicle(model, x, y, z, a, color1, color2, -1);
	if(vehicleid == INVALID_VEHICLE_ID) {
		return INVALID_VEHICLE_ID;
	}
	new ORM:ormid = CreateVehicleORM(vehicleid);

	vehicle_Model[vehicleid] = model;
	vehicle_Owner[vehicleid] = owner;
	vehicle_OwnerType[vehicleid] = type;
	vehicle_Color1[vehicleid] = color1;
	vehicle_Color2[vehicleid] = color2;
	vehicle_Fuel[vehicleid] = fuel;
	vehicle_FuelType[vehicleid] = fuel_type;
	vehicle_PosX[vehicleid] = x;
	vehicle_PosY[vehicleid] = y;
	vehicle_PosZ[vehicleid] = z;
	vehicle_PosA[vehicleid] = a;
	vehicle_CreationTimestamp[vehicleid] = timestamp;

	if(isnull(plate)) {
		#define R random // tikiuos nepasikartos (17'576'000 galimi variantai)
		format(vehicle_Plate[vehicleid], 8, "%i%i%i:%c%c%c", R(10), R(10), R(10), R(26) + 'A', R(26) + 'A', R(26) + 'A');
		#undef R
	}
	else {
		vehicle_Plate[vehicleid][0] = EOS;
		strcat(vehicle_Plate[vehicleid], plate);
	}
	ApplyVehicleData(vehicleid, .setpos = false);
	orm_insert(ormid, "OnVehicleInsert", "i", vehicleid);
	return vehicleid;
}

LoadVehicle(sqlid = -1, row = 0, applydata = true) {
	new Cache:cache;
	if(sqlid != -1) {
		format_query("SELECT * FROM vehicles WHERE uid = %i", sqlid);
		cache = mysql_query(database, query);
	}
	if( ! cache_get_row_count()) {
		return INVALID_VEHICLE_ID;
	}

	new model = cache_get_field_content_int(row, "model");
	new vehicleid = CreateVehicle(model, 0, 0, 0, 0, 0, 0, 0);

	new ORM:ormid = CreateVehicleORM(vehicleid);

	orm_apply_cache(ormid, row);

	if(applydata) {
		ApplyVehicleData(vehicleid);
	}

	if(sqlid != -1) {
		cache_delete(cache);
	}

	return vehicleid;
}

LoadVehicles(sqlid = -1, playerid = INVALID_PLAYER_ID, jobid = JOB_NONE) {
	if(sqlid != -1) {
		format_query("SELECT * FROM vehicles WHERE uid = %i", sqlid);
	}
	else if(playerid != INVALID_PLAYER_ID) {
		format_query("SELECT * FROM vehicles WHERE owner = %i AND owner_type = %i", char_ID[playerid], VEHICLE_OWNER_TYPE_PLAYER);
	}
	else if(jobid != JOB_NONE) {
		format_query("SELECT * FROM vehicles WHERE owner = %i AND owner_type = %i", jobid, VEHICLE_OWNER_TYPE_JOB);
	}
	new Cache:cache = mysql_query(database, query);
	new count = OnVehiclesLoad();
	cache_delete(cache);

	return count;
}

SaveVehicle(vehicleid, update_pos = true, remove = false) {
	M:G:I("Iðsaugoma maðina, id: %i, update_pos: %i, remove: %i", vehicleid, update_pos, remove);
	
	if(vehicle_ID[vehicleid] != 0) {
		if(update_pos) {
			SaveVehiclePos(vehicleid);
		}
		orm_update(vehicle_ORM[vehicleid]);
		if(remove) {
			orm_destroy(vehicle_ORM[vehicleid]);
			DestroyVehicle(vehicleid);
		}
	}
}

DeleteVehicle(vehicleid) {
	if(vehicle_ID[vehicleid] != 0) {
		orm_delete(vehicle_ORM[vehicleid]);
	}
	DestroyVehicle(vehicleid);
}

vehicle_GetParam(vehicleid, type) {
	return vehicle_Params[vehicleid] & type;
}

vehicle_ChangeParam(vehicleid, type, toggle) {
	if(toggle) {
		vehicle_Params[vehicleid] |= type;
	}
	else {
		vehicle_Params[vehicleid] &= ~type;
	}
	new type_;
	switch(type) {
		case eVehicle_Param_Engine: type_ = VEHICLE_TYPE_ENGINE;
		case eVehicle_Param_Lights: type_ = VEHICLE_TYPE_LIGHTS;
		case eVehicle_Param_Alarm: type_ = VEHICLE_TYPE_ALARM;
		case eVehicle_Param_Doors: type_ = VEHICLE_TYPE_DOORS;
		case eVehicle_Param_Bonnet: type_ = VEHICLE_TYPE_BONNET;
		case eVehicle_Param_Boot: type_ = VEHICLE_TYPE_BOOT;
		case eVehicle_Param_Objective: type_ = VEHICLE_TYPE_OBJECTIVE;
	}
	SetVehicleParams(vehicleid, type_, toggle);
}

ApplySavedVehiclePos(vehicleid) {
	SetVehiclePos(vehicleid, 
		vehicle_PosX[vehicleid], 
		vehicle_PosY[vehicleid],
		vehicle_PosZ[vehicleid]);
	SetVehicleZAngle(vehicleid,
		vehicle_PosA[vehicleid]);
}

SaveVehiclePos(vehicleid) {
	GetVehiclePos(vehicleid, 
		vehicle_PosX[vehicleid], 
		vehicle_PosY[vehicleid],
		vehicle_PosZ[vehicleid]);
	GetVehicleZAngle(vehicleid,
		vehicle_PosA[vehicleid]);
}

GetVehicleOwnerType(vehicleid) {
	return vehicle_OwnerType[vehicleid];
}

GetVehicleOwner(vehicleid) {
	return vehicle_Owner[vehicleid];
}

SetVehicleStatus(vehicleid, status) {
	vehicle_Status[vehicleid] = status;
}

GetVehicleStatus(vehicleid) {
	return vehicle_Status[vehicleid];
}

SetVehiclePrice(vehicleid, price) {
	vehicle_Price[vehicleid] = price;
}

GetVehiclePrice(vehicleid) {
	return vehicle_Price[vehicleid];
}