#include <YSI\y_hooks>

forward OnRequestQuestProgress(playerid, quest);

CMD:uzduotys(playerid, unused[]) {
	ListQuests(playerid);	
	return true;
}

GetQuestProgress(playerid, quest[]) {
	return call OnRequestQuestProgress(playerid, quest);
}

UpdateQuestProgress(playerid, quest[], progress) {
	call OnUpdateQuestProgress(playerid, quest, progress);
}

ListQuests(playerid) {
	inline response(re, li) {
		#pragma unused li
		if(re) {
			call OnSelectQuestFromList(playerid);
		}
	}

	call OnGenerateQuestList(playerid);

	dialogShow(playerid, using inline response, DIALOG_STYLE_LIST, "Uþduoèiø sàraðas", g_DialogText, "Rinktis", "Uþdaryti");
}