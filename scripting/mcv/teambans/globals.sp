#define IsDebug() g_iCvar[pluginDebug]
#define GetLogLevel() g_iCvar[logLevel]

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
	String:banReason[TEAMBANS_REASON_LENGTH],
	Handle:banCheck,
	banDate
};

enum Cvars
{
	bool:pluginDebug,
	String:pluginTag[MAX_MESSAGE_LENGTH],
	logLevel,
	Float:playerChecks,
	defaultBanLength,
	String:defaultBanReason[TEAMBANS_REASON_LENGTH]
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

// Forwards
Handle g_hOnBan = null;
Handle g_hOnUnban = null;