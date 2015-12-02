YCMD:dmeniu(playerid, params[], help) {
	if(help) {
		return M:P:I(playerid, "Direktoriaus darbo valdymo meniu.");
	}
	if(player_JobRank[playerid] != JOB_RANK_LEADER) {
		return M:P:E(playerid, "Ði komanda skirta tik direktoriams!");
	}
	if(player_Job[playerid] == JOB_NONE) {
		return M:P:E(playerid, "Nedirbi jokiame darbe.");
	}
	
	job_LeaderMenu(playerid, player_Job[playerid]);

	return true;
}

job_LeaderMenu(playerid, job)
{
	dialogSetHeader(job_Name[job]);
	dialogAddOption("Darbuotojai %i/%i", jobOnline(job), jobTotal(job));
	dialogAddOption("Transportas %i/%i", jobActiveVehicles(job), jobTotalVehicles(job));
	dialogAddOption("Rangø tvarkymas");

	CallLocalFunction("OnPlayerOpenLeaderMenu", "ii", playerid, job);
	// https://trello.com/c/gx5jGD86/27-pabaigti-dmeniu
	// 4 punktas

	inline LeaderMenu(re, li) {
		#pragma unused li
		if(re) {
			dialog_Row("Darbuotojai") {
				job_LeaderMenu_GenEmployers(playerid, job);
			}
			else dialog_Row("Transportas") {
				//job_LeaderMenu_GenVehicles(playerid, job); ????????????
			}
			else dialog_Row("Rangø tvarkymas") {
				job_LeaderMenu_RankList(playerid, job);
			}
			else if(!CallLocalFunction("OnPlSelectLeaderMenu", "ii", playerid, job)) {
				job_LeaderMenu(playerid, job);
			}
		}
	}

	dialogShow(playerid, using inline LeaderMenu, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Uþdaryti");
}

jobOnline(job) { // darbuotojø
	new count;
	foreach(new i : Player) {
		if(player_Job[i] == job) {
			count++;
		}
	}
	return count;
}

jobTotal(job) { // darbuotojø
	format_query("SELECT * FROM chars WHERE job = %i", job);
	new Cache:cache = mysql_query(database, query);

	new count = cache_get_row_count();
	cache_delete(cache);
	return count;
}

jobActiveVehicles(job) {
	new count;
	foreach(new i : Vehicle) {
		if(vehicle_OwnerType[i] == VEHICLE_OWNER_TYPE_JOB 
			&& vehicle_Owner[i] == job 
			&& vehicle_Status[i] == VEHICLE_STATUS_ACTIVE) {
			count++;
		}
	}
	return count;
}

jobTotalVehicles(job) {
	format_query("SELECT * FROM vehicles WHERE owner_type = %i AND owner = %i", VEHICLE_OWNER_TYPE_JOB, job);
	new Cache:cache = mysql_query(database, query);

	new count = cache_get_row_count();
	cache_delete(cache);
	return count;
}

job_SetRankSalary(job, rank, salary)
{
	job_Ranks[job][rank][job_RankSalary] = salary;
}
job_ResetRankSalary(job, rank)
{
	job_Ranks[job][rank][job_RankSalary] = 0;
}
job_SetRankName(job, rank, input[])
{
	format(job_RankName[job][rank], 32, input);
}
job_ResetRankName(job, rank)
{
	job_RankName[job][rank][0] = EOS;
}
job_GenerateAvailableSkins(job, rank)
{
	for(new i; job_PossibleSkins[job][i]; ++i)
	{
		if(job_Ranks[job][rank][job_RankSkin] == i)
		{
			dialogAddOption("ID: %i", job_PossibleSkins[job][i]);

		} else {

			dialogAddOption("ID: %i", job_PossibleSkins[job][i]);
		}
	}
}
job_ResetRankSkin(job, rank)
{
	memset(job_Ranks[job][rank][job_RankSkin]);
}
job_SetRankSkin(job, rank, li)
{
	job_Ranks[job][rank][job_RankSkin] = li;
}
job_GetRankSkin(job, rank)
{
	return job_GetSkin(job, job_Ranks[job][rank][job_RankSkin]);
}
job_GetSkin(job, li)
{
	return job_PossibleSkins[job][li];
}
job_ResetRankVehicles(job, rank)
{
	for(new i; i < JOB_COUNT_OF_VEHICLES; ++i)
	{
		job_Ranks[job][rank][job_RankVehicles][i] = 0;
	}
}
job_ToggleRankVehicle(job, rank, vehicle)
{
	job_Ranks[job][rank][job_RankVehicles][vehicle] ^= 1;
}

job_MessageToMembers(job, text[], va_args<>)
{
	static buffer[300];
	va_formatex(buffer, _, text, va_start<2>);

	format_colors(buffer, MSG_C_SNOW);

	foreach(new i : Player) if(player_Job[i] == job) {
		SendClientMessage(i, 0xfffafaff, buffer);
	}
}

job_GetRankName(id, job = JOB_NONE)
{
	new rankname[32];

	if(job != JOB_NONE)
	{
		if(id == JOB_RANK_LEADER) {
			rankname = "Direktorius";
		}
		else if(id < 0) {
			rankname = "Pavaduotojas";
		}
		else return job_RankName[job][id];
		
	} else {
		if(id == NONE) {
			rankname = "-";
		}
		else if(isnull(job_RankName[ player_Job[id] ][ player_JobRank[id] ]))
			rankname = "Neþinomas";
		else {
			if(player_JobRank[id] == JOB_RANK_LEADER) {
				rankname = "Direktorius";
			}
			else if(player_JobRank[id] < 0) {
				rankname = "Pavaduotojas";
			}
			else return job_RankName[ player_Job[id] ][ player_JobRank[id] ];
		}
	}

	return rankname;
}

job_LeaderMenu_RankName(playerid, job, li, justchange = false)
{
	dialogSetHeader("Rango pavadinimas");

	dialogAddOption("Áraðyk bûsimà rango pavadinimà (max 31 simbolis)");

	inline set_rank_name(re2)
	{
		if( ! re2)
		{
			if(justchange)
			{
				job_LeaderMenu_RankInfo(playerid, job, li);

			} else {

				job_ResetRankName(job, li);
				job_LeaderMenu_RankList(playerid, job);
			}
			
			return;
		}
		if(isnull(dialog_Input) || strlen(dialog_Input) > 31)
		{
			job_LeaderMenu_RankName(playerid, job, li, justchange);

		} else {

			job_SetRankName(job, li, dialog_Input);

			if(justchange)
			{
				job_LeaderMenu_RankInfo(playerid, job, li);

			} else {

				job_LeaderMenu_RankSkin(playerid, job, li);
			}
		}
	}
	
	dialogShow(playerid, using inline set_rank_name, DIALOG_STYLE_INPUT, justchange?(" "):("1/4"), g_DialogText, "Rinktis", "Atgal");
}

job_LeaderMenu_RankSkin(playerid, job, li, justchange = false)
{
	dialogSetHeader("Rango iðvaizda");

	job_HideSkin(playerid);
	job_ShowSkin(playerid, job_GetRankSkin(job, li));

	if(justchange)
	{
		dialogAddOption("Gráþti atgal.");

	} else {

		dialogAddOption("Rango maðinos (3/4)");
	}
	dialogSkipLine();

	job_GenerateAvailableSkins(job, li);

	inline set_rank_skin(re3, li3)
	{
		if( ! re3)
		{
			job_HideSkin(playerid);
			if(justchange)
			{
				job_LeaderMenu_RankInfo(playerid, job, li);

			} else {

				job_ResetRankSkin(job, li);
				job_LeaderMenu_RankName(playerid, job, li);
			}

		} else {

			new skin_idx = li3 - 4;
			
			dialog_Row("Rango maðinos (3/4)")
			{
				job_HideSkin(playerid);
				job_LeaderMenu_RankVehicles(playerid, job, li);

			} else
			dialog_Row("Gráþti atgal")
			{
				job_HideSkin(playerid);
				job_LeaderMenu_RankInfo(playerid, job, li);
			}
			else if(skin_idx >= 0)
			{
				job_SetRankSkin(job, li, skin_idx);				
				job_LeaderMenu_RankSkin(playerid, job, li, justchange);
			
			} else {

				job_LeaderMenu_RankSkin(playerid, job, li, justchange);
			}
		}
	}
	dialogShow(playerid, using inline set_rank_skin, DIALOG_STYLE_LIST, justchange?(" "):("2/4"), g_DialogText, "Rinktis", "Atgal");
}

job_LeaderMenu_RankVehicles(playerid, job, li, justchange = false)
{
	dialogSetHeader("Rango maðinos");

	if(justchange)
	{
		dialogAddOption("Gráþti atgal.");

	} else {

		dialogAddOption("Rango alga (4/4)");
	}
	dialogSkipLine();
	

	dialogAddOption("Pasirink norimas maðinas");
	dialogSkipLine();

	job_GenerateVehicleList(job, li);

	inline set_rank_vehicles(re4, li4)
	{
		if( ! re4)
		{
			if(justchange)
			{
				job_LeaderMenu_RankInfo(playerid, job, li);

			} else {

				job_ResetRankVehicles(job, li);
				job_LeaderMenu_RankSkin(playerid, job, li);
			}

		} else {

			dialog_Row("Rango alga")
			{
				job_LeaderMenu_RankSalary(playerid, job, li);
			}
			else
			dialog_Row("Gráþti atgal")
			{
				job_LeaderMenu_RankInfo(playerid, job, li);
			}
			else if(li4 > 5) {

				job_ToggleRankVehicle(job, li, li4 - 6);
				job_LeaderMenu_RankVehicles(playerid, job, li, justchange);
			}
			else {

				job_LeaderMenu_RankVehicles(playerid, job, li);
			}
		}
	}
	dialogShow(playerid, using inline set_rank_vehicles, DIALOG_STYLE_LIST, justchange?(" "):("3/4"), g_DialogText, "Rinktis", "Atgal");
}

job_LeaderMenu_RankSalary(playerid, job, li, justchange = false)
{
	dialogSetHeader("Rango gaunama alga");

	dialogAddOption("Algos dydis gali bûti nuo %i€ iki %i€", (((li + 1) * 1000) - 200), (((li + 1) * 1000) + 200));

	inline ko_tu_nx_neveiki(re5, li5)
	{
		#pragma unused li5

		if( ! re5)
		{
			if(justchange)
			{
				job_LeaderMenu_RankInfo(playerid, job, li);

			} else {

				job_ResetRankSalary(job, li);
				job_LeaderMenu_RankVehicles(playerid, job, li);
			}
		
		} else {

			new salary = strval(dialog_Input);

			if(((li + 1) * 1000) - 200 <= salary <= ((li + 1) * 1000) + 200)
			{
				job_SetRankSalary(job, li, salary);

				if(justchange)
				{
					job_LeaderMenu_RankInfo(playerid, job, li);

				} else {

					M:P:I(playerid, "Sëkmingai sukûrei naujà rangà!");

					job_LeaderMenu_RankList(playerid, job);
				}

			} else {

				job_LeaderMenu_RankSalary(playerid, job, li, justchange);
			}
		}
	}

	dialogShow(playerid, using inline ko_tu_nx_neveiki, DIALOG_STYLE_INPUT, justchange?(" "):("4/4"), g_DialogText, "Sukurti", "Atgal");
}

job_LeaderMenu_RankInfo(playerid, job, rank)
{
	dialogSetHeader("Rango '%s' nustatymai", job_GetRankName(rank, job));

	inline manage_rank(re, li)
	{
		#pragma unused li
		if(re)
		{
			dialog_Row("Keisti pavadinimà")
			{
				job_LeaderMenu_RankName(playerid, job, rank, true);
			}
			dialog_Row("Keisti iðvaizdà")
			{
				job_LeaderMenu_RankSkin(playerid, job, rank, true);
			}
			dialog_Row("Nustatyti algà")
			{
				job_LeaderMenu_RankSalary(playerid, job, rank, true);
			}
			dialog_Row("Leidþiamos darbinës maðinos")
			{
				job_LeaderMenu_RankVehicles(playerid, job, rank, true);
			}

		} else {

			job_LeaderMenu_RankList(playerid, job);
		}
	}

	dialogAddOption("Keisti pavadinimà.");
	dialogAddOption("Keisti iðvaizdà.");
	dialogAddOption("Nustatyti algà.");
	dialogAddOption("Leidþiamos darbinës maðinos.");

	dialogShow(playerid, using inline manage_rank, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
}

job_LeaderMenu_RankList(playerid, job)
{
	dialogSetHeader("Rangø tvarkymas");

	dialogAddOption("Visi rangai");
	dialogSkipLine();

	job_GenerateRankList(job, true);

	inline manage_rank(re1, li1)
	{
		#pragma unused li1

		if( ! re1)
		{
			job_LeaderMenu(playerid, job);
			return;
		}

		li1 -= 4;
		if(li1 < 0)
		{
			job_LeaderMenu_RankList(playerid, job);
		
		} else {

			// KURIAM NAUJÀ RANGÀ
			new I_HATE_PAWN[32]; format(I_HATE_PAWN, 32, "%s", job_GetRankName(li1, job));

			if(isnull(I_HATE_PAWN))
			{
				job_LeaderMenu_RankName(playerid, job, li1);

			} else { // EDITINAM JAU SUKURTÀ

				job_LeaderMenu_RankInfo(playerid, job, li1);
			}
		}
	}

	dialogShow(playerid, using inline manage_rank, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
}

job_LeaderMenu_GenEmployers(playerid, job)
{
	format_query("SELECT * FROM chars WHERE job = %i", job);
	new Cache:r = mysql_query(database, query);

	new count = cache_get_row_count();

	if( ! count) // darbuojø nëra
	{
		dialogSetHeader("Darbuotojø tvarkymas");
		dialogAddOption("Darbuotojø nëra.");

		inline empty(re1, li1)
		{
			#pragma unused re1, li1
			job_LeaderMenu(playerid, job);
		}

		dialogShow(playerid, using inline empty, DIALOG_STYLE_LIST, " ", g_DialogText, "Atgal", "");
	
	} else {

		dialogSetHeader("Darbuotojø tvarkymas");

		// sudarom sàraðà visø darbuotojø
		// virðuje - prisijungæ (ðviesûs nick, (samp id))
		// apaèioje - atsijungæ (pilki nick, <sql id>)
		job_GenerateEmployers(job);

		cache_delete(r);

		// kai pasirenka kurá nors darbuotojà ið sàraðo
		//job_TryFixInline(playerid, job);
		inline players_list(re1, li1)
		{
			if( ! re1)
			{
				job_LeaderMenu(playerid, job);

			} else {

				if(li1 < 2)
				{
					job_LeaderMenu_GenEmployers(playerid, job);

				} else {

					job_EmployerInfo_Offline[job] = job_EXTRACT_SHIT_FROM_THIS_LINE(job_EmployerInfo_ID[job], dialog_Input);

					job_LeaderMenu_GenEmplInfo(playerid, job);
				}
			}
		}

		dialogShow(playerid, using inline players_list, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
	}
}

job_LeaderMenu_GenEmplInfo(playerid, job)
{
	new id = job_EmployerInfo_ID[job];
	new offline = job_EmployerInfo_Offline[job];

	if(id == INVALID_PLAYER_ID)
	{
		job_LeaderMenu_GenEmployers(playerid, job);
	
	} else {

		if(offline) // informacija ið sql
		{
			format_query("SELECT * FROM chars WHERE uid = %i", id);
			new Cache:r = mysql_query(database, query);
			if( ! cache_get_row_count())
			{
				M:P:E(playerid, "Pasirinktas þaidëjas nebeegzistuoja O.o");
				job_LeaderMenu_GenEmployers(playerid, job);
				return;
			}
			new name[MAX_PLAYER_NAME]; cache_get_field_content(0, "name", name);
			dialogSetHeader("%s {aaaaaa}(neprisijungæs)", name);

			//dialogAddOption("{aaaaaa}Darbuotojo statistika.");
			dialogAddOption("Rangas: %s.", job_GetRankName(max(cache_get_field_content_int(0, "job_rank"), 0), cache_get_field_content_int(0, "job")));

			new buff[200], job_exp[JOB_COUNT];
			cache_get_field_content(0, "job_exp", buff); sscanf(buff, F:0("p<,>a<i>[%i]", JOB_COUNT), job_exp);

			dialogAddOption("Darbo patirtis: %i.", job_exp[job]); // DONE
			dialogAddOption("Darbuotojo informacija.");
			dialogSkipLine();
			dialogAddOption("Atleisti ið darbo.");

			cache_delete(r);

			inline atsijunges(re2, li2)
			{
				#pragma unused li2
				if(re2)
				{
					dialog_Row("Rangas") // DONE
					{
						job_LeaderMenu_SetNewRank(playerid, job);

					} else
					dialog_Row("Darbuotojo statistika")
					{
						//job_LeaderMenu_

					} else
					dialog_Row("Darbuotojo informacija") // DONE
					{
						// TODO: player_ShowInformation(playerid, name);

					} else {

						job_LeaderMenu_GenEmplInfo(playerid, job);
					}

				} else {

					job_LeaderMenu_GenEmployers(playerid, job);
				}
			}
			dialogShow(playerid, using inline atsijunges, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");

		} else {

			dialogSetHeader("%s", player_Name[id]);

			// TODO: Padaryti darbuotojo statistikà 
			//dialogAddOption("{aaaaaa}Darbuotojo statistika.");
			dialogAddOption("Rangas: %s.", job_GetRankName(id)); // DONE
			dialogAddOption("Darbo patirtis: %i.", GetPlayerJobExp(playerid, job)); // DONE
			dialogAddOption("Darbuotojo informacija."); // DONE
			dialogSkipLine();
			dialogAddOption("Atleisti ið darbo.");

			inline employer_info(re2, li2)
			{
				#pragma unused li2
				if( ! re2)
				{
					job_LeaderMenu_GenEmployers(playerid, job);
					return;
				}
				if( ! IsPlayerConnected(id))
				{
					job_LeaderMenu_GenEmployers(playerid, job);
					return;
				}
				if( player_Job[id] != job)
				{
					job_LeaderMenu_GenEmployers(playerid, job);
					return;
				}

				dialog_Row("Rangas") // DONE
				{
					job_LeaderMenu_SetNewRank(playerid, job);

				} else
				dialog_Row("Darbuotojo statistika")
				{
					//job_LeaderMenu_

				} else
				dialog_Row("Darbuotojo informacija") // DONE
				{
					// TODO: player_ShowInformation(playerid, player_Name[id]);

				} else {

					job_LeaderMenu_GenEmplInfo(playerid, job);
				}
			}

			dialogShow(playerid, using inline employer_info, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
		}
	}
}

job_LeaderMenu_SetNewRank(playerid, job)
{
	new id = job_EmployerInfo_ID[job];
	new offline = job_EmployerInfo_Offline[job];
	new Cache:r;

	if(offline) {
		format_query("SELECT * FROM chars WHERE uid = %i AND job = %i", id, job);
		r = mysql_query(database, query);

		if(cache_get_row_count()) {
			new name[MAX_PLAYER_NAME]; cache_get_field_content(0, "name", name);
			new rankid = cache_get_field_content_int(0, "job_rank");
			dialogSetHeader("%s (%s)", name, job_GetRankName(rankid, job));
			cache_delete(r);
		}
		else {
			cache_delete(r);
			job_LeaderMenu_GenEmployers(playerid, job);
		}
	}
	else {
		dialogSetHeader("%s (%s)", player_Name[id], job_GetRankName(id));
	}
	dialogAddOption("Paskirti kità rangà");
	dialogSkipLine();

	job_GenerateRankList(job);

	inline change_rank(re3, li3)
	{
		if( ! re3)
		{
			job_LeaderMenu_GenEmplInfo(playerid, job);
			return;
		}

		if( ! offline)
		{
			if( ! IsPlayerConnected(id))
			{
				job_LeaderMenu_GenEmployers(playerid, job);
				return;
			}
			if( player_Job[id] != job)
			{
				job_LeaderMenu_GenEmployers(playerid, job);
				return;
			}
		
		} else {

			format_query("SELECT * FROM chars WHERE uid = %i AND job = %i", id, job);
			r = mysql_query(database, query);
			if( ! cache_get_row_count())
			{
				cache_delete(r);
				job_LeaderMenu_GenEmployers(playerid, job);
				return;
			}
		}

		new rank_id = job_GetNthRank(job, li3 - 4);
		if(rank_id == BAD_INDEX)
		{
			job_LeaderMenu_SetNewRank(playerid, job);

		} else {

			new name[MAX_PLAYER_NAME];
			if(offline)
			{
				cache_get_field_content(0, "name", name);
				cache_delete(r);
				format_query("UPDATE chars SET job_rank = %i WHERE uid = %i AND job = %i", rank_id, id, job);
				mysql_query(database, query, false);

			} else {
				cache_delete(r);
				player_JobRank[id] = rank_id;
				M:P:I(id, "Gavai naujà darbo rangà: [highlight]%s[]!", job_GetRankName(id));
			}

			M:P:I(playerid, "Sëkmingai paskyrei rangà [highlight]%s[] þaidëjui [name]%s[].", offline?job_GetRankName(rank_id, job):job_GetRankName(id), offline?name:player_Name[id]);

			job_LeaderMenu_GenEmplInfo(playerid, job);
		}
	}

	dialogShow(playerid, using inline change_rank, DIALOG_STYLE_LIST, " ", g_DialogText, "Rinktis", "Atgal");
}

job_GenerateVehicleList(job, rank)
{
	new j = 1;
	foreach(new i : job_Garage<job>)
	{
		if(job_Ranks[job][rank][job_RankVehicles][j - 1])
		{
			dialogAddOption("%i) %s", j, vehicle_Name[ GetVehicleModel(i) - 400 ]);

		} else {

			dialogAddOption("%i) {aaaaaa}%s", j, vehicle_Name[ GetVehicleModel(i) - 400 ]);
		}
		j++;	
	}
}

job_GetNthRank(job, n)
{
	if(0 <= n < JOB_COUNT_OF_RANKS)
	{
		for(new i, j; i < JOB_COUNT_OF_RANKS; ++i)
		{
			new I_STILL_HATE_PAWN[32]; format(I_STILL_HATE_PAWN, 32, "%s", job_GetRankName(i, job));
			if(isnull(I_STILL_HATE_PAWN))
				continue;
			if(j++ == n)
			{
				return i;
			}
		}
		return BAD_INDEX;

	} else {

		return BAD_INDEX;
	}
}

// Disallowed
job_IsVehicleAllowed(job, rank, vehicle)
{
	new j;
	foreach(new i : job_Garage<job>)
	{
		if(i == vehicle)
		{
			return ! job_Ranks[job][rank][job_RankVehicles][j];
		}
		j++;
	}
	return true;
}

job_GenerateEmployers(job)
{
	new id[20];
	new k, online;
	foreach(new i : Player) {
		if(player_Job[i] != job) {
			continue;
		}
		format(id, sizeof id, "%i (%i)", ++k, i);
		dialogAddOption("%s %s", id, player_Name[i]);
	}
	online = k;
	new i, count;
	if((count = cache_get_row_count())) do {
		new sqlid = cache_get_field_content_int(i, "uid");
		if(player_SQL_ID_TO_PLAYER_ID(sqlid) != INVALID_PLAYER_ID) continue;

		format(id, sizeof id, "%i <%i>", ++k, sqlid);

		static name[MAX_PLAYER_NAME]; cache_get_field_content(i, "name", name);

		dialogAddOption("%s {aaaaaa}%s", id, name);

	} while(++i < count);

	return online;
}














job_GenerateRankList(job, bool:all = false)
{
	if(all)
	{
		for(new i; i < JOB_COUNT_OF_RANKS; ++i)
		{
			if(!strlen(job_GetRankName(i, job)))
				dialogAddOption("(%i) {aaaaaa}Kurti naujà rangà", i + 1);
			else
				dialogAddOption("(%i) %s", i + 1, job_GetRankName(i, job));
		}
	
	} else {

		for(new i; i < JOB_COUNT_OF_RANKS; ++i)
		{
			if(!strlen(job_GetRankName(i, job)))
				continue;
			dialogAddOption("%s", job_GetRankName(i, job));
		}
	}
}

job_EXTRACT_SHIT_FROM_THIS_LINE(&id, input[])
{
	new line[100]; memcpy(line, input, 0, strlen(input) * 4);

	new idx = strfind(line, "(") + 1;
	new offline = false;
	if(idx == 0)
	{
		idx = strfind(line, "<") + 1;
		if(idx)
		{
			offline = true;
		
		} else {

			id = INVALID_PLAYER_ID;
			return true;
		}
	}

	new idx_end;
	if(offline) idx_end = strfind(line, ">");
	else idx_end = strfind(line, ")");

	new dest[12];

	memcpy(dest, line[idx], 0, (idx_end - idx) * 4);

	id = strval(dest);

	return offline;
}

stock PlayerText:createSkin(playerid, skin, Float:l)
{
	new PlayerText:id = CreatePlayerTextDraw(playerid, 520.0, 150.0, "TEXTDRAWAS TIPO");
	PlayerTextDrawFont(playerid, id, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawTextSize(playerid, id, 120.0, 200.0);

	PlayerTextDrawSetPreviewModel(playerid, id, skin);
	PlayerTextDrawSetPreviewRot(playerid, id, 0, 0, l);

	PlayerTextDrawBackgroundColor(playerid, id, 0xFFFFFFFF);

	PlayerTextDrawShow(playerid, id);

	return id;
}

new Float:skin_prev_count[MAX_PLAYERS], 
	Timer:skin_prev_timer[MAX_PLAYERS];

new PlayerText:skin1[MAX_PLAYERS],
	PlayerText:skin2[MAX_PLAYERS];

timer rotateSkin[50](playerid, skin)
{
	if(skin_prev_count[playerid] + 5 >= 360)
	{
		skin_prev_count[playerid] = 0;
	}

	PlayerTextDrawDestroy(playerid, skin1[playerid]);
	skin1[playerid] = skin2[playerid];
	skin2[playerid] = createSkin(playerid, skin, skin_prev_count[playerid]);
	skin_prev_count[playerid] += 5;
}

job_ShowSkin(playerid, skin)
{
	skin_prev_count[playerid] = 0;

	skin1[playerid] = createSkin(playerid, skin, skin_prev_count[playerid]); skin_prev_count[playerid] += 5;
	skin2[playerid] = createSkin(playerid, skin, skin_prev_count[playerid]);

	skin_prev_timer[playerid] = repeat rotateSkin(playerid, skin);

	return true;
}

job_HideSkin(playerid)
{
	stop skin_prev_timer[playerid];
	skin_prev_timer[playerid] = Timer:0;

	skin_prev_count[playerid] = -1;

	PlayerTextDrawDestroy(playerid, skin1[playerid]);
	PlayerTextDrawDestroy(playerid, skin2[playerid]);

	return true;
}