#include <a_samp>

// #define _DEBUG 5

#include "../include/vehicleutil.inc"

#include <crashdetect>
#include <jit>

#include <YSI\y_va>
#include <YSI\y_iterate>
#include <YSI\y_inline>
#include <YSI\y_timers>
#include <YSI\y_commands>
#include <YSI\y_dialog>

//#include "..\gamemodes\modules\server\anticheat.pwn"

//#include "../gamemodes/modules/server/anticheat-hooks.pwn"

#include <noclass>
#include <streamer>
#include <attachments-fix>
#include <formatex>
// #include <CTime>
#include <strlib>
#include <djson>
#include <colours>
#include <whirlpool>
#include <sscanf2>
#include <timestampToDate>
#include <colandreas>
#include <extended_vehicle_functions>
#include <mapandreas>
#include <PathFinder>
// #include <profiler>
// #include <rnpc>
#include <YSF>
#include <SKY>
#include <weapon-config>
// #include <FCNPC>
// #include <RAKTOOLS>
#include <items_and_containers>

//#define ADD_VEHICLES

#include "..\gamemodes\lib\macros.inc"
#include "..\gamemodes\lib\samp.inc"
#include "..\gamemodes\lib\util.inc"
#include "..\gamemodes\lib\positions.inc"

#include "..\gamemodes\modules\server\database.pwn"

#include "..\gamemodes\modules\game\jobs\data.pwn"
#include "..\gamemodes\modules\player\data.pwn"
#include "..\gamemodes\modules\game\vehicles\data.pwn"

#include "..\gamemodes\modules\game\managers\entrance-manager.pwn"
#include "..\gamemodes\modules\game\managers\fade-manager.pwn"
#include "..\gamemodes\modules\game\managers\command-manager.pwn"
#include "..\gamemodes\modules\game\managers\permission-manager.pwn"

// npcs
// #include "..\gamemodes\modules\game\npcs\damage-handler.pwn"
// #include "..\gamemodes\modules\game\npcs\guardians.pwn"

//#include "..\gamemodes\modules\game\places\snake-farm.pwn"

#include "..\gamemodes\modules\player\auth.pwn"
#include "..\gamemodes\modules\player\class-selection.pwn"
#include "..\gamemodes\modules\player\gamestart.pwn"
#include "..\gamemodes\modules\player\general.pwn"
#include "..\gamemodes\modules\player\tutorial.pwn"
#include "..\gamemodes\modules\player\experience.pwn"
#include "..\gamemodes\modules\player\notifications.pwn"
#include "..\gamemodes\modules\player\targetmenu.pwn"
#include "..\gamemodes\modules\player\ui.pwn" // user interface
#include "..\gamemodes\modules\player\ui\level_up.pwn"
#include "..\gamemodes\modules\player\ui\inventory_crafting_container.pwn"
#include "..\gamemodes\modules\player\ui\player_health.pwn"
#include "..\gamemodes\modules\player\ui\enemy_health.pwn"
#include "..\gamemodes\modules\player\ui\cash_update.pwn"

#include "..\gamemodes\modules\game\vehicles\shop.pwn"
#include "..\gamemodes\modules\game\vehicles\special.pwn"
#include "..\gamemodes\modules\game\vehicles\utils.pwn"
#include "..\gamemodes\modules\game\vehicles\errors_and_upgrades.pwn"
#include "..\gamemodes\modules\game\vehicles\speedometer.pwn"
#include "..\gamemodes\modules\game\vehicles\camera_target.pwn"
#include "..\gamemodes\modules\game\vehicles\garage.pwn"
#include "..\gamemodes\modules\game\vehicles\player.pwn"
#include "..\gamemodes\modules\game\vehicles\car_lot.pwn"

#include "..\gamemodes\modules\game\houses\general.pwn"
#include "..\gamemodes\modules\game\houses\permissions.pwn"
#include "..\gamemodes\modules\game\houses\ownership.pwn"
#include "..\gamemodes\modules\game\houses\interiors.pwn"
#include "..\gamemodes\modules\game\houses\management.pwn"

// quests
#include "..\gamemodes\modules\game\quests\general.pwn"

#include "..\gamemodes\modules\game\quests\another\data.pwn"
#include "..\gamemodes\modules\game\quests\another\storyline.pwn"

// darbai
#include "..\gamemodes\modules\game\jobs\leader_menu.pwn"
#include "..\gamemodes\modules\game\jobs\management.pwn"
#include "..\gamemodes\modules\game\jobs\general.pwn"

