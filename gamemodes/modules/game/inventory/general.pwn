#include <YSI_Coding\y_hooks>

#define GetSelectedItem Item:_GetSelectedItem

forward OnPlayerSelectItem(playerid, item_name[], Item:uiid);
forward OnPlayerUseItem(playerid, item_name[], Item:uiid);

static   isInventoryOpen [MAX_PLAYERS char];
static       selectedRow [MAX_PLAYERS char];
static  Item:listedItems [MAX_PLAYERS][8];
static       currentPage [MAX_PLAYERS];

hook OnResetPlayerVars(playerid) {
	isInventoryOpen{playerid} = 0;
	selectedRow{playerid} = NONE;
	currentPage[playerid] = 0;
}

hook OnCharacterDespawn(playerid) {
	new filename[50];
	format(filename, _, "%i_%s", GetPlayerCharID(playerid), player_Name[playerid]);
	Container_Save(Player, playerid, "scriptfiles/inventory", filename);
	Container_Clear(Player, playerid);
}

hook OnPlayerDataLoaded(playerid) {
	new filename[50];
	format(filename, _, "%i_%s", GetPlayerCharID(playerid), player_Name[playerid]);
	Container_Load(Player, playerid, "scriptfiles/inventory", filename);
	call OnInventoryLoaded(playerid);
}

CMD:open(playerid, params[]) {
	OpenInventory(playerid);
	return true;
}

CMD:itm(playerid, params[]) {
	new Item:uiid = CreateItem(params);
	Container_AddItem(Player, playerid, uiid);
	M:P:G(playerid, "[highlight]%s[] ádëtas á inventoriø.", params);
	return true;
}

