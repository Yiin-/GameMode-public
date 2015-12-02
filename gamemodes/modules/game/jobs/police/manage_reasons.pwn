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
					M:P:G(playerid, "�ra�ei nauj� nusikaltim�!");
					job_MessageToMembers(JOB_POLICE, 
						"Naujas baud�iamas nusikaltimas: [highlight]%s[]. Ie�k. lygis: [number]%i[].",
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
		dialogSetHeader("Ie�komumo lygis u� �� nusikaltim�. (1-80)");
		dialogShow(playerid, using inline AddNewReasonValue, DIALOG_STYLE_INPUT, "2/2 - Ie�komumo lygis u� nusikaltim�", g_DialogText, "�ra�yti", "Atgal");
	}
}

dialog_AddNewReason(playerid) {
	// vdruk jis neteko direktoriaus kol rinkosi k� paspaust
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
		dialogSetHeader("Naujo nusikaltimo pavadinimas (maks. ilgis 50 simboli�).");
		dialogShow(playerid, using inline AddNewReason, DIALOG_STYLE_INPUT, "1/2 - Nusikaltimo pavadinimas", g_DialogText, "�ra�yti", "Atgal");
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
					M:P:G(playerid, "Nusikalimo pavadinimas s�kmingai pakeistas.");
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
					job_MessageToMembers(JOB_POLICE, "Naujas ie�komumo lygis u� \"[highlight]%s[]\" yra [number]%i[].",
						dj(file, F:0("reasons/%i/reason", idx)), value);

					djSetInt(file, F:0("reasons/%i/value", idx), value);
					M:P:G(playerid, "Ie�komumo lygis u� nusikaltim� s�kmingai pakeistas.");
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
		dialogSetHeader("Koks bus naujas ie�komumo lygis u� nusikaltim�?");
		dialogAddOption("Dabartinis ie�komumo lygis: %i", djInt(file, F:0("reasons/%i/value", idx)));
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
				M:P:G(playerid, "Nusikaltimas s�kminai i�trintas i� s�ra�o.");
				dialog_ManageReasons(playerid);
			}
			else {
				dialog_EditReason(playerid, idx);
			}
		}
		dialogSetHeader("Ar tikrai nori i�trinti �� nusikaltim� i� s�ra�o?");
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
				dialog_Row("Keisti nusikaltimo pavadinim�") {
					dialog_ChangeReason(playerid, idx);
				}
				else dialog_Row("Keisti ie�komumo lyg� u� nusikaltim�") {
					dialog_ChangeReasonValue(playerid, idx);
				}
				else dialog_Row("Trinti nusikaltim�") {
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
		dialogAddOption("Keisti nusikaltimo pavadinim�.");
		dialogAddOption("Keisti ie�komumo lyg� u� nusikaltim�.");
		dialogAddOption("Trinti nusikaltim�.");
		dialogShow(playerid, using inline EditReason, DIALOG_STYLE_LIST, "Nusikaltimo tvarkymas", g_DialogText, "Rinktis", "Atgal");
	}
}

dialog_ManageReasons(playerid) {
	if(player_Job[playerid] == JOB_POLICE && player_JobRank[playerid] == JOB_RANK_LEADER) {
		format(g_DialogText, sizeof g_DialogText, "Prie�astis\tIe�komumo lygis");

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
		dialogShow(playerid, using inline ManageReasons, DIALOG_STYLE_TABLIST_HEADERS, "Pasirink prie�ast� kuri� nori tvarkyti", g_DialogText, "Rinktis", "Atgal");
	}
}

dialog_ReasonsMainPage(playerid) {
	getJobJsonFile:file<JOB_POLICE>;

	inline ReasonsMainPage(re, li) {
		#pragma unused li
		if(re) {
			dialog_Row("Prid�ti nauj� galim� nusikaltim�") {
				dialog_AddNewReason(playerid);
			}
			else dialog_Row("Per�i�r�ti ir tvarkyti s�ra��") {
				dialog_ManageReasons(playerid);
			}
			else dialog_ReasonsMainPage(playerid);
		}
		else job_LeaderMenu(playerid, player_Job[playerid]);
	} 

	if(!djCount(file, "reasons")) {
		dialogSetHeader("S�ra�as tu��ias");
		dialogAddOption("Prid�ti nauj� galim� nusikaltim�.");
	}
	else {
		dialogSetHeader("�ra�yt� nusikaltim� skai�ius s�ra�e: %i", djCount(file, "reasons"));
		dialogAddOption("Per�i�r�ti ir tvarkyti s�ra��.");
		dialogAddOption("Prid�ti nauj� galim� nusikaltim�.");
	}
	dialogShow(playerid, using inline ReasonsMainPage, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
	return true;
}

hook OnPlSelectLeaderMenu(playerid, job) {
	if(job == JOB_POLICE) {
		dialog_Row("Baud�iam� nusikaltim� s�ra�as") {
			dialog_ReasonsMainPage(playerid);
			return true;
		}
	}
	return false;
}

hook OnPlayerOpenLeaderMenu(playerid, job) {
	if(job == JOB_POLICE) {
		dialogAddOption("Baud�iam� nusikaltim� s�ra�as.");
	}
}