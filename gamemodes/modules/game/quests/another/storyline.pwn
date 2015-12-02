/*
 * Another - storyline
 * 
 * Mi�ke �alia apleistos trobel�s randi keist� sen� dienora�t�, ta�iau
 * bent jau tai, kas ka�kada tai buvo. Viskas k� jame dar �manoma perskaityti,
 * tai yra apra�ymas apie kaim� �alia kalno vadimo 'Velnio pilimi'.
 * 
 * Dienora�tyje ra�oma apie jaunos �urnalist�s, katik baigusios mokykl� gyvenim�
 * tame kaime. Nor�dama para�yti puik� straipsn� ir taip prad�ti kilti
 * karjeros laiptais, ji pasirinko tyrin�ti to kaimo istorij�, apie kuri� nedaug
 * kas k� �inojo. Ta�iau ne visiems kaimo gyventojams jos �niuk�tin�jimas ir buvimas
 * tame kaime patiko, tod�l dienora�tyje kelet� kart� u�simenama apie nepaai�kinam� 
 * �moni� apatij� prad�jus dom�tis kaimelio praeitimi.
 *
 * Vien� nakt�, beklaid�iodama m�nesienos nutvieskstame miestelio pakra�tyje,
 * Ji sutinka senel� vardu Sofija, gyvenan�i� netoliese esan�iame name.
 * Senel� skirtingai nuo kit� kaimelio gyventoj� steb�tinai atvirai atsakin�ja 
 * � merginos nedr�siai u�duodamus klausimus. Savo dienora�tyje mergina ra�o, 
 * kad Sofija gyvena viena ir retai kada i�eina � vie�um�. Jaunoji �urnalist� 
 * sudominta senel�s istorij� apie miestel� ir kaip jis keit�si metai po met�,
 * vis daugiau laiko praleisdavo su ja. �ioje vietoje tekstas nutr�ksta,
 * liko tik i�pl��t� ir i�blukusi� puslapi� liku�iai.
 * 
 * Greit praverti ne�skaitomus puslapius, v�l aptinki pa�ystam� ra�t�,
 * tik jau kitu ra�alu ir para�yta matomai paskubomis. Raid�s neai�kios,
 * dienora�tis purvinas ir �em�tas, ta�iau nuvalius dulkes matai merginos
 * paskutin� �inut� - "a� tik noriu, kad viskas baigtusi".
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
					M:P:I(playerid, "U�duotis '[highlight]Kiti[]' prad�ta!");
				}
			}
			dialogShow(playerid, using inline response, DIALOG_STYLE_MSGBOX, "U�duotis 'Kiti': Prad�ia", Intro, "U�daryti", "");
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