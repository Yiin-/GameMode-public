#include <YSI\y_hooks>

#define MIN_ORDERS 5
#define MAX_ORDERS 12

#define XP_FOR_SUCCESSFUL_DELIVER 16
#define TEXT_TAG_PIZZA "[highlight][Picø pristatymas][] "

static const MIN_REWARD = 20;

static const unique_job_id = UNIQUE_SYMBOL;

static job_entry_pickup;
static pizza_start_point;

static pizza_delivery_xp[MAX_PLAYERS];
static pizza_delivery_lvl[MAX_PLAYERS];

static delivered[MAX_PLAYERS];
static failed_deliveries[MAX_PLAYERS];
static amount_to_deliver[MAX_PLAYERS];
static is_delivering[MAX_PLAYERS];

static pizza_delivery_point[MAX_PLAYERS][MAX_ORDERS];
static pizza_delivery_point_marker[MAX_PLAYERS][MAX_ORDERS];

static const Float:delivery_points[][3] = {
	{1402.0027,285.1216,19.1259},
	{1414.5769,263.2251,19.1284},
	{1925.3596,171.5882,36.8519},
	{1945.9343,164.3274,36.8275},
	{2204.6968,62.2354,28.0139},
	{2236.6863,167.8323,27.7236},
	{2258.3872,166.9694,27.7170},
	{2285.8577,160.7229,28.0136}
};

enum order_info {
	Float:order_dest_position[3],
	order_dest_time,
	order_reward
};
static orders[MAX_PLAYERS][MAX_ORDERS][order_info];

hook OnCreatePlayerORM(ORM:ormid, playerid) {
	orm_addvar_int(ormid, pizza_delivery_xp[playerid], "pizza_delivery_xp");
	orm_addvar_int(ormid, pizza_delivery_lvl[playerid], "pizza_delivery_lvl");
}

stock GetPizzaMiniJobID() {
	return unique_job_id;
}

hook OnGameModeInit() {
	job_entry_pickup = CreatePickup(1337, 1, 1362.0211,246.8763,19.5669);
	pizza_start_point = CreatePickup(1337, 1, 1366.8068, 248.5254, 19.5669);
}

hook OnPlayerConnect(playerid) {
	delivered[playerid] = 0;
	failed_deliveries[playerid] = 0;
	amount_to_deliver[playerid] = 0;
	is_delivering[playerid] = false;
}

hook OnCharacterDespawn(playerid) {
	if(is_delivering[playerid]) {
		for(new i; i < sizeof pizza_delivery_point_marker[]; ++i) {
			if(pizza_delivery_point_marker[playerid][i]) {
				DestroyDynamicMapIcon(pizza_delivery_point_marker[playerid][i]);
			}
			if(pizza_delivery_point[playerid][i]) {
				DestroyDynamicArea(pizza_delivery_point[playerid][i]);
			}
		}
		delivered[playerid] = 0;
		failed_deliveries[playerid] = 0;
		amount_to_deliver[playerid] = 0;
		is_delivering[playerid] = false;
	}
}

