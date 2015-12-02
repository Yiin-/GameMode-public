enum ALS
{
	Bit:ALS_OnScriptInit,
	Bit:ALS_OnScriptExit,
	Bit:ALS_OnGameModeInit,
	Bit:ALS_OnGameModeExit,
	Bit:ALS_OnFilterScriptInit,
	Bit:ALS_OnFilterScriptExit,
	Bit:ALS_OnPlayerConnect,
	Bit:ALS_OnPlayerDisconnect,
	Bit:ALS_OnPlayerSpawn,
	Bit:ALS_OnPlayerDeath,
	Bit:ALS_OnVehicleSpawn,
	Bit:ALS_OnVehicleDeath,
	Bit:ALS_OnPlayerText,
	Bit:ALS_OnPlayerCommandText,
	Bit:ALS_OnPlayerRequestClass,
	Bit:ALS_OnPlayerEnterVehicle,
	Bit:ALS_OnPlayerExitVehicle,
	Bit:ALS_OnPlayerStateChange,
	Bit:ALS_OnPlayerEnterCheckpoint,
	Bit:ALS_OnPlayerLeaveCheckpoint,
	Bit:ALS_OnPlayerEnterRaceCheckpoint,
	Bit:ALS_OnPlayerLeaveRaceCheckpoint,
	Bit:ALS_OnRconCommand,
	Bit:ALS_OnPlayerRequestSpawn,
	Bit:ALS_OnObjectMoved,
	Bit:ALS_OnPlayerObjectMoved,
	Bit:ALS_OnPlayerPickUpPickup,
	Bit:ALS_OnVehicleMod,
	Bit:ALS_OnEnterExitModShop,
	Bit:ALS_OnVehiclePaintjob,
	Bit:ALS_OnVehicleRespray,
	Bit:ALS_OnVehicleDamageStatusUpdate,
	Bit:ALS_OnPlayerSelectedMenuRow,
	Bit:ALS_OnPlayerExitedMenu,
	Bit:ALS_OnPlayerInteriorChange,
	Bit:ALS_OnPlayerKeyStateChange,
	Bit:ALS_OnRconLoginAttempt,
	Bit:ALS_OnPlayerUpdate,
	Bit:ALS_OnPlayerStreamIn,
	Bit:ALS_OnPlayerStreamOut,
	Bit:ALS_OnVehicleStreamIn,
	Bit:ALS_OnVehicleStreamOut,
	Bit:ALS_OnDialogResponse,
	Bit:ALS_OnPlayerClickPlayer,
	Bit:ALS_OnPlayerLogin,
	Bit:ALS_OnPlayerLogout,
	Bit:ALS_OnPlayerTakeDamage,
	Bit:ALS_OnPlayerGiveDamage,
	Bit:ALS_OnPlayerClickMap,
	Bit:ALS_OnPlayerCommandReceived,
	Bit:ALS_OnPlayerCommandPerformed,
	Bit:ALS_OnUnoccupiedVehicleUpdate,
	Bit:ALS_OnPlayerClickTextDraw,
	Bit:ALS_OnPlayerClickPlayerTextDraw,
	Bit:ALS_OnPlayerEditObject,
	Bit:ALS_OnPlayerEditAttachedObject,
	// YSI
	Bit:ALS_OnPlayerEnterArea,
	Bit:ALS_OnPlayerLeaveArea,
	Bit:ALS_OnPlayerFinishRace,
	Bit:ALS_OnPlayerExitRace,
	Bit:ALS_OnRaceEnd,
	#if defined _YSI_PLUGINS_STREAMER
		Bit:ALS_OnDynamicObjectMoved,
		Bit:ALS_OnPlayerEditDynamicObject,
		Bit:ALS_OnPlayerSelectDynamicObject,
		Bit:ALS_OnPlayerPickUpDynamicPickup,
		Bit:ALS_OnPlayerEnterDynamicCP,
		Bit:ALS_OnPlayerLeaveDynamicCP,
		Bit:ALS_OnPlayerEnterDynamicRaceCP,
		Bit:ALS_OnPlayerLeaveDynamicRaceCP,
		Bit:ALS_OnPlayerEnterDynamicArea,
		Bit:ALS_OnPlayerLeaveDynamicArea,
	#endif
	Bit:ALS_OnCharacterDespawn,
	Bit:ALS_OnPlayerSelectTargetMenu,
	Bit:ALS_OnPlayerOpenTargetMenu,
	Bit:ALS_OnCreateVehicleORM,
	Bit:ALS_OnCreatePlayerORM,
	Bit:ALS_OnPlOpenTargetVehMenu,
	Bit:ALS_OnPlSelectTargetVehMenu,
	Bit:ALS_OnPlayerDamage,
	Bit:ALS_OnPlayerDamageDone,
	Bit:ALS_OnPlayerDeathFinished,
	Bit:ALS_OnPlayerLeftJob,
	Bit:ALS_OnPlayerJoinJob,
	Bit:ALS_OnJobSave,
	Bit:ALS_OnJobLoad,
	Bit:ALS_OnPlayerOpenLeaderMenu,
	Bit:ALS_OnPlayerSelectLeaderMenu,
	Bit:ALS_OnGuardianDetectTarget,
	Bit:ALS_OnNpcTakeDamage,
	Bit:ALS_OnGangLoad,
	Bit:ALS_OnGangSave,
	Bit:ALS_OnResetPlayerVars,
	Bit:ALS_OnPlayerKillPlayer,
	Bit:ALS_OnGangWarEnd,
	Bit:ALS_OnPlayerCashUpdate,
	Bit:ALS_OnPlayerLevelUp,
	Bit:ALS_OnPlayerUseItem,
	Bit:ALS_OnPlayerSelectItem,
	Bit:ALS_OnSelectManagedItemMenu,
	Bit:ALS_OnOpenManagedItemMenu,
	Bit:ALS_OnInventoryClose,
	Bit:ALS_OnPlayerDataLoaded,
	Bit:ALS_OnPlayerEquipItem,
	Bit:ALS_OnPlayerTakeOffItem,
	Bit:ALS_OnInventoryLoaded,
	Bit:ALS_OnGenerateItemInfo,
	Bit:ALS_OnPlayerExtinguishFire,
	Bit:ALS_OnSelectQuestFromList,
	Bit:ALS_OnGenerateQuestList,
	Bit:ALS_OnUpdateQuestProgress,
	Bit:ALS_OnRequestQuestProgress,
	Bit:ALS_OnPlayerEnterEntrance,
	Bit:ALS_OnPlayerLeaveEntrance,
	Bit:ALS_OnPlayerUseEntrance,
	Bit:ALS_OnPlayerEnterHouse,
	Bit:ALS_OnPlayerLeftHouse,
	Bit:ALS_OnPermissionCheck,
	Bit:ALS_OnPlayerSelectObject
}

