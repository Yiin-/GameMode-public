#include <YSI_Coding\y_hooks>

// ne enum'as, nes tag mismatch
new const icc_container_name       = 0;
new const icc_container_key        = 1;
new const icc_container_first_btn  = 2;
new const icc_container_second_btn = 3;
new const icc_inventory_rows       = 4;
new const icc_container_rows       = 5;
new const icc_inventory_amount     = 6;
new const icc_inventory_weight     = 7;
new const icc_container_amount     = 8;
new const icc_container_value      = 9;
new const inventory_current_page   = 10;
new const container_current_page   = 11;

new Text:icc_td[38];
new Text:inventory_row_td[8];
new Text:container_row_td[8];

new const icc_inventory_use_btn = 9;
new const icc_inventory_use_txt = 22;
new const icc_inventory_drop_btn = 10;
new const icc_inventory_drop_txt = 23;
new const icc_inventory_destroy_btn = 11;
new const icc_inventory_destroy_txt = 24;
new const icc_inventory_info_btn = 12;
new const icc_inventory_info_txt = 25;
new const icc_inventory_more_btn = 13;
new const icc_inventory_more_txt1 = 35;
new const icc_inventory_more_txt2 = 36;
new const icc_inventory_more_txt3 = 37;
new const icc_inventory_prev_btn = 31;
new const icc_inventory_next_btn = 32;

static const container_td[] = {
	1, 4, 14, 15, 16, 19, 21, 26, 29, 33, 34
};
static const crafting_td[] = {
	2, 5, 6, 8, 17, 27, 30
};
new PlayerText:icc_ptd[MAX_PLAYERS][12];
new PlayerText:inventory_row_item_name_ptd[MAX_PLAYERS][8];
new PlayerText:container_row_item_name_ptd[MAX_PLAYERS][8];
new PlayerText:crafting_row_item_name_ptd[MAX_PLAYERS][7];
new PlayerText:crafting_result_item[MAX_PLAYERS];
new PlayerText:crafting_success_rate[MAX_PLAYERS];

Text:icc_TD(index) {
	return icc_td[index];
}
Text:InventoryRow_TD(index) {
	return inventory_row_td[index];
}
Text:ContainerRow_TD(index) {
	return container_row_td[index];
}

PlayerText:icc_PTD(playerid, index) {
	return icc_ptd[playerid][index];
}

PlayerText:InventoryRow_ItemName_PTD(playerid, index) {
	return inventory_row_item_name_ptd[playerid][index];
}
PlayerText:ContainerRow_ItemName_PTD(playerid, index) {
	return container_row_item_name_ptd[playerid][index];
}
PlayerText:CraftingRow_ItemName_PTD(playerid, index) {
	return crafting_row_item_name_ptd[playerid][index];
}
PlayerText:CraftingResult_ItemName_PTD(playerid) {
	return crafting_result_item[playerid];
}
PlayerText:CraftingSuccessRate_PTD(playerid) {
	return crafting_success_rate[playerid];
}

ShowCrafting(playerid) {
	foreach(new i : Array(crafting_td)) {
		TextDrawShowForPlayer(playerid, icc_td[i]);
	}
	foreach(new PlayerText:i : Array(crafting_row_item_name_ptd[playerid])) {
		PlayerTextDrawShow(playerid, i);
	}
	PlayerTextDrawShow(playerid, crafting_result_item[playerid]);
	PlayerTextDrawShow(playerid, crafting_success_rate[playerid]);
}

HideCrafting(playerid) {
	foreach(new i : Array(crafting_td)) {
		TextDrawHideForPlayer(playerid, icc_td[ i ]);
	}
	foreach(new PlayerText:i : Array(crafting_row_item_name_ptd[playerid])) {
		PlayerTextDrawHide(playerid, i);
	}
	PlayerTextDrawHide(playerid, crafting_result_item[playerid]);
	PlayerTextDrawHide(playerid, crafting_success_rate[playerid]);
}

ShowContainer(playerid, update_rows = false) {
	foreach(new i : Array(container_td)) {
		TextDrawShowForPlayer(playerid, icc_td[i]);
	}
	if(update_rows) {
		foreach(new PlayerText:i : Array(container_row_item_name_ptd[playerid])) {
			PlayerTextDrawShow(playerid, i);
		}
	}
}

HideContainer(playerid) {
	foreach(new i : Array(container_td)) {
		TextDrawHideForPlayer(playerid, icc_td[i]);
	}
	foreach(new PlayerText:i : Array(container_row_item_name_ptd[playerid])) {
		PlayerTextDrawHide(playerid, i);
	}
}

