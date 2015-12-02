/*
 * Another - storyline
 * 
 * Miðke ðalia apleistos trobelës randi keistà senà dienoraðtá, taèiau
 * bent jau tai, kas kaþkada tai buvo. Viskas kà jame dar ámanoma perskaityti,
 * tai yra apraðymas apie kaimà ðalia kalno vadimo 'Velnio pilimi'.
 * 
 * Dienoraðtyje raðoma apie jaunos þurnalistës, katik baigusios mokyklà gyvenimà
 * tame kaime. Norëdama paraðyti puikø straipsná ir taip pradëti kilti
 * karjeros laiptais, ji pasirinko tyrinëti to kaimo istorijà, apie kurià nedaug
 * kas kà þinojo. Taèiau ne visiems kaimo gyventojams jos ðniukðtinëjimas ir buvimas
 * tame kaime patiko, todël dienoraðtyje keletà kartø uþsimenama apie nepaaiðkinamà 
 * þmoniø apatijà pradëjus domëtis kaimelio praeitimi.
 *
 * Vienà naktá, beklaidþiodama mënesienos nutvieskstame miestelio pakraðtyje,
 * Ji sutinka senelæ vardu Sofija, gyvenanèià netoliese esanèiame name.
 * Senelë skirtingai nuo kitø kaimelio gyventojø stebëtinai atvirai atsakinëja 
 * á merginos nedràsiai uþduodamus klausimus. Savo dienoraðtyje mergina raðo, 
 * kad Sofija gyvena viena ir retai kada iðeina á vieðumà. Jaunoji þurnalistë 
 * sudominta senelës istorijø apie miestelá ir kaip jis keitësi metai po metø,
 * vis daugiau laiko praleisdavo su ja. Ðioje vietoje tekstas nutrûksta,
 * liko tik iðplëðtø ir iðblukusiø puslapiø likuèiai.
 * 
 * Greit praverti neáskaitomus puslapius, vël aptinki paþystamà raðtà,
 * tik jau kitu raðalu ir paraðyta matomai paskubomis. Raidës neaiðkios,
 * dienoraðtis purvinas ir þemëtas, taèiau nuvalius dulkes matai merginos
 * paskutinæ þinutæ - "að tik noriu, kad viskas baigtusi".
 */

static Intro[2000];

hook OnGameModeInit() {
	new File:file = fopen("Quests/another-intro.txt", io_read);

	if(file) {
		new buff[100];
		while(fread(file, buff)) {
			strcat(Intro, buff);
		}

		fclose(file);
	}
	else {
		print("Error: Quest 'Another' wasn't loaded properly.");
	}
}

hook OnPlayerUseItem(playerid, item_name[], Item:uiid) {
	if(GetItemDefaultType(item_name) == GetItemType("Quest")) {
		if( ! strcmp(item_name, "Senas dienorastis")) {
			inline response(unused1, unused2) {
				#pragma unused unused1, unused2
				if(GetQuestProgress(playerid, "Another") == qp_none) {
					UpdateQuestProgress(playerid, "Another", qp_got_letter);
					M:P:I(playerid, "Uþduotis '[highlight]Kiti[]' pradëta!");
				}
			}
			dialogShow(playerid, using inline response, DIALOG_STYLE_MSGBOX, "Uþduotis 'Kiti': Pradþia", Intro, "Uþdaryti", "");
		}
	}
}

hook OnPlayerSelectItem(playerid, item_name[], Item:uiid) {
	if(GetItemDefaultType(item_name) == GetItemType("Quest")) {
		if( ! strcmp(item_name, "Senas dienorastis")) {
			return true;
		}
	}
	return false;
}