#define ALS_DATA<>

#define ALS_DETECT<%0>

// ALS Callback.
#define _ALS_C_INT<%0,%2>(%3) ALS_MAKE<..._On%0>(ALS_RS_%3);
#define ALS_C_INT<%0,%2>(%3) return _ALS_C_INT<%0,%2>(%3)
// ALS Forward.
#define ALS_F_INT<%0,%8>(%1) forward ALS_MAKE<..._On%0>(ALS_KS_%1);//ALS_F_INT1<%0,%8>(%1)ALS_F_INT2<%0,%8>(%1)
//#define ALS_F_INT1<%0,%8>(%1) public ALS_MAKE<..._On%0>(ALS_KS_%1)<_ALS_:unhooked>{return ALS_R_%0;}
//#define ALS_F_INT2<%0,%8>(%1) public ALS_MAKE<..._On%0>(ALS_KS_%1)<>{return ALS_R_%0;}

// ALS Go (ignore extra parameters).
#define ALS_G_INT<%0,%1>(%8)(%2) W@(#On#%0,(x:#%1#),%2)

// Default return value definitions.
#define ALS_R_ScriptInit 1
#define ALS_R_ScriptExit 1
#define ALS_R_GameModeInit 1
#define ALS_R_GameModeExit 1
#define ALS_R_FilterScriptInit 1
#define ALS_R_FilterScriptExit 1
#define ALS_R_PlayerConnect 1
#define ALS_R_PlayerDisconnect 1
#define ALS_R_PlayerSpawn 1
#define ALS_R_PlayerDeath 1
#define ALS_R_VehicleSpawn 1
#define ALS_R_VehicleDeath 1
#define ALS_R_PlayerText 1
#define ALS_R_PlayerCommandText 0
#define ALS_R_PlayerRequestClass 1
#define ALS_R_PlayerEnterVehicle 1
#define ALS_R_PlayerExitVehicle 1
#define ALS_R_PlayerStateChange 1
#define ALS_R_PlayerEnterCheckpoint 1
#define ALS_R_PlayerLeaveCheckpoint 1
#define ALS_R_PlayerEnterRaceCheckpoint 1
#define ALS_R_PlayerLeaveRaceCheckpoint 1
#define ALS_R_RconCommand 1
#define ALS_R_PlayerRequestSpawn 1
#define ALS_R_ObjectMoved 1
#define ALS_R_PlayerObjectMoved 1
#define ALS_R_PlayerPickUpPickup 1
#define ALS_R_VehicleMod 1
#define ALS_R_EnterExitModShop 1
#define ALS_R_VehiclePaintjob 1
#define ALS_R_VehicleRespray 1
#define ALS_R_VehicleDamageStatusUpdate 1
#define ALS_R_PlayerSelectedMenuRow 1
#define ALS_R_PlayerExitedMenu 1
#define ALS_R_PlayerInteriorChange 1
#define ALS_R_PlayerKeyStateChange 1
#define ALS_R_RconLoginAttempt 1
#define ALS_R_PlayerUpdate 1
#define ALS_R_PlayerStreamIn 1
#define ALS_R_PlayerStreamOut 1
#define ALS_R_VehicleStreamIn 1
#define ALS_R_VehicleStreamOut 1
#define ALS_R_DialogResponse 1
#define ALS_R_PlayerClickPlayer 1
#define ALS_R_PlayerLogin 1
#define ALS_R_PlayerLogout 1
#define ALS_R_PlayerTakeDamage 1
#define ALS_R_PlayerGiveDamage 1
#define ALS_R_PlayerClickMap 1
#define ALS_R_PlayerCommandReceived 1
#define ALS_R_PlayerCommandPerformed -1
#define ALS_R_UnoccupiedVehicleUpdate 1
// 0.3e
#define ALS_R_PlayerClickTextDraw 1
#define ALS_R_PlayerClickPlayerTextDraw 1
#define ALS_R_PlayerEditObject 1
#define ALS_R_PlayerEditAttachedObject 1
#define ALS_R_PlayerSelectObject 1
// YSI
#define ALS_R_PlayerEnterArea 1
#define ALS_R_PlayerLeaveArea 1
#define ALS_R_PlayerFinishRace 1
#define ALS_R_PlayerExitRace 1
#define ALS_R_RaceEnd 1
#define ALS_R_MasterSystemClose 1
// Streamer plugins.
#define ALS_R_DynamicObjectMoved 1
#define ALS_R_PlayerEditDynamicObject 1
#define ALS_R_PlayerSelectDynamicObject 1
#define ALS_R_PlayerPickUpDynamicPickup 1
#define ALS_R_PlayerEnterDynamicCP 1
#define ALS_R_PlayerLeaveDynamicCP 1
#define ALS_R_PlayerEnterDynamicRaceCP 1
#define ALS_R_PlayerLeaveDynamicRaceCP 1
#define ALS_R_PlayerEnterDynamicArea 1
#define ALS_R_PlayerLeaveDynamicArea 1
// Custom
#define ALS_R_CharacterDespawn 1
#define ALS_R_PlayerSelectTargetMenu 1
#define ALS_R_PlayerOpenTargetMenu 1
#define ALS_R_CreateVehicleORM 1
#define ALS_R_CreatePlayerORM 1
#define ALS_R_PlOpenTargetVehMenu 1
#define ALS_R_PlSelectTargetVehMenu 1
#define ALS_R_PlayerDamage 1
#define ALS_R_PlayerDamageDone 1
#define ALS_R_PlayerDeathFinished 1
#define ALS_R_PlayerLeftJob 1
#define ALS_R_PlayerJoinJob 1
#define ALS_R_JobSave 1
#define ALS_R_JobLoad 1
#define ALS_R_PlayerOpenLeaderMenu 1
#define ALS_R_PlayerSelectLeaderMenu 1
#define ALS_R_GuardianDetectTarget 1
#define ALS_R_NpcTakeDamage 1
#define ALS_R_GangLoad 1
#define ALS_R_GangSave 1
#define ALS_R_ResetPlayerVars 1
#define ALS_R_PlayerKillPlayer 1
#define ALS_R_GangWarEnd 1
#define ALS_R_PlayerCashUpdate 1
#define ALS_R_PlayerLevelUp 1
#define ALS_R_PlayerUseItem 0
#define ALS_R_PlayerSelectItem 0
#define ALS_R_SelectManagedItemMenu 1
#define ALS_R_OpenManagedItemMenu 1
#define ALS_R_InventoryClose 1
#define ALS_R_PlayerDataLoaded 1
#define ALS_R_PlayerEquipItem 0
#define ALS_R_PlayerTakeOffItem 1
#define ALS_R_InventoryLoaded 1
#define ALS_R_GenerateItemInfo 1
#define ALS_R_PlayerExtinguishFire 1
#define ALS_R_SelectQuestFromList 1
#define ALS_R_GenerateQuestList 1
#define ALS_R_UpdateQuestProgress 1
#define ALS_R_RequestQuestProgress 0
#define ALS_R_PlayerEnterEntrance 1
#define ALS_R_PlayerLeaveEntrance 1
#define ALS_R_PlayerUseEntrance 1
#define ALS_R_PlayerEnterHouse 1
#define ALS_R_PlayerLeftHouse 1
#define ALS_R_PermissionCheck 1
// Alternates
#define ALS_R_PlayerLeaveRaceCP 1
#define ALS_R_PlayerEnterRaceCP 1
#define ALS_R_VehicleDamageStatusUpd 1
#define ALS_R_UnoccupiedVehicleUpd 1
#define ALS_R_PlayerClickPlayerTD 1
#define ALS_R_PlayerEditAttachedObj 1
#define ALS_R_PlayerCmdPerformed 1
#define ALS_R_PlayerEditDynObject 1
#define ALS_R_PlayerSelectDynObject 1
#define ALS_R_PlayerPickUpDynPickup 1
#define ALS_R_PlayerEnterDynRaceCP 1
#define ALS_R_PlayerLeaveDynRaceCP 1
#define ALS_R_PlayerEnterDynArea 1
#define ALS_R_PlayerLeaveDynArea 1
#define ALS_R_PlSelectTargetMenu 1
#define ALS_R_PlSelectLeaderMenu 1

