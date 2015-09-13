#pragma semicolon 1

// Core
#include <sourcemod>

#pragma newdecls required

// Includes
#include <teambans>

public Plugin myinfo =
{
	name = TEAMBANS_PLUGIN_NAME,
	author = TEAMBANS_PLUGIN_AUTHOR,
	version = TEAMBANS_PLUGIN_VERSION,
	description = TEAMBANS_PLUGIN_DESCRIPTION,
	url = TEAMBANS_PLUGIN_URL
};

public void OnPluginStart()
{
	HookEvent("weapon_fire", Event_WeaponFire);
}

public Action Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if(TeamBans_IsClientBanned(client))
		{
			char sReason[TEAMBANS_REASON_LENGTH];
			TeamBans_GetClientReason(client, sReason, sizeof(sReason));
			
			PrintToChatAll("Client: %d", client);
			PrintToChatAll("Status: %d", TeamBans_IsClientBanned(client));
			PrintToChatAll("Team: %d", TeamBans_GetClientTeam(client));
			PrintToChatAll("Length: %d", TeamBans_GetClientLength(client));
			PrintToChatAll("Timeleft: %d", TeamBans_GetClientTimeleft(client));
			PrintToChatAll("Reason: %s", sReason);
		}
		else
		{
			PrintToChatAll("Client: %d", client);
			PrintToChatAll("Status: %d", TeamBans_IsClientBanned(client));
		}
	}
}

public void TeamBans_OnClientBan(int admin, int client, int team, int length, int timeleft, const char[] reason)
{
	PrintToChatAll("Admin: %d", admin);
	PrintToChatAll("Client: %d", client);
	PrintToChatAll("Team: %d", team);
	PrintToChatAll("Length: %d", length);
	PrintToChatAll("Timeleft: %d", timeleft);
	PrintToChatAll("Reason: %s", reason);
}

public void TeamBans_OnClientUnban(int admin, int client, int team, int length, const char[] reason)
{
	PrintToChatAll("Admin: %d", admin);
	PrintToChatAll("Client: %d", client);
	PrintToChatAll("Team: %d", team);
	PrintToChatAll("Length: %d", length);
	PrintToChatAll("Reason: %s", reason);
}
