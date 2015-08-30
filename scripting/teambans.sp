#pragma semicolon 1

// Core
#include <sourcemod>
#include <cstrike>
#include <adminmenu>
#include <topmenus>

#pragma newdecls required

// Includes
#include <multicolors>

// Include all .sp-files from teambans-folder
#include "teambans/globals.sp"
#include "teambans/log.sp"
#include "teambans/cvars.sp"
#include "teambans/stocks.sp"
#include "teambans/commands.sp"
#include "teambans/functions.sp"
#include "teambans/timer.sp"
#include "teambans/callbacks.sp"
#include "teambans/sql.sp"
#include "teambans/adminmenu.sp"

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	version = PLUGIN_VERSION,
	description = PLUGIN_DESCRIPTION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSS && GetEngineVersion() != Engine_CSGO)
	{
		TB_LogFile(ERROR, "Only CS:S/CS:GO support");
		SetFailState("Only CS:S/CS:GO support");
		return;
	}
	
	BuildPath(Path_SM, g_sReasonsPath, sizeof(g_sReasonsPath), "configs/teambans/reasons.cfg");
	CheckReasonsFile();
	
	BuildPath(Path_SM, g_sLengthPath, sizeof(g_sLengthPath), "configs/teambans/length.cfg");
	CheckLengthFile();
	
	SQL_OnPluginStart();
	Cvar_OnPluginStart();
	
	RegConsoleCmd("sm_teambans", Command_TeamBans);
	
	RegAdminCmd("sm_ctban", Command_SetCTBan, ADMFLAG_BAN);
	RegAdminCmd("sm_tban", Command_SetTBan, ADMFLAG_BAN);
	
	RegAdminCmd("sm_ctunban", Command_DelCTBan, ADMFLAG_UNBAN);
	RegAdminCmd("sm_tunban", Command_DelTBan, ADMFLAG_UNBAN);

	AddCommandListener(Command_JoinTeam, "jointeam");
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	if(GetEngineVersion() == Engine_CSGO)
		LoadTranslations("teambans.csgo.phrases");
	else if(GetEngineVersion() == Engine_CSS)
		LoadTranslations("teambans.css.phrases");

	LoadTranslations("common.phrases");
	
	CheckAllClients();
	
}

public void OnMapStart()
{
	CheckReasonsFile();
	CheckLengthFile();
}

public void OnClientConnected(int client)
{
	ResetVars(client);
}

public void OnClientDisconnect(int client)
{
	ResetVars(client);
}

public void OnClientAuthorized(int client, const char[] auth)
{
	g_iPlayer[client][clientAuth] = true;
	g_iPlayer[client][clientID] = client;
	
	if (g_dDB == null)
		return;
	
	CheckTeamBans(client);
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsClientValid(client) || !g_iPlayer[client][clientReady])
		return;
	
	IsAndMoveClient(client);
}
