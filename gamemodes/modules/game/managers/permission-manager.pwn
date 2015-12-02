#include <YSI\y_hooks>

forward OnPermissionCheck(playerid, entity[], node[], child_node[], entity_id);

HasPermission(playerid, entity[], node[] = "", child_node[] = "", id = 0) {
	return call OnPermissionCheck(playerid, isnull(entity) ? ("\1") : entity, isnull(node) ? ("\1") : node, isnull(child_node) ? ("\1") : child_node, id);
}