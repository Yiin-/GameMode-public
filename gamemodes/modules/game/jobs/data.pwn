#include <YSI_Coding\y_hooks>

#define JOB_COUNT_OF_VEHICLES 20
#define JOB_COUNT_OF_RANKS 10

enum {
	JOB_RANK_LEADER = -1,
	JOB_RANK_ASSISTANT = -2
};

enum {
	JOB_NONE,
	JOB_TAXI,
	JOB_POLICE,
	JOB_MECH,
	JOB_FIRE,
	JOB_HEALTH,
	JOB_TRUCK,
	JOB_COUNT
};

//#define GetJobName(%0) (((%0)>=sizeof(job_Name)||(%0<0))?("-"):job_Name[%0])


new job_Name[JOB_COUNT][] = {
	"Bedarbis",
	"Taksi",
	"Policija",
	"Mechanikai",
	"Ugniagesiai",
	"Medikai",
	"Fûristai"
};
#define getJobJsonFile:%0<%1> new %0[50];format(%0, sizeof %0, "Jobs/%s.json", GetJobName(%1))

#define GetJobName(%0) job_Name[%0]

new Iterator:job_Garage<JOB_COUNT, MAX_VEHICLES>;

new
	job_Leader[JOB_COUNT],
	job_Cash[JOB_COUNT]
;

new const job_PossibleSkins[][20] = {
	// vyr /**/ mot
	{0, /**/0, ...},
	{7, 142, /**/9, 11, 0, ...}, // Taxi
	{280, 281, 282, 283, 284, 285, 286, 287, 288, /**/12, 55, 150, 191, 0, ...}, // Police
	{50, 8, 95, 133, /**/192, 195, 201, 0, ...}, // Mechanic
	{277, 278, 279, /**/277, 278, 279, 0, ...}, // Firefighter
	{274, 275, 276, /**/41, 69, 90, 91, 0, ...}, // Medic
	{1, 44, 72, 73, /**/263, 40, 0, ...} // Trucking
	// {{42, 70, 133, 144, 0, /**/131, 148, 0, ...}} // Crafter

};

new job_RankName[JOB_COUNT][JOB_COUNT_OF_RANKS][32];
enum job_RankInfo
{
	// rango pavadinimas
	// job_RankName[32],

	// rango gaunama alga
	job_RankSalary,

	// rango maðinos 
	job_RankVehicles[JOB_COUNT_OF_VEHICLES],

	// rango skinas
	job_RankSkin
};

new job_Ranks[JOB_COUNT][JOB_COUNT_OF_RANKS][job_RankInfo];

new job_EmployerInfo_ID[JOB_COUNT];
new job_EmployerInfo_Offline[JOB_COUNT];

hook OnGameModeInit() {
	Iter_Init(job_Garage);

	job_Load();
	job_LoadVehicles();
}

hook OnGameModeExit()
{
	job_Save();
	job_SaveVehicles();
}

job_AddVehicle(job, idx)
{
	if(Iter_Count(job_Garage<job>) < JOB_COUNT_OF_VEHICLES)
	{
		Iter_Add(job_Garage<job>, idx);

		return true;
	
	} else {

		return false;
	}
}

job_RemoveVehicle(job, idx)
{
	new k, bool:next = false;

	foreach(new i : job_Garage<job>)
	{
		if(i == idx)
		{
			for(new j; j < JOB_COUNT_OF_RANKS; ++j)
			{
				if(k + 1 < Itter_Count(job_Garage<job>))
				{
					if(job_Ranks[job][j][job_RankVehicles][k + 1])
					{
						job_Ranks[job][j][job_RankVehicles][k + 1] = 0;
						job_Ranks[job][j][job_RankVehicles][k] = 1;
					}

				} else {

					job_Ranks[job][j][job_RankVehicles][k] = 0;
				}
			}
			next = true;
		
		} else if (next) {

			for(new j; j < JOB_COUNT_OF_RANKS; ++j)
			{
				if(k + 1 < Itter_Count(job_Garage<job>))
				{
					if(job_Ranks[job][j][job_RankVehicles][k + 1])
					{
						job_Ranks[job][j][job_RankVehicles][k + 1] = 0;
						job_Ranks[job][j][job_RankVehicles][k] = 1;
					}
				
				} else {

					job_Ranks[job][j][job_RankVehicles][k] = 0;
				}
			}
		}
		k++;
	}
	Iter_Remove(job_Garage<job>, idx);
}

job_Save(job = 0, single = false)
{
	if(job)
	{
		new FILE[50]; format(FILE, sizeof FILE, "Jobs/%s.json", GetJobName(job));

		CallLocalFunction("OnJobSave", "is", job, FILE);

		djSetInt(FILE, "leader",job_Leader[job]);
		djSetInt(FILE, "cash", job_Cash[job]);

		djUnset(FILE, "rank");

		for(new i; i < JOB_COUNT_OF_RANKS; ++i)
		{
			new id = djAppend(FILE, "rank", "");

			djSet(FILE, F:0("rank/%i/name", id), job_RankName[job][i]);
			djSetInt(FILE, F:0("rank/%i/salary", id), job_Ranks[job][i][job_RankSalary]);
			djSetInt(FILE, F:0("rank/%i/skin", id), job_Ranks[job][i][job_RankSkin]);

			for(new j; j < JOB_COUNT_OF_VEHICLES; ++j)
			{
				djAppend(FILE, F:0("rank/%i/vehicle", id), F:1("%i", job_Ranks[job][i][job_RankVehicles][j]));
			}
		}
	}
	if(++job < JOB_COUNT && !single)
	{
		job_Save(job);
	}
}

job_Load(job = 0)
{
	if(job)
	{
		new FILE[50]; format(FILE, sizeof FILE, "Jobs/%s.json", GetJobName(job));

		DJSON_cache_ReloadFile(FILE);

		CallLocalFunction("OnJobLoad", "is", job, FILE);

		job_Leader[job] = djInt(FILE, "leader");
		job_Cash[job] = djInt(FILE, "cash");

		for(new i; i < JOB_COUNT_OF_RANKS; ++i)
		{
			job_SetRankName(job, i, dj(FILE, F:0("rank/%i/name", i)));
			
			job_Ranks[job][i][job_RankSalary] = djInt(FILE, F:0("rank/%i/salary",i));
			job_Ranks[job][i][job_RankSkin] = djInt(FILE, F:0("rank/%i/skin",i));

			for(new j, k = djCount(FILE, F:0("rank/%i/vehicle", i)); j < k; ++j)
			{
				job_Ranks[job][i][job_RankVehicles][j] = djInt(FILE, F:0("rank/%i/vehicle/%i", i, j));
			}
		}
	}
	if(++job < JOB_COUNT)
	{
		job_Load(job);
	}
}

job_LoadVehicles(job = 0)
{
	LoadVehicles(.jobid = job++);
	
	if(job < JOB_COUNT) {
		job_LoadVehicles(job);
	}
}

job_SaveVehicles()
{
	for(new job; job < JOB_COUNT; ++job) {
		// einam per visas darbo maðinas
		foreach(new i : job_Garage<job>)
		{
			SaveVehicle(i, true, true);
		}
	}
}