// Chain call declarations.
#define ALS_DO_ScriptInit<%0> %0<ScriptInit,>(none:)
#define ALS_DO_ScriptExit<%0> %0<ScriptExit,>(none:)
#define ALS_DO_GameModeInit<%0> %0<GameModeInit,>(none:)
#define ALS_DO_GameModeExit<%0> %0<GameModeExit,>(none:)
#define ALS_DO_FilterScriptInit<%0> %0<FilterScriptInit,>(none:)
#define ALS_DO_FilterScriptExit<%0> %0<FilterScriptExit,>(none:)
#define ALS_DO_PlayerConnect<%0> %0<PlayerConnect,i>(end:playerid)
#define ALS_DO_PlayerDisconnect<%0> %0<PlayerDisconnect,ii>(more:playerid,end:reason)
#define ALS_DO_PlayerSpawn<%0> %0<PlayerSpawn,i>(end:playerid)
#define ALS_DO_PlayerDeath<%0> %0<PlayerDeath,iii>(more:playerid,more:killerid,end:reason)
#define ALS_DO_VehicleSpawn<%0> %0<VehicleSpawn,i>(end:vehicleid)
#define ALS_DO_VehicleDeath<%0> %0<VehicleDeath,ii>(more:vehicleid,end:killerid)
#define ALS_DO_PlayerText<%0> %0<PlayerText,is>(more:playerid,end_string:text[])
#define ALS_DO_PlayerCommandText<%0> %0<PlayerCommandText,is>(more:playerid,end_string:cmdtext[])
#define ALS_DO_PlayerRequestClass<%0> %0<PlayerRequestClass,ii>(more:playerid,end:classid)
#define ALS_DO_PlayerEnterVehicle<%0> %0<PlayerEnterVehicle,iii>(more:playerid,more:vehicleid,end:ispassenger)
#define ALS_DO_PlayerExitVehicle<%0> %0<PlayerExitVehicle,ii>(more:playerid,end:vehicleid)
#define ALS_DO_PlayerStateChange<%0> %0<PlayerStateChange,iii>(more:playerid,more:newstate,end:oldstate)
#define ALS_DO_PlayerEnterCheckpoint<%0> %0<PlayerEnterCheckpoint,i>(end:playerid)
#define ALS_DO_PlayerLeaveCheckpoint<%0> %0<PlayerLeaveCheckpoint,i>(end:playerid)
#define ALS_DO_PlayerEnterRaceCheckpoint<%0> %0<PlayerEnterRaceCheckpoint,i>(end:playerid)
#define ALS_DO_PlayerLeaveRaceCheckpoint<%0> %0<PlayerLeaveRaceCheckpoint,i>(end:playerid)
#define ALS_DO_RconCommand<%0> %0<RconCommand,s>(end_string:cmd[])
#define ALS_DO_PlayerRequestSpawn<%0> %0<PlayerRequestSpawn,i>(end:playerid)
#define ALS_DO_ObjectMoved<%0> %0<ObjectMoved,i>(end:objectid)
#define ALS_DO_PlayerObjectMoved<%0> %0<PlayerObjectMoved,ii>(more:playerid,end:objectid)
#define ALS_DO_PlayerPickUpPickup<%0> %0<PlayerPickUpPickup,ii>(more:playerid,end:pickupid)
#define ALS_DO_VehicleMod<%0> %0<VehicleMod,iii>(more:playerid,more:vehicleid,end:componentid)
#define ALS_DO_EnterExitModShop<%0> %0<EnterExitModShop,iii>(more:playerid,more:enterexit,end:interiorid)
#define ALS_DO_VehiclePaintjob<%0> %0<VehiclePaintjob,iii>(more:playerid,more:vehicleid,end:paintjobid)
#define ALS_DO_VehicleRespray<%0> %0<VehicleRespray,iiii>(more:playerid,more:vehicleid,more:color1,end:color2)
#define ALS_DO_VehicleDamageStatusUpdate<%0> %0<VehicleDamageStatusUpdate,ii>(more:vehicleid,end:playerid)
#define ALS_DO_PlayerSelectedMenuRow<%0> %0<PlayerSelectedMenuRow,ii>(more:playerid,end:row)
#define ALS_DO_PlayerExitedMenu<%0> %0<PlayerExitedMenu,i>(end:playerid)
#define ALS_DO_PlayerInteriorChange<%0> %0<PlayerInteriorChange,iii>(more:playerid,more:newinteriorid,end:oldinteriorid)
#define ALS_DO_PlayerKeyStateChange<%0> %0<PlayerKeyStateChange,iii>(more:playerid,more:newkeys,end:oldkeys)
#define ALS_DO_RconLoginAttempt<%0> %0<RconLoginAttempt,ssi>(string:ip[],string:password[],end:success)
#define ALS_DO_PlayerUpdate<%0> %0<PlayerUpdate,i>(end:playerid)
#define ALS_DO_PlayerStreamIn<%0> %0<PlayerStreamIn,ii>(more:playerid,end:forplayerid)
#define ALS_DO_PlayerStreamOut<%0> %0<PlayerStreamOut,ii>(more:playerid,end:forplayerid)
#define ALS_DO_VehicleStreamIn<%0> %0<VehicleStreamIn,ii>(more:vehicleid,end:forplayerid)
#define ALS_DO_VehicleStreamOut<%0> %0<VehicleStreamOut,ii>(more:vehicleid,end:forplayerid)
#define ALS_DO_DialogResponse<%0> %0<DialogResponse,iiiis>(more:playerid,more:dialogid,more:response,more:listitem,end_string:inputtext[])
#define ALS_DO_PlayerClickPlayer<%0> %0<PlayerClickPlayer,iii>(more:playerid,more:clickedplayerid,end:source)
#define ALS_DO_PlayerLogin<%0> %0<PlayerLogin,ii>(more:playerid,end:uid)
#define ALS_DO_PlayerLogout<%0> %0<PlayerLogout,ii>(more:playerid,end:uid)
#if defined GetPlayerLastShotVectors // 0.3z RC4
	#define ALS_DO_PlayerGiveDamage<%0> %0<PlayerGiveDamage,iifii>(more:playerid,more:damagedid,Float:amount,more:weaponid,end:bodypart)
	#define ALS_DO_PlayerTakeDamage<%0> %0<PlayerTakeDamage,iifii>(more:playerid,more:issuerid,Float:amount,more:weaponid,end:bodypart)
