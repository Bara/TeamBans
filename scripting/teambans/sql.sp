stock void SQL_OnPluginStart()
{
	if (!SQL_CheckConfig("teambans"))
	{
		TB_LogFile(ERROR, "(SQL_OnPluginStart) Database failure: Couldn't find Database entry \"teambans\"");
		
		SetFailState("(SQL_OnPluginStart) Database failure: Couldn't find Database entry \"teambans\"");
		return;
	}
	
	Database.Connect(SQL_OnConnect, "teambans");
}

public void SQL_OnConnect(Database db, const char[] error, any data)
{
	if(db == null || strlen(error) > 0)
	{
		TB_LogFile(ERROR, "(SQL_OnConnect) Connection to database failed!: %s", error);
		
		SetFailState("(SQL_OnConnect) Connection to database failed!: %s", error);
		return;
	}
	
	DBDriver iDriver = db.Driver;
		
	char sDriver[16];
	iDriver.GetIdentifier(sDriver, sizeof(sDriver));
	
	if (!StrEqual(sDriver, "mysql", false))
	{
		TB_LogFile(ERROR, "(SQL_OnConnect) Only mysql support!");
		
		SetFailState("(SQL_OnConnect) Only mysql support!");
		return;
	}

	g_dDB = db;

	SQL_CheckTables();

	g_dDB.SetCharset("utf8");
	
	CheckAllClients();
}

public void SQL_OnClientAuthorized(Database db, DBResultSet results, const char[] error, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if(!client || g_iPlayer[client][clientID] != client)
		return;
	
	if(db == null || strlen(error) > 0)
	{
		if(GetLogLevel() >= view_as<int>(ERROR))
			TB_LogFile(ERROR, "[TeamBans] (SQL_OnClientAuthorized) Query failed: %s", error);
		
		return;
	}
	else
	{
		if(results.HasResults)
		{
			char sCommunityID[64];
			
			if(!GetClientAuthId(client, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
				return;
			
			while(results.FetchRow())
			{
				if(IsDebug() && GetLogLevel() >= view_as<int>(DEBUG))
					TB_LogFile(DEBUG, "[TeamBans] (SQL_OnClientAuthorized) %N - %s", client, sCommunityID);
				
				g_iPlayer[client][banLength] = results.FetchInt(0);
				g_iPlayer[client][banTimeleft] = results.FetchInt(1);
				int active = results.FetchInt(2);
				results.FetchString(3, g_iPlayer[client][banReason], MAX_BAN_REASON_LENGTH);
				g_iPlayer[client][banID] = results.FetchInt(4);
				g_iPlayer[client][banTeam] = results.FetchInt(5);
				
				if(active == 1)
				{
					g_iPlayer[client][clientBanned] = true;
					
					if (g_iPlayer[client][banLength] == 0)
					{
						g_iPlayer[client][banLength] = 0;
						g_iPlayer[client][banTimeleft] = 0;
						g_iPlayer[client][clientReady] = true;
					}
					else if (g_iPlayer[client][banLength] > 0 && g_iPlayer[client][banTimeleft] > 0)
					{
						SafeCloseHandle(g_iPlayer[client][banCheck]);
	
						if (g_iPlayer[client][banCheck] == null)
							g_iPlayer[client][banCheck]  = CreateTimer(60.0, Timer_BanCheck, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
						g_iPlayer[client][clientReady] = true;
					}
				}
				
				CreateTimer(5.0, Timer_SQLConnect, GetClientUserId(client));
				
				if(IsDebug() && GetLogLevel() >= view_as<int>(DEBUG))
					TB_LogFile(DEBUG, "clientIndex: %d - banLength: %d - banTimeleft: %d - banActive: %d - banReason: %s - banID: %d - banTeam: %d", client, g_iPlayer[client][banLength], g_iPlayer[client][banTimeleft], g_iPlayer[client][clientBanned], g_iPlayer[client][banReason], g_iPlayer[client][banID], g_iPlayer[client][banTeam]);
			}
			g_iPlayer[client][clientReady] = true;
		}
	}
}

public void SQL_ReCheckTeamBans(Database db, DBResultSet results, const char[] error, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if(!client || g_iPlayer[client][clientID] != client)
		return;
	
	if(db == null || strlen(error) > 0)
	{
		if(GetLogLevel() >= view_as<int>(ERROR))
			TB_LogFile(ERROR, "[TeamBans] (SQL_ReCheckTeamBans) Query failed: %s", error);
		return;
	}
	else
	{
		if(results.HasResults)
		{
			char sCommunityID[64];
			
			if(!GetClientAuthId(client, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
				return;
			
			while(results.FetchRow())
			{
				if(IsDebug() && GetLogLevel() >= view_as<int>(DEBUG))
					TB_LogFile(DEBUG, "[TeamBans] (SQL_ReCheckTeamBans) %N - %s", client, sCommunityID);
				
				g_iPlayer[client][banLength] = results.FetchInt(0);
				g_iPlayer[client][banTimeleft] = results.FetchInt(1);
				int active = results.FetchInt(2);
				results.FetchString(3, g_iPlayer[client][banReason], MAX_BAN_REASON_LENGTH);
				g_iPlayer[client][banID] = results.FetchInt(4);
				g_iPlayer[client][banTeam] = results.FetchInt(5);
				
				if(active == 1)
				{
					g_iPlayer[client][clientBanned] = true;
					
					if (g_iPlayer[client][banLength] == 0)
					{
						g_iPlayer[client][banLength] = 0;
						g_iPlayer[client][banTimeleft] = 0;
						g_iPlayer[client][clientReady] = true;
					}
					else if (g_iPlayer[client][banLength] > 0 && g_iPlayer[client][banTimeleft] > 0)
					{
						SafeCloseHandle(g_iPlayer[client][banCheck]);
	
						if (g_iPlayer[client][banCheck] == null)
							g_iPlayer[client][banCheck]  = CreateTimer(60.0, Timer_BanCheck, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
						g_iPlayer[client][clientReady] = true;
					}
				}
				
				CreateTimer(5.0, Timer_SQLConnect, GetClientUserId(client));
			}
			g_iPlayer[client][clientReady] = true;
		}
	}
}
