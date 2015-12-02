#include <YSI\y_hooks>

static const s_QuestName[] = "Kiti";
static s_QuestProgress[MAX_PLAYERS];

// quest progess
enum {
	qp_none,
	qp_got_letter
};

hook OnRequestQuestProgress(playerid, quest[]) {
	if( ! strcmp(quest, "Another")) {
		return s_QuestProgress[playerid];
	}
	return qp_none;
}

hook OnUpdateQuestProgress(playerid, quest[], progess) {
	if( ! strcmp(quest, "Another")) {
		s_QuestProgress[playerid] = progess;
	}
}

hook OnPlayerDataLoaded(playerid) {
	new FILE[50]; format(FILE, sizeof FILE, "Quests/%s.json", player_Name[playerid]);

	DJSON_cache_ReloadFile(FILE);

	new path[50]; format(path, _, "%s/progress", s_QuestName);
	s_QuestProgress[playerid] = djInt(FILE, path);
}

hook OnResetPlayerVars(playerid) {
	new FILE[50]; format(FILE, sizeof FILE, "Quests/%s.json", player_Name[playerid]);

	new path[50]; format(path, _, "%s/progress", s_QuestName);
	djSetInt(FILE, path, s_QuestProgress[playerid]);
}

hook OnSelectQuestFromList(playerid) {

}

hook OnGenerateQuestList(playerid) {
	if(s_QuestProgress[playerid] != qp_none) {
		dialogAddLine("%s", s_QuestName);
	}
}