hook OnGameModeInit() {
	icc_td[0] = TextDrawCreate(162.000000, 127.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[0], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[0], 254.000000, 285.000000);
	TextDrawAlignment(icc_td[0], 1);
	TextDrawColor(icc_td[0], -1);
	TextDrawSetShadow(icc_td[0], 0);
	TextDrawSetOutline(icc_td[0], 0);
	TextDrawBackgroundColor(icc_td[0], 255);
	TextDrawFont(icc_td[0], 4);
	TextDrawSetProportional(icc_td[0], 0);
	TextDrawSetShadow(icc_td[0], 0);

	icc_td[1] = TextDrawCreate(418.000000, 127.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[1], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[1], 216.000000, 285.000000);
	TextDrawAlignment(icc_td[1], 1);
	TextDrawColor(icc_td[1], -1);
	TextDrawSetShadow(icc_td[1], 0);
	TextDrawSetOutline(icc_td[1], 0);
	TextDrawBackgroundColor(icc_td[1], 255);
	TextDrawFont(icc_td[1], 4);
	TextDrawSetProportional(icc_td[1], 0);
	TextDrawSetShadow(icc_td[1], 0);

	icc_td[2] = TextDrawCreate(5.000000, 127.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[2], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[2], 155.000000, 203.000000);
	TextDrawAlignment(icc_td[2], 1);
	TextDrawColor(icc_td[2], -1);
	TextDrawSetShadow(icc_td[2], 0);
	TextDrawSetOutline(icc_td[2], 0);
	TextDrawBackgroundColor(icc_td[2], 255);
	TextDrawFont(icc_td[2], 4);
	TextDrawSetProportional(icc_td[2], 0);
	TextDrawSetShadow(icc_td[2], 0);

	icc_td[3] = TextDrawCreate(163.000000, 128.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[3], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[3], 252.000000, 254.000000);
	TextDrawAlignment(icc_td[3], 1);
	TextDrawColor(icc_td[3], 877223679);
	TextDrawSetShadow(icc_td[3], 0);
	TextDrawSetOutline(icc_td[3], 0);
	TextDrawBackgroundColor(icc_td[3], 255);
	TextDrawFont(icc_td[3], 4);
	TextDrawSetProportional(icc_td[3], 0);
	TextDrawSetShadow(icc_td[3], 0);

	icc_td[4] = TextDrawCreate(419.000000, 128.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[4], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[4], 214.000000, 254.000000);
	TextDrawAlignment(icc_td[4], 1);
	TextDrawColor(icc_td[4], 877223679);
	TextDrawSetShadow(icc_td[4], 0);
	TextDrawSetOutline(icc_td[4], 0);
	TextDrawBackgroundColor(icc_td[4], 255);
	TextDrawFont(icc_td[4], 4);
	TextDrawSetProportional(icc_td[4], 0);
	TextDrawSetShadow(icc_td[4], 0);

	icc_td[5] = TextDrawCreate(6.000000, 128.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[5], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[5], 153.000000, 149.000000);
	TextDrawAlignment(icc_td[5], 1);
	TextDrawColor(icc_td[5], 877223679);
	TextDrawSetShadow(icc_td[5], 0);
	TextDrawSetOutline(icc_td[5], 0);
	TextDrawBackgroundColor(icc_td[5], 255);
	TextDrawFont(icc_td[5], 4);
	TextDrawSetProportional(icc_td[5], 0);
	TextDrawSetShadow(icc_td[5], 0);

	icc_td[6] = TextDrawCreate(6.000000, 278.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[6], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[6], 153.000000, 25.000000);
	TextDrawAlignment(icc_td[6], 1);
	TextDrawColor(icc_td[6], 877223679);
	TextDrawSetShadow(icc_td[6], 0);
	TextDrawSetOutline(icc_td[6], 0);
	TextDrawBackgroundColor(icc_td[6], 255);
	TextDrawFont(icc_td[6], 4);
	TextDrawSetProportional(icc_td[6], 0);
	TextDrawSetShadow(icc_td[6], 0);

	icc_td[7] = TextDrawCreate(291.000000, 131.000000, "Inventorius");
	TextDrawLetterSize(icc_td[7], 0.212122, 1.209163);
	TextDrawAlignment(icc_td[7], 2);
	TextDrawColor(icc_td[7], -238809089);
	TextDrawSetShadow(icc_td[7], 0);
	TextDrawSetOutline(icc_td[7], 0);
	TextDrawBackgroundColor(icc_td[7], 877223679);
	TextDrawFont(icc_td[7], 2);
	TextDrawSetProportional(icc_td[7], 1);
	TextDrawSetShadow(icc_td[7], 0);

	icc_td[8] = TextDrawCreate(41.000000, 132.000000, " Daiktu gamyba");
	TextDrawLetterSize(icc_td[8], 0.218682, 1.121666);
	TextDrawAlignment(icc_td[8], 1);
	TextDrawColor(icc_td[8], -238809089);
	TextDrawSetShadow(icc_td[8], 0);
	TextDrawSetOutline(icc_td[8], 0);
	TextDrawBackgroundColor(icc_td[8], 255);
	TextDrawFont(icc_td[8], 2);
	TextDrawSetProportional(icc_td[8], 1);
	TextDrawSetShadow(icc_td[8], 0);

	icc_td[9] = TextDrawCreate(163.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[9], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[9], 60.000000, 28.000000);
	TextDrawAlignment(icc_td[9], 1);
	TextDrawColor(icc_td[9], 665739519);
	TextDrawSetShadow(icc_td[9], 0);
	TextDrawSetOutline(icc_td[9], 0);
	TextDrawBackgroundColor(icc_td[9], 255);
	TextDrawFont(icc_td[9], 4);
	TextDrawSetProportional(icc_td[9], 0);
	TextDrawSetShadow(icc_td[9], 0);
	TextDrawSetSelectable(icc_td[9], true);

	icc_td[10] = TextDrawCreate(224.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[10], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[10], 60.000000, 28.000000);
	TextDrawAlignment(icc_td[10], 1);
	TextDrawColor(icc_td[10], 877223679);
	TextDrawSetShadow(icc_td[10], 0);
	TextDrawSetOutline(icc_td[10], 0);
	TextDrawBackgroundColor(icc_td[10], 255);
	TextDrawFont(icc_td[10], 4);
	TextDrawSetProportional(icc_td[10], 0);
	TextDrawSetShadow(icc_td[10], 0);
	TextDrawSetSelectable(icc_td[10], true);

	icc_td[11] = TextDrawCreate(285.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[11], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[11], 60.000000, 28.000000);
	TextDrawAlignment(icc_td[11], 1);
	TextDrawColor(icc_td[11], -1069995009);
	TextDrawSetShadow(icc_td[11], 0);
	TextDrawSetOutline(icc_td[11], 0);
	TextDrawBackgroundColor(icc_td[11], 255);
	TextDrawFont(icc_td[11], 4);
	TextDrawSetProportional(icc_td[11], 0);
	TextDrawSetShadow(icc_td[11], 0);
	TextDrawSetSelectable(icc_td[11], true);

	icc_td[12] = TextDrawCreate(346.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[12], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[12], 39.000000, 28.000000);
	TextDrawAlignment(icc_td[12], 1);
	TextDrawColor(icc_td[12], -427941121);
	TextDrawSetShadow(icc_td[12], 0);
	TextDrawSetOutline(icc_td[12], 0);
	TextDrawBackgroundColor(icc_td[12], 255);
	TextDrawFont(icc_td[12], 4);
	TextDrawSetProportional(icc_td[12], 0);
	TextDrawSetShadow(icc_td[12], 0);
	TextDrawSetSelectable(icc_td[12], true);

	icc_td[13] = TextDrawCreate(386.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[13], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[13], 29.000000, 28.000000);
	TextDrawAlignment(icc_td[13], 1);
	TextDrawColor(icc_td[13], -256);
	TextDrawSetShadow(icc_td[13], 0);
	TextDrawSetOutline(icc_td[13], 0);
	TextDrawBackgroundColor(icc_td[13], 255);
	TextDrawFont(icc_td[13], 4);
	TextDrawSetProportional(icc_td[13], 0);
	TextDrawSetShadow(icc_td[13], 0);
	TextDrawSetSelectable(icc_td[13], true);

	icc_td[14] = TextDrawCreate(419.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[14], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[14], 78.000000, 27.000000);
	TextDrawAlignment(icc_td[14], 1);
	TextDrawColor(icc_td[14], 696302079);
	TextDrawSetShadow(icc_td[14], 0);
	TextDrawSetOutline(icc_td[14], 0);
	TextDrawBackgroundColor(icc_td[14], 255);
	TextDrawFont(icc_td[14], 4);
	TextDrawSetProportional(icc_td[14], 0);
	TextDrawSetShadow(icc_td[14], 0);
	TextDrawSetSelectable(icc_td[14], true);

	icc_td[15] = TextDrawCreate(498.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[15], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[15], 67.000000, 27.000000);
	TextDrawAlignment(icc_td[15], 1);
	TextDrawColor(icc_td[15], 701391103);
	TextDrawSetShadow(icc_td[15], 0);
	TextDrawSetOutline(icc_td[15], 0);
	TextDrawBackgroundColor(icc_td[15], 255);
	TextDrawFont(icc_td[15], 4);
	TextDrawSetProportional(icc_td[15], 0);
	TextDrawSetShadow(icc_td[15], 0);
	TextDrawSetSelectable(icc_td[15], true);

	icc_td[16] = TextDrawCreate(566.000000, 383.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[16], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[16], 67.000000, 27.000000);
	TextDrawAlignment(icc_td[16], 1);
	TextDrawColor(icc_td[16], -427941121);
	TextDrawSetShadow(icc_td[16], 0);
	TextDrawSetOutline(icc_td[16], 0);
	TextDrawBackgroundColor(icc_td[16], 255);
	TextDrawFont(icc_td[16], 4);
	TextDrawSetProportional(icc_td[16], 0);
	TextDrawSetShadow(icc_td[16], 0);
	TextDrawSetSelectable(icc_td[16], true);

	icc_td[17] = TextDrawCreate(6.000000, 304.000000, "LD_SPAC:white");
	TextDrawLetterSize(icc_td[17], 0.000000, 0.000000);
	TextDrawTextSize(icc_td[17], 153.000000, 25.000000);
	TextDrawAlignment(icc_td[17], 1);
	TextDrawColor(icc_td[17], 665739519);
	TextDrawSetShadow(icc_td[17], 0);
	TextDrawSetOutline(icc_td[17], 0);
	TextDrawBackgroundColor(icc_td[17], 255);
	TextDrawFont(icc_td[17], 4);
	TextDrawSetProportional(icc_td[17], 0);
	TextDrawSetShadow(icc_td[17], 0);
	TextDrawSetSelectable(icc_td[17], true);

	icc_td[18] = TextDrawCreate(188.000000, 147.000000, "Pavadinimas                                            kiekis         svoris");
	TextDrawLetterSize(icc_td[18], 0.180732, 1.115831);
	TextDrawAlignment(icc_td[18], 1);
	TextDrawColor(icc_td[18], -1);
	TextDrawSetShadow(icc_td[18], 0);
	TextDrawSetOutline(icc_td[18], 0);
	TextDrawBackgroundColor(icc_td[18], 255);
	TextDrawFont(icc_td[18], 2);
	TextDrawSetProportional(icc_td[18], 1);
	TextDrawSetShadow(icc_td[18], 0);

	icc_td[19] = TextDrawCreate(443.000000, 147.000000, "Pavadinimas                             kiekis");
	TextDrawLetterSize(icc_td[19], 0.180732, 1.115831);
	TextDrawAlignment(icc_td[19], 1);
	TextDrawColor(icc_td[19], -1);
	TextDrawSetShadow(icc_td[19], 0);
	TextDrawSetOutline(icc_td[19], 0);
	TextDrawBackgroundColor(icc_td[19], 255);
	TextDrawFont(icc_td[19], 2);
	TextDrawSetProportional(icc_td[19], 1);
	TextDrawSetShadow(icc_td[19], 0);

	icc_td[20] = TextDrawCreate(171.000000, 149.000000, "#");
	TextDrawLetterSize(icc_td[20], 0.248667, 0.864999);
	TextDrawAlignment(icc_td[20], 1);
	TextDrawColor(icc_td[20], -1);
	TextDrawSetShadow(icc_td[20], 0);
	TextDrawSetOutline(icc_td[20], 0);
	TextDrawBackgroundColor(icc_td[20], 255);
	TextDrawFont(icc_td[20], 1);
	TextDrawSetProportional(icc_td[20], 1);
	TextDrawSetShadow(icc_td[20], 0);

	icc_td[21] = TextDrawCreate(424.000000, 149.000000, "#");
	TextDrawLetterSize(icc_td[21], 0.248667, 0.864999);
	TextDrawAlignment(icc_td[21], 1);
	TextDrawColor(icc_td[21], -1);
	TextDrawSetShadow(icc_td[21], 0);
	TextDrawSetOutline(icc_td[21], 0);
	TextDrawBackgroundColor(icc_td[21], 255);
	TextDrawFont(icc_td[21], 1);
	TextDrawSetProportional(icc_td[21], 1);
	TextDrawSetShadow(icc_td[21], 0);

	icc_td[22] = TextDrawCreate(174.000000, 391.000000, "Naudoti");
	TextDrawLetterSize(icc_td[22], 0.217744, 1.372499);
	TextDrawAlignment(icc_td[22], 1);
	TextDrawColor(icc_td[22], -1);
	TextDrawSetShadow(icc_td[22], 0);
	TextDrawSetOutline(icc_td[22], 0);
	TextDrawBackgroundColor(icc_td[22], 255);
	TextDrawFont(icc_td[22], 2);
	TextDrawSetProportional(icc_td[22], 1);
	TextDrawSetShadow(icc_td[22], 0);

	icc_td[23] = TextDrawCreate(238.000000, 391.000000, "Ismesti");
	TextDrawLetterSize(icc_td[23], 0.217744, 1.372499);
	TextDrawAlignment(icc_td[23], 1);
	TextDrawColor(icc_td[23], -1);
	TextDrawSetShadow(icc_td[23], 0);
	TextDrawSetOutline(icc_td[23], 0);
	TextDrawBackgroundColor(icc_td[23], 255);
	TextDrawFont(icc_td[23], 2);
	TextDrawSetProportional(icc_td[23], 1);
	TextDrawSetShadow(icc_td[23], 0);

	icc_td[24] = TextDrawCreate(292.000000, 391.000000, "Sunaikinti");
	TextDrawLetterSize(icc_td[24], 0.217744, 1.372499);
	TextDrawAlignment(icc_td[24], 1);
	TextDrawColor(icc_td[24], -1);
	TextDrawSetShadow(icc_td[24], 0);
	TextDrawSetOutline(icc_td[24], 0);
	TextDrawBackgroundColor(icc_td[24], 255);
	TextDrawFont(icc_td[24], 2);
	TextDrawSetProportional(icc_td[24], 1);
	TextDrawSetShadow(icc_td[24], 0);

	icc_td[25] = TextDrawCreate(356.000000, 391.000000, "Info");
	TextDrawLetterSize(icc_td[25], 0.217744, 1.372499);
	TextDrawAlignment(icc_td[25], 1);
	TextDrawColor(icc_td[25], -1);
	TextDrawSetShadow(icc_td[25], 0);
	TextDrawSetOutline(icc_td[25], 0);
	TextDrawBackgroundColor(icc_td[25], 255);
	TextDrawFont(icc_td[25], 2);
	TextDrawSetProportional(icc_td[25], 1);
	TextDrawSetShadow(icc_td[25], 0);

	icc_td[26] = TextDrawCreate(600.000000, 390.000000, "Informacija");
	TextDrawLetterSize(icc_td[26], 0.217744, 1.372499);
	TextDrawAlignment(icc_td[26], 2);
	TextDrawColor(icc_td[26], -1);
	TextDrawSetShadow(icc_td[26], 0);
	TextDrawSetOutline(icc_td[26], 0);
	TextDrawBackgroundColor(icc_td[26], 255);
	TextDrawFont(icc_td[26], 2);
	TextDrawSetProportional(icc_td[26], 1);
	TextDrawSetShadow(icc_td[26], 0);

	icc_td[27] = TextDrawCreate(84.000000, 309.000000, "Gaminti");
	TextDrawLetterSize(icc_td[27], 0.217744, 1.372499);
	TextDrawAlignment(icc_td[27], 2);
	TextDrawColor(icc_td[27], -1);
	TextDrawSetShadow(icc_td[27], 0);
	TextDrawSetOutline(icc_td[27], 0);
	TextDrawBackgroundColor(icc_td[27], 255);
	TextDrawFont(icc_td[27], 2);
	TextDrawSetProportional(icc_td[27], 1);
	TextDrawSetShadow(icc_td[27], 0);

	icc_td[28] = TextDrawCreate(396.000000, 132.000000, "ESC");
	TextDrawLetterSize(icc_td[28], 0.174172, 1.168332);
	TextDrawAlignment(icc_td[28], 1);
	TextDrawColor(icc_td[28], -414434049);
	TextDrawSetShadow(icc_td[28], 0);
	TextDrawSetOutline(icc_td[28], 0);
	TextDrawBackgroundColor(icc_td[28], 255);
	TextDrawFont(icc_td[28], 2);
	TextDrawSetProportional(icc_td[28], 1);
	TextDrawSetShadow(icc_td[28], 0);

	icc_td[29] = TextDrawCreate(621.000000, 131.000000, "X");
	TextDrawLetterSize(icc_td[29], 0.174172, 1.168332);
	TextDrawTextSize(icc_td[29], 15.000000, 15.000000);
	TextDrawAlignment(icc_td[29], 2);
	TextDrawColor(icc_td[29], -414434049);
	TextDrawUseBox(icc_td[29], 1);
	TextDrawBoxColor(icc_td[29], 16);
	TextDrawSetShadow(icc_td[29], 0);
	TextDrawSetOutline(icc_td[29], 0);
	TextDrawBackgroundColor(icc_td[29], 255);
	TextDrawFont(icc_td[29], 2);
	TextDrawSetProportional(icc_td[29], 1);
	TextDrawSetShadow(icc_td[29], 0);
	TextDrawSetSelectable(icc_td[29], true);

	icc_td[30] = TextDrawCreate(147.000000, 132.000000, "X");
	TextDrawLetterSize(icc_td[30], 0.174172, 1.168332);
	TextDrawTextSize(icc_td[30], 15.000000, 15.000000);
	TextDrawAlignment(icc_td[30], 2);
	TextDrawColor(icc_td[30], -414434049);
	TextDrawUseBox(icc_td[30], 1);
	TextDrawBoxColor(icc_td[30], 16);
	TextDrawSetShadow(icc_td[30], 0);
	TextDrawSetOutline(icc_td[30], 0);
	TextDrawBackgroundColor(icc_td[30], 255);
	TextDrawFont(icc_td[30], 2);
	TextDrawSetProportional(icc_td[30], 1);
	TextDrawSetShadow(icc_td[30], 0);
	TextDrawSetSelectable(icc_td[30], true);

	icc_td[31] = TextDrawCreate(271.000000, 362.000000, "<-");
	TextDrawLetterSize(icc_td[31], 0.276778, 1.518332);
	TextDrawTextSize(icc_td[31], 16.000000, 16.000000);
	TextDrawAlignment(icc_td[31], 2);
	TextDrawColor(icc_td[31], -1);
	TextDrawUseBox(icc_td[31], 1);
	TextDrawBoxColor(icc_td[31], -248);
	TextDrawSetShadow(icc_td[31], 0);
	TextDrawSetOutline(icc_td[31], 0);
	TextDrawBackgroundColor(icc_td[31], 255);
	TextDrawFont(icc_td[31], 2);
	TextDrawSetProportional(icc_td[31], 1);
	TextDrawSetShadow(icc_td[31], 0);
	TextDrawSetSelectable(icc_td[31], true);

	icc_td[32] = TextDrawCreate(311.000000, 362.000000, "->");
	TextDrawLetterSize(icc_td[32], 0.276778, 1.518332);
	TextDrawTextSize(icc_td[32], 16.000000, 16.000000);
	TextDrawAlignment(icc_td[32], 2);
	TextDrawColor(icc_td[32], -1);
	TextDrawUseBox(icc_td[32], 1);
	TextDrawBoxColor(icc_td[32], -248);
	TextDrawSetShadow(icc_td[32], 0);
	TextDrawSetOutline(icc_td[32], 0);
	TextDrawBackgroundColor(icc_td[32], 255);
	TextDrawFont(icc_td[32], 2);
	TextDrawSetProportional(icc_td[32], 1);
	TextDrawSetShadow(icc_td[32], 0);
	TextDrawSetSelectable(icc_td[32], true);

	icc_td[33] = TextDrawCreate(507.000000, 362.000000, "<-");
	TextDrawLetterSize(icc_td[33], 0.276778, 1.518332);
	TextDrawTextSize(icc_td[33], 16.000000, 16.000000);
	TextDrawAlignment(icc_td[33], 2);
	TextDrawColor(icc_td[33], -1);
	TextDrawUseBox(icc_td[33], 1);
	TextDrawBoxColor(icc_td[33], -248);
	TextDrawSetShadow(icc_td[33], 0);
	TextDrawSetOutline(icc_td[33], 0);
	TextDrawBackgroundColor(icc_td[33], 255);
	TextDrawFont(icc_td[33], 2);
	TextDrawSetProportional(icc_td[33], 1);
	TextDrawSetShadow(icc_td[33], 0);
	TextDrawSetSelectable(icc_td[33], true);

	icc_td[34] = TextDrawCreate(547.000000, 362.000000, "->");
	TextDrawLetterSize(icc_td[34], 0.276778, 1.518332);
	TextDrawTextSize(icc_td[34], 16.000000, 16.000000);
	TextDrawAlignment(icc_td[34], 2);
	TextDrawColor(icc_td[34], -1);
	TextDrawUseBox(icc_td[34], 1);
	TextDrawBoxColor(icc_td[34], -248);
	TextDrawSetShadow(icc_td[34], 0);
	TextDrawSetOutline(icc_td[34], 0);
	TextDrawBackgroundColor(icc_td[34], 255);
	TextDrawFont(icc_td[34], 2);
	TextDrawSetProportional(icc_td[34], 1);
	TextDrawSetShadow(icc_td[34], 0);
	TextDrawSetSelectable(icc_td[34], true);

	icc_td[35] = TextDrawCreate(395.000000, 386.000000, "-");
	TextDrawLetterSize(icc_td[35], 0.749985, 1.302498);
	TextDrawAlignment(icc_td[35], 1);
	TextDrawColor(icc_td[35], 255);
	TextDrawSetShadow(icc_td[35], 0);
	TextDrawSetOutline(icc_td[35], 0);
	TextDrawBackgroundColor(icc_td[35], 255);
	TextDrawFont(icc_td[35], 1);
	TextDrawSetProportional(icc_td[35], 1);
	TextDrawSetShadow(icc_td[35], 0);

	icc_td[36] = TextDrawCreate(395.000000, 390.000000, "-");
	TextDrawLetterSize(icc_td[36], 0.749985, 1.302498);
	TextDrawAlignment(icc_td[36], 1);
	TextDrawColor(icc_td[36], 255);
	TextDrawSetShadow(icc_td[36], 0);
	TextDrawSetOutline(icc_td[36], 0);
	TextDrawBackgroundColor(icc_td[36], 255);
	TextDrawFont(icc_td[36], 1);
	TextDrawSetProportional(icc_td[36], 1);
	TextDrawSetShadow(icc_td[36], 0);

	icc_td[37] = TextDrawCreate(395.000000, 394.000000, "-");
	TextDrawLetterSize(icc_td[37], 0.749985, 1.302498);
	TextDrawAlignment(icc_td[37], 1);
	TextDrawColor(icc_td[37], 255);
	TextDrawSetShadow(icc_td[37], 0);
	TextDrawSetOutline(icc_td[37], 0);
	TextDrawBackgroundColor(icc_td[37], 255);
	TextDrawFont(icc_td[37], 1);
	TextDrawSetProportional(icc_td[37], 1);
	TextDrawSetShadow(icc_td[37], 0);

	for(new i; i < 8; ++i) {
		inventory_row_td[i] = TextDrawCreate(167.000000, 161.000000 + (25.0 * i), "LD_SPAC:white");
		TextDrawLetterSize(inventory_row_td[i], 0.000000, 0.000000);
		TextDrawTextSize(inventory_row_td[i], 241.000000, 25.00000);
		TextDrawAlignment(inventory_row_td[i], 1);
		TextDrawColor(inventory_row_td[i], 877223679);
		TextDrawSetShadow(inventory_row_td[i], 0);
		TextDrawSetOutline(inventory_row_td[i], 0);
		TextDrawBackgroundColor(inventory_row_td[i], 255);
		TextDrawFont(inventory_row_td[i], 4);
		TextDrawSetProportional(inventory_row_td[i], 0);
		TextDrawSetShadow(inventory_row_td[i], 0);
		TextDrawSetSelectable(inventory_row_td[i], true);
	}

	for(new i; i < 8; ++i) {
		container_row_td[i] = TextDrawCreate(423.000000, 161.000000 + (25.0 * i), "LD_SPAC:white");
		TextDrawLetterSize(container_row_td[i], 0.000000, 0.000000);
		TextDrawTextSize(container_row_td[i], 208.000000, 25.000000);
		TextDrawAlignment(container_row_td[i], 1);
		TextDrawColor(container_row_td[i], 877223679);
		TextDrawSetShadow(container_row_td[i], 0);
		TextDrawSetOutline(container_row_td[i], 0);
		TextDrawBackgroundColor(container_row_td[i], 255);
		TextDrawFont(container_row_td[i], 4);
		TextDrawSetProportional(container_row_td[i], 0);
		TextDrawSetShadow(container_row_td[i], 0);
		TextDrawSetSelectable(container_row_td[i], true);
	}
}

