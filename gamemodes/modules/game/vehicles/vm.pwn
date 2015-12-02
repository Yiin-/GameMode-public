enum e_VM_QUESTIONS {
	e_CorrectAnswer,
	e_Answer1[50],
	e_Answer2[50],
	e_Answer3[50],
	e_Question[200]
};

new VM_Questions[ 10 ][e_VM_QUESTIONS] =
{
	{0, "Neturi", "Turi", "Turi, tik nereguliuojamoje sankryþoje.", "Ar turi pirmumo teis¿ policijos automobilis su iðjungtais ðvyturëliais ?"},
	{1, "Nereikia", "Reikia", "Reikia, tik uþ miesto ribø", "Ar mieste turite praleisti autobusà iðvaþiuojantá ið stotelës?"},
	{0, "Negalima", "Galima", "Galima, tik vasaros metu", "Ar galima vaþiuoti mopedais/keturaèiais greitkeliuose?"},
	{0, "Ne", "Taip", "Taip, tik nereguliuojamoje sankryþoje", "Ar ágyja pirmumo teisæ transporto priemonë su geltonais ðvyturëliais?"},
	{2, "De?in¿ rank? i?tiesti link kair?s Tr. priemon?s pus?s", "I?kelti de?in¿ rank? ? vir?¸", "I?tiesti de?in¿ rank? ? ?on? ir perlenkti per alk?n¿ ? vir?¸", "Kaip parodyti pos?kio signal? ? kair¿ su de?ine ranka ?"},
	{0, "Negalima", "Galima", "Negalima, tik su mopedais/ketura?iais", "Ar galima stov?ti u? p?s. per?jos ? Kelias turi po vien? kiekvienos krypties eismo juost?."},
	{2, "15 km/h", "30 km/h", "20 km/h", "Kokiu grei?iu galima va?iuoti stov?jimo aik?tel?se ?"},
	{0, "Negalima", "Galima", "Galima, tik 70 km/h grei?iu", "Ar galima va?iuoti greitkeliu, tempiant Tr. priemon¿ lank??ia vilktimi ?"},
	{1, "Negalima", "Galima", "Galima, tik ne?galiesiems", "Ar galima apsisukti sankry?oje ?"},
	{0, "Negalima", "Galima", "Galima, tik lanks?ia vilktimi", "Ar galima vilkti mopedais, mopedus ?"}
};