#define PLUGIN_NAME "TeamBans"
#define PLUGIN_AUTHOR "Bara"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_DESCRIPTION "With TeamBans you can ban players from a team. (CT and T ban aren't supported)"
#define PLUGIN_URL "www.bara.in"

#define MAX_BAN_REASON_LENGTH 256

#define TEAMBANS_SERVER 1
#define TEAMBANS_T CS_TEAM_T
#define TEAMBANS_CT CS_TEAM_CT

#define IsDebug() g_iCvar[pluginDebug].BoolValue
#define GetLogLevel() g_iCvar[logLevel].IntValue

#define QUERY_SELECT_BAN "SELECT length, timeleft, active, reason, id, team, date FROM teambans WHERE playerid = '%s' AND uadminid IS NULL AND active = '1' ORDER BY id DESC LIMIT 1;"
#define QUERY_DELETE_BAN "UPDATE `teambans` SET `timeleft` = '0', `active` = '0', `uadminid` = '%s', `uadminname` = '%s' WHERE `playerid` = '%s' AND `uadminid` IS NULL AND `active` = '1' AND `id` = '%d';"
#define QUERY_UPDATE_BAN "UPDATE `teambans` SET `timeleft` = '%d' WHERE `playerid`= '%s' AND `uadminid` IS NULL AND `active` = '1' AND `length` > '0' AND `timeleft` > '0' AND `id` = '%d';"

enum ELOG_LEVEL
{
	TRACE,
	DEBUG,
	DEFAULT = 2,
	INFO,
	WARN,
	ERROR
}

char g_sELogLevel[6][32] = {
	"default",
	"trace",
	"debug",
	"info",
	"warn",
	"error"
};


enum Data
{
	clientID,
	bool:clientAuth,
	bool:clientReady,
	bool:clientBanned,
	banID,
	banLength,
	banTimeleft,
	banTeam,
	String:banReason[MAX_BAN_REASON_LENGTH],
	Handle:banCheck,
	banDate
};

enum Cvars
{
	ConVar:pluginDebug,
	ConVar:pluginTag,
	ConVar:logLevel,
	ConVar:playerChecks,
	ConVar:defaultBanLength,
	ConVar:defaultBanReason
};

int g_iPlayer[MAXPLAYERS + 1][Data];
int g_iCvar[Cvars];

char g_sTag[256] = "";

Database g_dDB = null;

// Adminmenu
TopMenu g_tTopMenu = null;
int g_iAMTarget[MAXPLAYERS + 1] = { 0, ... };
int g_iAMTime[MAXPLAYERS + 1] = { 0, ... };
int g_iAMTeam[MAXPLAYERS + 1] = { 0, ... };

// Reasons
char g_sReasonsPath[PLATFORM_MAX_PATH];
KeyValues g_kvReasons;

// Length
char g_sLengthPath[PLATFORM_MAX_PATH];
KeyValues g_kvLength;