hook OnPlayerPickUpPickup(playerid, pickupid) {
	if(pickupid == job_entry_pickup) {
		if(IsPlayerWorking(playerid)) {
			if(IsPlayerWorking(playerid, unique_job_id)) {
				M:P:I(playerid, #TEXT_TAG_PIZZA"Norëdamas palikti ðá darbà, raðyk /paliktild");
			}
			else {
				M:P:E(playerid, #TEXT_TAG_PIZZA"Norëdamas ásidarbinti, turi palikti darbà kuriame dabar dirbi. /paliktild");
			}
		}
		else {
			M:P:G(playerid, #TEXT_TAG_PIZZA"Sëkmingai ásidarbinai á \"Picø iðveþiotojus\"!");

			SetPlayerMiniJob(playerid, unique_job_id);

			M:P:I(playerid, #TEXT_TAG_PIZZA"Norëdamas pradëti dirbti, paimk picas ið picerijos virtuvës ir pristatyk jas á namus.");
			M:P:I(playerid, #TEXT_TAG_PIZZA"Uþ kiekvienà laiku nuveþtà picà gausi atlygá (€).");
		}
	}
	if(pickupid == pizza_start_point) {
		if(IsPlayerWorking(playerid, unique_job_id)) {
			if(is_delivering[playerid]) {
				FinishDelivery(playerid);
			}
			else {
				StartNewDelivery(playerid);
			}
		}
		else {
			M:P:E(playerid, "Picerija ðiuo metu uþdaryta.");
		}
	}
}

SuccessfulOrder(playerid) {
	delivered[playerid]++;

	new old_xp = pizza_delivery_xp[playerid];
	new new_xp = pizza_delivery_xp[playerid] += XP_FOR_SUCCESSFUL_DELIVER;

	M:P:I(playerid, #TEXT_TAG_PIZZA"Pristatyta picø: [number]%i[]/[number]%i[].", delivered[playerid], amount_to_deliver[playerid]);
	M:P:G(playerid, #TEXT_TAG_PIZZA"Gavai [number]%i[] patirties uþ sëkmingà picos pristatymà! Dabar turi [number]%i[] patirties.", XP_FOR_SUCCESSFUL_DELIVER, pizza_delivery_xp[playerid]);

	new lvl;

	if((lvl = ShallLevelUp(old_xp, new_xp))) {
		M:P:G(playerid, #TEXT_TAG_PIZZA"Tavo naujas pricø pristatymo lygis: [number]%i[]! Sveikinimai nuo picerijos!", lvl);

		pizza_delivery_lvl[playerid] = lvl;
	}

	if(delivered[playerid] == amount_to_deliver[playerid]) {
		M:P:G(playerid, "Pabaigei visus uþsakymus, gali gráþti atgal á picerijà.");
	}
}

FailedOrder(playerid) {
	failed_deliveries[playerid]++;
	delivered[playerid]++;

	if(delivered[playerid] == amount_to_deliver[playerid]) {
		M:P:G(playerid, "Pabaigei visus uþsakymus, gali gráþti atgal á picerijà.");
	}
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	foreach(new i : Limit(sizeof pizza_delivery_point[])) {
		if(areaid == pizza_delivery_point[playerid][i]) {
			if(gettime() <= orders[playerid][i][order_dest_time]) {
				SuccessfulOrder(playerid);
			}
			else {
				new time_diff = gettime() - orders[playerid][i][order_dest_time];

				switch(time_diff) {
					case 0..30: {
						if(random(3)) {
							M:P:E(playerid, #TEXT_TAG_PIZZA"Pavëlavai atveþti picà...");
							FailedOrder(playerid);
						}
						else {
							M:P:G(playerid, #TEXT_TAG_PIZZA"Atveþti picà pavëlavai [number]%i[]sec, bet klientas buvo geros nuotaikos todël nieko nesakë!", time_diff);
							SuccessfulOrder(playerid);
						}
					}
					case 31..90: {
						if(random(11)) {
							M:P:E(playerid, #TEXT_TAG_PIZZA"Atveþei visiðkai atðalusià picà...");
							FailedOrder(playerid);
						}
						else {
							M:P:G(playerid, #TEXT_TAG_PIZZA"Atveþti picà pavëlavai [number]%i[]sec, bet klientas buvo geros nuotaikos todël nieko nesakë!", time_diff);
							SuccessfulOrder(playerid);
						}
					}
					default: {
						if(random(50)) {
							M:P:E(playerid, #TEXT_TAG_PIZZA"Picà atveþei taip vëlai, kad klientas pamirðo jog iðvis buvo jà uþsisakæs..!");
							FailedOrder(playerid);
						}
						else {
							M:P:G(playerid, #TEXT_TAG_PIZZA"Panaðu kad ðis þmogus suvalgytø betkà... Tau pasisekë :p");
							SuccessfulOrder(playerid);
						}
					}
				}
			}

			DestroyDynamicArea(areaid);
			DestroyDynamicMapIcon(pizza_delivery_point_marker[playerid][i]);
			pizza_delivery_point[playerid][i] = 0;
			pizza_delivery_point_marker[playerid][i] = 0;
		}
	}
}

FinishDelivery(playerid) {
	new diff = amount_to_deliver[playerid] - delivered[playerid];

	if(diff) {
		M:P:E(playerid, #TEXT_TAG_PIZZA"Kà èia veiki, dar [number]%i[] %s laukia savo picos!", diff, LithuanizeString(diff, "klientas", "klientø", "klientai"));
	}
	else {
		new bonus_cash = (7 + pizza_delivery_lvl[playerid]) * delivered[playerid];

		if( ! failed_deliveries[playerid]) {
			bonus_cash *= 2;
			M:P:G(playerid, #TEXT_TAG_PIZZA"Sëkmingai pristatei visas picas laiku, gauni dvigubà bonusà: [number]%i[]€!", bonus_cash);
		}
		else {
			M:P:G(playerid, #TEXT_TAG_PIZZA"Sëkmingai pristatei [number]%i[] %s. Bonusas: [number]%i[]€",
				delivered[playerid] - failed_deliveries[playerid], LithuanizeString(delivered[playerid] - failed_deliveries[playerid], "picà", "picø", "picas"), bonus_cash);
		}

		AdjustPlayerCash(playerid, bonus_cash);

		is_delivering[playerid] = false;
	}
}

StartNewDelivery(playerid) {
	new order_count = MIN_ORDERS + random(MAX_ORDERS + 1 - MIN_ORDERS);

	GenerateRandomOrders(playerid, order_count);

	M:P:G(playerid, #TEXT_TAG_PIZZA"Gavai [number]%i[] %s!", amount_to_deliver[playerid], LithuanizeString(amount_to_deliver[playerid], "uþsakymà", "uþsakymø", "uþsakymus"));

	delivered[playerid] = 0;
	failed_deliveries[playerid] = 0;

	is_delivering[playerid] = true;
}

#define max_points (sizeof delivery_points)

new Iterator:unique_destinations<max_points>;

GenerateRandomOrders(playerid, count) {
	if(count > max_points) {
		count = max_points;
	}
	foreach(new i : Limit(max_points - count)) {
		Iter_Add(unique_destinations, random(max_points));
	}

	for(new i; i < count && i < sizeof delivery_points; ++i) {
		new delivery_point = Iter_Free(unique_destinations);
		Iter_Add(unique_destinations, delivery_point);

		new Float:distance = GetDistanceBetweenPoints(XYZ0(delivery_points[delivery_point]), 1366.8068, 248.5254, 19.5669);

		orders[playerid][i][order_dest_time] = gettime() + floatround(distance * 5.0) + random(90);
		orders[playerid][i][order_reward] = MIN_REWARD + (random(10) ? random(10) : random(200));

		M:P:I(playerid, "%i) random: %i, Atstumas: %f, Laikas: %isec, atlygis: %i", i+1, random(90), distance, orders[playerid][i][order_dest_time] - gettime(), orders[playerid][i][order_reward]);

		pizza_delivery_point[playerid][i] = CreateDynamicSphere(XYZ0(delivery_points[delivery_point]), 5.0, .worldid = VW_DEFAULT, .playerid = playerid);
		pizza_delivery_point_marker[playerid][i] = CreateDynamicMapIcon(XYZ0(delivery_points[delivery_point]), 0, 0xE67E22FF, .playerid = playerid, .streamdistance = 1000.0, .style = MAPICON_GLOBAL_CHECKPOINT);
	}

	amount_to_deliver[playerid] = min(count, max_points);

	Iter_Clear(unique_destinations);
}
#undef max_points