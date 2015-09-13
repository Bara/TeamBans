void CreateNatives()
{
	CreateNative("TeamBans_IsClientBanned", Native_IsClientBanned);
	CreateNative("TeamBans_GetClientTeam", Native_GetClientTeam);
	CreateNative("TeamBans_GetClientLength", Native_GetClientLength);
	CreateNative("TeamBans_GetClientTimeleft", Native_GetClientTimeleft);
	CreateNative("TeamBans_GetClientReason", Native_GetClientReason);
}

public int Native_IsClientBanned(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return g_iPlayer[client][clientBanned];
}

public int Native_GetClientTeam(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if(g_iPlayer[client][clientBanned])
		return g_iPlayer[client][banTeam];
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	
	return 0;
}

public int Native_GetClientLength(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if(g_iPlayer[client][clientBanned])
		return g_iPlayer[client][banLength];
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	
	return 0;
}

public int Native_GetClientTimeleft(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if(g_iPlayer[client][clientBanned])
		return g_iPlayer[client][banTimeleft];
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	
	return 0;
}

public int Native_GetClientReason(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(g_iPlayer[client][clientBanned])
	{
		int length = GetNativeCell(3);
		
		char sBuffer[TEAMBANS_REASON_LENGTH];
		
		strcopy(sBuffer, length, g_iPlayer[client][banReason]);
		
		SetNativeString(2, sBuffer, length);
	}
	else
		ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not banned!", client);
	
	return 0;
}
