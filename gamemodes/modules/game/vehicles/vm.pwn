enum e_VM_QUESTIONS {
	e_CorrectAnswer,
	e_Answer1[50],
	e_Answer2[50],
	e_Answer3[50],
	e_Question[200]
};

new VM_Questions[ 10 ][e_VM_QUESTIONS] =
{
	{0, "Neturi", "Turi", "Turi, tik nereguliuojamoje sankry�oje.", "Ar turi pirmumo teis� policijos automobilis su i�jungtais �vytur�liais ?"},
	{1, "Nereikia", "Reikia", "Reikia, tik u� miesto rib�", "Ar mieste turite praleisti autobus� i�va�iuojant� i� stotel�s?"},
	{0, "Negalima", "Galima", "Galima, tik vasaros metu", "Ar galima va�iuoti mopedais/ketura�iais greitkeliuose?"},
	{0, "Ne", "Taip", "Taip, tik nereguliuojamoje sankry�oje", "Ar �gyja pirmumo teis� transporto priemon� su geltonais �vytur�liais?"},
	{2, "De?in� rank? i?tiesti link kair?s Tr. priemon?s pus?s", "I?kelti de?in� rank? ? vir?�", "I?tiesti de?in� rank? ? ?on? ir perlenkti per alk?n� ? vir?�", "Kaip parodyti pos?kio signal? ? kair� su de?ine ranka ?"},
	{0, "Negalima", "Galima", "Negalima, tik su mopedais/ketura?iais", "Ar galima stov?ti u? p?s. per?jos ? Kelias turi po vien? kiekvienos krypties eismo juost?."},
	{2, "15 km/h", "30 km/h", "20 km/h", "Kokiu grei?iu galima va?iuoti stov?jimo aik?tel?se ?"},
	{0, "Negalima", "Galima", "Galima, tik 70 km/h grei?iu", "Ar galima va?iuoti greitkeliu, tempiant Tr. priemon� lank??ia vilktimi ?"},
	{1, "Negalima", "Galima", "Galima, tik ne?galiesiems", "Ar galima apsisukti sankry?oje ?"},
	{0, "Negalima", "Galima", "Galima, tik lanks?ia vilktimi", "Ar galima vilkti mopedais, mopedus ?"}
};