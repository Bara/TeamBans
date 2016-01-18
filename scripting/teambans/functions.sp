void CheckTeamBans(int client)
{
	if(!IsFakeClient(client))
	{
		char sCommunityID[64];
		
		if(!GetClientAuthId(client, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
			return;
		
		char sQuery[2048];
		Format(sQuery, sizeof(sQuery), QUERY_SELECT_BAN, sCommunityID);
		
		if(IsDebug() && GetLogLevel() >= view_as<int>(DEBUG))
			TB_LogFile(DEBUG, "[TeamBans] (UTIL_CheckTeamBans) %s", sQuery);
		
		if(g_dDB != null)
			g_dDB.Query(SQL_OnClientAuthorized, sQuery, GetClientUserId(client), DBPrio_High);
	}
}

void SetTeamBan(int admin, int client, int team, int length, int timeleft, const char[] eReason)
{
	char seName[MAX_NAME_LENGTH], seAdmin[MAX_NAME_LENGTH], sName[MAX_NAME_LENGTH], sAdmin[MAX_NAME_LENGTH], reason[256];
	GetClientName(client, seName, sizeof(seName));
	
	if (admin < 1)
		Format(seAdmin, sizeof(seAdmin), "Console");
	else
		GetClientName(admin, seAdmin, sizeof(seAdmin));
		
	g_dDB.Escape(seName, sName, sizeof(sName));
	g_dDB.Escape(seAdmin, sAdmin, sizeof(sAdmin));
	g_dDB.Escape(eReason, reason, sizeof(reason));
	
	char sACommunityID[64];
	
 	if(admin > 0)
 	{
		if(!GetClientAuthId(admin, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
			Format(sACommunityID, sizeof(sACommunityID), "0");
	}
	else
		Format(sACommunityID, sizeof(sACommunityID), "0");
 	
 	char sCommunityID[64];
 	if(!GetClientAuthId(client, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 		return;
	
	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), "INSERT INTO `teambans` (`playerid`, `playername`, `date`, `length`, `timeleft`, `team`, `active`, `reason`, `adminid`, `adminname`) VALUES ('%s', '%s', UNIX_TIMESTAMP(), '%d', '%d', '%d', '1', '%s', '%s', '%s');", sCommunityID, sName, length, timeleft, team, reason, sACommunityID, sAdmin);
	
	if(IsDebug() && GetLogLevel() >= view_as<int>(DEBUG))
		TB_LogFile(DEBUG, "[TeamBans] (SetTeamBan) %s", sQuery);
	
	Call_StartForward(g_hOnBan);
	Call_PushCell(admin);
	Call_PushCell(client);
	Call_PushString(sCommunityID);
	Call_PushCell(team);
	Call_PushCell(length);
	Call_PushCell(timeleft);
	Call_PushString(reason);
	Call_Finish();
	
	if(team > TEAMBANS_SERVER)
		g_dDB.Query(SQLCallback_SetBan, sQuery, GetClientUserId(client), DBPrio_High);
	else if(team == TEAMBANS_SERVER)
		g_dDB.Query(SQLCallback_SetServerBan, sQuery, GetClientUserId(client), DBPrio_High);
	
	char sTeam[6];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientValid(i))
		{
			if(team == TEAMBANS_CT)
				Format(sTeam, sizeof(sTeam), "%T", "CT", i);
			else if(team == TEAMBANS_T)
				Format(sTeam, sizeof(sTeam), "%T", "T", i);
			
			if(team > TEAMBANS_SERVER)
			{
				if(length > 0)
					CShowActivityEx(admin, g_sTag, "%T", "OnTeamBan", i, client, sTeam, length, reason);
				else if(length == 0)
					CShowActivityEx(admin, g_sTag, "%T", "OnTeamBanPerma", i, client, sTeam, reason);
			}
			else if(team == TEAMBANS_SERVER)
			{
				if(length > 0)
					CShowActivityEx(admin, g_sTag, "%T", "OnServerBan", i, client, sTeam, length, reason);
				else if(length == 0)
					CShowActivityEx(admin, g_sTag, "%T", "OnServerBanPerma", i, client, sTeam, reason);
			}
		}
	}
}

void DelTeamBan(int admin, int client)
{
	char reason[256];
	strcopy(reason, sizeof(reason), g_iPlayer[client][banReason]);

	int length = g_iPlayer[client][banLength];
	int team = g_iPlayer[client][banTeam];

	char sAdmin[MAX_NAME_LENGTH];
	char sACommunityID[64];
	
	if (admin == 0)
	{
		Format(sAdmin, sizeof(sAdmin), "Console");
		Format(sACommunityID, sizeof(sACommunityID), "0");
	}
	else
	{
		GetClientName(admin, sAdmin, sizeof(sAdmin));
		if(!GetClientAuthId(admin, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
		{
			Format(sAdmin, sizeof(sAdmin), "Console");
			Format(sACommunityID, sizeof(sACommunityID), "0");
		}
	}
	
	char sCommunityID[64];
 	if(!GetClientAuthId(client, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 		return;

	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), QUERY_DELETE_BAN, sACommunityID, sAdmin, sCommunityID, g_iPlayer[client][banID]);
	
	if(IsDebug() && GetLogLevel() >= view_as<int>(DEBUG))
		TB_LogFile(DEBUG, "[TeamBans] (DelTeamBan) %s", sQuery);
	
	Call_StartForward(g_hOnUnban);
	Call_PushCell(admin);
	Call_PushCell(client);
	Call_PushCell(g_iPlayer[client][banTeam]);
	Call_PushCell(g_iPlayer[client][banLength]);
	Call_PushString(g_iPlayer[client][banReason]);
	Call_Finish();
	
	g_dDB.Query(SQLCallback_DelBan, sQuery, GetClientUserId(client), DBPrio_High);
	
	char sTeam[6];
	
	if(team != TEAMBANS_SERVER)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i))
			{
				if(team == TEAMBANS_CT)
					Format(sTeam, sizeof(sTeam), "%T", "CT", i);
				else if(team == TEAMBANS_T)
					Format(sTeam, sizeof(sTeam), "%T", "T", i);
				
				if(length > 0)
					CShowActivityEx(admin, g_sTag, "%T", "OnTeamUnBan", i, client, length, reason, sTeam);
				else if(length == 0)
					CShowActivityEx(admin, g_sTag, "%T", "OnTeamUnBanPerma", i,  client, reason, sTeam);
			}
		}
	}
}

void CheckOfflineBans(int admin, char[] target,  int team, int length, char[] reason)
{
	char sQuery[2048];
	Format(sQuery, sizeof(sQuery), QUERY_SELECT_BAN, target);
	
	if(IsDebug() && GetLogLevel() >= view_as<int>(DEBUG))
		TB_LogFile(DEBUG, "[TeamBans] (CheckOfflineBans) %s", sQuery);
	
	if(g_dDB != null)
	{
		DataPack pack = new DataPack();
		
		pack.WriteCell(GetClientUserId(admin));
		pack.WriteString(target);
		pack.WriteCell(team);
		pack.WriteCell(length);
		pack.WriteString(reason);
		
		g_dDB.Query(SQL_CheckOfflineBans, sQuery, pack, DBPrio_High);
	}
}
