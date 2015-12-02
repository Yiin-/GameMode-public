#include <YSI_Coding\y_hooks>

hook OnPlayerLevelUp(playerid) {
	M:P:G(playerid, "Tavo nauajs lygis: %i", GetPlayerLevel(playerid));
}