IsInventoryClosed(playerid) {
	return ! isInventoryOpen{playerid};
}
IsInventoryOpen(playerid) {
	return isInventoryOpen{playerid};
}
OpenInventory(playerid) {
	if(IsInventoryOpen(playerid)) {
		Inv_UnselectCurrentRow(playerid);
		HideInventory(playerid);
	}
	isInventoryOpen{playerid} = true;
	selectedRow{playerid} = NONE;
	currentPage[playerid] = 0;

	SelectTextDraw(playerid, 0x5ED0B9FF);

	ShowInventory(playerid);

	ListInventoryItems(playerid);
}
CloseInventory(playerid) {
	call OnInventoryClose(playerid);

	isInventoryOpen{playerid} = false;

	CancelSelectTextDraw(playerid);

	Inv_UnselectCurrentRow(playerid);

	HideInventory(playerid);
}
Inv_SelectItem(playerid, row) {
	// paslepiam prieð tai paspaustà
	if(GetSelectedRow(playerid) != NONE) {
		Inv_UnselectCurrentRow(playerid);
	}
	if(DoubleClick(playerid, row)) {
		Inv_UseSelectedItem(playerid);
		selectedRow{playerid} = NONE;
	}
	else {
		// naujai paspaustas
		if(GetSelectedRow(playerid) != row) {
			TextDrawColor(InventoryRow_TD(row), 0x1ABC9CFF);
			TextDrawShowForPlayer(playerid, InventoryRow_TD(row));

			ShowInventoryOptions(playerid);

			selectedRow{playerid} = row;

			new item_name[32], Item:item = GetSelectedItem(playerid);
			GetItemName(item, item_name);

			if(call OnPlayerSelectItem(playerid, item_name, _:item)) {
				TextDrawColor(icc_TD(icc_inventory_use_btn), 665739519);
				TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_use_btn));
				TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_use_txt));
			}
			else {
				TextDrawColor(icc_TD(icc_inventory_use_btn), 0x7F8C8DFF);
				TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_use_btn));
				TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_use_txt));
			}
		}
		// tas pats paspaustas, atþymim
		else {
			selectedRow{playerid} = NONE;
		}
	}
}
Inv_UseSelectedItem(playerid) {
	new Item:item = GetSelectedItem(playerid);
	if( ! item) {
		return;
	}

	new item_name[32];
	GetItemName(item, item_name);

	call OnPlayerUseItem(playerid, item_name, _:item);
}
Inv_DropSelectedItem(playerid) {
	#pragma unused playerid
}
Inv_DestroySelectedItem(playerid) {
	new Item:item = GetSelectedItem(playerid);
	if(item) {
		inline confirm(re, li) {
			#pragma unused li
			if(re) {
				new item_name[32];
				GetItemName(item, item_name);
				
				if(DeleteItem(item)) {
					M:P:G(playerid, "\"[highlight]%s[]\" sunaikintas sëkmingai.", item_name);
					ListInventoryItems(playerid);
				}
				else {
					M:P:E(playerid, "\"[highlight]%s[]\" sunaikinti nepavyko.", item_name);
				}
			}
		}
		dialogSetHeader("Ar tikrai nori sunaikinti ðá daiktà?");
		dialogAddOption("Jis bus sunaikintas visam laikui.");
		dialogShow(playerid, using inline confirm, DIALOG_STYLE_MSGBOX, " ", g_DialogText, "Taip", "Atðaukti");
	}
}
Inv_SelectedItemInformation(playerid) {
	#pragma unused playerid
	DisplayItemInfo(playerid, GetSelectedItem(playerid));
}
Inv_ManageSelectedItem(playerid) {
	new item_name[32], Item:item = GetSelectedItem(playerid);
	GetItemName(item, item_name);

	inline response(re, li) {
		#pragma unused li
		if(re) {
			call OnSelectManagedItemMenu(playerid, item_name, item);
		}
	}
	
	dialogSetHeader("%s - Pasirinkimai", item_name);

	call OnOpenManagedItemMenu(playerid, item_name, _:item);

	dialogShow(playerid, using inline response, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atðaukti");
}
Inv_ShowPreviousPage(playerid) {
	if( ! IsFirstPage(playerid)) {
		ListInventoryItems(playerid, --currentPage[playerid]);
	}
}
Inv_ShowNextPage(playerid) {
	if( ! IsLatestPage(playerid)) {
		ListInventoryItems(playerid, ++currentPage[playerid]);
	}
}
Inv_Update(playerid) {
	ListInventoryItems(playerid);
}
Inv_UnselectCurrentRow(playerid) {
	HideInventoryOptions(playerid);

	if(GetSelectedRow(playerid) != NONE) {
		if(IsItemOnPlayer(playerid, GetSelectedItem(playerid))) {
			TextDrawColor(InventoryRow_TD(GetSelectedRow(playerid)), 0x27AE60FF);
		}
		else {
			TextDrawColor(InventoryRow_TD(GetSelectedRow(playerid)), 877223679);
		}
		TextDrawShowForPlayer(playerid, InventoryRow_TD(GetSelectedRow(playerid)));
	}
}
static _GetSelectedItem(playerid) {
	new row = GetSelectedRow(playerid);
	if(row == NONE) {
		return 0;
	}
	return _:listedItems[playerid][row];
}
static GetSelectedRow(playerid) {
	return selectedRow{playerid} == 255 ? NONE : selectedRow{playerid};
}
static DoubleClick(playerid, row) {
	static tick[MAX_PLAYERS];
	static last_row[MAX_PLAYERS char];

	if(last_row{playerid} == row) {
		if(tick[playerid] + 600 > GetTickCount()) {
			tick[playerid] = 0;
			return true;
		}
	}
	tick[playerid] = GetTickCount();
	last_row{playerid} = row;

	return false;
}
static GetPageUpperBound(playerid) {
	return floatround((-1.0 + Container_CountItems(Player, playerid)) / 8.0, floatround_floor);
}
static IsFirstPage(playerid) {
	return ! GetCurrentPage(playerid);
}
static IsLatestPage(playerid) {
	return GetCurrentPage(playerid) == GetPageUpperBound(playerid);
}
static GetCurrentPage(playerid) {
	return max(min(currentPage[playerid], GetPageUpperBound(playerid)), 0);
}

static ListInventoryItems(playerid, page = NONE) {
	if(page == NONE) {
		page = GetCurrentPage(playerid);
	}
	if(IsLatestPage(playerid))
		TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_next_btn));
	else TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_next_btn));

	if(IsFirstPage(playerid))
		TextDrawHideForPlayer(playerid, icc_TD(icc_inventory_prev_btn));
	else TextDrawShowForPlayer(playerid, icc_TD(icc_inventory_prev_btn));

	new index[256], amount[256], weight[256];
	
	new row = 0;

	new eq_count = Container_CountItems(Equipment, playerid);
	printf("eq_count: %i, page * 8: %i", eq_count, page * 8);
	if(eq_count > page * 8) {
		new eq_i = page * 8;
		while(row < 8 && eq_i < eq_count) {
			new Item:uiid = Container_GetItemAt(Equipment, playerid, eq_i);
			
			DisplayInventoryItem(playerid, row, eq_i, uiid, index, amount, weight, .equiped = true);

			++eq_i;
			++row;
		}
	}
	new i = (eq_count > page * 8) 
			? 0 
			: (page * 8 - eq_count);

	new count = Container_CountItems(Player, playerid);

	printf("count: %i, i: %i", count, i);
	while(row < 8 && i < count) {
		new Item:uiid = Container_GetItemAt(Player, playerid, i);

		DisplayInventoryItem(playerid, row, i + eq_count, uiid, index, amount, weight);
		
		++i;
		++row;
	}
	while(row < 8) {
		HideInventoryRow(playerid, row);
		++row;
	}
	
	Inv_UnselectCurrentRow(playerid);

	PlayerTextDrawSetString(playerid, icc_PTD(playerid, icc_inventory_rows), index);
	PlayerTextDrawSetString(playerid, icc_PTD(playerid, icc_inventory_amount), amount);
	PlayerTextDrawSetString(playerid, icc_PTD(playerid, icc_inventory_weight), weight);
	PlayerTextDrawShow(playerid, icc_PTD(playerid, icc_inventory_rows));
	PlayerTextDrawShow(playerid, icc_PTD(playerid, icc_inventory_amount));
	PlayerTextDrawShow(playerid, icc_PTD(playerid, icc_inventory_weight));
	PlayerTextDrawSetString(playerid, icc_PTD(playerid, inventory_current_page), F:0("%i", page + 1));
	PlayerTextDrawShow(playerid, icc_PTD(playerid, inventory_current_page));
}