#else
	#define ALS_DO_PlayerGiveDamage<%0> %0<PlayerGiveDamage,iifi>(more:playerid,more:damagedid,Float:amount,end:weaponid)
	#define ALS_DO_PlayerTakeDamage<%0> %0<PlayerTakeDamage,iifi>(more:playerid,more:issuerid,Float:amount,end:weaponid)
#endif
#define ALS_DO_PlayerClickMap<%0> %0<PlayerClickMap,ifff>(more:playerid,Float:fX,Float:fY,end_Float:fZ)
#define ALS_DO_PlayerCommandReceived<%0> %0<PlayerCommandReceived,is>(more:playerid,end_string:cmdtext[])
#define ALS_DO_PlayerCommandPerformed<%0> %0<PlayerCommandPerformed,isi>(more:playerid,string:cmdtext[],end:success)
#if defined GetServerTickRate // 0.3z RC5
	#define ALS_DO_UnoccupiedVehicleUpdate<%0> %0<UnoccupiedVehicleUpdate,iiifff>(more:vehicleid,more:playerid,more:passenger_seat,Float:new_x,Float:new_y,end_Float:new_z)
#else
	#define ALS_DO_UnoccupiedVehicleUpdate<%0> %0<UnoccupiedVehicleUpdate,iii>(more:vehicleid,more:playerid,end:passenger_seat)
