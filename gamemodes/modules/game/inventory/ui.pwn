#include <YSI_Coding\y_hooks>

static inventory_td[] = {
	0, 3, 7, 9, 10, 11, 12, 13, 18, 20, 22, 23, 24, 25, 28, 31, 32, 35, 36, 37
};

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if(IsInventoryClosed(playerid)) {
		return;
	}
	if(Dialog_Get(playerid) != -1) {
		return;
	}
	for(new row; row < 8; ++row) {
		if(clickedid == InventoryRow_TD(row)) {
			Inv_SelectItem(playerid, row);
			break;
		}
	}
	if(clickedid == INVALID_TEXT_DRAW) {
		CloseInventory(playerid);
	}
	if(clickedid == icc_TD(icc_inventory_use_btn)) {
		Inv_UseSelectedItem(playerid);
	}
	if(clickedid == icc_TD(icc_inventory_drop_btn)) {
		Inv_DropSelectedItem(playerid);
	}
	if(clickedid == icc_TD(icc_inventory_destroy_btn)) {
		Inv_DestroySelectedItem(playerid);
	}
	if(clickedid == icc_TD(icc_inventory_info_btn)) {
		Inv_SelectedItemInformation(playerid);
	}
	if(clickedid == icc_TD(icc_inventory_more_btn)) {
		Inv_ManageSelectedItem(playerid);
	}
	if(clickedid == icc_TD(icc_inventory_prev_btn)) { // atgal
		Inv_ShowPreviousPage(playerid);
	}
	if(clickedid == icc_TD(icc_inventory_next_btn)) { // pirmyn
		Inv_ShowNextPage(playerid);
	}
}

ShowInventoryOptions(playerid) {
	TextDrawTextSize(icc_TD(0), 254.0, 285.0);
	TextDrawShowForPlayer(playerid, icc_TD(0));

	TextDrawColor(icc_TD(icc_inventory_use_btn), 0x7F8C8DFF);
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_use_btn));
	
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_drop_btn));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_drop_txt));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_destroy_btn));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_destroy_txt));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_info_btn));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_info_txt));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_more_btn));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_more_txt1));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_more_txt2));
	TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_more_txt3));
}

HideInventoryOptions(playerid) {
	TextDrawTextSize(icc_TD(0), 254.0, 256.0);
	TextDrawShowForPlayer(playerid, icc_TD(0));

	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_use_btn));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_use_txt));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_drop_btn));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_drop_txt));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_destroy_btn));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_destroy_txt));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_info_btn));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_info_txt));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_more_btn));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_more_txt1));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_more_txt2));
	TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_more_txt3));
}

ShowInventoryRow(playerid, row) {
	PlayerTextDrawShow(playerid, InventoryRow_ItemName_PTD(playerid, row));
	TextDrawShowForPlayer(playerid, InventoryRow_TD(row));
}

HideInventoryRow(playerid, row) {
	PlayerTextDrawHide(playerid, InventoryRow_ItemName_PTD(playerid, row));
	TextDrawHideForPlayer(playerid, InventoryRow_TD(row));
}

ShowInventory(playerid, update_rows = false) {
	foreach(new i : Array(inventory_td)) {
		TextDrawShowForPlayer(playerid, icc_TD(i));
	}
	HideInventoryOptions(playerid);

	if(update_rows) {
		foreach(new i : Array(_:inventory_row_item_name_ptd[playerid])) {
			PlayerTextDrawShow(playerid, PlayerText:i);
		}
	}
}

HideInventory(playerid) {
	foreach(new i : Array(inventory_td)) {
		TextDrawHideForPlayer(playerid, icc_TD(i));
	}
	foreach(new i : Limit(8)) {
		HideInventoryRow(playerid, i);
	}
	foreach(new i : Array(icc_ptd[playerid])) {
		PlayerTextDrawHide(playerid, PlayerText:i);
	}
}