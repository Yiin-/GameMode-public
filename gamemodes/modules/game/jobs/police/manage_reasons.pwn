#include <YSI_Coding\y_hooks>

new reason_tmp[51];

dialog_AddNewReasonValue(playerid) {
	new reason_tmp_[51]; format(reason_tmp_, sizeof reason_tmp_, reason_tmp);
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		inline AddNewReasonValue(re, li) {
			#pragma unused li
			if(re) {
				new value = strval(dialog_Input);
				if(value > 0 && value <= 80) {
					getJobJsonFile:file<JOB_POLICE>;

					new id = djAppend(file,"reasons","");
					djSet(file, F:0("reasons/%i/reason", id), reason_tmp_);
					djSetInt(file, F:0("reasons/%i/value", id), value);
					M:P:G(playerid, "Áraðei naujà nusikaltimà!");
					job_MessageToMembers(JOB_POLICE, 
						"Naujas baudþiamas nusikaltimas: [highlight]%s[]. Ieðk. lygis: [number]%i[].",
						reason_tmp_, value);
					dialog_ReasonsMainPage(playerid);
				}
				else {
					format(reason_tmp, sizeof reason_tmp, reason_tmp_);
					dialog_AddNewReasonValue(playerid);
				}
			}
			else {
				dialog_AddNewReason(playerid);
			}
		}
		dialogSetHeader("Ieðkomumo lygis uþ ðá nusikaltimà. (1-80)");
		dialogShow(playerid, using inline AddNewReasonValue, DIALOG_STYLE_INPUT, "2/2 - Ieðkomumo lygis uþ nusikaltimà", g_DialogText, "Áraðyti", "Atgal");
	}
}

dialog_AddNewReason(playerid) {
	// vdruk jis neteko direktoriaus kol rinkosi kà paspaust
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		inline AddNewReason(re, li) {
			#pragma unused li
			if(re) {
				if(isnull(dialog_Input) || strlen(dialog_Input) > 50) {
					dialog_AddNewReason(playerid);
				}
				else {
					format(reason_tmp, sizeof reason_tmp, dialog_Input);
					dialog_AddNewReasonValue(playerid);
				}
			}
			else {
				dialog_ReasonsMainPage(playerid);
			}
		}
		dialogSetHeader("Naujo nusikaltimo pavadinimas (maks. ilgis 50 simboliø).");
		dialogShow(playerid, using inline AddNewReason, DIALOG_STYLE_INPUT, "1/2 - Nusikaltimo pavadinimas", g_DialogText, "Áraðyti", "Atgal");
	}
}

dialog_ChangeReason(playerid, idx) {
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		getJobJsonFile:file<JOB_POLICE>;

		inline ChangeReason(re, li) {
			#pragma unused li
			if(re) {
				if(!isnull(dialog_Input) && strlen(dialog_Input) <= 50) {
					job_MessageToMembers(JOB_POLICE, "Pakeitas nusikaltimo \"[highlight]%s[]\" pavadinimas!",
						dj(file, F:0("reasons/%i/reason", idx)));
					job_MessageToMembers(JOB_POLICE, "Naujas pavadinimas yra \"[highlight]%s[]\".",
						dialog_Input);

					djSet(file, F:0("reasons/%i/reason", idx), dialog_Input);
					M:P:G(playerid, "Nusikalimo pavadinimas sëkmingai pakeistas.");
					dialog_EditReason(playerid, idx);
				}
				else {
					dialog_ChangeReason(playerid, idx);
				}
			}
			else {
				dialog_EditReason(playerid, idx);
			}
		}
		dialogSetHeader("Koks bus naujas nusikaltimo pavadinimas?");
		dialogAddOption("Dabartinis pavadinimas: %s", dj(file, F:0("reasons/%i/reason", idx)));
		dialogShow(playerid, using inline ChangeReason, DIALOG_STYLE_INPUT, " ", g_DialogText, "Keisti", "Atgal");
	}
}
dialog_ChangeReasonValue(playerid, idx) {
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		getJobJsonFile:file<JOB_POLICE>;
		inline ChangeReasonValue(re, li) {
			#pragma unused li
			if(re) {
				new value = strval(dialog_Input);
				if(value > 0 && value <= 80) {
					job_MessageToMembers(JOB_POLICE, "Naujas ieðkomumo lygis uþ \"[highlight]%s[]\" yra [number]%i[].",
						dj(file, F:0("reasons/%i/reason", idx)), value);

					djSetInt(file, F:0("reasons/%i/value", idx), value);
					M:P:G(playerid, "Ieðkomumo lygis uþ nusikaltimà sëkmingai pakeistas.");
					dialog_EditReason(playerid, idx);
				}
				else {
					dialog_ChangeReasonValue(playerid, idx);
				}
			}
			else {
				dialog_EditReason(playerid, idx);
			}
		}
		dialogSetHeader("Koks bus naujas ieðkomumo lygis uþ nusikaltimà?");
		dialogAddOption("Dabartinis ieðkomumo lygis: %i", djInt(file, F:0("reasons/%i/value", idx)));
		dialogShow(playerid, using inline ChangeReasonValue, DIALOG_STYLE_INPUT, " ", g_DialogText, "Keisti", "Atgal");
	}
}
dialog_DeleteReason(playerid, idx) {
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		getJobJsonFile:file<JOB_POLICE>;
		inline DeleteReason(re, li) {
			#pragma unused li
			if(re) {
				djUnset(file, F:0("reasons/%i", idx));
				M:P:G(playerid, "Nusikaltimas sëkminai iðtrintas ið sàraðo.");
				dialog_ManageReasons(playerid);
			}
			else {
				dialog_EditReason(playerid, idx);
			}
		}
		dialogSetHeader("Ar tikrai nori iðtrinti ðá nusikaltimà ið sàraðo?");
		dialogShow(playerid, using inline DeleteReason, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Taip", "Atgal");
	}
}

