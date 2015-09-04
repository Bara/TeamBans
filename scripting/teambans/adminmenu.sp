public void OnAdminMenuReady(Handle aTopmenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopmenu);
	
	if (topmenu == g_tTopMenu)
		return;
	
	g_tTopMenu = topmenu;
	
	TopMenuObject PlayerCommands = g_tTopMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);
	
	if(PlayerCommands != INVALID_TOPMENUOBJECT)
	{
		g_tTopMenu.AddItem("sm_ctban", AdminMenu_CTBan, PlayerCommands, "sm_ctban", ADMFLAG_BAN);
		g_tTopMenu.AddItem("sm_tban", AdminMenu_TBan, PlayerCommands, "sm_tban", ADMFLAG_BAN);
		g_tTopMenu.AddItem("sm_sban", AdminMenu_SBan, PlayerCommands, "sm_sban", ADMFLAG_BAN);
	}
}

public void AdminMenu_CTBan(Handle topmenu, TopMenuAction action, TopMenuObject topobj_id, int client, char[] title, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		char sBuffer[6];
		Format(sBuffer, sizeof(sBuffer), "%T", "CT", client);
		Format(title, maxlength, "%T", "TeamBansTitle", client, sBuffer);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayCTBansMenu(client);
	}
}

public void AdminMenu_TBan(Handle topmenu, TopMenuAction action, TopMenuObject topobj_id, int client, char[] title, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		char sBuffer[6];
		Format(sBuffer, sizeof(sBuffer), "%T", "T", client);
		Format(title, maxlength, "%T", "TeamBansTitle", client, sBuffer);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayTBansMenu(client);
	}
}

public void AdminMenu_SBan(Handle topmenu, TopMenuAction action, TopMenuObject topobj_id, int client, char[] title, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		char sBuffer[6];
		Format(title, maxlength, "%T", "ServerBansTitle", client, sBuffer);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplaySBansMenu(client);
	}
}

stock void DisplayCTBansMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_CTBansPlayerList);
	
	char sTitle[100];
	Format(sTitle, sizeof(sTitle), "%T", "SelectPlayer", client);
	menu.SetTitle(sTitle);
	menu.ExitBackButton = true;
	
	AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_CONNECTED);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

stock void DisplayTBansMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_TBansPlayerList);
	
	char sTitle[100];
	Format(sTitle, sizeof(sTitle), "%T", "SelectPlayer", client);
	menu.SetTitle(sTitle);
	menu.ExitBackButton = true;
	
	AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_CONNECTED);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

stock void DisplaySBansMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_SBansPlayerList);
	
	char sTitle[100];
	Format(sTitle, sizeof(sTitle), "%T", "SelectPlayer", client);
	menu.SetTitle(sTitle);
	menu.ExitBackButton = true;
	
	AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_CONNECTED);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_CTBansPlayerList(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_End)
		delete menu;
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_ExitBack && g_tTopMenu)
			g_tTopMenu.Display(client, TopMenuPosition_LastCategory);
	}
	else if (action == MenuAction_Select)
	{
		char sInfo[32], sName[32];
		int iUserID, iTarget;

		menu.GetItem(param, sInfo, sizeof(sInfo), _, sName, sizeof(sName));
		iUserID = StringToInt(sInfo);

		if ((iTarget = GetClientOfUserId(iUserID)) == 0)
			CPrintToChat(client, "%T", "Player no longer available", client);
		else if (!CanUserTarget(client, iTarget))
			CPrintToChat(client, "%T", "Unable to target", client);
		else if (HasClientTeamBan(iTarget))
		{
			if(GetClientBanTeam(iTarget) == CS_TEAM_CT)
				CPrintToChat(client, "%T", "IsAlreadyCTBanned", client, g_sTag);
			else if(GetClientBanTeam(iTarget) == CS_TEAM_T)
				CPrintToChat(client, "%T", "IsAlreadyTBanned", client, g_sTag);
		}
		else
		{
			g_iAMTeam[client] = CS_TEAM_CT;
			g_iAMTarget[client] = iTarget;
			DisplayTeamBanTimeMenu(client);
		}
	}
}

