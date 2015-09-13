#if defined _teambans_included
 #endinput
#endif
#define _teambans_included

#define TEAMBANS_PLUGIN_NAME "TeamBans"
#define TEAMBANS_PLUGIN_AUTHOR "Bara"
#define TEAMBANS_PLUGIN_VERSION "1.0.0"
#define TEAMBANS_PLUGIN_DESCRIPTION "With TeamBans you can ban players from a team. (CT and T ban aren't supported)"
#define TEAMBANS_PLUGIN_URL "www.bara.in"

#define TEAMBANS_SERVER 1
#define TEAMBANS_T 2
#define TEAMBANS_CT 3

#define TEAMBANS_REASON_LENGTH 256

native bool TeamBans_IsClientBanned(int client);
native int TeamBans_GetClientTeam(int client);
native int TeamBans_GetClientLength(int client);
native int TeamBans_GetClientTimeleft(int client);
native void TeamBans_GetClientReason(int client, const char[] reason, int maxlength);

stock bool IsTeamBansLoaded()
{
	return LibraryExists("teambans");
}

public SharedPlugin __pl_teambans = 
{
	name = "teambans",
	file = "teambans.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_teambans_SetNTVOptional()
{
	MarkNativeAsOptional("TeamBans_IsClientBanned");
}
#endif