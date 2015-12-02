// Duoti �aid�jui darb� su pakvietimu
job_Join(playerid, job)
{
	if(player_Job[playerid])
	{
		M:P:E(playerid, "Jau esi �sidarbin�s kitur. Palikti darb� gali savo darboviet�je.");
	}
	else {
		player_Job[playerid] = job;
		CallLocalFunction("OnPlayerJoinJob", "ii", playerid, job);

		M:P:I(playerid, "S�kmingai �sidarbinai. Tavo naujas darbas: [highlight]%s[].", GetJobName(job));
	}
}

CMD:paliktid(playerid, p[]) {
	job_Kick(playerid);

	return true;
}

// I�mest �aid�j� i� darbo su pakv
job_Kick(playerid)
{
	CallLocalFunction("OnPlayerLeftJob", "ii", playerid, player_Job[playerid]);
	M:P:I(playerid, "Esi atleistas i� darbo. Atlyginimas, t.y. [number]%i[]� s�kmingai pervesti � tavo banko s�skait�.", player_JobSalary[playerid]);

	player_Job[playerid] = JOB_NONE;
}

CMD:dpakv(playerid, V_P[])
{
	if(player_JobRank[playerid] == JOB_RANK_LEADER)
	{
		extract V_P -> new player:id; else
		{
			M:P:E(playerid, "Toks �aid�jas nerastas.");
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
			M:P:E(playerid, "Toks �aid�jas nerastas.");
			return true;
		}

		job_Invite(id, player_Job[playerid], playerid);

	} else {

		M:P:E(playerid, "Tu nesi jokio darbo pavaduotojas.");
	}
	return true;
}

// Pakviesti �aid�j� � darb�
job_Invite(playerid, job, inviter)
{
	if(player_Job[playerid])
	{
		if(player_Job[playerid] == job)
		{
			M:P:E(inviter, "�aid�jas jau dirba �iame darbe.");
		
		} else {

			M:P:E(inviter, "�aid�jas jau turi darb�.");
		}

		return;
	}
	inline response(re, li)
	{
		#pragma unused li
		if(re)
		{
			// �aid�jas sutiko, priimam j� � darb�
			job_Join(playerid, job);

			// Prane�ame visiems prisijungusiems darbuotojams apie �� naujok�
			job_MessageToMembers(job, "[name]%s[] nuo �iol yra tavo bendradarbis.", player_Name[playerid]);
		}
	}
	dialogSetHeader("[[highlight]%s[]] - Esi kvie�iamas �sidarbinti.", GetJobName(job));
	dialogSkipLine();
	dialogAddOption("Ar priimi �� kvietim�?");

	dialogShow(playerid, using inline response, DIALOG_STYLE_MSGBOX, "Pakvietimas", g_DialogText, "Taip", "Ne");
}