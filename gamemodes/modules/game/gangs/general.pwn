#include <YSI_Coding\y_hooks>

#define MAX_GANGS MAX_PLAYERS
#define MAX_GANG_NAME 32

enum {
	GANG_NAME_NO_NAME,
	GANG_NAME_EXISTS,
	GANG_NAME_OK
};

static gangId[MAX_GANGS];
static gangName[MAX_GANGS][MAX_GANG_NAME];
static gangLeader[MAX_GANGS];
static gangPoints[MAX_GANGS];
static gangBase[MAX_GANGS];
static gangCreatedAt[MAX_GANGS][20];

static Iterator:Gang<MAX_GANGS>;

hook OnCharacterDespawn(playerid) {
	SaveGang(GetPlayerGang(playerid));
}

GetGangCreatedAt(gang) {
	return gangCreatedAt[gang];
}

// alias
stock GetGangID(gang) {
	return GetGangId(gang);
}
// get sql id
GetGangId(gang) {
	return gangId[gang];
}

GetGangLeader(gang) {
	return gangLeader[gang];
}

GetGangPoints(gang) {
	return gangPoints[gang];
}

AdjustGangPoints(gang, amount) {
	return gangPoints[gang] += amount;
}

GetGangBase(gang) {
	return gangBase[gang];
}

GetGangName(gang) {
	return gangName[gang];
}

SetGangName(name[], gang = NONE) {
	static idx;
	while((idx = strfind(name, "%")) != -1) {
		strdel(name, idx, idx);
	}
	mysql_escape_string(name, name, .max_len = MAX_GANG_NAME);
	if(isnull(name)) {
		return GANG_NAME_NO_NAME;
	}
	else {
		format_query("SELECT id FROM gangs WHERE name = '%s'", name);
		new const Cache:r = mysql_query(database, query);
		if(cache_num_rows()) {
			cache_delete(r);
			return GANG_NAME_EXISTS;
		}
		else if(gang != NONE) {
			cache_delete(r);
			if(GetGangId(gang)) {
				format_query("UPDATE gangs SET name = '%s' WHERE uid = %i", name, GetGangId(gang));
				mysql_query(database, query, false);
			}
			strset(gangName[gang], name);
			return GANG_NAME_OK;
		}
	}
	return GANG_NAME_OK;
}

IsGangLeader(playerid, gang = NONE) {
	if(gang == NONE) {
		gang = GetPlayerGang(playerid, .local = true);
	}
	return GetGangLeader(gang) == GetPlayerCharID(playerid)
		&& GetPlayerGangRank(playerid) == GANG_RANK_LEADER;
}

CreateGang(playerid, name[]) {
	format_query("INSERT INTO gangs (leader, name) VALUES (%i, '%s')", GetPlayerCharID(playerid), name);
	new Cache:cache = mysql_query(database, query);

	new gang = Iter_Free(Gang);

	strset(gangName[gang], name);
	gangId[gang] = cache_insert_id();
	gangLeader[gang] = GetPlayerCharID(playerid);
	gangBase[gang] = NONE;

	SetPlayerGang(playerid, GetGangId(gang));
	SetPlayerGangRank(playerid, GANG_RANK_LEADER);

	cache_delete(cache);

	format_query("SELECT created_at FROM gangs WHERE uid = %i", GetGangId(gang));
	cache = mysql_query(database, query);

	cache_get_field_content(0, "created_at", gangCreatedAt[gang]);

	cache_delete(cache);

	return gang;
}

DeleteGang(gang = NONE, sqlid = NONE) {
	if(sqlid == NONE) {
		sqlid = GetGangId(gang);
	}
	format_query("DELETE FROM gangs WHERE uid = %i", sqlid);
	mysql_tquery(database, query);
	format_query("UPDATE chars SET gang = 0 WHERE gang = %i", sqlid);
	mysql_tquery(database, query);

	if(gang != NONE) {
		Iter_Remove(Gang, gang);

		foreach(new i : Player) {
			if(GetPlayerGang(i) == sqlid) {
				KickFromGang(i, .gang_was_deleted = true);
			}
		}
	}
}

SaveGang(gang) {
	format_query("       \
		UPDATE           \
			gangs        \
		SET              \
			base = %i,   \
			points = %i, \
			name = '%s'  \
		WHERE            \
			uid = %i",
		GetGangBase(gang),
		GetGangPoints(gang),
		GetGangName(gang),
		GetGangId(gang)
	);

	mysql_query(database, query, false);

	Iter_Remove(Gang, gang);

	call OnGangSave(gang);
}

LoadGang(gangid) {
	if(FindGang(gangid) != NONE) {
		return;
	}
	format_query("SELECT * FROM gangs WHERE uid = %i", gangid);
	new Cache:cache = mysql_query(database, query);

	if( ! cache_num_rows()) {
		cache_delete(cache);
		return;
	}
	new gang = Iter_Free(Gang);

	gangId[gang] = gangid;
	gangLeader[gang] = cache_get_field_content_int(0, "leader");
	gangBase[gang] = cache_get_field_content_int(0, "base");
	gangPoints[gang] = cache_get_field_content_int(0, "points");
	cache_get_field_content(0, "name", gangName[gang]);
	cache_get_field_content(0, "created_at", gangCreatedAt[gang]);

	cache_delete(cache);

	call OnGangLoad(gang);
}

FindGang(gangid) {
	foreach(new i : Gang) {
		if(gangId[i] == gangid) {
			return i;
		}
	}
	return NONE;
}