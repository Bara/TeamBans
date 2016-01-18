void CreateNatives()
{
	CreateNative("TeamBans_IsClientBanned", Native_IsClientBanned);
	
	CreateNative("TeamBans_GetClientTeam", Native_GetClientTeam);
	CreateNative("TeamBans_GetClientLength", Native_GetClientLength);
	CreateNative("TeamBans_GetClientTimeleft", Native_GetClientTimeleft);
	CreateNative("TeamBans_GetClientReason", Native_GetClientReason);
	
	CreateNative("TeamBans_SetClientBan", Native_SetClientBan);
	// CreateNative("TeamBans_DelClientBan", Native_DelClientBan);
	
	g_hOnBan = CreateGlobalForward("TeamBans_OnClientBan", ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_String);
	g_hOnUnban = CreateGlobalForward("TeamBans_OnClientUnban", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_String);
}

public int Native_IsClientBanned(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return g_iPlayer[client][clientBanned];
}

public int Native_GetClientTeam(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(IsClientValid(client))
	{
		if(g_iPlayer[client][clientBanned])
			return g_iPlayer[client][banTeam];
		else
			ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	}
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is invalid!", client);
	
	return 0;
}

public int Native_GetClientLength(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(IsClientValid(client))
	{
		if(g_iPlayer[client][clientBanned])
			return g_iPlayer[client][banLength];
		else
			ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	}
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is invalid!", client);
	
	return 0;
}

public int Native_GetClientTimeleft(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if(IsClientValid(client))
	{
		if(g_iPlayer[client][clientBanned])
			return g_iPlayer[client][banTimeleft];
		else
			ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	}
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is invalid!", client);
	
	return 0;
}

public int Native_GetClientReason(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(IsClientValid(client))
	{
		if(g_iPlayer[client][clientBanned])
		{
			int length = GetNativeCell(3);
			
			char sBuffer[TEAMBANS_REASON_LENGTH];
			
			strcopy(sBuffer, length, g_iPlayer[client][banReason]);
			
			SetNativeString(2, sBuffer, length);
		}
		else
			ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	}
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is invalid!", client);
	
	return 0;
}

public int Native_SetClientBan(Handle plugin, int numParams)
{
	char reason[TEAMBANS_REASON_LENGTH];
	
	int admin = GetNativeCell(1);
	int client = GetNativeCell(2);
	int team = GetNativeCell(3);
	int length = GetNativeCell(4);
	int timeleft = GetNativeCell(5);
	GetNativeString(6, reason, TEAMBANS_REASON_LENGTH);
	
	if(team == TEAMBANS_CT && g_iCvar[enableCTBan].BoolValue)
		ThrowNativeError(SP_ERROR_NATIVE, "CT-Ban disabled!", client);
	
	if(team == TEAMBANS_T && !g_iCvar[enableTBan].BoolValue)
		ThrowNativeError(SP_ERROR_NATIVE, "T-Ban disabled!", client);
	
	if(team == TEAMBANS_SERVER && !g_iCvar[enableServerBan].BoolValue)
		ThrowNativeError(SP_ERROR_NATIVE, "Server-Ban disabled!", client);
	
	if(IsClientValid(client))
	{
		char sCommunityID[64], sACommunityID[64];
 		if(!GetClientAuthId(client, AuthId_SteamID64, sCommunityID, sizeof(sCommunityID)))
 			ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is invalid!", client);
 		
 		if(admin > 0)
 		{
 			if(!GetClientAuthId(admin, AuthId_SteamID64, sACommunityID, sizeof(sACommunityID)))
 				Format(sACommunityID, sizeof(sACommunityID), "0");
 		}
 		else
 			Format(sACommunityID, sizeof(sACommunityID), "0");
 		
		if(GetLogLevel() >= view_as<int>(INFO))
			TB_LogFile(INFO, "[TeamBans] (Native_SetClientBan) Admin: \"%L\" %s - Player: \"%L\" %s - Length: %d - Reason: %s", admin, sACommunityID, client, sCommunityID, length, reason);
		
		if (g_iPlayer[client][clientBanned] && g_iPlayer[client][banTeam] > TEAMBANS_SERVER && g_iPlayer[client][banTeam] == team)
		{
			char sTeam[12], sTranslation[64], sBuffer[256];
			
			if(team == TEAMBANS_CT)
				Format(sTeam, sizeof(sTeam), "CT");
			else if(team == TEAMBANS_T)
				Format(sTeam, sizeof(sTeam), "T");
			
			Format(sTranslation, sizeof(sTranslation), "IsAlready%sBanned", sTeam);
			Format(sBuffer, sizeof(sBuffer), "%T", sTranslation, admin);
			
			if(GetEngineVersion() == Engine_CSS)
				MC_RemoveTags(sBuffer, sizeof(sBuffer));
			else if(GetEngineVersion() == Engine_CSGO)
				C_RemoveTags(sBuffer, sizeof(sBuffer));
			
			ThrowNativeError(SP_ERROR_NATIVE, sBuffer);
			
		}
		else
			SetTeamBan(admin, admin, team, length, timeleft, reason);
	}
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is invalid!", client);
}