DisplayInventoryItem(playerid, row, i, Item:uiid, index[], amount[], weight[], equiped = false, 
	indexsize = sizeof index, amountsize = sizeof amount, weightsize = sizeof weight
) {
	printf("DisplayInventoryItem %i @ row %i and index %i.%s", _:uiid, row, i, equiped?(" Equiped"):(""));

	new name[32];
	GetItemName(uiid, name);

	listedItems[playerid][row] = uiid;

	PlayerTextDrawSetString(playerid, InventoryRow_ItemName_PTD(playerid, row), name);
	PlayerTextDrawColor(playerid, InventoryRow_ItemName_PTD(playerid, row), GetItemColor(uiid, name));

	new item_info_count = max(GetItemInfo(uiid, "count"), 1);

	strcat(index, F:0("%i~n~~n~", i + 1), indexsize);
	strcat(amount, F:0("%i~n~~n~", item_info_count), amountsize);
	strcat(weight, F:0("%.2f~n~~n~", 0.001 * GetItemDefaultWeight(name) * item_info_count), weightsize);

	if(equiped) {
		TextDrawColor(InventoryRow_TD(row), 0x27AE60FF);
	}
	else {
		TextDrawColor(InventoryRow_TD(row), 0);
	}

	ShowInventoryRow(playerid, row);
}

/*CMD:what(playerid, unused[]) {
	new count = Container_CountItems(Player, playerid);

	M:P:X(playerid, "Daiktai inventoriuje:");
	while(row < 8 && i < count) {
		new Item:uiid = Container_GetItemAt(Player, playerid, i);
		M:P:X(playerid, "> %s (%i)", )
	}

	return true;
}*/

#undef GetSelectedItem