#include "..\gamemodes\modules\game\jobs\taxi.pwn"

#include "..\gamemodes\modules\game\jobs\medics.pwn"

#include "..\gamemodes\modules\game\jobs\firefighters.pwn"
#include "..\gamemodes\modules\game\jobs\firefighters\fire.pwn"

#include "..\gamemodes\modules\game\jobs\police.pwn"
#include "..\gamemodes\modules\game\jobs\police\commands.pwn"
#include "..\gamemodes\modules\game\jobs\police\jail.pwn"
#include "..\gamemodes\modules\game\jobs\police\crime_bullets.pwn"
#include "..\gamemodes\modules\game\jobs\police\manage_passengers.pwn"
#include "..\gamemodes\modules\game\jobs\police\manage_reasons.pwn"
#include "..\gamemodes\modules\game\jobs\police\target_menu.pwn"

#include "..\gamemodes\modules\game\gangs\player-data.pwn"
#include "..\gamemodes\modules\game\gangs\general.pwn"
#include "..\gamemodes\modules\game\gangs\commands.pwn"
#include "..\gamemodes\modules\game\gangs\gang-wars.pwn"
#include "..\gamemodes\modules\game\gangs\territories\general.pwn"
#include "..\gamemodes\modules\game\gangs\menu\create_gang.pwn"
#include "..\gamemodes\modules\game\gangs\menu\leader_menu.pwn"
#include "..\gamemodes\modules\game\gangs\menu\member_menu.pwn"

#include "..\gamemodes\modules\game\items\general.pwn"
#include "..\gamemodes\modules\game\inventory\equipment.pwn"
#include "..\gamemodes\modules\game\items\weapons\general.pwn"
#include "..\gamemodes\modules\game\items\weapons\equipment.pwn"
#include "..\gamemodes\modules\game\inventory\ui.pwn"
#include "..\gamemodes\modules\game\inventory\general.pwn"

// uþsiëmimai
#include "..\gamemodes\modules\game\activities\fishing.pwn"
#include "..\gamemodes\modules\game\activities\mining.pwn"

// apmokami
#include "..\gamemodes\modules\game\activities\paid\general.pwn"
#include "..\gamemodes\modules\game\activities\paid\pizza.pwn"
                                      
// darbø map
/**
 * Èia includinti map darbø failus, pvz
 *
 * #include "..\gamemodes\maps\MAP_Policija.pwn"
 * #include "..\gamemodes\maps\MAP_Ligonine.pwn"
 */

#include "..\gamemodes\modules\debug\admin.pwn"
#include "..\gamemodes\modules\debug\general.pwn"
#include "..\gamemodes\modules\debug\ninja.pwn"
#include "..\gamemodes\modules\debug\vehicle.pwn"
// #include "..\gamemodes\modules\debug\npc.pwn"

#include <YSI\y_hooks>

/*public OnCheatDetected(playerid, ip_address[], type, code) {
	M:P:E(playerid, "Serveris pastebëjo neleistinà veiklà, saugumo sumetimais esi iðmetamas ið serverio.");
	M:P:I(playerid, "Prieþastis: %s", ACReason[code]);

	defer KickPlayer(playerid);

	return false;
}*/

hook OnScriptInit() {
	CA_Init();
	//Profiler_Start();
}

hook OnGameModeInit() {
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(false);
	SetWeather(24);
	SetGameModeText("GameMode 6");

	// YSF
	AllowNickNameCharacters(true, ' ',
		'à','è','æ','ë','á','ð','ø','û','þ',
		'À','È','Æ','Ë','Á','Ð','Ø','Û','Þ',
		':'
	);

	// SKY
	SetVehiclePassengerDamage(true);
	SetCustomFallDamage(true, 640.0, -0.75);
	SetDisableSyncBugs(true);
}

hook OnGuardianDetectTarget(gid, target) {
	print("OnGuardianDetectTarget()");
	return true;
}

printContainers(A, B) {
	print("Equipment:");
	for(new i = Container_CountItems(A, 0); --i >= 0;) {
		new Item:item = Container_GetItemAt(A, 0, i);
		new item_name[32]; GetItemName(item, item_name);

		printf("> %s id:%i", item_name, _:item);
	}

	print("Inventory:");
	for(new i = Container_CountItems(B, 0); --i >= 0;) {
		new Item:item = Container_GetItemAt(B, 0, i);
		new item_name[32]; GetItemName(item, item_name);

		printf("> %s id:%i", item_name, _:item);
	}
}