public int MenuHandler_TBansPlayerList(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_End)
		delete menu;
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_ExitBack && g_tTopMenu)
			g_tTopMenu.Display(client, TopMenuPosition_LastCategory);
	}
	else if (action == MenuAction_Select)
	{
		char sInfo[32], sName[32];
		int iUserID, iTarget;

		menu.GetItem(param, sInfo, sizeof(sInfo), _, sName, sizeof(sName));
		iUserID = StringToInt(sInfo);

		if ((iTarget = GetClientOfUserId(iUserID)) == 0)
			CPrintToChat(client, "%T", "Player no longer available", client);
		else if (!CanUserTarget(client, iTarget))
			CPrintToChat(client, "%T", "Unable to target", client);
		else if (HasClientTeamBan(iTarget))
		{
			if(GetClientBanTeam(iTarget) == CS_TEAM_T)
				CPrintToChat(client, "%T", "IsAlreadyTBanned", client, g_sTag);
			else if(GetClientBanTeam(iTarget) == CS_TEAM_CT)
				CPrintToChat(client, "%T", "IsAlreadyCTBanned", client, g_sTag);
		}
		else
		{
			g_iAMTeam[client] = CS_TEAM_T;
			g_iAMTarget[client] = iTarget;
			DisplayTeamBanTimeMenu(client);
		}
	}
}

public int MenuHandler_SBansPlayerList(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_End)
		delete menu;
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_ExitBack && g_tTopMenu)
			g_tTopMenu.Display(client, TopMenuPosition_LastCategory);
	}
	else if (action == MenuAction_Select)
	{
		char sInfo[32], sName[32];
		int iUserID, iTarget;

		menu.GetItem(param, sInfo, sizeof(sInfo), _, sName, sizeof(sName));
		iUserID = StringToInt(sInfo);

		if ((iTarget = GetClientOfUserId(iUserID)) == 0)
			CPrintToChat(client, "%T", "Player no longer available", client);
		else if (!CanUserTarget(client, iTarget))
			CPrintToChat(client, "%T", "Unable to target", client);
		else
		{
			g_iAMTeam[client] = TEAMBANS_SERVER;
			g_iAMTarget[client] = iTarget;
			DisplayTeamBanTimeMenu(client);
		}
	}
}

stock void DisplayTeamBanTimeMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_TeamBanTimeList);

	char sTitle[128];
	Format(sTitle, sizeof(sTitle), "%T", "SelectLength", client);
	menu.SetTitle(sTitle);
	menu.ExitBackButton = true;

	char sLength[12], sLengthName[256];
	g_kvLength.GotoFirstSubKey(false);
	do
	{
		g_kvLength.GetSectionName(sLength, sizeof(sLength));
		g_kvLength.GetString(NULL_STRING, sLengthName, sizeof(sLengthName));

		menu.AddItem(sLength, sLengthName);
	}
	while (g_kvLength.GotoNextKey(false));
	
	g_kvLength.Rewind();

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_TeamBanTimeList(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_End)
		delete menu;
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_ExitBack && g_tTopMenu)
			g_tTopMenu.Display(client, TopMenuPosition_LastCategory);
	}
	else if (action == MenuAction_Select)
	{
		char sInfo[32];

		menu.GetItem(param, sInfo, sizeof(sInfo));
		g_iAMTime[client] = StringToInt(sInfo);
		
		DisplayTeamBanReasons(client);
	}
}

stock void DisplayTeamBanReasons(int client)
{
	Menu menu = CreateMenu(MenuHandler_TeamBanReasons);

	char sTitle[100];
	Format(sTitle, sizeof(sTitle), "%T", "SelectReason", client);
	menu.SetTitle(sTitle);
	menu.ExitBackButton = true;
	
	char sReason[256];
	g_kvReasons.GotoFirstSubKey(false);
	do
	{
		g_kvReasons.GetString(NULL_STRING, sReason, sizeof(sReason));
		menu.AddItem(sReason, sReason);
	}
	while (g_kvReasons.GotoNextKey(false));
	
	g_kvReasons.Rewind();

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_TeamBanReasons(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_End)
		delete menu;
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_ExitBack && g_tTopMenu)
			g_tTopMenu.Display(client, TopMenuPosition_LastCategory);
	}
	else if (action == MenuAction_Select)
	{
		char sInfo[32];
		menu.GetItem(param, sInfo, sizeof(sInfo));
		
		SetTeamBan(client, g_iAMTarget[client], g_iAMTeam[client], g_iAMTime[client], g_iAMTime[client], sInfo);
		
		g_iAMTarget[client] = 0;
		g_iAMTime[client] = 0;
		g_iAMTeam[client] = 0;
	}
}
