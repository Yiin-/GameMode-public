// Duoti þaidëjui darbà su pakvietimu
job_Join(playerid, job)
{
	if(player_Job[playerid])
	{
		M:P:E(playerid, "Jau esi ásidarbinæs kitur. Palikti darbà gali savo darbovietëje.");
	}
	else {
		player_Job[playerid] = job;
		CallLocalFunction("OnPlayerJoinJob", "ii", playerid, job);

		M:P:I(playerid, "Sëkmingai ásidarbinai. Tavo naujas darbas: [highlight]%s[].", GetJobName(job));
	}
}

CMD:paliktid(playerid, p[]) {
	job_Kick(playerid);

	return true;
}

// Iðmest þaidëjà ið darbo su pakv
job_Kick(playerid)
{
	CallLocalFunction("OnPlayerLeftJob", "ii", playerid, player_Job[playerid]);
	M:P:I(playerid, "Esi atleistas ið darbo. Atlyginimas, t.y. [number]%i[]€ sëkmingai pervesti á tavo banko sàskaità.", player_JobSalary[playerid]);

	player_Job[playerid] = JOB_NONE;
}

CMD:dpakv(playerid, V_P[])
{
	if(player_JobRank[playerid] == JOB_RANK_LEADER)
	{
		extract V_P -> new player:id; else
		{
			M:P:E(playerid, "Toks þaidëjas nerastas.");
			return true;
		}

		job_Invite(id, player_Job[playerid], playerid);

	} else {

		M:P:E(playerid, "Tu nesi jokio darbo direktorius.");
	}
	return true;
}

CMD:ppakv(playerid, V_P[])
{
	if(player_Job[playerid] && player_JobRank[playerid] < 0)
	{
		extract V_P -> new player:id; else
		{
			M:P:E(playerid, "Toks þaidëjas nerastas.");
			return true;
		}

		job_Invite(id, player_Job[playerid], playerid);

	} else {

		M:P:E(playerid, "Tu nesi jokio darbo pavaduotojas.");
	}
	return true;
}

// Pakviesti þaidëjà á darbà
job_Invite(playerid, job, inviter)
{
	if(player_Job[playerid])
	{
		if(player_Job[playerid] == job)
		{
			M:P:E(inviter, "Þaidëjas jau dirba ðiame darbe.");
		
		} else {

			M:P:E(inviter, "Þaidëjas jau turi darbà.");
		}

		return;
	}
	inline response(re, li)
	{
		#pragma unused li
		if(re)
		{
			// þaidëjas sutiko, priimam já á darbà
			job_Join(playerid, job);

			// Praneðame visiems prisijungusiems darbuotojams apie ðá naujokà
			job_MessageToMembers(job, "[name]%s[] nuo ðiol yra tavo bendradarbis.", player_Name[playerid]);
		}
	}
	dialogSetHeader("[[highlight]%s[]] - Esi kvieèiamas ásidarbinti.", GetJobName(job));
	dialogSkipLine();
	dialogAddOption("Ar priimi ðá kvietimà?");

	dialogShow(playerid, using inline response, DIALOG_STYLE_MSGBOX, "Pakvietimas", g_DialogText, "Taip", "Ne");
}