hook OnPlayerEquipItem(playerid, item_name[], Item:uiid) {
	return true;
}

main() {
	/*enum { A, B };
	new Item:i1 = CreateItem("Snaiperis");

	EquipItem(0, i1);

	printContainers(Equipment, Player);

	TakeOffItem(0, i1);

	printContainers(Equipment, Player);*/

	// printf("call: %i", HasPermission(0, "House", "enter", .id = 1337));
	// printf("call: %i", call OnPlayerSelectItem(0, "ne M4A1", 0));
	// printf("call: %i", call OnPlayerSelectItem(0, "M4A1", 0));
}

public OnGameModeExit() {
	//Profiler_Stop();

	return true;
}

// CMD:w(playerid, weather[]) {
// 	
// 		• 24 - Laba ðviesu
// 		• 91 - labai tamsu
// 	
// 	SetWeather(strval(weather));
// 	return true;
// }

public OnPlayerRequestClass(playerid, classid) return 1;
public OnPlayerConnect(playerid) return 1;
public OnPlayerDisconnect(playerid, reason) return 1;
public OnPlayerSpawn(playerid) return 1;
public OnVehicleSpawn(vehicleid) return 1;
public OnVehicleDeath(vehicleid, killerid) return 1;
public OnPlayerText(playerid, text[]) return 1;
public OnPlayerCommandText(playerid, cmdtext[]) return 0;
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) return 1;
public OnPlayerExitVehicle(playerid, vehicleid) return 1;
public OnPlayerStateChange(playerid, newstate, oldstate) return 1;
public OnPlayerEnterCheckpoint(playerid) return 1;
public OnPlayerLeaveCheckpoint(playerid) return 1;
public OnPlayerEnterRaceCheckpoint(playerid) return 1;
public OnPlayerLeaveRaceCheckpoint(playerid) return 1;
public OnRconCommand(cmd[]) return true;
public OnPlayerRequestSpawn(playerid) return 1;
public OnObjectMoved(objectid) return 1;
public OnPlayerObjectMoved(playerid, objectid) return 1;
public OnPlayerPickUpPickup(playerid, pickupid) return 1;
public OnVehicleMod(playerid, vehicleid, componentid) return 1;
public OnVehiclePaintjob(playerid, vehicleid, paintjobid) return 1;
public OnVehicleRespray(playerid, vehicleid, color1, color2) return 1;
public OnPlayerSelectedMenuRow(playerid, row) return 1;
public OnPlayerExitedMenu(playerid) return 1;
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) return 1;
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) return 1;
public OnRconLoginAttempt(ip[], password[], success) return 1;
public OnPlayerUpdate(playerid) return true;
public OnPlayerStreamIn(playerid, forplayerid) return 1;
public OnPlayerStreamOut(playerid, forplayerid) return 1;
public OnVehicleStreamIn(vehicleid, forplayerid) return 1;
public OnVehicleStreamOut(vehicleid, forplayerid) return 1;
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) return 1;
public OnPlayerClickPlayer(playerid, clickedplayerid, source) return 1;

// Nepanaudotos (kol kas) funkcijos ir kintamieji
#pragma unused ContainerRow_ItemName_PTD
#pragma unused ContainerRow_TD
#pragma unused CraftingResult_ItemName_PTD
#pragma unused CraftingRow_ItemName_PTD
#pragma unused CraftingSuccessRate_PTD
#pragma unused GetItemDefaultPrice
#pragma unused GetMaxWarsPerGang
#pragma unused GetPlayerMiningLevel
#pragma unused HasItemEquiped
#pragma unused HideContainer
#pragma unused HideCrafting
#pragma unused SetItemDefaultPrice
#pragma unused SetItemDefaultType
#pragma unused SetItemDefaultWeight
#pragma unused ShowContainer
#pragma unused ShowCrafting
#pragma unused job_IsVehicleAllowed
#pragma unused job_RemoveVehicle
#pragma unused SetPlayerJobExp
#pragma unused player_SqlIdToPlayerID
#pragma unused police_WantedByType
#pragma unused vehicle_DamageStatus
#pragma unused vehicle_GamePrice
#pragma unused vehicle_GetParam
#pragma unused vehicle_RealPrice
#pragma unused vehicle_TrunkSize
#pragma unused vehicle_Weight
#pragma unused SetEntranceText
#pragma unused GetPlayerCurrentHouseInterior
#pragma unused IsPlayerInAnyHouse
#pragma unused IsPlayerInHisHouse
#pragma unused printContainers
