#include <YSI\y_hooks>

CMD:nuomotis(playerid, unused[]) {
	new houseid = GetCurrentHouse(playerid);
	if(houseid != NONE) {
		if(GetHouseState(houseid) == E_HOUSE_STATE_FORRENT) {
			ShowRentOffer(playerid, houseid);
		}
		else {
			M:P:E(playerid, "Norëdamas nuomotis patalpas, turi bûti prie áëjimo á jas.");
		}
	}
	return true;
}

CMD:pirkti(playerid, unused[]) {
	new houseid = GetCurrentHouse(playerid);
	if(houseid != NONE) {
		if(GetHouseState(houseid) == E_HOUSE_STATE_FORSALE) {
			ShowSaleOffer(playerid, houseid);
		}
		else {
			M:P:E(playerid, "Norëdamas pirkti patalpas, turi bûti prie áëjimo á jas.");
		}
	}
	return true;
}

ShowRentOffer(playerid, houseid) {
	dialogSetHeader("%s [nr.: %i]", GetHouseTypeText(houseid, .color = false), houseid);

	dialogAddOption("Nuomos kaina: {f1c40f}%i €/parà", GetHouseRentPrice(houseid));

	dialogAddLine("Áraðyk keliom parom nori iðsinuomuoti ðias patalpas (min: 5)");

	inline response(re, li) {
		#pragma unused li
		if(GetHouseState(houseid) == E_HOUSE_STATE_FORRENT) {
			if(re) {
				new days = strval(dialog_Input);
				if(days >= 5) {
					new total_rent_price = GetHouseRentPrice(houseid) * days;

					if(GetPlayerCash(playerid) >= total_rent_price) {
						AdjustPlayerCash(playerid, -total_rent_price);
						SetHouseTenant(houseid, GetPlayerCharID(playerid));
						SetHouseState(houseid, E_HOUSE_STATE_RENTED);

						SaveHouse(houseid);
						UpdateHouseLabel(houseid);
						Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);

						M:P:G(playerid, "Sëkmingai iðsinuomojai patalpas!");
					}
					else {
						M:P:E(playerid, "Neturi uþtektinai pinigø tokiam nuomos laikotarpiui.");
						ShowRentOffer(playerid, houseid);
					}
				}
				else {
					ShowRentOffer(playerid, houseid);
				}
			}
		}
		else {
			M:P:E(playerid, "Namas jau yra iðnuomotas");
		}
	}

	dialogShow(playerid, using inline response, DIALOG_STYLE_INPUT, "Patalpø nuoma", g_DialogText, "Nuomotis", "Atðaukti");
}

ShowSaleOffer(playerid, houseid) {
	dialogSetHeader("%s [nr.: %i]", GetHouseTypeText(houseid, .color = false), houseid);

	dialogAddOption("Patalpø kaina: {f1c40f}%i €", GetHousePrice(houseid));

	inline response(re, li) {
		#pragma unused li
		if(GetHouseState(houseid) == E_HOUSE_STATE_FORSALE) {
			if(re) {
				if(GetPlayerCash(playerid) >= GetHousePrice(houseid)) {
					AdjustPlayerCash(playerid, -GetHousePrice(houseid));
					SetHouseOwner(houseid, GetPlayerCharID(playerid));
					SetHouseState(houseid, E_HOUSE_STATE_OCCUPIED);

					SaveHouse(houseid);
					UpdateHouseLabel(houseid);
					Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);

					M:P:G(playerid, "Sëkmingai nusipirkai patalpas!");
				}
				else {
					M:P:E(playerid, "Neturi uþtektinai pinigø ásigyti ðiom patalpoms.");
					ShowSaleOffer(playerid, houseid);
				}
			}
		}
		else {
			M:P:E(playerid, "Patalpos nebëra parduodamos.");
		}
	}

	dialogShow(playerid, using inline response, DIALOG_STYLE_MSGBOX, "Patalpø pirkimas", g_DialogText, "Pirkti", "Atðaukti");
}