hook OnPlayerConnect(playerid) {


	for(new i; i < 8; ++i) {
		inventory_row_item_name_ptd[playerid][i] = CreatePlayerTextDraw(playerid, 192.000000, 166.000000 + (25.0 * i), "Daikto pavadinimas");
		PlayerTextDrawLetterSize(playerid, inventory_row_item_name_ptd[playerid][i], 0.182606, 1.232500);
		PlayerTextDrawAlignment(playerid, inventory_row_item_name_ptd[playerid][i], 1);
		PlayerTextDrawColor(playerid, inventory_row_item_name_ptd[playerid][i], -1);
		PlayerTextDrawSetShadow(playerid, inventory_row_item_name_ptd[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, inventory_row_item_name_ptd[playerid][i], 0);
		PlayerTextDrawBackgroundColor(playerid, inventory_row_item_name_ptd[playerid][i], 255);
		PlayerTextDrawFont(playerid, inventory_row_item_name_ptd[playerid][i], 2);
		PlayerTextDrawSetProportional(playerid, inventory_row_item_name_ptd[playerid][i], 1);
		PlayerTextDrawSetShadow(playerid, inventory_row_item_name_ptd[playerid][i], 0);
	}

	for(new i; i < 8; ++i) {
		container_row_item_name_ptd[playerid][i] = CreatePlayerTextDraw(playerid, 446.000000, 166.000000 + (25.0 * i), "Daikto pavadinimas");
		PlayerTextDrawLetterSize(playerid, container_row_item_name_ptd[playerid][i], 0.182606, 1.232500);
		PlayerTextDrawAlignment(playerid, container_row_item_name_ptd[playerid][i], 1);
		PlayerTextDrawColor(playerid, container_row_item_name_ptd[playerid][i], -1);
		PlayerTextDrawSetShadow(playerid, container_row_item_name_ptd[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, container_row_item_name_ptd[playerid][i], 0);
		PlayerTextDrawBackgroundColor(playerid, container_row_item_name_ptd[playerid][i], 255);
		PlayerTextDrawFont(playerid, container_row_item_name_ptd[playerid][i], 2);
		PlayerTextDrawSetProportional(playerid, container_row_item_name_ptd[playerid][i], 1);
		PlayerTextDrawSetShadow(playerid, container_row_item_name_ptd[playerid][i], 0);
	}

	for(new i; i < 7; ++i) {
		crafting_row_item_name_ptd[playerid][i] = CreatePlayerTextDraw(playerid, 12.000000, 150.000000 + (18.0 * i), "  material");
		PlayerTextDrawLetterSize(playerid, crafting_row_item_name_ptd[playerid][i], 0.219619, 1.372499);
		PlayerTextDrawTextSize(playerid, crafting_row_item_name_ptd[playerid][i], 153.000000, 16.000000);
		PlayerTextDrawAlignment(playerid, crafting_row_item_name_ptd[playerid][i], 1);
		PlayerTextDrawColor(playerid, crafting_row_item_name_ptd[playerid][i], -1);
		PlayerTextDrawUseBox(playerid, crafting_row_item_name_ptd[playerid][i], 1);
		PlayerTextDrawBoxColor(playerid, crafting_row_item_name_ptd[playerid][i], -240);
		PlayerTextDrawSetShadow(playerid, crafting_row_item_name_ptd[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, crafting_row_item_name_ptd[playerid][i], 0);
		PlayerTextDrawBackgroundColor(playerid, crafting_row_item_name_ptd[playerid][i], 255);
		PlayerTextDrawFont(playerid, crafting_row_item_name_ptd[playerid][i], 2);
		PlayerTextDrawSetProportional(playerid, crafting_row_item_name_ptd[playerid][i], 1);
		PlayerTextDrawSetShadow(playerid, crafting_row_item_name_ptd[playerid][i], 0);
		PlayerTextDrawSetSelectable(playerid, crafting_row_item_name_ptd[playerid][i], true);
	}

	icc_ptd[playerid][icc_container_name] = CreatePlayerTextDraw(playerid, 518.000000, 131.000000, " Ginklu parduotuve");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_container_name], 0.218682, 1.121666);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_container_name], 2);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_container_name], -238809089);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_name], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_container_name], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_container_name], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_container_name], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_container_name], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_name], 0);

	icc_ptd[playerid][icc_container_key] = CreatePlayerTextDraw(playerid, 629.000000, 147.000000, "kaina");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_container_key], 0.180732, 1.115831);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_container_key], 3);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_container_key], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_key], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_container_key], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_container_key], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_container_key], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_container_key], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_key], 0);

	icc_ptd[playerid][icc_container_first_btn] = CreatePlayerTextDraw(playerid, 458.000000, 390.000000, "Pirkti");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_container_first_btn], 0.217744, 1.372499);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_container_first_btn], 2);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_container_first_btn], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_first_btn], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_container_first_btn], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_container_first_btn], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_container_first_btn], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_container_first_btn], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_first_btn], 0);

	icc_ptd[playerid][icc_container_second_btn] = CreatePlayerTextDraw(playerid, 532.000000, 390.000000, "parduoti");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_container_second_btn], 0.217744, 1.372499);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_container_second_btn], 2);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_container_second_btn], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_second_btn], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_container_second_btn], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_container_second_btn], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_container_second_btn], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_container_second_btn], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_second_btn], 0);

	icc_ptd[playerid][icc_inventory_rows] = CreatePlayerTextDraw(playerid, 178.000000, 166.000000, "1.~n~~n~2.~n~~n~3.~n~~n~4.~n~~n~5.~n~~n~6.~n~~n~7.~n~~n~8.~n~");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_inventory_rows], 0.216808, 1.378333);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_inventory_rows], 3);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_inventory_rows], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_inventory_rows], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_inventory_rows], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_inventory_rows], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_inventory_rows], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_inventory_rows], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_inventory_rows], 0);

	icc_ptd[playerid][icc_container_rows] = CreatePlayerTextDraw(playerid, 433.000000, 166.000000, "1.~n~~n~2.~n~~n~3.~n~~n~4.~n~~n~5.~n~~n~6.~n~~n~7.~n~~n~8.~n~");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_container_rows], 0.216808, 1.378333);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_container_rows], 3);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_container_rows], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_rows], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_container_rows], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_container_rows], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_container_rows], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_container_rows], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_rows], 0);

	icc_ptd[playerid][icc_inventory_amount] = CreatePlayerTextDraw(playerid, 353.000000, 166.000000, "6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_inventory_amount], 0.216808, 1.378333);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_inventory_amount], 3);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_inventory_amount], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_inventory_amount], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_inventory_amount], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_inventory_amount], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_inventory_amount], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_inventory_amount], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_inventory_amount], 0);

	icc_ptd[playerid][icc_inventory_weight] = CreatePlayerTextDraw(playerid, 399.000000, 166.000000, "32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_inventory_weight], 0.216808, 1.378333);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_inventory_weight], 3);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_inventory_weight], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_inventory_weight], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_inventory_weight], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_inventory_weight], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_inventory_weight], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_inventory_weight], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_inventory_weight], 0);

	icc_ptd[playerid][icc_container_amount] = CreatePlayerTextDraw(playerid, 575.000000, 166.000000, "6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~6~n~~n~");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_container_amount], 0.216808, 1.378333);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_container_amount], 3);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_container_amount], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_amount], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_container_amount], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_container_amount], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_container_amount], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_container_amount], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_amount], 0);

	icc_ptd[playerid][icc_container_value] = CreatePlayerTextDraw(playerid, 626.000000, 166.000000, "32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~32~n~~n~");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][icc_container_value], 0.216808, 1.378333);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][icc_container_value], 3);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][icc_container_value], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_value], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][icc_container_value], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][icc_container_value], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][icc_container_value], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][icc_container_value], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][icc_container_value], 0);

	crafting_result_item[playerid] = CreatePlayerTextDraw(playerid, 11.000000, 286.000000, " Pagamintas daiktas");
	PlayerTextDrawLetterSize(playerid, crafting_result_item[playerid], 0.173704, 1.150833);
	PlayerTextDrawTextSize(playerid, crafting_result_item[playerid], 130.000000, 16.000000);
	PlayerTextDrawAlignment(playerid, crafting_result_item[playerid], 1);
	PlayerTextDrawColor(playerid, crafting_result_item[playerid], -1);
	PlayerTextDrawUseBox(playerid, crafting_result_item[playerid], 1);
	PlayerTextDrawBoxColor(playerid, crafting_result_item[playerid], -240);
	PlayerTextDrawSetShadow(playerid, crafting_result_item[playerid], 0);
	PlayerTextDrawSetOutline(playerid, crafting_result_item[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, crafting_result_item[playerid], 255);
	PlayerTextDrawFont(playerid, crafting_result_item[playerid], 2);
	PlayerTextDrawSetProportional(playerid, crafting_result_item[playerid], 1);
	PlayerTextDrawSetShadow(playerid, crafting_result_item[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, crafting_result_item[playerid], true);

	crafting_success_rate[playerid] = CreatePlayerTextDraw(playerid, 155.000000, 286.000000, "76%");
	PlayerTextDrawLetterSize(playerid, crafting_success_rate[playerid], 0.173704, 1.150833);
	PlayerTextDrawAlignment(playerid, crafting_success_rate[playerid], 3);
	PlayerTextDrawColor(playerid, crafting_success_rate[playerid], 785150463);
	PlayerTextDrawSetShadow(playerid, crafting_success_rate[playerid], 0);
	PlayerTextDrawSetOutline(playerid, crafting_success_rate[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, crafting_success_rate[playerid], 255);
	PlayerTextDrawFont(playerid, crafting_success_rate[playerid], 2);
	PlayerTextDrawSetProportional(playerid, crafting_success_rate[playerid], 1);
	PlayerTextDrawSetShadow(playerid, crafting_success_rate[playerid], 0);

	icc_ptd[playerid][inventory_current_page] = CreatePlayerTextDraw(playerid, 291.000000, 362.000000, "42");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][inventory_current_page], 0.232737, 1.442498);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][inventory_current_page], 2);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][inventory_current_page], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][inventory_current_page], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][inventory_current_page], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][inventory_current_page], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][inventory_current_page], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][inventory_current_page], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][inventory_current_page], 0);

	icc_ptd[playerid][container_current_page] = CreatePlayerTextDraw(playerid, 527.000000, 362.000000, "42");
	PlayerTextDrawLetterSize(playerid, icc_ptd[playerid][container_current_page], 0.232737, 1.442498);
	PlayerTextDrawAlignment(playerid, icc_ptd[playerid][container_current_page], 2);
	PlayerTextDrawColor(playerid, icc_ptd[playerid][container_current_page], -1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][container_current_page], 0);
	PlayerTextDrawSetOutline(playerid, icc_ptd[playerid][container_current_page], 0);
	PlayerTextDrawBackgroundColor(playerid, icc_ptd[playerid][container_current_page], 255);
	PlayerTextDrawFont(playerid, icc_ptd[playerid][container_current_page], 2);
	PlayerTextDrawSetProportional(playerid, icc_ptd[playerid][container_current_page], 1);
	PlayerTextDrawSetShadow(playerid, icc_ptd[playerid][container_current_page], 0);
}