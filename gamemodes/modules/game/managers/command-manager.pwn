public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success) {
	if(success != COMMAND_OK) {
		M:P:E(playerid, "Tokios komandos nëra.");
	}
	return COMMAND_OK;
}

public e_COMMAND_ERRORS:OnPlayerCommandPerformed(playerid, cmdtext[], e_COMMAND_ERRORS:success) {
	if(success != COMMAND_OK) {
		M:P:E(playerid, "Ðios komandos naudoti negali.");
	}
	return COMMAND_OK;
}