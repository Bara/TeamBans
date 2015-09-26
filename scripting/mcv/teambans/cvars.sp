public void MCV_OnCVarsLoaded()
{
	CreateConVar("teambans_version", TEAMBANS_PLUGIN_VERSION, TEAMBANS_PLUGIN_DESCRIPTION, FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	g_iCvar[pluginDebug] = MCV_AddBool("teambans_enable_debug", true, "Enable debugging?");
	
	if(GetEngineVersion() == Engine_CSS)
		MCV_AddString("teambans_plugin_tag", "{azure}[TeamBans] {white}", "Choose the plugin tag for this plugin", g_iCvar[pluginTag], MAX_MESSAGE_LENGTH);
	else if(GetEngineVersion() == Engine_CSGO)
		MCV_AddString("teambans_plugin_tag", "{green}[TeamBans] {lightgreen}", "Choose the plugin tag for this plugin", g_iCvar[pluginTag], MAX_MESSAGE_LENGTH);
	
	g_iCvar[logLevel] = MCV_AddInt("teambans_log_level", 1, "0 - Trace, 1 - Debug, 2 - Default, 3 - Info, 4 - Warning, 5 - Error");
	g_iCvar[playerChecks] = MCV_AddFloat("teambans_player_checks", 3.0, "Check clients every x seconds");
	g_iCvar[defaultBanLength] = MCV_AddInt("teambans_default_ban_length", 30, "Default ban length in minutes");
	MCV_AddString("teambans_default_ban_reason", "DefaultReason", "Default ban reason phrase (Attention! Changes at your own risk!)", g_iCvar[defaultBanReason], TEAMBANS_REASON_LENGTH);
	
	PrintToServer("teambans_enable_debug: %d", g_iCvar[pluginDebug]);
	PrintToServer("teambans_plugin_tag: %s", g_iCvar[pluginTag]);
	PrintToServer("teambans_log_level: %d", g_iCvar[logLevel]);
	PrintToServer("teambans_player_checks: %d", g_iCvar[playerChecks]);
	PrintToServer("teambans_default_ban_length: %d", g_iCvar[defaultBanLength]);
	PrintToServer("teambans_default_ban_reason: %s", g_iCvar[defaultBanReason]);
	
	Format(g_sTag, sizeof(g_sTag), g_iCvar[pluginTag]);
	CreateTimer(g_iCvar[playerChecks], Timer_CheckClients, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}