dialog_EditReason(playerid, idx) {
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		getJobJsonFile:file<JOB_POLICE>;

		if(idx >= djCount(file, "reasons")) {
			dialog_ManageReasons(playerid);
			return;
		}
		inline EditReason(re, li) {
			#pragma unused li
			if(re) {
				dialog_Row("Keisti nusikaltimo pavadinimà") {
					dialog_ChangeReason(playerid, idx);
				}
				else dialog_Row("Keisti ieðkomumo lygá uþ nusikaltimà") {
					dialog_ChangeReasonValue(playerid, idx);
				}
				else dialog_Row("Trinti nusikaltimà") {
					dialog_DeleteReason(playerid, idx);
				}
				else {
					dialog_EditReason(playerid, idx);
				}
			}
			else {
				dialog_ManageReasons(playerid);
			}
		}

		dialogSetHeader("%s", dj(file, F:0("reasons/%i/reason", idx)));
		dialogAddOption("Keisti nusikaltimo pavadinimà.");
		dialogAddOption("Keisti ieðkomumo lygá uþ nusikaltimà.");
		dialogAddOption("Trinti nusikaltimà.");
		dialogShow(playerid, using inline EditReason, DIALOG_STYLE_LIST, "Nusikaltimo tvarkymas", g_DialogText, "Rinktis", "Atgal");
	}
}

dialog_ManageReasons(playerid) {
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		format(g_DialogText, sizeof g_DialogText, "Prieþastis\tIeðkomumo lygis");

		getJobJsonFile:file<JOB_POLICE>;

		if( ! djCount(file, "reasons")) {
			dialog_ReasonsMainPage(playerid);
			return;
		}

		inline ManageReasons(re, li) {
			if(re) {
				dialog_EditReason(playerid, li);
			}
			else {
				dialog_ReasonsMainPage(playerid);
			}
		}

		for(new i, j = djCount(file, "reasons"); i < j; ++i) {
			static value; value = djInt(file, F:0("reasons/%i/value", i));
			dialogAddLine("%s\t%i", dj(file, F:0("reasons/%i/reason", i)), value);
		}
		dialogShow(playerid, using inline ManageReasons, DIALOG_STYLE_TABLIST_HEADERS, "Pasirink prieþastá kurià nori tvarkyti", g_DialogText, "Rinktis", "Atgal");
	}
}

dialog_ReasonsMainPage(playerid) {
	getJobJsonFile:file<JOB_POLICE>;

	inline ReasonsMainPage(re, li) {
		#pragma unused li
		if(re) {
			dialog_Row("Pridëti naujà galimà nusikaltimà") {
				dialog_AddNewReason(playerid);
			}
			else dialog_Row("Perþiûrëti ir tvarkyti sàraðà") {
				dialog_ManageReasons(playerid);
			}
			else dialog_ReasonsMainPage(playerid);
		}
		else job_LeaderMenu(playerid, player_Job[playerid]);
	} 

	if(!djCount(file, "reasons")) {
		dialogSetHeader("Sàraðas tuðèias");
		dialogAddOption("Pridëti naujà galimà nusikaltimà.");
	}
	else {
		dialogSetHeader("Áraðytø nusikaltimø skaièius sàraðe: %i", djCount(file, "reasons"));
		dialogAddOption("Perþiûrëti ir tvarkyti sàraðà.");
		dialogAddOption("Pridëti naujà galimà nusikaltimà.");
	}
	dialogShow(playerid, using inline ReasonsMainPage, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
	return true;
}

hook OnPlSelectLeaderMenu(playerid, job) {
	if(job == JOB_POLICE) {
		dialog_Row("Baudþiamø nusikaltimø sàraðas") {
			dialog_ReasonsMainPage(playerid);
			return true;
		}
	}
	return false;
}

hook OnPlayerOpenLeaderMenu(playerid, job) {
	if(job == JOB_POLICE) {
		dialogAddOption("Baudþiamø nusikaltimø sàraðas.");
	}
}