#include <YSI\y_hooks>

CMD:nuomotis(playerid, unused[]) {
	new houseid = GetCurrentHouse(playerid);
	if(houseid != NONE) {
		if(GetHouseState(houseid) == E_HOUSE_STATE_FORRENT) {
			ShowRentOffer(playerid, houseid);
		}
		else {
			M:P:E(playerid, "Nor�damas nuomotis patalpas, turi b�ti prie ��jimo � jas.");
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
			M:P:E(playerid, "Nor�damas pirkti patalpas, turi b�ti prie ��jimo � jas.");
		}
	}
	return true;
}

ShowRentOffer(playerid, houseid) {
	dialogSetHeader("%s [nr.: %i]", GetHouseTypeText(houseid, .color = false), houseid);

	dialogAddOption("Nuomos kaina: {f1c40f}%i �/par�", GetHouseRentPrice(houseid));

	dialogAddLine("�ra�yk keliom parom nori i�sinuomuoti �ias patalpas (min: 5)");

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

						M:P:G(playerid, "S�kmingai i�sinuomojai patalpas!");
					}
					else {
						M:P:E(playerid, "Neturi u�tektinai pinig� tokiam nuomos laikotarpiui.");
						ShowRentOffer(playerid, houseid);
					}
				}
				else {
					ShowRentOffer(playerid, houseid);
				}
			}
		}
		else {
			M:P:E(playerid, "Namas jau yra i�nuomotas");
		}
	}

	dialogShow(playerid, using inline response, DIALOG_STYLE_INPUT, "Patalp� nuoma", g_DialogText, "Nuomotis", "At�aukti");
}

ShowSaleOffer(playerid, houseid) {
	dialogSetHeader("%s [nr.: %i]", GetHouseTypeText(houseid, .color = false), houseid);

	dialogAddOption("Patalp� kaina: {f1c40f}%i �", GetHousePrice(houseid));

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

					M:P:G(playerid, "S�kmingai nusipirkai patalpas!");
				}
				else {
					M:P:E(playerid, "Neturi u�tektinai pinig� �sigyti �iom patalpoms.");
					ShowSaleOffer(playerid, houseid);
				}
			}
		}
		else {
			M:P:E(playerid, "Patalpos neb�ra parduodamos.");
		}
	}

	dialogShow(playerid, using inline response, DIALOG_STYLE_MSGBOX, "Patalp� pirkimas", g_DialogText, "Pirkti", "At�aukti");
}