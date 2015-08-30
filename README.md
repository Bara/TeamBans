[CS:S/CS:GO] TeamBans [![build status](http://ci.git.tf/projects/7/status.png?ref=master)](http://ci.git.tf/projects/7?ref=master)
---
[TeamBans on Git.TF](http://git.tf/Bara/TeamBans)

### Short description
With TeamBans you can ban players from a team. CT and T ban aren't supported (but planned)

### Supported Games
 * Counter-Strike: Source (partially tested)
 * Counter-Strike: Global Offensive (untested)

### Features
 * Public player list with banned players with informations about her bans
 * Per player is only 1 team ban allowed
 * Instant move on/after ban
 * No Glitch Bug
 * MySQL Support
 * Adminmenu Support
 * Custom reasons
 * Custom lengths

### CVars
 * teambans_enable_debug
  * Default value: "1"
  * More log actions
  * If this cvar 1, then I can give more/better support
 * teambans_plugin_tag
  * (CSS) Default value: "{strange}[TeamBans] {grey}"
  * (CSGO) Default value: "{green}[TeamBans] {default}"
  * Tag for the most chat messages
  * 2 different default values for better css and csgo support
 * teambans_log_level
  * Default value: "2"
  * 0 - Trace, 1 - Debug, 2 - Default, 3 - Info, 4 - Warning, 5 - Error
  * Own folders in log directory
 * teambans_player_checks
  * Default value: "3.0"
  * Interval per player check (required for no glitch bug)
 * teambans_default_ban_length
  * Default value: "30"
  * Default ban length for a ban without length
 * teambans_default_ban_reason
  * Default value: "DefaultReason"
  * Default ban reason for a ban without reason

### Player Commands
 * sm_teambans

### Admin Commands
 * sm_ctban
 * sm_ctunban
 * sm_tban
 * sm_tunban

### Requirement
 * SourceMod 1.7.0+
 * Multi Colors 2.0.0+ (only for compile)

### Installation
 * Upload both config files (configs/teambans/reasons.cfg + configs/teambans/reasons.cfg)
 * Upload translation file (CSS: translations/teambans.css.phrases.txt and CSGO: translations/teambans.csgo.phrases.txt)
 * Add config entry "teambans" in configs/databases.cfg
 * Upload binary file (plugins/teambans.smx) or compile for yourself