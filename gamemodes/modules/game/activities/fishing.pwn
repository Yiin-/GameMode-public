

CMD:zvejoti(playerid, p[]) {
	new Float:depth = 0.0, Float:playerdepth = 0.0, isInWater;
	if(CA_IsPlayerInWater(playerid, depth, playerdepth)) {
		if(playerdepth > 0.0) {
			isInWater = 1;
		}
	}
	if( !isInWater && CA_IsPlayerNearWater(playerid)) {
		M:P:G(playerid, "Gali þvejoti.");
	}
	else {
		M:P:E(playerid, "Þvejoti negali.");
		if(isInWater) {
			M:P:E(playerid, "Esi vandens telkinyje, kurio gylis yra [number]%.2f[]m. Tavo gylis: [number]%.2f[]m.", depth, playerdepth);
		}
	}
	return true;
}