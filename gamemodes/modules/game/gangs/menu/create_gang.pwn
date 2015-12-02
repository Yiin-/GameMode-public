gangMenu_CreateGang(playerid) {
	inline confirm_gang_creation(re, li) {
		#pragma unused li
		if(re) {
			gangMenu_EnterGangName(playerid);
		}
	}
	dialogSetHeader("Tu neturi jokios gaujos. Ar nori sukurti nauj�?");
	dialogAddOption("Suk�r�s gauj�, tapsi gaujos lyderis ir gal�si � gauj� priimti naujus narius.");
	dialogAddOption("Taip pat b�damas lyderiu gali skelbti kitoms gaujoms karus bei kovoti d�l teritorij�.");

	dialogShow(playerid, using inline confirm_gang_creation, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Kurti", "At�aukti");
}

static gangMenu_EnterGangName(playerid) {
	inline validate_gang_name(re, li) {
		#pragma unused li
		if(re) {
			switch(SetGangName(dialog_Input)) {
				case GANG_NAME_NO_NAME: {
					M:P:E(playerid, "Ne�ra�ei jokio pavadinimo.");
				}
				case GANG_NAME_EXISTS: {
					M:P:E(playerid, "Toks gaujos pavadinimas jau yra naudojamas.");
				}
				case GANG_NAME_OK: {
					new gang = CreateGang(playerid, dialog_Input);
					M:P:G(playerid, "Gauja [highlight]%s[] s�kmingai sukurta, dabar esi jos lyderis.", GetGangName(gang));
				}
			}
		}
	}
	dialogSetHeader("Pasirink norim� gaujos pavadinim�.");
	dialogAddOption("Gaujos pavadinime turi b�ti 1-"#MAX_GANG_NAME" simboli�.");
	dialogShow(playerid, using inline validate_gang_name, DIALOG_STYLE_INPUT, " ", g_DialogText, "Kurti", "At�aukti");
}