#endif
// 0.3e
#define ALS_DO_PlayerClickTextDraw<%0> %0<PlayerClickTextDraw,ii>(more:playerid,end_tag:Text:clickedid)
#define ALS_DO_PlayerClickPlayerTextDraw<%0> %0<PlayerClickPlayerTextDraw,iii>(more:playerid,end_tag:PlayerText:playertextid)
#define ALS_DO_PlayerEditObject<%0> %0<PlayerEditObject,iiiiffffff>(more:playerid,more:playerobject,more:objectid,more:response,Float:fX,Float:fY,Float:fZ,Float:fRotX,Float:fRotY,end_Float:fRotZ)
#define ALS_DO_PlayerEditAttachedObject<%0> %0<PlayerEditAttachedObject,iiiiifffffffff>(more:playerid,more:response,more:index,more:modelid,more:boneid,Float:fOffsetX,Float:fOffsetY,Float:fOffsetZ,Float:fRotX,Float:fRotY,Float:fRotZ,Float:fScaleX,Float:fScaleY,end_Float:fScaleZ)
#define ALS_DO_PlayerSelectObject<%0> %0<PlayerSelectObject,iiiifff>(more:playerid,more:type,more:objectid,more:modelid,Float:fX,Float:fY,end_Float:fZ)
// YSI
#define ALS_DO_PlayerEnterArea<%0> %0<PlayerEnterArea,ii>(more:playerid,end:areaid)
#define ALS_DO_PlayerLeaveArea<%0> %0<PlayerLeaveArea,ii>(more:playerid,end:areaid)
#define ALS_DO_PlayerFinishRace<%0> %0<PlayerFinishRace,iiiii>(more:playerid,more:race,more:position,more:prize,end:time)
#define ALS_DO_PlayerExitRace<%0> %0<PlayerExitRace,ii>(more:playerid,end:race)
#define ALS_DO_RaceEnd<%0> %0<RaceEnd,i>(end:race)
// Streamer plugin.
#define ALS_DO_DynamicObjectMoved<%0> %0<DynamicObjectMoved,i>(end:objectid)
#define ALS_DO_PlayerEditDynamicObject<%0> %0<PlayerEditDynamicObject,iiiiiiiii>(more:playerid,more:objectid,more:response,Float:x,Float:y,Float:z,Float:rx,Float:ry,end_Float:rz)
#define ALS_DO_PlayerSelectDynamicObject<%0> %0<PlayerSelectDynamicObject,iiiiii>(more:playerid,more:objectid,more:modelid,Float:x,Float:y,end_Float:z)
#define ALS_DO_PlayerPickUpDynamicPickup<%0> %0<PlayerPickUpDynamicPickup,ii>(more:playerid,end:pickupid)
#define ALS_DO_PlayerEnterDynamicCP<%0> %0<PlayerEnterDynamicCP,ii>(more:playerid,end:checkpointid)
#define ALS_DO_PlayerLeaveDynamicCP<%0> %0<PlayerLeaveDynamicCP,ii>(more:playerid,end:checkpointid)
#define ALS_DO_PlayerEnterDynamicRaceCP<%0> %0<PlayerEnterDynamicRaceCP,ii>(more:playerid,end:checkpointid)
#define ALS_DO_PlayerLeaveDynamicRaceCP<%0> %0<PlayerLeaveDynamicRaceCP,ii>(more:playerid,end:checkpointid)
#define ALS_DO_PlayerEnterDynamicArea<%0> %0<PlayerEnterDynamicArea,ii>(more:playerid,end:areaid)
#define ALS_DO_PlayerLeaveDynamicArea<%0> %0<PlayerLeaveDynamicArea,ii>(more:playerid,end:areaid)
// Custom
#define ALS_DO_CharacterDespawn<%0> %0<CharacterDespawn,i>(end:playerid)
#define ALS_DO_PlayerSelectTargetMenu<%0> %0<PlayerSelectTargetMenu,iii>(more:playerid, more:targetid, end:li)
#define ALS_DO_PlayerOpenTargetMenu<%0> %0<PlayerOpenTargetMenu,ii>(more:playerid, end:targetid)
#define ALS_DO_CreateVehicleORM<%0> %0<CreateVehicleORM,ii>(ORM:ormid, end:vehicleid)
#define ALS_DO_CreatePlayerORM<%0> %0<CreatePlayerORM,ii>(ORM:ormid, end:playerid)
#define ALS_DO_PlOpenTargetVehMenu<%0> %0<PlOpenTargetVehMenu,ii>(more:playerid, end:vehicleid)
#define ALS_DO_PlSelectTargetVehMenu<%0> %0<PlSelectTargetVehMenu,iii>(more:playerid, more:vehicleid, end:li)
#define ALS_DO_PlayerDamage<%0> %0<PlayerDamage,ifiii>(more:playerid, Float:amount, more:issuerid, more:weapon, end:bodypart)
#define ALS_DO_PlayerDamageDone<%0> %0<PlayerDamageDone,ifiii>(more:playerid, Float:amount, more:issuerid, more:weapon, end:bodypart)
#define ALS_DO_PlayerDeathFinished<%0> %0<PlayerDeathFinished,ii>(more:playerid, end_tag:bool:cancelable)
#define ALS_DO_PlayerLeftJob<%0> %0<PlayerLeftJob,ii>(more:playerid, end:job)
#define ALS_DO_PlayerJoinJob<%0> %0<PlayerJoinJob,ii>(more:playerid, end:job)
#define ALS_DO_JobSave<%0> %0<JobSave,is>(more:job, end_string:file)
#define ALS_DO_JobLoad<%0> %0<JobLoad,is>(more:job, end_string:file)
#define ALS_DO_PlayerOpenLeaderMenu<%0> %0<PlayerOpenLeaderMenu,ii>(more:playerid, end:job)
#define ALS_DO_PlayerSelectLeaderMenu<%0> %0<PlayerSelectLeaderMenu,ii>(more:playerid, end:job)
#define ALS_DO_GuardianDetectTarget<%0> %0<GuardianDetectTarget,ii>(more:gid, end:target)
#define ALS_DO_NpcTakeDamage<%0> %0<NpcTakeDamage,iiiif>(more:npcid, more:damagerid, more:weaponid, more:bodypart, end_Float:health_loss)
#define ALS_DO_GangLoad<%0> %0<GangLoad,i>(end:gang)
#define ALS_DO_GangSave<%0> %0<GangSave,i>(end:gang)
#define ALS_DO_ResetPlayerVars<%0> %0<ResetPlayerVars,i>(end:playerid)
#define ALS_DO_PlayerKillPlayer<%0> %0<PlayerKillPlayer,iii>(more:playerid, more:killerid, end:weaponid)
#define ALS_DO_GangWarEnd<%0> %0<GangWarEnd,ii>(more:winner, end:loser)
#define ALS_DO_PlayerCashUpdate<%0> %0<PlayerCashUpdate,ii>(more:playerid, end:difference)
#define ALS_DO_PlayerLevelUp<%0> %0<PlayerLevelUp,i>(end:playerid)
#define ALS_DO_PlayerUseItem<%0> %0<PlayerUseItem,isi>(more:playerid, string:item_name[], end_tag:Item:uiid)
#define ALS_DO_PlayerSelectItem<%0> %0<PlayerSelectItem,isi>(more:playerid, string:item_name[], end_tag:Item:uiid)
#define ALS_DO_SelectManagedItemMenu<%0> %0<SelectManagedItemMenu,isi>(more:playerid, string:item_name[], end_tag:Item:uiid)
#define ALS_DO_OpenManagedItemMenu<%0> %0<OpenManagedItemMenu,isi>(more:playerid, string:item_name[], end_tag:Item:uiid)
#define ALS_DO_InventoryClose<%0> %0<InventoryClose,i>(end:playerid)
#define ALS_DO_PlayerDataLoaded<%0> %0<PlayerDataLoaded,i>(end:playerid)
#define ALS_DO_PlayerEquipItem<%0> %0<PlayerEquipItem,isi>(more:playerid, string:item_name[], end_tag:Item:uiid)
#define ALS_DO_PlayerTakeOffItem<%0> %0<PlayerTakeOffItem,isi>(more:playerid, string:item_name[], end_tag:Item:uiid)
#define ALS_DO_InventoryLoaded<%0> %0<InventoryLoaded,i>(end:playerid)
#define ALS_DO_GenerateItemInfo<%0> %0<GenerateItemInfo,i>(end_tag:Item:uiid)
#define ALS_DO_PlayerExtinguishFire<%0> %0<PlayerExtinguishFire,i>(end:playerid)
#define ALS_DO_SelectQuestFromList<%0> %0<SelectQuestFromList,i>(end:playerid)
#define ALS_DO_GenerateQuestList<%0> %0<GenerateQuestList,i>(end:playerid)
#define ALS_DO_UpdateQuestProgress<%0> %0<UpdateQuestProgress,isi>(more:playerid, string:quest[], end:progress)
#define ALS_DO_RequestQuestProgress<%0> %0<RequestQuestProgress,is>(more:playerid, end_string:quest[])
#define ALS_DO_PlayerEnterEntrance<%0> %0<PlayerEnterEntrance,ii>(more:playerid, end:entranceid)
#define ALS_DO_PlayerLeaveEntrance<%0> %0<PlayerLeaveEntrance,ii>(more:playerid, end:entranceid)
#define ALS_DO_PlayerUseEntrance<%0> %0<PlayerUseEntrance,ii>(more:playerid, end:entranceid)
#define ALS_DO_PlayerEnterHouse<%0> %0<PlayerEnterHouse,ii>(more:playerid, end:houseid)
#define ALS_DO_PlayerLeftHouse<%0> %0<PlayerLeftHouse,ii>(more:playerid, end:houseid)
#define ALS_DO_PermissionCheck<%0> %0<PermissionCheck,isssi>(more:playerid, string:entity[], string:node[], string:node_child[], end:entity_id)

