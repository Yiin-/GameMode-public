// core
native Item:CreateItem(const name[]);
native DeleteItem({Item, _}:uiid);

// item info
native IsItemInContainer ({Item, _}:uiid);
native GetItemContainer  ({Item, _}:uiid, &containerType, &containerId);

native Item:GetItemInfo_OtherItem ({Item, _}:uiid, const key[]);
native SetItemInfo_OtherItem      ({Item, _}:uiid, const key[], {Item, _}:other_item_uiid);

// getters
native GetItemName           ({Item, _}:uiid, name[], len = sizeof name);
native GetItemInfo           ({Item, _}:uiid, const info[], infoType = 0);
native GetItemInfo_Text		 ({Item, _}:uiid, const info[], dest[], index = 0, len = sizeof dest);
native GetItemInfoUpperBound ({Item, _}:uiid, infoType = 0);
native GetItemInfoKey        ({Item, _}:uiid, index, key[], infoType = 0, len = sizeof key);
native GetItemInfoValue      ({Item, _}:uiid, index, infoType = 0);

// setters
native SetItemInfo	    ({Item, _}:uiid, const info[], value, infoType = 0);
native SetItemInfo_Text ({Item, _}:uiid, const info[], text[], infoType = 0);
native AdjustItemInfo	({Item, _}:uiid, const key[], difference, index = 0);
native DeleteItemInfo	({Item, _}:uiid, const info[], infoType = 0);
native ClearItemInfo	({Item, _}:uiid, infoType = 0);

// container
enum eContainerType {
	Player,
	Shop,
	Vehicle,
	World,
	Other
};

native Container_Save           (containerType, containerId, const path[], const filename[]);
native Container_Load           (containerType, containerId, const path[], const filename[]);

native Container_AddItem        (containerType, containerId, {Item, _}:uiid);
native Container_RemoveItem     (containerType, containerId, {Item, _}:uiid);

native Container_Clear          (containerType, containerId);
native Container_RemoveAll      (containerType, containerId);

native Container_CountItems     (containerType, containerId);
native bool:Container_HasItem   (containerType, containerId, const name[]);
native Item:Container_FindItem  (containerType, containerId, const name[], nth = 0);
native Item:Container_GetItemAt (containerType, containerId, slot);
native Container_GetItemSlot    (containerType, containerId, {Item, _}:uiid);

#define iterstart@Container 0
iterfunc Container(cur, type, id)F@a$ {
	static idx, size;
	if( ! cur) {
		idx = 0;
		size = Container_CountItems(type, id);
	}
	if(idx == size) {
		return 0;
	}
	static save_a_call;
	if(size != (save_a_call = Container_CountItems(type, id))) {
		size = save_a_call;
		return _:Container_GetItemAt(type, id, idx - 1);
	}
	else {
		return _:Container_GetItemAt(type, id, idx++);
	}
}