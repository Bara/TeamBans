public Action Command_JoinTeam(int client, const char[] command, int args)
{
	if (!IsClientValid(client) || !g_iPlayer[client][clientReady])
		return Plugin_Continue;

	char sTeam[3];
	GetCmdArg(1, sTeam, sizeof(sTeam));
	int iTeam = StringToInt(sTeam);
	
	if(IsAndMoveClient_JoinTeam(client, iTeam))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Command_TeamBans(int client, int args)
{
	if (IsClientValid(client))
	{
		Menu menu = CreateMenu(Menu_Block);
		char sTitle[256];
		Format(sTitle, sizeof(sTitle), "%T", "TeamBansList", client);
		menu.SetTitle(sTitle);

		int count = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i))
			{
				if (HasClientTeamBan(i))
				{
					char sUserID[128];
					IntToString(GetClientUserId(i), sUserID, sizeof(sUserID));

					char sName[MAX_NAME_LENGTH], sTeam[4];
					
					if(GetClientBanTeam(client) == CS_TEAM_CT)
						Format(sTeam, sizeof(sTeam), "%T", "CT", client);
					else if(GetClientBanTeam(client) == CS_TEAM_T)
						Format(sTeam, sizeof(sTeam), "%T", "T", client);
					
					if(g_iPlayer[i][banLength] > 0)
						Format(sName, sizeof(sName), "%T", "TeamBansListPlayer", client, sTeam, i, g_iPlayer[i][banTimeleft], g_iPlayer[i][banLength]);
					else if(g_iPlayer[i][banLength] == 0)
						Format(sName, sizeof(sName), "%T", "TeamBansListPlayerPerma", client, sTeam, i);
					
					menu.AddItem(sUserID, sName);

					count++;
				}
			}
		}

		if(count == 0)
		{
			char sBuffer[64];
			Format(sBuffer, sizeof(sBuffer), "%T", "NoPlayers", client);
			menu.AddItem("", sBuffer, ITEMDRAW_DISABLED);
		}

		menu.ExitButton = true;
		menu.Display(client, 30);
	}
}

public int Menu_Block(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sUserID[64];
		menu.GetItem(param, sUserID, sizeof(sUserID));
		int userid = StringToInt(sUserID);
		int target = GetClientOfUserId(userid);

		if (IsClientValid(target))
		{
			char sTeam[6];
			
			if(GetClientBanTeam(target) == CS_TEAM_CT)
				Format(sTeam, sizeof(sTeam), "%T", "CT", client);
			else if(GetClientBanTeam(target) == CS_TEAM_T)
				Format(sTeam, sizeof(sTeam), "%T", "T", client);

			if(g_iPlayer[target][banLength] > 0)
				CPrintToChat(client, "%T", "TeamBansInfo", client, g_sTag, target, g_iPlayer[target][banLength], g_iPlayer[target][banTimeleft], g_iPlayer[target][banReason], sTeam);
			else if(g_iPlayer[target][banLength] == 0)
				CPrintToChat(client, "%T", "TeamBansInfoPerma", client, g_sTag, target, g_iPlayer[target][banReason], sTeam);
		}

		Command_TeamBans(client, 0);
		delete menu;
	}
}