#define ALS_KS_more:%0,         %0,ALS_KS_
#define ALS_KS_ref_more:%0,     &%0,ALS_KS_
#define ALS_KS_string:%0[],     %0[],ALS_KS_
#define ALS_KS_Float:%0,        Float:%0,ALS_KS_
#define ALS_KS_ref_Float:%0,    &Float:%0,ALS_KS_
#define ALS_KS_ORM:%0,          ORM:%0,ALS_KS_
#define ALS_KS_tag:%3:%0,       %3:%0,ALS_KS_
#define ALS_KS_end:%0)          %0)
#define ALS_KS_ref_end:%0)      &%0)
#define ALS_KS_none:)           )
#define ALS_KS_end_string:%0[]) %0[])
#define ALS_KS_end_Float:%0)    Float:%0)
#define ALS_KS_end_tag:%3:%0)   %3:%0)

#define ALS_TS_more:%0,         %0,ALS_TS_
#define ALS_TS_ref_more:%0,     &%0,ALS_TS_
#define ALS_TS_string:%0[],     (%0),ALS_TS_
#define ALS_TS_Float%0,         Float:%0,ALS_TS_
#define ALS_TS_ref_bool%0,      &bool:%0,ALS_TS_
#define ALS_TS_ORM%0,           ORM:%0,ALS_TS_
#define ALS_TS_tag:%3:%0,       %3:%0,ALS_TS_
#define ALS_TS_end:%0)          %0)
#define ALS_TS_ref_end:%0)      &%0)
#define ALS_TS_none:)           )
#define ALS_TS_end_string:%0[]) (%0))
#define ALS_TS_end_Float:%0)    Float:%0)
#define ALS_TS_end_tag:%3:%0)   %3:%0)

#define ALS_RS_more:%0,         %0,ALS_RS_
#define ALS_RS_string:%0[],     ((%0[0])?(%0):NULL),ALS_RS_
#define ALS_RS_Float:%0,        (_:%0),ALS_RS_
#define ALS_RS_tag:%3:%0,       (_:%0),ALS_RS_
#define ALS_RS_end:%0)          %0)
#define ALS_RS_none:)           )
#define ALS_RS_end_string:%0[]) ((%0[0])?(%0):NULL))
#define ALS_RS_end_Float:%0)    (_:%0))
#define ALS_RS_end_tag:%3:%0)   (_:%0))

#define ALS_DO:%9<%0> ALS_DO_%0<%9>

#define ALS_CALL<%0> ALS_DO:ALS_C_INT<%0>
#define ALS_GET<%0> ALS_DO:_ALS_C_INT<%0>
#define ALS_FORWARD<%0> ALS_DO:ALS_F_INT<%0>

#define call%0On%1(%2) ALS_DO:ALS_G_INT<%1>(%2)