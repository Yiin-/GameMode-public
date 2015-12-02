gangMenu_CreateGang(playerid) {
	inline confirm_gang_creation(re, li) {
		#pragma unused li
		if(re) {
			gangMenu_EnterGangName(playerid);
		}
	}
	dialogSetHeader("Tu neturi jokios gaujos. Ar nori sukurti naujà?");
	dialogAddOption("Sukûræs gaujà, tapsi gaujos lyderis ir galësi á gaujà priimti naujus narius.");
	dialogAddOption("Taip pat bûdamas lyderiu gali skelbti kitoms gaujoms karus bei kovoti dël teritorijø.");

	dialogShow(playerid, using inline confirm_gang_creation, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Kurti", "Atðaukti");
}

static gangMenu_EnterGangName(playerid) {
	inline validate_gang_name(re, li) {
		#pragma unused li
		if(re) {
			switch(SetGangName(dialog_Input)) {
				case GANG_NAME_NO_NAME: {
					M:P:E(playerid, "Neáraðei jokio pavadinimo.");
				}
				case GANG_NAME_EXISTS: {
					M:P:E(playerid, "Toks gaujos pavadinimas jau yra naudojamas.");
				}
				case GANG_NAME_OK: {
					new gang = CreateGang(playerid, dialog_Input);
					M:P:G(playerid, "Gauja [highlight]%s[] sëkmingai sukurta, dabar esi jos lyderis.", GetGangName(gang));
				}
			}
		}
	}
	dialogSetHeader("Pasirink norimà gaujos pavadinimà.");
	dialogAddOption("Gaujos pavadinime turi bûti 1-"#MAX_GANG_NAME" simboliø.");
	dialogShow(playerid, using inline validate_gang_name, DIALOG_STYLE_INPUT, " ", g_DialogText, "Kurti", "Atðaukti");
}