#include <YSI_Coding\y_hooks>

SetPlayerJobExp(playerid, amount, job = JOB_NONE) {
	if(job == JOB_NONE) {
		job = player_Job[playerid];
	}
	player_JobExp[playerid][job] = amount;
}

GivePlayerJobExp(playerid, amount) {
	new job = player_Job[playerid];
	return player_JobExp[playerid][job] += amount;
}

GetPlayerJobExp(playerid, job) {
	return player_JobExp[playerid][job];
}

hook OnPlOpenTargetVehMenu(playerid, vehicleid) {
	if(player_Job[playerid] && player_JobRank[playerid] == JOB_RANK_LEADER) {
		if(vehicle_Status[vehicleid] == VEHICLE_STATUS_FORSALE) {
			dialogAddOption("Pirkti ma�in� (darbui)");
		}
	}
}

hook OnPlSelectTargetVehMenu(playerid, vehicleid, li) {
	// same checks, nes �aid�jui gal�jo nuimti direktori�, 
	// arba ma�in� jau kas nors nupirkti kol jis pasirinko
	// kad nori j� pirkti
	if(player_Job[playerid] && player_JobRank[playerid] == JOB_RANK_LEADER) {
		if(vehicle_Status[vehicleid] == VEHICLE_STATUS_FORSALE) {
			dialog_Row("Pirkti ma�in� (darbui)") {
				vehicle_TryToBuy(vehicleid, playerid, .forjob = true);
			}
		}
	}
}