public Action Command_SetCTBan(int client, int args)
{
	if (args < 2)
	{
		CReplyToCommand(client, "%T", "CTBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}
	
	// Get client
	char sArg1[MAX_NAME_LENGTH];
	GetCmdArg(1, sArg1, sizeof(sArg1));
	
	// Get Length
	char sArg2[12];
	GetCmdArg(2, sArg2, sizeof(sArg2));
	
	int iLength;
	
	if(args == 1)
	{
		char sDLength[12];
		g_iCvar[defaultBanLength].GetString(sDLength, sizeof(sDLength));
		iLength = StringToInt(sDLength);
	}
	else
		iLength = StringToInt(sArg2);
	
	if(iLength < 0)
	{
		CReplyToCommand(client, "%T", "CTBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}
	
	// Get Reason
	char sReason[128], sBuffer[128];
	if(args >= 3)
	{
		for (int i = 3; i <= args; i++)
		{
			GetCmdArg(i, sBuffer, sizeof(sBuffer));
			Format(sReason, sizeof(sReason), "%s %s", sReason , sBuffer);
		}
	}
	else
	{
		char sTBuffer[32];
		g_iCvar[defaultBanReason].GetString(sTBuffer, sizeof(sTBuffer));
		Format(sReason, sizeof(sReason), "%T", sTBuffer, LANG_SERVER);
	}
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(sArg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		char sCommunityID[64], sACommunityID[64];
 		if(!GetClientAuthId(target, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 			return Plugin_Handled;
 		
 		if(client > 0)
 		{
 			if(!GetClientAuthId(client, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
 				Format(sACommunityID, sizeof(sACommunityID), "0");
 		}
 		else
 			Format(sACommunityID, sizeof(sACommunityID), "0");
 		
 		if(GetLogLevel() >= view_as<int>(INFO))
			TB_LogFile(INFO, "[TeamBans] (Command_SetCTBan) Admin: \"%L\" %s - Player: \"%L\" %s - Length: %d - Reason: %s", client, sACommunityID, target, sCommunityID, iLength, sReason);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "%T", "Invalid", client);
			return Plugin_Handled;
		}
		
		// Only one team ban/person
		if (!HasClientTeamBan(target))
			SetTeamBan(client, target, CS_TEAM_CT, iLength, iLength, sReason);
		else
		{
			if(GetClientBanTeam(client) == CS_TEAM_CT)
			{
				CReplyToCommand(client, "%T", "IsAlreadyCTBanned", client, g_sTag);
				return Plugin_Handled;
			}
			CReplyToCommand(client, "%T", "IsAlreadyTBanned", client, g_sTag);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action Command_SetTBan(int client, int args)
{
	if (args < 3)
	{
		CReplyToCommand(client, "%T", "TBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}
	
	// Get client
	char sArg1[MAX_NAME_LENGTH];
	GetCmdArg(1, sArg1, sizeof(sArg1));
	
	// Get Length
	char sArg2[12];
	GetCmdArg(2, sArg2, sizeof(sArg2));
	
	int iLength;
	
	if(args == 1)
	{
		char sDLength[12];
		g_iCvar[defaultBanLength].GetString(sDLength, sizeof(sDLength));
		iLength = StringToInt(sDLength);
	}
	else
		iLength = StringToInt(sArg2);
	
	if(iLength < 0)
	{
		CReplyToCommand(client, "%T", "TBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}
	
	// Get Reason
	char sReason[128], sBuffer[128];
	if(args >= 3)
	{
		for (int i = 3; i <= args; i++)
		{
			GetCmdArg(i, sBuffer, sizeof(sBuffer));
			Format(sReason, sizeof(sReason), "%s %s", sReason , sBuffer);
		}
	}
	else
	{
		char sTBuffer[32];
		g_iCvar[defaultBanReason].GetString(sTBuffer, sizeof(sTBuffer));
		Format(sReason, sizeof(sReason), "%T", sTBuffer, LANG_SERVER);
	}

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(sArg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		char sCommunityID[64], sACommunityID[64];
 		if(!GetClientAuthId(target, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 			return Plugin_Handled;
 		
 		if(client > 0)
 		{
 			if(!GetClientAuthId(client, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
 				Format(sACommunityID, sizeof(sACommunityID), "0");
 		}
 		else
 			Format(sACommunityID, sizeof(sACommunityID), "0");
 		
 		if(GetLogLevel() >= view_as<int>(INFO))
			TB_LogFile(INFO, "[TeamBans] (Command_SetTBan) Admin: \"%L\" %s - Player: \"%L\" %s - Length: %d - Reason: %s", client, sACommunityID, target, sCommunityID, iLength, sReason);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "%T", "Invalid", client);
			return Plugin_Handled;
		}

		// Only one team ban/person
		if (!HasClientTeamBan(target))
			SetTeamBan(client, target, CS_TEAM_T, iLength, iLength, sReason);
		else
		{
			if(GetClientBanTeam(client) == CS_TEAM_T)
			{
				CReplyToCommand(client, "%T", "IsAlreadyTBanned", client, g_sTag);
				return Plugin_Handled;
			}
			CReplyToCommand(client, "%T", "IsAlreadyCTBanned", client, g_sTag);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action Command_SetSBan(int client, int args)
{
	if (args < 3)
	{
		CReplyToCommand(client, "%T", "SBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}
	
	// Get client
	char sArg1[MAX_NAME_LENGTH];
	GetCmdArg(1, sArg1, sizeof(sArg1));
	
	// Get Length
	char sArg2[12];
	GetCmdArg(2, sArg2, sizeof(sArg2));
	
	int iLength;
	
	if(args == 1)
	{
		char sDLength[12];
		g_iCvar[defaultBanLength].GetString(sDLength, sizeof(sDLength));
		iLength = StringToInt(sDLength);
	}
	else
		iLength = StringToInt(sArg2);
	
	if(iLength < 0)
	{
		CReplyToCommand(client, "%T", "SBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}
	
	// Get Reason
	char sReason[128], sBuffer[128];
	if(args >= 3)
	{
		for (int i = 3; i <= args; i++)
		{
			GetCmdArg(i, sBuffer, sizeof(sBuffer));
			Format(sReason, sizeof(sReason), "%s %s", sReason , sBuffer);
		}
	}
	else
	{
		char sTBuffer[32];
		g_iCvar[defaultBanReason].GetString(sTBuffer, sizeof(sTBuffer));
		Format(sReason, sizeof(sReason), "%T", sTBuffer, LANG_SERVER);
	}

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(sArg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		char sCommunityID[64], sACommunityID[64];
 		if(!GetClientAuthId(target, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 			return Plugin_Handled;
 		
 		if(client > 0)
 		{
 			if(!GetClientAuthId(client, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
 				Format(sACommunityID, sizeof(sACommunityID), "0");
 		}
 		else
 			Format(sACommunityID, sizeof(sACommunityID), "0");
 		
 		if(GetLogLevel() >= view_as<int>(INFO))
			TB_LogFile(INFO, "[TeamBans] (Command_SetTBan) Admin: \"%L\" %s - Player: \"%L\" %s - Length: %d - Reason: %s", client, sACommunityID, target, sCommunityID, iLength, sReason);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "%T", "Invalid", client);
			return Plugin_Handled;
		}

		SetTeamBan(client, target, TEAMBANS_SERVER, iLength, iLength, sReason);
	}
	return Plugin_Continue;
}

public Action Command_DelCTBan(int client, int args)
{
	if (args != 1)
	{
		CReplyToCommand(client, "%T", "CTUnBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}

	char sArg1[MAX_NAME_LENGTH];
	GetCmdArg(1, sArg1, sizeof(sArg1));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(sArg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		char sCommunityID[64], sACommunityID[64];
 		if(!GetClientAuthId(target, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 			return Plugin_Handled;
 		
 		if(!GetClientAuthId(client, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
 			return Plugin_Handled;
 		
 		if(GetLogLevel() >= view_as<int>(INFO))
			TB_LogFile(INFO, "[TeamBans] (Command_DelCTBan) Admin: \"%L\" %s - Player: \"%L\" %s", client, sACommunityID, target, sCommunityID);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "%T", "Invalid", client);
			return Plugin_Handled;
		}

		if (HasClientTeamBan(target) && GetClientBanTeam(client) == CS_TEAM_CT)
			DelTeamBan(client, target);
		else
		{
			CReplyToCommand(client, "%T", "IsntCTBanned", client, g_sTag);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action Command_DelTBan(int client, int args)
{
	if (args != 1)
	{
		CReplyToCommand(client, "%T", "TUnBanSyntax", client, g_sTag);
		return Plugin_Handled;
	}

	char sArg1[MAX_NAME_LENGTH];
	GetCmdArg(1, sArg1, sizeof(sArg1));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(sArg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		char sCommunityID[64], sACommunityID[64];
 		if(!GetClientAuthId(target, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 			return Plugin_Handled;
 		
 		if(!GetClientAuthId(client, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
 			return Plugin_Handled;
 		
 		if(GetLogLevel() >= view_as<int>(INFO))
			TB_LogFile(INFO, "[TeamBans] (Command_DelTBan) Admin: \"%L\" %s - Player: \"%L\" %s", client, sACommunityID, target, sCommunityID);

		if (!IsClientValid(target))
		{
			CReplyToCommand(client, "%T", "Invalid", client);
			return Plugin_Handled;
		}

		if (HasClientTeamBan(target) && GetClientBanTeam(client) == CS_TEAM_T)
			DelTeamBan(client, target);
		else
		{
			CReplyToCommand(client, "%T", "IsntTBanned", client, g_sTag);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
