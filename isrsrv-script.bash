#!/bin/bash

#Interstellar Rift server script by 7thCore
#If you do not know what any of these settings are you are better off leaving them alone. One thing might brake the other if you fiddle around with it.
VERSION="202201141818"

#Basics
NAME="IsRSrv" #Name of the tmux session

#Server configuration
SERVICE_NAME="isrsrv" #Name of the service files, script and script log
SRV_DIR="/srv/$SERVICE_NAME/server" #Location of the server located on your hdd/ssd
SCRIPT_NAME="$SERVICE_NAME-script.bash" #Script name
CONFIG_DIR="/srv/$SERVICE_NAME/config" #Location of this script
UPDATE_DIR="/srv/$SERVICE_NAME/updates" #Location of update information for the script's automatic update feature

#Script configuration
if [ -f "$CONFIG_DIR/$SERVICE_NAME-script.conf" ] ; then
	TMPFS_ENABLE=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf | grep script_tmpfs= | cut -d = -f2) #Get configuration for tmpfs
	BCKP_DELOLD=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf | grep script_bckp_delold= | cut -d = -f2) #Delete old backups.
	LOG_DELOLD=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf | grep script_log_delold= | cut -d = -f2) #Delete old logs.
	LOG_GAME_DELOLD=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf | grep script_log_game_delold= | cut -d = -f2) #Delete old game logs.
	DUMP_GAME_DELOLD=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf | grep script_dump_game_delold= | cut -d = -f2) #Delete old game dumps.
	UPDATE_IGNORE_FAILED_ACTIVATIONS=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf | grep script_update_ignore_failed_startups= | cut -d = -f2) #Ignore failed startups during update configuration
	TIMEOUT_SAVE=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf | grep script_timeout_save= | cut -d = -f2) #Get timeout configuration for save timeout.
else
	if [[ "install" != "$1" ]] && [[ "help" != "$1" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Configuration) Error: The script configuration file is missing. Generating missing configuration strings using default values."
	fi
fi

#Steamcmd configuration
if [ -f "$CONFIG_DIR/$SERVICE_NAME-steam.conf" ] ; then
	STEAMCMD_UID=$(cat $CONFIG_DIR/$SERVICE_NAME-steam.conf | grep steamcmd_username= | cut -d = -f2) #Your steam username
	STEAMCMD_PSW=$(cat $CONFIG_DIR/$SERVICE_NAME-steam.conf | grep steamcmd_password= | cut -d = -f2) #Your steam password
	STEAMCMD_BETA_BRANCH=$(cat $CONFIG_DIR/$SERVICE_NAME-steam.conf | grep steamcmd_beta_branch= | cut -d = -f2) #Beta branch enabled?
	STEAMCMD_BETA_BRANCH_NAME=$(cat $CONFIG_DIR/$SERVICE_NAME-steam.conf | grep steamcmd_beta_branch_name= | cut -d = -f2) #Beta branch name
	STEAMGUARD_CLI=$(cat $CONFIG_DIR/$SERVICE_NAME-steam.conf | grep steamguard_cli= | cut -d = -f2) #If you have a steamguard application present and configured
else
	STEAMCMD_UID="disabled"
	STEAMCMD_PSW="disabled"
	STEAMCMD_BETA_BRANCH="0"
	STEAMCMD_BETA_BRANCH_NAME="0"
	STEAMGUARD_CLI="0"
fi

#Email configuration
if [ -f "$CONFIG_DIR/$SERVICE_NAME-email.conf" ] ; then
	EMAIL_SENDER=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf | grep email_sender= | cut -d = -f2) #Send emails from this address
	EMAIL_RECIPIENT=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf | grep email_recipient= | cut -d = -f2) #Send emails to this address
	EMAIL_UPDATE=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf | grep email_update= | cut -d = -f2) #Send emails when server updates
	EMAIL_START=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf | grep email_start= | cut -d = -f2) #Send emails when the server starts up
	EMAIL_STOP=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf | grep email_stop= | cut -d = -f2) #Send emails when the server shuts down
	EMAIL_CRASH=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf | grep email_crash= | cut -d = -f2) #Send emails when the server crashes
else
	EMAIL_SENDER="0"
	EMAIL_RECIPIENT="0"
	EMAIL_UPDATE="0"
	EMAIL_START="0"
	EMAIL_STOP="0"
	EMAIL_CRASH="0"
fi

#Discord configuration
if [ -f "$CONFIG_DIR/$SERVICE_NAME-discord.conf" ] ; then
	DISCORD_UPDATE=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf | grep discord_update= | cut -d = -f2) #Send notification when the server updates
	DISCORD_START=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf | grep discord_start= | cut -d = -f2) #Send notifications when the server starts
	DISCORD_STOP=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf | grep discord_stop= | cut -d = -f2) #Send notifications when the server stops
	DISCORD_CRASH=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf | grep discord_crash= | cut -d = -f2) #Send notifications when the server crashes
else
	DISCORD_UPDATE="0"
	DISCORD_START="0"
	DISCORD_STOP="0"
	DISCORD_CRASH="0"
fi

#App id of the steam game
APPID="363360"

#Wine configuration
WINE_ARCH="win64" #Architecture of the wine prefix
WINE_PREFIX_GAME_DIR="drive_c/Games/InterstellarRift" #Server executable directory
WINE_PREFIX_GAME_EXE="Build/IR.exe -server -serverAddition %i -inline -linux -nossl -noConsoleAutoComplete" #Server executable
WINE_PREFIX_GAME_CONFIG="drive_c/users/$SERVICE_NAME/AppData/Roaming/InterstellarRift"

#Ramdisk configuration
TMPFS_DIR="/srv/$SERVICE_NAME/tmpfs" #Locaton of your tmpfs partition.

#TmpFs/hdd variables
if [[ "$TMPFS_ENABLE" == "1" ]]; then
	BCKP_SRC_DIR="$TMPFS_DIR/drive_c/users/$SERVICE_NAME/AppData/Roaming/InterstellarRift" #Application data of the tmpfs
	SERVICE="$SERVICE_NAME-tmpfs" #TmpFs service file name
else
	BCKP_SRC_DIR="$SRV_DIR/drive_c/users/$SERVICE_NAME/AppData/Roaming/InterstellarRift" #Application data of the hdd/ssd
	SERVICE="$SERVICE_NAME" #Hdd/ssd service file name
fi

#Backup configuration
BCKP_SRC="*" #What files to backup, * for all
BCKP_DIR="/srv/$SERVICE_NAME/backups" #Location of stored backups
BCKP_DEST="$BCKP_DIR/$(date +"%Y")/$(date +"%m")/$(date +"%d")" #How backups are sorted, by default it's sorted in folders by month and day

#Log configuration
export LOG_DIR="/srv/$SERVICE_NAME/logs/$(date +"%Y")/$(date +"%m")/$(date +"%d")"
export LOG_DIR_ALL="/srv/$SERVICE_NAME/logs"
export LOG_SCRIPT="$LOG_DIR/$SERVICE_NAME-script.log" #Script log
export LOG_TMP="/tmp/$SERVICE_NAME-$SERVICE_NAME-tmux.log"
export CRASH_DIR="/srv/$SERVICE_NAME/logs/crashes/$(date +"%Y-%m-%d_%H-%M")"

#Console collors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHTRED='\033[1;31m'
NC='\033[0m'

#-------Do not edit anything beyond this line-------

#Generate log folder structure
script_logs() {
	#If there is not a folder for today, create one
	if [ ! -d "$LOG_DIR" ]; then
		mkdir -p $LOG_DIR
	fi
}

#---------------------------

#Deletes old files
script_remove_old_files() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove old files) Beginning removal of old files." | tee -a "$LOG_SCRIPT"
	#Delete old logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove old files) Removing old script logs: $LOG_DELOLD days old." | tee -a "$LOG_SCRIPT"
	find $LOG_DIR_ALL/* -mtime +$LOG_DELOLD -delete
	#Delete old game logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove old files) Removing old game logs: $LOG_GAME_DELOLD days old." | tee -a "$LOG_SCRIPT"
	find $BCKP_SRC_DIR/Logs/* -mtime +$LOG_GAME_DELOLD -delete
	#Delete old game dumps
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove old files) Removing old dump files: $DUMP_GAME_DELOLD days old." | tee -a "$LOG_SCRIPT"
	find $BCKP_SRC_DIR/Dumps/* -mtime +$DUMP_GAME_DELOLD -delete
	#Delete empty folders
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove old files) Removing empty script log folders." | tee -a "$LOG_SCRIPT"
	find $LOG_DIR_ALL/ -type d -empty -delete
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove old files) Removal of old files complete." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Prints out if the server is running
script_status() {
	script_logs
	IFS=","
	for SERVER_SERVICE in $(cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt | tr "\\n" "," | sed 's/,$//'); do
		SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is activating. Please wait." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is in deactivating. Please wait." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "disabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is disabled." | tee -a "$LOG_SCRIPT"
		fi
	done
	if pidof -x "$SCRIPT_PID_CHECK" -o $$ > /dev/null; then
		echo "Is another instance of the script running?: YES"
	else
		echo "Is another instance of the script running?: NO"
	fi
}

#---------------------------

#Adds a server instance to the server list file
script_add_server() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Add server instance) User adding new server instance." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to add a server instance? (y/n): " ADD_SERVER_INSTANCE
	if [[ "$ADD_SERVER_INSTANCE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo ""
		echo "List of current servers (your new server instance must NOT be identical to any of them!):"
		if [ ! -f $CONFIG_DIR/$SERVICE_NAME-server-list.txt ] ; then
			touch $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		fi
		cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		echo ""
		read -p "Specify your server instance (Single digit numbers must have a 0 before them. Example: 07): " SERVER_INSTANCE
		echo "$SERVICE@$SERVER_INSTANCE.service" >> $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		systemctl --user enable $SERVICE@$SERVER_INSTANCE.service
		echo ""
		read -p "Server instance $SERVER_INSTANCE added successfully. Do you want to start it? (y/n): " START_SERVER_INSTANCE
		if [[ "$START_SERVER_INSTANCE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			systemctl --user start $SERVICE@$SERVER_INSTANCE.service
		fi
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Add server instance) Server instance $SERVER_INSTANCE successfully added." | tee -a "$LOG_SCRIPT"
	else
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Add server instance) User canceled adding new server instance." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Removes a server instance from the server list file
script_remove_server() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove server instance) User started removal of server instance." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to remove a server instance? (y/n): " REMOVE_SERVER_INSTANCE
	if [[ "$REMOVE_SERVER_INSTANCE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo ""
		echo "List of current servers:"
		cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		echo ""
		read -p "Specify your server instance (Single digit numbers must have a 0 before them. Example: 07): " SERVER_INSTANCE
		sed -e "s/$SERVICE@$SERVER_INSTANCE.service//g" -i $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		sed '/^$/d' -i $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		systemctl --user disable $SERVICE@$SERVER_INSTANCE.service
		echo ""
		read -p "Server instance $SERVER_INSTANCE removed successfully. Do you want to stop it? (y/n): " STOP_SERVER_INSTANCE
		if [[ "$STOP_SERVER_INSTANCE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			systemctl --user stop $SERVICE@$SERVER_INSTANCE.service
		fi
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove server instance) Server instance $SERVER_INSTANCE successfully removed." | tee -a "$LOG_SCRIPT"
	else
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Remove server instance) User canceled removal of server instance." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Attaches to the server tmux session
script_attach() {
	if [ -z "$1" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach) Failed to attach. Specify server ID: $SCRIPT_NAME -attach ID" | tee -a "$LOG_SCRIPT"
	else
		tmux -L $SERVICE_NAME-$1-tmux.sock has-session -t $NAME 2>/dev/null
		if [ $? == 0 ]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach) User attached to server session with ID: $1" | tee -a "$LOG_SCRIPT"
			tmux -L $SERVICE_NAME-$1-tmux.sock attach -t $NAME
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach) User deattached from server session with ID: $1" | tee -a "$LOG_SCRIPT"
		else
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach) Failed to attach to server session with ID: $1" | tee -a "$LOG_SCRIPT"
		fi
	fi
}

#---------------------------

#Attaches to the server commands script tmux session
script_attach_commands() {
	if [ -z "$1" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach Commands) Failed to attach. Specify server ID: $SCRIPT_NAME -attach_commands ID" | tee -a "$LOG_SCRIPT"
	else
		tmux -L $SERVICE_NAME-commands-$1-tmux.sock has-session -t $NAME-Commands-$1 2>/dev/null
		if [ $? == 0 ]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach Commands) User attached to commands script session with ID: $1" | tee -a "$LOG_SCRIPT"
			tmux -L $SERVICE_NAME-commands-$1-tmux.sock attach -t $NAME-Commands-$1
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach Commands) User deattached from commands script session with ID: $1" | tee -a "$LOG_SCRIPT"
		else
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Attach Commands) Failed to attach to commands script session with ID: $1" | tee -a "$LOG_SCRIPT"
		fi
	fi
}

#---------------------------

#Disable all script services
script_disable_services() {
	script_logs
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		if [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			systemctl --user disable $SERVER_SERVICE
		fi
	done
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE_NAME@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		if [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			systemctl --user disable $SERVER_SERVICE
		fi
	done
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-sync-tmpfs.service)" == "enabled" ]]; then
		systemctl --user disable $SERVICE_NAME-sync-tmpfs.service
	fi
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-1.timer)" == "enabled" ]]; then
		systemctl --user disable $SERVICE_NAME-timer-1.timer
	fi
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-2.timer)" == "enabled" ]]; then
		systemctl --user disable $SERVICE_NAME-timer-2.timer
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Disable services) Services successfully disabled." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Disables all script services, available to the user
script_disable_services_manual() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Disable services) WARNING: This will disable all script services. The server will be disabled." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to disable all services? (y/n): " DISABLE_SCRIPT_SERVICES
	if [[ "$DISABLE_SCRIPT_SERVICES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		script_disable_services
	elif [[ "$DISABLE_SCRIPT_SERVICES" =~ ^([nN][oO]|[nN])$ ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Disable services) Disable services canceled." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

# Enable script services by reading the configuration file
script_enable_services() {
	script_logs
	if [[ "$TMPFS_ENABLE" == "1" ]]; then
		if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-sync-tmpfs.service)" == "disabled" ]]; then
			systemctl --user enable $SERVICE_NAME-sync-tmpfs.service
		fi
	fi
	IFS=","
	for SERVER_SERVICE in $(cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt | tr "\\n" "," | sed 's/,$//'); do
		if [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "disabled" ]]; then
			systemctl --user enable $SERVER_SERVICE
		fi
	done
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-1.timer)" == "disabled" ]]; then
		systemctl --user enable $SERVICE_NAME-timer-1.timer
	fi
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-2.timer)" == "disabled" ]]; then
		systemctl --user enable $SERVICE_NAME-timer-2.timer
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Enable services) Services successfully Enabled." | tee -a "$LOG_SCRIPT"
}

#---------------------------

# Enable script services by reading the configuration file, available to the user
script_enable_services_manual() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Enable services) This will enable all script services. All added servers will be enabled." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to enable all services? (y/n): " ENABLE_SCRIPT_SERVICES
	if [[ "$ENABLE_SCRIPT_SERVICES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		script_enable_services
	elif [[ "$ENABLE_SCRIPT_SERVICES" =~ ^([nN][oO]|[nN])$ ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Enable services) Enable services canceled." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Disables all script services an re-enables them by reading the configuration file
script_reload_services() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Reload services) This will reload all script services." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to reload all services? (y/n): " RELOAD_SCRIPT_SERVICES
	if [[ "$RELOAD_SCRIPT_SERVICES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		script_disable_services
		systemctl --user daemon-reload
		script_enable_services
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Reload services) Reload services complete." | tee -a "$LOG_SCRIPT"
	elif [[ "$RELOAD_SCRIPT_SERVICES" =~ ^([nN][oO]|[nN])$ ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Reload services) Reload services canceled." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#If the aluna crash handler is running, kill it due to it freezing
script_crash_kill() {
	script_logs
	if [[ "$(ps ux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}' | head -1)" -gt "0" ]]; then
		while [[ "$(ps ux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}' | head -1)" -gt "0" ]]; do
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Aluna Crash Handler) AlunaCrashHandler.exe detected. Killing the process." | tee -a "$LOG_SCRIPT"
			kill $(ps ux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}' | head -1)
		done
		if [[ "$(ps ux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}' | head -1)" -eq "" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Aluna Crash Handler) AlunaCrashHandler.exe process killed." | tee -a "$LOG_SCRIPT"
		elif [[ "$(ps ux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}' | head -1)" -gt "0" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Aluna Crash Handler) Failed to kill AlunaCrashHandler.exe process." | tee -a "$LOG_SCRIPT"
		fi
	elif [[ "$(ps ux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}' | head -1)" -eq "" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Aluna Crash Handler) AlunaCrashHandler.exe not detected. Server nominal." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Systemd service sends notification if notifications for start enabled
script_send_notification_start_initialized() {
	script_logs
	if [[ "$EMAIL_START" == "1" ]]; then
		mail -r "$EMAIL_SENDER ($NAME-$1)" -s "Notification: Server startup $1" $EMAIL_RECIPIENT <<- EOF
		Server startup for $1 was initialized at $(date +"%d.%m.%Y %H:%M:%S")
		EOF
	fi
	if [[ "$DISCORD_START" == "1" ]]; then
		while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
			curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server startup for $1 was initialized.\"}" "$DISCORD_WEBHOOK"
		done < $CONFIG_DIR/discord_webhooks.txt
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server startup for $1 was initialized." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Systemd service sends notification if notifications for start enabled
script_send_notification_start_complete() {
	script_logs
	if [[ "$EMAIL_START" == "1" ]]; then
		mail -r "$EMAIL_SENDER ($NAME-$1)" -s "Notification: Server startup $1" $EMAIL_RECIPIENT <<- EOF
		Server startup for $1 was completed at $(date +"%d.%m.%Y %H:%M:%S")
		EOF
	fi
	if [[ "$DISCORD_START" == "1" ]]; then
		while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
			curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server startup for $1 complete.\"}" "$DISCORD_WEBHOOK"
		done < $CONFIG_DIR/discord_webhooks.txt
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server startup for $1 complete." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Systemd service sends notification if notifications for stop enabled
script_send_notification_stop_initialized() {
	script_logs
	if [[ "$EMAIL_STOP" == "1" ]]; then
		mail -r "$EMAIL_SENDER ($NAME-$1)" -s "Notification: Server shutdown $1" $EMAIL_RECIPIENT <<- EOF
		Server shutdown was initiated at $(date +"%d.%m.%Y %H:%M:%S")
		EOF
	fi
	if [[ "$DISCORD_STOP" == "1" ]]; then
		while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
			curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server shutdown for $1 was initialized.\"}" "$DISCORD_WEBHOOK"
		done < $CONFIG_DIR/discord_webhooks.txt
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server shutdown for $1 was initialized." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Systemd service sends notification if notifications for stop enabled
script_send_notification_stop_complete() {
	script_logs
	if [[ "$EMAIL_STOP" == "1" ]]; then
		mail -r "$EMAIL_SENDER ($NAME-$1)" -s "Notification: Server shutdown $1" $EMAIL_RECIPIENT <<- EOF
		Server shutdown was complete at $(date +"%d.%m.%Y %H:%M:%S")
		EOF
	fi
	if [[ "$DISCORD_STOP" == "1" ]]; then
		while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
			curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server shutdown for $1 complete.\"}" "$DISCORD_WEBHOOK"
		done < $CONFIG_DIR/discord_webhooks.txt
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server shutdown for $1 complete." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Systemd service sends email if email notifications for crashes enabled
script_send_notification_crash() {
	script_logs
	if [ ! -d "$CRASH_DIR" ]; then
		mkdir -p "$CRASH_DIR"
	fi
	
	systemctl --user status $SERVICE@$1.service > $CRASH_DIR/service_log.txt
	zip -j $CRASH_DIR/service_logs.zip $CRASH_DIR/service_log.txt
	zip -j $CRASH_DIR/script_logs.zip $LOG_SCRIPT
	find "$BCKP_SRC_DIR"/Logs/ -iname *$1* -maxdepth 1 -type f \( ! -iname "chat.txt" \) -mmin -30 -exec zip $CRASH_DIR/game_logs.zip -j {} +
	zip -j $CRASH_DIR/wine_logs.zip "$(find $LOG_DIR/$SERVICE_NAME-wine-$1*.log -type f -printf '%T@\t%p\n' | sort -t $'\t' -g | tail -n -1 | cut -d $'\t' -f 2-)"
	rm $CRASH_DIR/service_log.txt
	
	if [[ "$EMAIL_CRASH" == "1" ]]; then
		mail -a $CRASH_DIR/service_logs.zip -a $CRASH_DIR/script_logs.zip -a $CRASH_DIR/game_logs.zip -a $CRASH_DIR/wine_logs.zip -r "$EMAIL_SENDER ($NAME $SERVICE_NAME)" -s "Notification: Crash" $EMAIL_RECIPIENT <<- EOF
		The $NAME server $1 crashed 3 times in the last 5 minutes. Automatic restart is disabled and the server is inactive. Please check the logs for more information.
		
		Attachment contents:
		service_logs.zip - Logs from the systemd service
		script_logs.zip - Logs from the script
		game_logs.zip - Logs from the game
		wine_logs.zip - Logs from the wine compatibility layer
		
		ONLY SEND game_logs.zip TO THE DEVS IF NEED BE! DON NOT SEND OTHER ARCHIVES!
		
		Contact the script developer 7thCore on discord for help regarding any problems the script may have caused.
		EOF
	fi
	
	if [[ "$DISCORD_CRASH" == "1" ]]; then
		while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
			curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Crash) The server crashed 3 times in the last 5 minutes. Automatic restart is disabled and the server is inactive. Please review your logs located in $CRASH_DIR.\"}" "$DISCORD_WEBHOOK"
		done < $CONFIG_DIR/discord_webhooks.txt
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Crash) Server crashed. Please review your logs located in $CRASH_DIR." | tee -a "$LOG_SCRIPT"
	
	touch /tmp/$(id -u $SERVICE_NAME).crash
}

#---------------------------

#Move the wine log and add date and time to it after service shutdown
script_move_wine_log() {
	script_logs
	if [ -f "$LOG_DIR_ALL/$SERVICE_NAME-wine-$1.log" ]; then
		mv $LOG_DIR_ALL/$SERVICE_NAME-wine-$1.log $LOG_DIR/$SERVICE_NAME-wine-$1-$(date +"%Y-%m-%d_%H-%M").log
	else
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Move wine log) Nothing to move." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Issue the save command to the server
script_save() {
	script_logs
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		export SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Save) Save game to disk for server $SERVER_NUMBER has been initiated." | tee -a "$LOG_SCRIPT"
			( sleep 5 && tmux -L $SERVICE_NAME-$SERVER_NUMBER-tmux.sock send-keys -t $NAME.0 'save' ENTER ) &
			timeout $TIMEOUT_SAVE /bin/bash -c '
			while read line; do
				if [[ "$line" == *"[Server]: Save completed."* ]] && [[ "$line" != *"[All]:"* ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Save) Save game to disk for server $SERVER_NUMBER has been completed." | tee -a "$LOG_SCRIPT"
					break
				elif [[ "$line" == *"INFO: Galaxy is already saving!"* ]] && [[ "$line" != *"[All]:"* ]]; then
					exit 7
					break
				else
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Save) Save game to disk for server $SERVER_NUMBER is in progress. Please wait..."
				fi
			done < <(tail -n1 -f /tmp/$SERVICE_NAME-$SERVICE_NAME-$SERVER_NUMBER-tmux.log)'
			EXIT_CODE="$?"
			if [[ "$EXIT_CODE" == "124" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Save) Save time limit for server $SERVER_NUMBER exceeded."
			elif [[ "$EXIT_CODE" == "7" ]]; then
                echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Save) Save loop on server $SERVER_NUMBER detected. Restarting..." | tee -a "$LOG_SCRIPT"
                while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
					curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Save loop on server $SERVER_NUMBER detected. Restarting...\"}" "$DISCORD_WEBHOOK"
				done < $CONFIG_DIR/discord_webhooks.txt
				script_restart $SERVER_NUMBER
			fi
		fi
	done
}

#---------------------------

#Sync server files from ramdisk to hdd/ssd
script_sync() {
	script_logs
	if [[ "$TMPFS_ENABLE" == "1" ]]; then
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Sync) Sync from tmpfs to disk has been initiated." | tee -a "$LOG_SCRIPT"
			rsync -aAXv --info=progress2 $TMPFS_DIR/ $SRV_DIR #| sed -e "s/^/$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Sync) Syncing: /" | tee -a "$LOG_SCRIPT"
			sleep 1
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Sync) Sync from tmpfs to disk has been completed." | tee -a "$LOG_SCRIPT"
		fi
	elif [[ "$TMPFS_ENABLE" == "0" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Sync) Server does not have tmpfs enabled." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Start the server
script_start() {
	script_logs
	if [ -z "$1" ]; then
		IFS=","
		for SERVER_SERVICE in $(cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt | tr "\\n" "," | sed 's/,$//'); do
			SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER start initialized." | tee -a "$LOG_SCRIPT"
				systemctl --user start $SERVER_SERVICE
				sleep 1
				while [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]]; do
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is activating. Please wait..." | tee -a "$LOG_SCRIPT"
					sleep 1
				done
				if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER has been successfully activated." | tee -a "$LOG_SCRIPT"
					sleep 1
				elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER failed to activate. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
					sleep 1
				fi
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is already running." | tee -a "$LOG_SCRIPT"
				sleep 1
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is in failed state. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
				read -p "Do you still want to start the server? (y/n): " FORCE_START
				if [[ "$FORCE_START" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					systemctl --user start $SERVER_SERVICE
					sleep 1
					while [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]]; do
						echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is activating. Please wait..." | tee -a "$LOG_SCRIPT"
						sleep 1
					done
					if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
						echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER has been successfully activated." | tee -a "$LOG_SCRIPT"
						sleep 1
					elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
						echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER failed to activate. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
						sleep 1
					fi
				fi
			fi
		done
	else
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "inactive" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 start initialized." | tee -a "$LOG_SCRIPT"
			systemctl --user start $SERVICE@$1.service
			sleep 1
			while [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "activating" ]]; do
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is activating. Please wait..." | tee -a "$LOG_SCRIPT"
				sleep 1
			done
			if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 has been successfully activated." | tee -a "$LOG_SCRIPT"
				sleep 1
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "failed" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 failed to activate. See systemctl --user status $SERVICE@$1.service for details." | tee -a "$LOG_SCRIPT"
				sleep 1
			fi
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is already running." | tee -a "$LOG_SCRIPT"
			sleep 1
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "failed" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is in failed state. See systemctl --user status $SERVICE@$1.service for details." | tee -a "$LOG_SCRIPT"
			read -p "Do you still want to start the server? (y/n): " FORCE_START
			if [[ "$FORCE_START" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				systemctl --user start $SERVICE@$1.service
				sleep 1
				while [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "activating" ]]; do
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is activating. Please wait..." | tee -a "$LOG_SCRIPT"
					sleep 1
				done
				if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 has been successfully activated." | tee -a "$LOG_SCRIPT"
					sleep 1
				elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "failed" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 failed to activate. See systemctl --user status $SERVICE@$1.service for details." | tee -a "$LOG_SCRIPT"
					sleep 1
				fi
			fi
		fi
	fi
}

#---------------------------

#Start the server ignorring failed states
script_start_ignore_errors() {
	script_logs
	if [ -z "$1" ]; then
		IFS=","
		for SERVER_SERVICE in $(cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt | tr "\\n" "," | sed 's/,$//'); do
			SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER start initialized." | tee -a "$LOG_SCRIPT"
				systemctl --user start $SERVER_SERVICE
				sleep 1
				while [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]]; do
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is activating. Please wait..." | tee -a "$LOG_SCRIPT"
					sleep 1
				done
				if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER has been successfully activated." | tee -a "$LOG_SCRIPT"
					sleep 1
				elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER failed to activate. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
					sleep 1
				fi
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is already running." | tee -a "$LOG_SCRIPT"
				sleep 1
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is in failed state. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
				systemctl --user start $SERVER_SERVICE
				sleep 1
				while [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]]; do
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER is activating. Please wait..." | tee -a "$LOG_SCRIPT"
					sleep 1
				done
				if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER has been successfully activated." | tee -a "$LOG_SCRIPT"
					sleep 1
				elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $SERVER_NUMBER failed to activate. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
					sleep 1
				fi
			fi
		done
	else
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "inactive" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 start initialized." | tee -a "$LOG_SCRIPT"
			systemctl --user start $SERVICE@$1.service
			sleep 1
			while [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "activating" ]]; do
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is activating. Please wait..." | tee -a "$LOG_SCRIPT"
				sleep 1
			done
			if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 has been successfully activated." | tee -a "$LOG_SCRIPT"
				sleep 1
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "failed" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 failed to activate. See systemctl --user status $SERVICE@$1.service for details." | tee -a "$LOG_SCRIPT"
				sleep 1
			fi
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is already running." | tee -a "$LOG_SCRIPT"
			sleep 1
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "failed" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is in failed state. See systemctl --user status $SERVICE@$1.service for details." | tee -a "$LOG_SCRIPT"
			systemctl --user start $SERVICE@$1.service
			sleep 1
			while [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "activating" ]]; do
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 is activating. Please wait..." | tee -a "$LOG_SCRIPT"
				sleep 1
			done
			if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 has been successfully activated." | tee -a "$LOG_SCRIPT"
				sleep 1
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "failed" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Start) Server $1 failed to activate. See systemctl --user status $SERVICE@$1.service for details." | tee -a "$LOG_SCRIPT"
				sleep 1
			fi
		fi
	fi
}

#---------------------------

#Stop the server
script_stop() {
	script_logs
	if [ -z "$1" ]; then
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $SERVER_NUMBER is not running." | tee -a "$LOG_SCRIPT"
				sleep 1
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $SERVER_NUMBER is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
				sleep 1
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $SERVER_NUMBER shutdown in progress." | tee -a "$LOG_SCRIPT"
				systemctl --user stop $SERVER_SERVICE
				sleep 1
				while [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]]; do
					echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $SERVER_NUMBER is deactivating. Please wait..." | tee -a "$LOG_SCRIPT"
					sleep 1
				done
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $SERVER_NUMBER is deactivated." | tee -a "$LOG_SCRIPT"
			fi
		done
	else
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "inactive" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $1 is not running." | tee -a "$LOG_SCRIPT"
			sleep 1
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "failed" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop)  Server $SERVER_NUMBER is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
			sleep 1
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $1 shutdown in progress." | tee -a "$LOG_SCRIPT"
			systemctl --user stop $SERVICE@$1.service
			sleep 1
			while [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "deactivating" ]]; do
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $1 is deactivating. Please wait..." | tee -a "$LOG_SCRIPT"
				sleep 1
			done
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Stop) Server $1 is deactivated." | tee -a "$LOG_SCRIPT"
		fi
	fi
}

#---------------------------

#Restart the server
script_restart() {
	script_logs
	if [ -z "$1" ]; then
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $SERVER_NUMBER is not running. Use -start to start the server." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $SERVER_NUMBER is activating. Aborting restart." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $SERVER_NUMBER is in deactivating. Aborting restart." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $SERVER_NUMBER is going to restart in 15-30 seconds, please wait..." | tee -a "$LOG_SCRIPT"
				sleep 1
				script_stop $SERVER_NUMBER
				sleep 1
				script_start $SERVER_NUMBER
				sleep 1
			fi
		done
	else
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "inactive" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $1 is not running. Use -start to start the server." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "activating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $1 is activating. Aborting restart." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "deactivating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $1 is in deactivating. Aborting restart." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE@$1.service)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Restart) Server $1 is going to restart in 15-30 seconds, please wait..." | tee -a "$LOG_SCRIPT"
			sleep 1
			script_stop $1
			sleep 1
			script_start $1
			sleep 1
		fi
	fi
}

#---------------------------

#Deletes old backups
script_deloldbackup() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Delete old backup) Deleting old backups: $BCKP_DELOLD days old." | tee -a "$LOG_SCRIPT"
	# Delete old backups
	find $BCKP_DIR/* -type f -mtime +$BCKP_DELOLD -delete
	# Delete empty folders
	find $BCKP_DIR/ -type d -empty -delete
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Delete old backup) Deleting old backups complete." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Creates a backup of the server
script_backup() {
	script_logs
	#If there is not a folder for today, create one
	if [ ! -d "$BCKP_DEST" ]; then
		mkdir -p $BCKP_DEST
	fi
	#Backup source to destination
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Backup) Backup has been initiated." | tee -a "$LOG_SCRIPT"
	cd "$BCKP_SRC_DIR"
	tar -cpvzf $BCKP_DEST/$(date +"%Y%m%d%H%M").tar.gz $BCKP_SRC #| sed -e "s/^/$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Backup) Compressing: /" | tee -a "$LOG_SCRIPT"
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Backup) Backup complete." | tee -a "$LOG_SCRIPT"
}

#---------------------------

#Automaticly backs up the server and deletes old backups
script_autobackup() {
	script_logs
	RUNNING_SERVERS="0"
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" != "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Autobackup) Server $SERVER_NUMBER is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
			RUNNING_SERVERS=$(($RUNNING_SERVERS + 1))
		fi
	done
	
	if [ $RUNNING_SERVERS -gt "0" ]; then
		sleep 1
		script_backup
		sleep 1
		script_deloldbackup
	fi
}

#---------------------------

#Delete the savegame from the server
script_delete_save() {
	script_logs
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]] && [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "activating" ]] && [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "deactivating" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Delete save) WARNING! This will delete the server's save game." | tee -a "$LOG_SCRIPT"
		read -p "Are you sure you want to delete the server's save game? (y/n): " DELETE_SERVER_SAVE
		if [[ "$DELETE_SERVER_SAVE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			read -p "Do you also want to delete the server.json? (y/n): " DELETE_SERVER_JSON
			if [[ "$DELETE_SERVER_JSON" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				if [[ "$TMPFS_ENABLE" == "1" ]]; then
					rm -rf $TMPFS_DIR
				fi
				rm -rf "$SRV_DIR/$WINE_PREFIX_GAME_CONFIG"/*
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Delete save) Deletion of save files and server.json complete." | tee -a "$LOG_SCRIPT"
			elif [[ "$DELETE_SERVER_JSON" =~ ^([nN][oO]|[nN])$ ]]; then
				if [[ "$TMPFS_ENABLE" == "1" ]]; then
					rm -rf $TMPFS_DIR
				fi
				cd "$SRV_DIR/$WINE_PREFIX_GAME_CONFIG"
				rm -rf $(ls | grep -v server.json)
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Delete save) Deletion of save files complete. Server.json is untouched." | tee -a "$LOG_SCRIPT"
			fi
		elif [[ "$DELETE_SERVER_SAVE" =~ ^([nN][oO]|[nN])$ ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Delete save) Save deletion canceled." | tee -a "$LOG_SCRIPT"
		fi
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Clear save) The server is running. Aborting..." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Change the steam branch of the app
script_change_branch() {
	script_logs
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]] && [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "activating" ]] && [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "deactivating" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Change branch) Server branch change initiated. Waiting on user configuration." | tee -a "$LOG_SCRIPT"
		read -p "Are you sure you want to change the server branch? (y/n): " CHANGE_SERVER_BRANCH
		if [[ "$CHANGE_SERVER_BRANCH" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			if [[ "$TMPFS_ENABLE" == "1" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Change branch) Clearing TmpFs directory and game installation." | tee -a "$LOG_SCRIPT"
				rm -rf $TMPFS_DIR
				rm -rf $SRV_DIR/$WINE_PREFIX_GAME_DIR/*
			elif [[ "$TMPFS_ENABLE" == "0" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Change branch) Clearing game installation." | tee -a "$LOG_SCRIPT"
				rm -rf $SRV_DIR/$WINE_PREFIX_GAME_DIR/*
			fi
			if [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
				PUBLIC_BRANCH="0"
			elif [[ "$STEAMCMD_BETA_BRANCH" == "0" ]]; then
				PUBLIC_BRANCH="1"
			fi
			echo "Current configuration:"
			echo 'Public branch: '"$PUBLIC_BRANCH"
			echo 'Beta branch enabled: '"$STEAMCMD_BETA_BRANCH"
			echo 'Beta branch name: '"$STEAMCMD_BETA_BRANCH_NAME"
			echo ""
			read -p "Public branch or beta branch? (public/beta): " SET_BRANCH_STATE
			echo ""
			if [[ "$SET_BRANCH_STATE" =~ ^([bB][eE][tT][aA]|[bB])$ ]]; then
				STEAMCMD_BETA_BRANCH="1"
				echo "Look up beta branch names at https://steamdb.info/app/363360/depots/"
				echo "Name example: ir_0.2.8"
				read -p "Enter beta branch name: " STEAMCMD_BETA_BRANCH_NAME
			elif [[ "$SET_BRANCH_STATE" =~ ^([pP][uU][bB][lL][iI][cC]|[pP])$ ]]; then
				STEAMCMD_BETA_BRANCH="0"
				STEAMCMD_BETA_BRANCH_NAME="none"
			fi
			sed -i '/steamcmd_beta_branch/d' $CONFIG_DIR/$SERVICE_NAME-steam.conf
			sed -i '/steamcmd_beta_branch_name/d' $CONFIG_DIR/$SERVICE_NAME-steam.conf
			echo 'steamcmd_beta_branch='"$STEAMCMD_BETA_BRANCH" >> $CONFIG_DIR/$SERVICE_NAME-steam.conf
			echo 'steamcmd_beta_branch_name='"$STEAMCMD_BETA_BRANCH_NAME" >> $CONFIG_DIR/$SERVICE_NAME-steam.conf
			if [[ "$STEAMCMD_BETA_BRANCH" == "0" ]]; then
				steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW +app_info_update 1 +app_info_print $APPID +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3 > $UPDATE_DIR/available.buildid
				steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW +app_info_update 1 +app_info_print $APPID +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3 > $UPDATE_DIR/available.timeupdated
				steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta validate +quit
			elif [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
				steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW +app_info_update 1 +app_info_print $APPID +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3 > $UPDATE_DIR/available.buildid
				steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW +app_info_update 1 +app_info_print $APPID +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3 > $UPDATE_DIR/available.timeupdated
				steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta $STEAMCMD_BETA_BRANCH_NAME validate +quit
			fi
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Change branch) Server branch change complete." | tee -a "$LOG_SCRIPT"
		elif [[ "$CHANGE_SERVER_BRANCH" =~ ^([nN][oO]|[nN])$ ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Change branch) Server branch change canceled." | tee -a "$LOG_SCRIPT"
		fi
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Change branch) The server is running. Aborting..." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Check for updates. If there are updates available, shut down the server, update it and restart it.
script_update() {
	script_logs
	if [[ "$STEAMCMD_UID" == "disabled" ]] && [[ "$STEAMCMD_PSW" == "disabled" ]]; then
		while [[ "$STEAMCMDSUCCESS" != "0" ]]; do
			read -p "Enter your Steam username: " STEAMCMD_UID
			echo ""
			read -p "Enter your Steam password: " STEAMCMD_PSW
			steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW +quit
			STEAMCMDSUCCESS=$?
			if [[ "$STEAMCMDSUCCESS" == "0" ]]; then
				echo "Steam login for $STEAMCMD_UID: SUCCEDED!"
			elif [[ "$STEAMCMDSUCCESS" != "0" ]]; then
				echo "Steam login for $STEAMCMD_UID: FAILED!"
				echo "Please try again."
			fi
		done
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Initializing update check." | tee -a "$LOG_SCRIPT"
	if [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Beta branch enabled. Branch name: $STEAMCMD_BETA_BRANCH_NAME" | tee -a "$LOG_SCRIPT"
	fi
	
	if [ ! -f $UPDATE_DIR/installed.buildid ] ; then
		touch $UPDATE_DIR/installed.buildid
		echo "0" > $UPDATE_DIR/installed.buildid
	fi
	
	if [ ! -f $UPDATE_DIR/installed.timeupdated ] ; then
		touch $UPDATE_DIR/installed.timeupdated
		echo "0" > $UPDATE_DIR/installed.timeupdated
	fi
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Removing Steam/appcache/appinfo.vdf" | tee -a "$LOG_SCRIPT"
	rm -rf "/srv/$SERVICE_NAME/.steam/appcache/appinfo.vdf"
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Connecting to steam servers." | tee -a "$LOG_SCRIPT"
	
	
	if [[ "$STEAMGUARD_CLI" == "1" ]]; then
		steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +app_info_update 1 +app_info_print $APPID +quit > /srv/$SERVICE_NAME/updates/steam_app_data.txt
	else
		steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW +app_info_update 1 +app_info_print $APPID +quit > /srv/$SERVICE_NAME/updates/steam_app_data.txt
	fi
	
	if [[ "$STEAMCMD_BETA_BRANCH" == "0" ]]; then
		AVAILABLE_BUILDID=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
		AVAILABLE_TIME=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
	elif [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
		AVAILABLE_BUILDID=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
		AVAILABLE_TIME=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
	fi
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Received application info data." | tee -a "$LOG_SCRIPT"
	
	INSTALLED_BUILDID=$(cat $UPDATE_DIR/installed.buildid)
	INSTALLED_TIME=$(cat $UPDATE_DIR/installed.timeupdated)
	
	if [ "$AVAILABLE_TIME" -gt "$INSTALLED_TIME" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) New update detected." | tee -a "$LOG_SCRIPT"
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Installed: BuildID: $INSTALLED_BUILDID, TimeUpdated: $INSTALLED_TIME" | tee -a "$LOG_SCRIPT"
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Available: BuildID: $AVAILABLE_BUILDID, TimeUpdated: $AVAILABLE_TIME" | tee -a "$LOG_SCRIPT"
		
		if [[ "$DISCORD_UPDATE" == "1" ]]; then
			while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
				curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) New update detected. Installing update.\"}" "$DISCORD_WEBHOOK"
			done < $CONFIG_DIR/discord_webhooks.txt
		fi
		
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
				WAS_ACTIVE=("$SERVER_SERVICE" "${WAS_ACTIVE[@]}")
			fi
		done
		sleep 1
		script_stop
		sleep 1
		
		if [[ "$TMPFS_ENABLE" == "1" ]]; then
			rsync -aAXv --info=progress2 $TMPFS_DIR/ $SRV_DIR
			rm -rf $TMPFS_DIR/$WINE_PREFIX_GAME_DIR
		fi
		
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Updating..." | tee -a "$LOG_SCRIPT"
		
		if [[ "$STEAMGUARD_CLI" == "1" ]]; then
			if [[ "$STEAMCMD_BETA_BRANCH" == "0" ]]; then
				steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID validate +quit
			elif [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
				steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta $STEAMCMD_BETA_BRANCH_NAME validate +quit
			fi
		else
			if [[ "$STEAMCMD_BETA_BRANCH" == "0" ]]; then
				steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID validate +quit
			elif [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
				steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta $STEAMCMD_BETA_BRANCH_NAME validate +quit
			fi
		fi
		
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Update completed." | tee -a "$LOG_SCRIPT"
		echo "$AVAILABLE_BUILDID" > $UPDATE_DIR/installed.buildid
		echo "$AVAILABLE_TIME" > $UPDATE_DIR/installed.timeupdated
		
		if [[ "$TMPFS_ENABLE" == "1" ]]; then
			mkdir -p $TMPFS_DIR/$WINE_PREFIX_GAME_DIR/Build
			rsync -aAXv --info=progress2 $SRV_DIR/ $TMPFS_DIR
		fi
		
		for SERVER_SERVICE in "${WAS_ACTIVE[@]}"; do
			SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$UPDATE_IGNORE_FAILED_ACTIVATIONS" == "1" ]]; then
				script_start_ignore_errors $SERVER_NUMBER
			else
				script_start $SERVER_NUMBER
			fi
		done
		
		if [[ "$EMAIL_UPDATE" == "1" ]]; then
			mail -r "$EMAIL_SENDER ($NAME-$SERVICE_NAME)" -s "Notification: Update" $EMAIL_RECIPIENT <<- EOF
			Server was updated. Please check the update notes if there are any additional steps to take.
			EOF
		fi
		
		if [[ "$DISCORD_UPDATE" == "1" ]]; then
			while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
				curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Server update complete.\"}" "$DISCORD_WEBHOOK"
			done < $CONFIG_DIR/discord_webhooks.txt
		fi
	elif [ "$AVAILABLE_TIME" -eq "$INSTALLED_TIME" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) No new updates detected." | tee -a "$LOG_SCRIPT"
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Update) Installed: BuildID: $INSTALLED_BUILDID, TimeUpdated: $INSTALLED_TIME" | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Uses steam to verfy the integrity of the game server files
script_verify_game_integrity() {
	script_logs
	if [[ "$STEAMCMD_UID" == "disabled" ]] && [[ "$STEAMCMD_PSW" == "disabled" ]]; then
		while [[ "$STEAMCMDSUCCESS" != "0" ]]; do
			read -p "Enter your Steam username: " STEAMCMD_UID
			echo ""
			read -p "Enter your Steam password: " STEAMCMD_PSW
			steamcmd +login $STEAMCMD_UID $STEAMCMD_PSW +quit
			STEAMCMDSUCCESS=$?
			if [[ "$STEAMCMDSUCCESS" == "0" ]]; then
				echo "Steam login for $STEAMCMD_UID: SUCCEDED!"
			elif [[ "$STEAMCMDSUCCESS" != "0" ]]; then
				echo "Steam login for $STEAMCMD_UID: FAILED!"
				echo "Please try again."
			fi
		done
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Integrity check) Initializing integrity check." | tee -a "$LOG_SCRIPT"
	if [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Integrity check) Beta branch enabled. Branch name: $STEAMCMD_BETA_BRANCH_NAME" | tee -a "$LOG_SCRIPT"
	fi
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Integrity check) Removing Steam/appcache/appinfo.vdf" | tee -a "$LOG_SCRIPT"
	rm -rf "/srv/$SERVICE_NAME/.steam/appcache/appinfo.vdf"
	
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
			WAS_ACTIVE=("$SERVER_SERVICE" "${WAS_ACTIVE[@]}")
		fi
	done
	sleep 1
	script_stop
	sleep 1
	
	if [[ "$TMPFS_ENABLE" == "1" ]]; then
		rsync -aAXv --info=progress2 $TMPFS_DIR/ $SRV_DIR
		rm -rf $TMPFS_DIR/$WINE_PREFIX_GAME_DIR
	fi
	
	if [[ "$STEAMGUARD_CLI" == "1" ]]; then
		if [[ "$STEAMCMD_BETA_BRANCH" == "0" ]]; then
			steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID validate +quit
		elif [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
			steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta $STEAMCMD_BETA_BRANCH_NAME validate +quit
		fi
	else
		if [[ "$STEAMCMD_BETA_BRANCH" == "0" ]]; then
			steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID validate +quit
		elif [[ "$STEAMCMD_BETA_BRANCH" == "1" ]]; then
			steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMD_UID $STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta $STEAMCMD_BETA_BRANCH_NAME validate +quit
		fi
	fi
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Integrity check) Integrity check completed." | tee -a "$LOG_SCRIPT"
	
	if [[ "$TMPFS_ENABLE" == "1" ]]; then
		mkdir -p $TMPFS_DIR/$WINE_PREFIX_GAME_DIR/Build
		rsync -aAXv --info=progress2 $SRV_DIR/ $TMPFS_DIR
	fi
	
	for SERVER_SERVICE in "${WAS_ACTIVE[@]}"; do
		SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$UPDATE_IGNORE_FAILED_ACTIVATIONS" == "1" ]]; then
			script_start_ignore_errors $SERVER_NUMBER
		else
			script_start $SERVER_NUMBER
		fi
	done
}

#---------------------------

#Install tmux configuration for specific server when first ran
script_server_tmux_install() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Server tmux configuration) Installing tmux configuration for server $1." | tee -a "$LOG_SCRIPT"
	if [ ! -f /tmp/$SERVICE_NAME-$1-tmux.conf ]; then
		touch /tmp/$SERVICE_NAME-$1-tmux.conf
		cat > /tmp/$SERVICE_NAME-$1-tmux.conf <<- EOF
		#Tmux configuration
		set -g activity-action other
		set -g allow-rename off
		set -g assume-paste-time 1
		set -g base-index 0
		set -g bell-action any
		set -g default-command "${SHELL}"
		#set -g default-terminal "tmux-256color"
		set -g default-terminal "screen-hack_color"
		set -g default-shell "/bin/bash"
		set -g default-size "132x42"
		set -g destroy-unattached off
		set -g detach-on-destroy on
		set -g display-panes-active-colour red
		set -g display-panes-colour blue
		set -g display-panes-time 1000
		set -g display-time 3000
		set -g history-limit 10000
		set -g key-table "root"
		set -g lock-after-time 0
		set -g lock-command "lock -np"
		set -g message-command-style fg=yellow,bg=black
		set -g message-style fg=black,bg=yellow
		set -g mouse on
		#set -g prefix C-b
		set -g prefix2 None
		set -g renumber-windows off
		set -g repeat-time 500
		set -g set-titles off
		set -g set-titles-string "#S:#I:#W - \"#T\" #{session_alerts}"
		set -g silence-action other
		set -g status on
		set -g status-bg green
		set -g status-fg black
		set -g status-format[0] "#[align=left range=left #{status-left-style}]#{T;=/#{status-left-length}:status-left}#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#{T:window-status-format}#[norange default]#{?window_end_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{window-status-current-style},default},#{window-status-current-style},#{window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#{T:window-status-current-format}#[norange list=on default]#{?window_end_flag,,#{window-status-separator}}}#[nolist align=right range=right #{status-right-style}]#{T;=/#{status-right-length}:status-right}#[norange default]"
		set -g status-format[1] "#[align=centre]#{P:#{?pane_active,#[reverse],}#{pane_index}[#{pane_width}x#{pane_height}]#[default] }"
		set -g status-interval 15
		set -g status-justify left
		set -g status-keys emacs
		set -g status-left "[#S] "
		set -g status-left-length 10
		set -g status-left-style default
		set -g status-position bottom
		set -g status-right "#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}\"#{=21:pane_title}\" %H:%M %d-%b-%y"
		set -g status-right-length 40
		set -g status-right-style default
		set -g status-style fg=black,bg=green
		set -g update-environment[0] "DISPLAY"
		set -g update-environment[1] "KRB5CCNAME"
		set -g update-environment[2] "SSH_ASKPASS"
		set -g update-environment[3] "SSH_AUTH_SOCK"
		set -g update-environment[4] "SSH_AGENT_PID"
		set -g update-environment[5] "SSH_CONNECTION"
		set -g update-environment[6] "WINDOWID"
		set -g update-environment[7] "XAUTHORITY"
		set -g visual-activity off
		set -g visual-bell off
		set -g visual-silence off
		set -g word-separators " -_@"

		#Change prefix key from ctrl+b to ctrl+a
		unbind C-b
		set -g prefix C-a
		bind C-a send-prefix

		#Bind C-a r to reload the config file
		bind-key r source-file /tmp/$SERVICE_NAME-$1-tmux.conf \; display-message "Config reloaded!"

		set-hook -g session-created 'resize-window -y 24 -x 10000'
		set-hook -g session-created "pipe-pane -o 'tee >> /tmp/$SERVICE_NAME-$1-tmux.log'"
		set-hook -g client-attached 'resize-window -y 24 -x 10000'
		set-hook -g client-detached 'resize-window -y 24 -x 10000'
		set-hook -g client-resized 'resize-window -y 24 -x 10000'

		#Default key bindings (only here for info)
		#Ctrl-b l (Move to the previously selected window)
		#Ctrl-b w (List all windows / window numbers)
		#Ctrl-b <window number> (Move to the specified window number, the default bindings are from 0 – 9)
		#Ctrl-b q  (Show pane numbers, when the numbers show up type the key to goto that pane)

		#Ctrl-b f <window name> (Search for window name)
		#Ctrl-b w (Select from interactive list of windows)

		#Copy/ scroll mode
		#Ctrl-b [ (in copy mode you can navigate the buffer including scrolling the history. Use vi or emacs-style key bindings in copy mode. The default is emacs. To exit copy mode use one of the following keybindings: vi q emacs Esc)
		EOF
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Server tmux configuration) Tmux configuration for server $1 installed successfully." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Install tmux configuration for specific server when first ran
script_commands_tmux_install() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Commands script tmux configuration) Installing tmux configuration for server $1." | tee -a "$LOG_SCRIPT"
	if [ ! -f /tmp/$SERVICE_NAME-commands-$1-tmux.conf ]; then
		touch /tmp/$SERVICE_NAME-commands-$1-tmux.conf
		cat > /tmp/$SERVICE_NAME-commands-$1-tmux.conf <<- EOF
		#Tmux configuration
		set -g activity-action other
		set -g allow-rename off
		set -g assume-paste-time 1
		set -g base-index 0
		set -g bell-action any
		set -g default-command "${SHELL}"
		#set -g default-terminal "tmux-256color"
		set -g default-terminal "screen-hack_color"
		set -g default-shell "/bin/bash"
		set -g default-size "132x42"
		set -g destroy-unattached off
		set -g detach-on-destroy on
		set -g display-panes-active-colour red
		set -g display-panes-colour blue
		set -g display-panes-time 1000
		set -g display-time 3000
		set -g history-limit 10000
		set -g key-table "root"
		set -g lock-after-time 0
		set -g lock-command "lock -np"
		set -g message-command-style fg=yellow,bg=black
		set -g message-style fg=black,bg=yellow
		set -g mouse on
		#set -g prefix C-b
		set -g prefix2 None
		set -g renumber-windows off
		set -g repeat-time 500
		set -g set-titles off
		set -g set-titles-string "#S:#I:#W - \"#T\" #{session_alerts}"
		set -g silence-action other
		set -g status on
		set -g status-bg green
		set -g status-fg black
		set -g status-format[0] "#[align=left range=left #{status-left-style}]#{T;=/#{status-left-length}:status-left}#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#{T:window-status-format}#[norange default]#{?window_end_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{window-status-current-style},default},#{window-status-current-style},#{window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#{T:window-status-current-format}#[norange list=on default]#{?window_end_flag,,#{window-status-separator}}}#[nolist align=right range=right #{status-right-style}]#{T;=/#{status-right-length}:status-right}#[norange default]"
		set -g status-format[1] "#[align=centre]#{P:#{?pane_active,#[reverse],}#{pane_index}[#{pane_width}x#{pane_height}]#[default] }"
		set -g status-interval 15
		set -g status-justify left
		set -g status-keys emacs
		set -g status-left "[#S] "
		set -g status-left-length 10
		set -g status-left-style default
		set -g status-position bottom
		set -g status-right "#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}\"#{=21:pane_title}\" %H:%M %d-%b-%y"
		set -g status-right-length 40
		set -g status-right-style default
		set -g status-style fg=black,bg=green
		set -g update-environment[0] "DISPLAY"
		set -g update-environment[1] "KRB5CCNAME"
		set -g update-environment[2] "SSH_ASKPASS"
		set -g update-environment[3] "SSH_AUTH_SOCK"
		set -g update-environment[4] "SSH_AGENT_PID"
		set -g update-environment[5] "SSH_CONNECTION"
		set -g update-environment[6] "WINDOWID"
		set -g update-environment[7] "XAUTHORITY"
		set -g visual-activity off
		set -g visual-bell off
		set -g visual-silence off
		set -g word-separators " -_@"

		#Change prefix key from ctrl+b to ctrl+a
		unbind C-b
		set -g prefix C-a
		bind C-a send-prefix

		#Bind C-a r to reload the config file
		bind-key r source-file /tmp/$SERVICE_NAME-commands-$1-tmux.conf \; display-message "Config reloaded!"

		set-hook -g session-created 'resize-window -y 24 -x 10000'
		set-hook -g session-created "pipe-pane -o 'tee >> /tmp/$SERVICE_NAME-commands-$1-tmux.log'"
		set-hook -g client-attached 'resize-window -y 24 -x 10000'
		set-hook -g client-detached 'resize-window -y 24 -x 10000'
		set-hook -g client-resized 'resize-window -y 24 -x 10000'

		#Default key bindings (only here for info)
		#Ctrl-b l (Move to the previously selected window)
		#Ctrl-b w (List all windows / window numbers)
		#Ctrl-b <window number> (Move to the specified window number, the default bindings are from 0 – 9)
		#Ctrl-b q  (Show pane numbers, when the numbers show up type the key to goto that pane)

		#Ctrl-b f <window name> (Search for window name)
		#Ctrl-b w (Select from interactive list of windows)

		#Copy/ scroll mode
		#Ctrl-b [ (in copy mode you can navigate the buffer including scrolling the history. Use vi or emacs-style key bindings in copy mode. The default is emacs. To exit copy mode use one of the following keybindings: vi q emacs Esc)
		EOF
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Commands script tmux configuration) Tmux configuration for server $1 installed successfully." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#Generates the wine prefix
script_generate_wine_prefix() {
	Xvfb :5 -screen 0 1024x768x16 &
	env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEDLLOVERRIDES="mscoree=d" WINEPREFIX=$SRV_DIR wineboot --init /nogui
	env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR winetricks corefonts
	env DISPLAY=:5.0 WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR winetricks -q vcrun2012
	env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR winetricks -q --force dotnet48
	env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR winetricks sound=disabled
	pkill -f Xvfb
}

#---------------------------

#Reinstalls the wine prefix
script_install_prefix() {
	script_logs
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]] && [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "activating" ]] && [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "deactivating" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Reinstall Wine prefix) Wine prefix reinstallation commencing. Waiting on user configuration." | tee -a "$LOG_SCRIPT"
		read -p "Are you sure you want to reinstall the wine prefix? (y/n): " REINSTALL_PREFIX
		if [[ "$REINSTALL_PREFIX" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			#If there is not a backup folder for today, create one
			if [ ! -d "$BCKP_DEST" ]; then
				mkdir -p $BCKP_DEST
			fi
			read -p "Do you want to keep the game installation and server data (saves,configs,etc.)? (y/n): " REINSTALL_PREFIX_KEEP_DATA
			if [[ "$REINSTALL_PREFIX_KEEP_DATA" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				mkdir -p $BCKP_DIR/prefix_backup/{game,appdata}
				mv "$SRV_DIR/$WINE_PREFIX_GAME_DIR"/* $BCKP_DIR/prefix_backup/game
				mv "$SRV_DIR/$WINE_PREFIX_GAME_CONFIG"/* $BCKP_DIR/prefix_backup/appdata
			fi
			rm -rf $SRV_DIR
			script_generate_wine_prefix
			if [[ "$REINSTALL_PREFIX_KEEP_DATA" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				mkdir -p "$SRV_DIR/$WINE_PREFIX_GAME_DIR"
				mkdir -p "$SRV_DIR/$WINE_PREFIX_GAME_CONFIG"
				mv $BCKP_DIR/prefix_backup/game/* "$SRV_DIR/$WINE_PREFIX_GAME_DIR"
				mv $BCKP_DIR/prefix_backup/appdata/* "$SRV_DIR/$WINE_PREFIX_GAME_CONFIG"
				rm -rf $BCKP_DIR/prefix_backup
			fi
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Reinstall Wine prefix) Wine prefix reinstallation complete." | tee -a "$LOG_SCRIPT"
		elif [[ "$REINSTALL_PREFIX" =~ ^([nN][oO]|[nN])$ ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Reinstall Wine prefix) Wine prefix reinstallation aborted." | tee -a "$LOG_SCRIPT"
		fi
	else
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Reinstall Wine prefix) Cannot reinstall wine prefix while server is running. Aborting..." | tee -a "$LOG_SCRIPT"
	fi
}

#---------------------------

#First timer function for systemd timers to execute parts of the script in order without interfering with each other
script_timer_one() {
	script_logs
	RUNNING_SERVERS="0"
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "activating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is activating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "deactivating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is in deactivating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is running." | tee -a "$LOG_SCRIPT"
			RUNNING_SERVERS=$(($RUNNING_SERVERS + 1))
		fi
	done
	
	if [ $RUNNING_SERVERS -gt "0" ]; then
		script_remove_old_files
		script_crash_kill
		script_save
		script_sync
		script_autobackup
		if [[ "$STEAMCMD_UID" != "disabled" ]] && [[ "$STEAMCMD_PSW" != "disabled" ]]; then
			script_update
		fi
	fi
}

#---------------------------

#Second timer function for systemd timers to execute parts of the script in order without interfering with each other
script_timer_two() {
	script_logs
	RUNNING_SERVERS="0"
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager $SERVICE@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_NUMBER=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "activating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is activating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "deactivating" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is in deactivating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] (Status) Server $SERVER_NUMBER is running." | tee -a "$LOG_SCRIPT"
			RUNNING_SERVERS=$(($RUNNING_SERVERS + 1))
		fi
	done
	
	if [ $RUNNING_SERVERS -gt "0" ]; then
		script_remove_old_files
		script_crash_kill
		script_save
		script_sync
		if [[ "$STEAMCMD_UID" != "disabled" ]] && [[ "$STEAMCMD_PSW" != "disabled" ]]; then
			script_update
		fi
	fi
}

#---------------------------

#Runs the diagnostics
script_diagnostics() {
	echo "Initializing diagnostics. Please wait..."
	sleep 3
	
	#Check package versions
	echo "wine version: $(wine --version)"
	echo "winetricks version: $(winetricks --version)"
	echo "tmux version: $(tmux -V)"
	echo "rsync version: $(rsync --version | head -n 1)"
	echo "curl version: $(curl --version | head -n 1)"
	echo "wget version: $(wget --version | head -n 1)"
	echo "cabextract version: $(cabextract --version)"
	echo "postfix version: $(postconf mail_version)"
	
	#Get distro name
	DISTRO=$(cat /etc/os-release | grep "^ID=" | cut -d = -f2)
	
	#Check package versions
	if [[ "$DISTRO" == "arch" ]]; then
		echo "xvfb version:$(pacman -Qi xorg-server-xvfb | grep "^Version" | cut -d : -f2)"
		echo "postfix version:$(pacman -Qi postfix | grep "^Version" | cut -d : -f2)"
		echo "zip version:$(pacman -Qi zip | grep "^Version" | cut -d : -f2)"
	elif [[ "$DISTRO" == "ubuntu" ]]; then
		echo "xvfb version:$(dpkg -s xvfb | grep "^Version" | cut -d : -f2)"
		echo "postfix version:$(dpkg -s postfix | grep "^Version" | cut -d : -f2)"
		echo "zip version:$(dpkg -s zip | grep "^Version" | cut -d : -f2)"
	fi
	
	if [ -d "/srv/$SERVICE_NAME/config" ]; then
		echo "Configuration folder present: Yes"
	else
		echo "Configuration folder present: No"
	fi

	if [ -d "/srv/$SERVICE_NAME/backups" ]; then
		echo "Backups folder present: Yes"
	else
		echo "Backups folder present: No"
	fi
	
	if [ -d "/srv/$SERVICE_NAME/logs" ]; then
		echo "Logs folder present: Yes"
	else
		echo "Logs folder present: No"
	fi
	
	if [ -d "/srv/$SERVICE_NAME/server" ]; then
		echo "Server folder present: Yes"
		echo ""
		echo "List of installed applications in the prefix:"
		env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR wine uninstaller --list
		echo ""
	else
		echo "Server folder present: No"
	fi
	
	if [ -d "/srv/$SERVICE_NAME/updates" ]; then
		echo "Updates folder present: Yes"
	else
		echo "Updates folder present: No"
	fi

	if [ -f "$CONFIG_DIR/$SERVICE_NAME-script.conf" ] ; then
		echo "Configuration file present: Yes"
	else
		echo "Configuration file present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-sync-tmpfs.service" ]; then
		echo "Tmpfs Sync service present: Yes"
	else
		echo "Tmpfs Sync service present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-tmpfs@.service" ]; then
		echo "Tmpfs service present: Yes"
	else
		echo "Tmpfs service present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE@.service" ]; then
		echo "Basic service present: Yes"
	else
		echo "Basic service present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-1.timer" ]; then
		echo "Timer 1 timer present: Yes"
	else
		echo "Timer 1 timer present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-1.service" ]; then
		echo "Timer 1 service present: Yes"
	else
		echo "Timer 1 service present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-2.timer" ]; then
		echo "Timer 2 timer present: Yes"
	else
		echo "Timer 2 timer present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-2.service" ]; then
		echo "Timer 2 service present: Yes"
	else
		echo "Timer 2 service present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-send-notification@.service" ]; then
		echo "Notification sending service present: Yes"
	else
		echo "Notification sending service present: No"
	fi
	
	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-commands@.service" ]; then
		echo "Commands script service present: Yes"
	else
		echo "Commands script service present: No"
	fi
	
	if [ -f "$SRV_DIR/$WINE_PREFIX_GAME_DIR/Build/IR.exe" ]; then
		echo "Game executable present: Yes"
	else
		echo "Game executable present: No"
	fi
	
	echo "Diagnostics complete."
}

#---------------------------

#Installs the steam configuration files and the game if the user so chooses
script_install_steam() {
	echo ""
	read -p "Do you want to use steam to download the game files and be resposible for maintaining them? (y/n): " INSTALL_STEAMCMD
	if [[ "$INSTALL_STEAMCMD" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		while [[ "$INSTALL_STEAMCMD_SUCCESS" != "0" ]]; do
			read -p "Enter your Steam username: " INSTALL_STEAMCMD_UID
			echo ""
			read -p "Enter your Steam password: " INSTALL_STEAMCMD_PSW
			steamcmd +login $INSTALL_STEAMCMD_UID $INSTALL_STEAMCMD_PSW +quit
			INSTALL_STEAMCMD_SUCCESS=$?
			if [[ "$INSTALL_STEAMCMD_SUCCESS" == "0" ]]; then
				echo "Steam login for $INSTALL_STEAMCMD_UID: SUCCEDED!"
			elif [[ "$INSTALL_STEAMCMD_SUCCESS" != "0" ]]; then
				echo "Steam login for $INSTALL_STEAMCMD_UID: FAILED!"
				echo "Please try again."
			fi
		done

		echo ""
		read -p "Do you have a Steam Guard Authentication app installed and configured? (y/n): " INSTALL_STEAMGUARD_CLI_STATE
		if [[ "$INSTALL_STEAMGUARD_CLI_STATE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			INSTALL_STEAMGUARD_CLI="1"
		else
			INSTALL_STEAMGUARD_CLI="0"
		fi

		echo ""
		read -p "Do you want the script to store your Steam credentials in the script's config file for automatic updates? (y/n): " INSTALL_STEAMCMD_STORE_CREDENTIALS_SETUP
		INSTALL_STEAMCMD_STORE_CREDENTIALS_SETUP=${INSTALL_STEAMCMD_STORE_CREDENTIALS_SETUP:=n}
		if [[ "$INSTALL_STEAMCMD_STORE_CREDENTIALS_SETUP" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			echo "Your Steam credentials WILL be stored on this system. Updates will be installed automaticly when an update is released."
			INSTALL_STEAMCMD_STORE_CREDENTIALS="1"
		else
			echo "Your Steam credentials WILL NOT be stored on this system. You will have to update your game manually when an update is released."
			INSTALL_STEAMCMD_STORE_CREDENTIALS="0"
		fi

		echo ""
		read -p "Enable beta branch? Used for experimental and legacy versions. (y/n): " INSTALL_STEAMCMD_BETA_BRANCH_STATE
		if [[ "$INSTALL_STEAMCMD_BETA_BRANCH_STATE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			INSTALL_STEAMCMD_BETA_BRANCH="1"
			echo "Look up beta branch names at https://steamdb.info/app/$APPID/depots/"
			echo "Name example: ir_0.2.8"
			read -p "Enter beta branch name: " INSTALL_STEAMCMD_BETA_BRANCH_NAME
		elif [[ "$SET_BETA_BRANCH_STATE" =~ ^([nN][oO]|[nN])$ ]]; then
			INSTALL_STEAMCMD_BETA_BRANCH="0"
			INSTALL_STEAMCMD_BETA_BRANCH_NAME="none"
		fi

		read -p "Do you want to install the server files with steam now? (y/n): " INSTALL_STEAMCMD_GAME_FILES
		if [[ "$INSTALL_STEAMCMD_GAME_FILES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			echo "Installing game..."
			if [[ "$INSTALL_STEAMGUARD_CLI" == "1" ]]; then
				steamcmd +login $INSTALL_STEAMCMD_UID $INSTALL_STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +app_info_update 1 +app_info_print $APPID +quit > /srv/$SERVICE_NAME/updates/steam_app_data.txt
			else
				steamcmd +login $INSTALL_STEAMCMD_UID $INSTALL_STEAMCMD_PSW +app_info_update 1 +app_info_print $APPID +quit > /srv/$SERVICE_NAME/updates/steam_app_data.txt
			fi

			if [[ "$INSTALL_STEAMCMD_BETA_BRANCH" == "0" ]]; then
				INSTALLED_BUILDID=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
				INSTALLED_TIME=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
				echo "$INSTALLED_BUILDID" > $UPDATE_DIR/installed.buildid
				echo "$INSTALLED_TIME" > $UPDATE_DIR/installed.timeupdated
				if [[ "$INSTALL_STEAMGUARD_CLI" == "1" ]]; then
					steamcmd +login $INSTALL_STEAMCMD_UID $INSTALL_STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID validate +quit"
				else
					steamcmd +login $INSTALL_STEAMCMD_UID $INSTALL_STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID validate +quit"
				fi
			elif [[ "$INSTALL_STEAMCMD_BETA_BRANCH" == "1" ]]; then
				INSTALLED_BUILDID=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$INSTALL_STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
				INSTALLED_TIME=$(cat /srv/$SERVICE_NAME/updates/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$INSTALL_STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
				echo "$INSTALLED_BUILDID" > $UPDATE_DIR/installed.buildid
				echo "$INSTALLED_TIME" > $UPDATE_DIR/installed.timeupdated
				if [[ "$INSTALL_STEAMGUARD_CLI" == "1" ]]; then
					steamcmd +login $INSTALL_STEAMCMD_UID $INSTALL_STEAMCMD_PSW $(steamguard -m /srv/$SERVICE_NAME/.steamguard/ code) +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta $INSTALL_STEAMCMD_BETA_BRANCH_NAME validate +quit"
				else
					steamcmd +login $INSTALL_STEAMCMD_UID $INSTALL_STEAMCMD_PSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID -beta $INSTALL_STEAMCMD_BETA_BRANCH_NAME validate +quit"
				fi
			fi
		else
			echo "Game files installation skipped"
		fi
	else
		echo ""
		echo "Manual game installation selected. Copy your game files to $SRV_DIR/$WINE_PREFIX_GAME_DIR after installation."
		INSTALL_STEAMCMD_UID="disabled"
		INSTALL_STEAMCMD_PSW="disabled"
		INSTALL_STEAMGUARD_CLI="0"
		INSTALL_STEAMCMD_STORE_CREDENTIALS="0"
		INSTALL_STEAMCMD_BETA_BRANCH="0"
		INSTALL_STEAMCMD_BETA_BRANCH_NAME="none"
	fi

	echo "Writing configuration file..."
	touch $CONFIG_DIR/$SERVICE_NAME-steam.conf
	if [[ "$STEAM_STORE_CREDENTIALS" == "1" ]]; then
		echo 'steamcmd_username='"$INSTALL_STEAMCMD_UID" > $CONFIG_DIR/$SERVICE_NAME-steam.conf
		echo 'steamcmd_password='"$INSTALL_STEAMCMD_PSW" >> $CONFIG_DIR/$SERVICE_NAME-steam.conf
		echo "steamcmd_steamguardapp=$INSTALL_STEAMGUARD_CLI" > $CONFIG_DIR/$SERVICE_NAME-steam.conf
	else
		echo 'steamcmd_username=disabled' > $CONFIG_DIR/$SERVICE_NAME-steam.conf
		echo 'steamcmd_password=disabled' >> $CONFIG_DIR/$SERVICE_NAME-steam.conf
		echo "steamcmd_steamguardapp=0" > $CONFIG_DIR/$SERVICE_NAME-steam.conf
	fi
	echo 'steamcmd_beta_branch='"$INSTALL_STEAMCMD_BETA_BRANCH" >> $CONFIG_DIR/$SERVICE_NAME-steam.conf
	echo 'steamcmd_beta_branch_name='"$INSTALL_STEAMCMD_BETA_BRANCH_NAME" >> $CONFIG_DIR/$SERVICE_NAME-steam.conf
	echo 'steamguard_cli='"$INSTALL_STEAMGUARD_CLI" >> $CONFIG_DIR/$SERVICE_NAME-steam.conf
	echo "Done"
}

#---------------------------

#Configures discord integration
script_install_discord() {
	echo ""
	read -p "Enable discord notifications (y/n): " INSTALL_DISCORD_ENABLE
	if [[ "$INSTALL_DISCORD_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo ""
		echo "You are able to add multiple webhooks for the script to use in the discord_webhooks.txt file located in the config folder."
		echo "EACH ONE HAS TO BE IN IT'S OWN LINE!"
		echo ""
		read -p "Enter your first webhook for the server: " INSTALL_DISCORD_WEBHOOK
		if [[ "$INSTALL_DISCORD_WEBHOOK" == "" ]]; then
			INSTALL_DISCORD_WEBHOOK="none"
		fi
		echo ""
		read -p "Discord notifications for game updates? (y/n): " INSTALL_DISCORD_UPDATE_ENABLE
			if [[ "$INSTALL_DISCORD_UPDATE_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_UPDATE="1"
			else
				INSTALL_DISCORD_UPDATE="0"
			fi
		echo ""
		read -p "Discord notifications for server startup? (y/n): " INSTALL_DISCORD_START_ENABLE
			if [[ "$INSTALL_DISCORD_START_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_START="1"
			else
				INSTALL_DISCORD_START="0"
			fi
		echo ""
		read -p "Discord notifications for server shutdown? (y/n): " INSTALL_DISCORD_STOP_ENABLE
			if [[ "$INSTALL_DISCORD_STOP_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_STOP="1"
			else
				INSTALL_DISCORD_STOP="0"
			fi
		echo ""
		read -p "Discord notifications for crashes? (y/n): " INSTALL_DISCORD_CRASH_ENABLE
			if [[ "$INSTALL_DISCORD_CRASH_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_CRASH="1"
			else
				INSTALL_DISCORD_CRASH="0"
			fi
	elif [[ "$INSTALL_DISCORD_ENABLE" =~ ^([nN][oO]|[nN])$ ]]; then
		INSTALL_DISCORD_UPDATE="0"
		INSTALL_DISCORD_START="0"
		INSTALL_DISCORD_STOP="0"
		INSTALL_DISCORD_CRASH="0"
	fi

	echo "Writing configuration file..."
	touch $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_update='"$INSTALL_DISCORD_UPDATE" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_start='"$INSTALL_DISCORD_START" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_stop='"$INSTALL_DISCORD_STOP" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_crash='"$INSTALL_DISCORD_CRASH" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo "$INSTALL_DISCORD_WEBHOOK" > $CONFIG_DIR/discord_webhooks.txt
	echo "Done"
}

#---------------------------

#Configures email integration
script_install_email() {
	echo ""
	read -p "Enable email notifications (y/n): " INSTALL_EMAIL_ENABLE
	if [[ "$INSTALL_EMAIL_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		read -p "Is postfix already configured on your system? (y/n): " INSTALL_EMAIL_CONFIGURED
		echo ""
		read -p "Enter your email address for the server (example: example@gmail.com): " INSTALL_EMAIL_SENDER
		echo ""
		if [[ "$INSTALL_EMAIL_CONFIGURED" =~ ^([nN][oO]|[nN])$ ]]; then
			read -p "Enter your password for $INSTALL_EMAIL_SENDER : " INSTALL_EMAIL_SENDER_PSW
		fi
		echo ""
		read -p "Enter the email that will recieve the notifications (example: example2@gmail.com): " INSTALL_EMAIL_RECIPIENT
		echo ""
		read -p "Email notifications for game updates? (y/n): " INSTALL_EMAIL_UPDATE_ENABLE
			if [[ "$INSTALL_EMAIL_UPDATE_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_UPDATE="1"
			else
				INSTALL_EMAIL_UPDATE="0"
			fi
		echo ""
		read -p "Email notifications for server startup? (WARNING: this can be anoying) (y/n): " INSTALL_EMAIL_CRASH_ENABLE
			if [[ "$INSTALL_EMAIL_CRASH_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_START="1"
			else
				INSTALL_EMAIL_START="0"
			fi
		echo ""
		read -p "Email notifications for server shutdown? (WARNING: this can be anoying) (y/n): " INSTALL_EMAIL_CRASH_ENABLE
			if [[ "$INSTALL_EMAIL_CRASH_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_STOP="1"
			else
				INSTALL_EMAIL_STOP="0"
			fi
		echo ""
		read -p "Email notifications for crashes? (y/n): " INSTALL_EMAIL_CRASH_ENABLE
			if [[ "$INSTALL_EMAIL_CRASH_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_CRASH="1"
			else
				INSTALL_EMAIL_CRASH="0"
			fi
		if [[ "$INSTALL_EMAIL_CONFIGURED" =~ ^([nN][oO]|[nN])$ ]]; then
			echo ""
			read -p "Enter the relay host (example: smtp.gmail.com): " INSTALL_EMAIL_RELAY_HOST
			echo ""
			read -p "Enter the relay host port (example: 587): " INSTALL_EMAIL_RELAY_HOST_PORT
			echo ""

			if [ "$EUID" -ne "0" ]; then
				cat >> /etc/postfix/main.cf <<- EOF
				relayhost = [$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_HOST_PORT
				smtp_sasl_auth_enable = yes
				smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
				smtp_sasl_security_options = noanonymous
				smtp_tls_CApath = /etc/ssl/certs
				smtpd_tls_CApath = /etc/ssl/certs
				smtp_use_tls = yes
				EOF

				cat > /etc/postfix/sasl_passwd <<- EOF
				[$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_HOST_PORT    $INSTALL_EMAIL_SENDER:$INSTALL_EMAIL_SENDER_PSW
				EOF

				sudo chmod 400 /etc/postfix/sasl_passwd
				sudo postmap /etc/postfix/sasl_passwd
				sudo systemctl enable postfix
			else
				echo "Add the following lines to /etc/postfix/main.cf"
				echo "relayhost = [$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_HOST_PORT"
				echo "smtp_sasl_auth_enable = yes"
				echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
				echo "smtp_sasl_security_options = noanonymous"
				echo "smtp_tls_CApath = /etc/ssl/certs"
				echo "smtpd_tls_CApath = /etc/ssl/certs"
				echo "smtp_use_tls = yes"
				echo ""
				echo "Add the following line to /etc/postfix/sasl_passwd"
				echo "[$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_HOST_PORT    $INSTALL_EMAIL_SENDER:$INSTALL_EMAIL_SENDER_PSW"
				echo ""
				echo "Execute the following commands:"
				echo "sudo chmod 400 /etc/postfix/sasl_passwd"
				echo "sudo postmap /etc/postfix/sasl_passwd"
				echo "sudo systemctl enable postfix"
			fi
		fi
	elif [[ "$INSTALL_EMAIL_ENABLE" =~ ^([nN][oO]|[nN])$ ]]; then
		INSTALL_EMAIL_SENDER="none"
		INSTALL_EMAIL_RECIPIENT="none"
		INSTALL_EMAIL_UPDATE="0"
		INSTALL_EMAIL_START="0"
		INSTALL_EMAIL_STOP="0"
		INSTALL_EMAIL_CRASH="0"
	fi

	echo "Writing configuration file..."
	echo 'email_sender='"$INSTALL_EMAIL_SENDER" >> /srv/$SERVICE_NAME/config/$SERVICE_NAME-email.conf
	echo 'email_recipient='"$INSTALL_EMAIL_RECIPIENT" >> /srv/$SERVICE_NAME/config/$SERVICE_NAME-email.conf
	echo 'email_update='"$INSTALL_EMAIL_UPDATE" >> /srv/$SERVICE_NAME/config/$SERVICE_NAME-email.conf
	echo 'email_start='"$INSTALL_EMAIL_START" >> /srv/$SERVICE_NAME/config/$SERVICE_NAME-email.conf
	echo 'email_stop='"$INSTALL_EMAIL_STOP" >> /srv/$SERVICE_NAME/config/$SERVICE_NAME-email.conf
	echo 'email_crash='"$INSTALL_EMAIL_CRASH" >> /srv/$SERVICE_NAME/config/$SERVICE_NAME-email.conf
	chown $SERVICE_NAME /srv/$SERVICE_NAME/config/$SERVICE_NAME-email.conf
	echo "Done"
}

#---------------------------

#Configures tmpfs integration
script_install_tmpfs() {
	echo ""
	read -p "Enable RamDisk (y/n): " INSTALL_TMPFS
	echo ""
	if [[ "$INSTALL_TMPFS" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		read -p "Ramdisk size (I recommend at least 8GB): " INSTALL_TMPFS_SIZE
		echo "Installing ramdisk configuration"
		if [ "$EUID" -ne "0" ]; then
			cat >> /etc/fstab <<- EOF

			# /mnt/tmpfs
			tmpfs				   /srv/isrsrv/tmpfs		tmpfs		   rw,size=$INSTALL_TMPFS_SIZE,uid=$(id -u $SERVICE_NAME),mode=0777	0 0
			EOF
		else
			echo "Add the following line to /etc/fstab:"
			echo "tmpfs				   /srv/isrsrv/tmpfs		tmpfs		   rw,size=$INSTALL_TMPFS_SIZE,uid=$(id -u $SERVICE_NAME),mode=0777	0 0"
		fi
		sed -i 's/script_tmpfs=0/script_tmpfs=1/g' /srv/$SERVICE_NAME/config/$SERVICE_NAME-script.conf
	else
		sed -i 's/script_tmpfs=1/script_tmpfs=0/g' /srv/$SERVICE_NAME/config/$SERVICE_NAME-script.conf
	fi
	chown $SERVICE_NAME /srv/$SERVICE_NAME/config/$SERVICE_NAME-script.conf
}

#---------------------------

#Configures the script
script_install() {
	echo -e "${CYAN}Script configuration${NC}"
	echo -e ""
	echo -e "The script uses steam to download the game server files, however you have the option to manualy copy the files yourself."
	echo -e "If you will be using steam for automatic updates of the server files and use steam guard authentication app on your"
	echo -e "mobile phone you can either:"
	echo -e ""
	echo -e "- change steam guard to use emails so it ask only once for the code"
	echo -e "- use a 3rd party steamguard-cli tool available from here: https://github.com/dyc3/steamguard-cli"
	echo -e ""
	echo -e "DO NOT ASK ME ON HOW TO GET STEAMGUARD-CLI WORKING. IT'S NOT MY POROJECT. BUT IF YOU HAVE MOBILE AUTHENTICATION FOR"
	echo -e "STEAM ON YOUR PHONE, IT WILL DISABLE IT AND USE ONLY THE ONE ON YOUR SERVER DUE TO VALVE ONLY ALLOWING ONE AUTHENTICATOR."
	echo -e ""
	echo -e "The script can work either way. The $SERVICE_NAME user's home directory is located in /srv/$SERVICE_NAME and all files are located there."
	echo -e "This configuration installation will only install the essential configuration. No steam, discord, email or tmpfs/ramdisk"
	echo -e "configuration will be applied and it can work without it. You can run the optional configuration for each using the"
	echo -e "following arguments with the script:"
	echo -e ""
	echo -e "${GREEN}install_steam   ${RED}- ${GREEN}Configures steamcmd, automatic updates and installs the game server files.${NC}"
	echo -e "${GREEN}install_discord ${RED}- ${GREEN}Configures discord integration.${NC}"
	echo -e "${GREEN}install_email   ${RED}- ${GREEN}Configures email integration. Due to postfix configuration files being in /etc this has to be executed as root.${NC}"
	echo -e "${GREEN}install_tmpfs   ${RED}- ${GREEN}Configures tmpfs/ramdisk. Due to it adding a line to /etc/fstab this has to be executed as root.${NC}"
	echo -e ""
	echo -e ""
	read -p "Press any key to continue" -n 1 -s -r
	echo ""

	echo ""
	read -p "Enable commands wrapper script (custom commands script for players)? (y/n): " INSTAL_SCRIPT_COMMANDS

	echo "Enable services"

	systemctl --user enable $SERVICE_NAME@01.service

	echo "$SERVICE_NAME@01.service" > $CONFIG_DIR/$SERVICE_NAME-server-list.txt

	if [[ "$INSTAL_SCRIPT_COMMANDS" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		systemctl --user enable $SERVICE_NAME-commands@1.service
		INSTALL_SCRIPT_COMMANDS_CONFIG="1"
	else
		INSTALL_SCRIPT_COMMANDS_CONFIG="0"
	fi

	echo "Writing config files"

	if [ -f "$CONFIG_DIR/$SERVICE_NAME-script.conf" ]; then
		rm $CONFIG_DIR/$SERVICE_NAME-script.conf
	fi

	touch $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_tmpfs=0' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_commands='"$INSTALL_SCRIPT_COMMANDS_CONFIG" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_bckp_delold=14' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_log_delold=7' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_log_game_delold=7' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_dump_game_delold=7' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_timeout_save=120' >> $CONFIG_DIR/$SERVICE_NAME-script.conf

	echo "Generating wine prefix"
	script_generate_wine_prefix

	if [ ! -d "$BCKP_SRC_DIR" ]; then
		mkdir -p "$BCKP_SRC_DIR"
	fi

	echo "Configuration complete"
	echo "For any settings you'll want to change, edit the files located in $CONFIG_DIR/"
	echo "To enable additional fuctions like steam, discord, email and tmpfs execute the script with the help argument."
}

#---------------------------

#Do not allow for another instance of this script to run to prevent data loss
if [[ "send_notification_start_initialized" != "$1" ]] && [[ "send_notification_start_complete" != "$1" ]] && [[ "send_notification_stop_initialized" != "$1" ]] && [[ "send_notification_stop_complete" != "$1" ]] && [[ "send_notification_crash" != "$1" ]] && [[ "move_wine_log" != "$1" ]] && [[ "server_tmux_install" != "$1" ]] && [[ "server_tmux_commands_install" != "$1" ]] && [[ "attach" != "$1" ]] && [[ "attach_commands" != "$1" ]] && [[ "status" != "$1" ]]; then
	SCRIPT_PID_CHECK=$(basename -- "$0")
	if pidof -x "$SCRIPT_PID_CHECK" -o $$ > /dev/null; then
		echo "An another instance of this script is already running, please clear all the sessions of this script before starting a new session"
		exit 1
	fi
fi

if [ "$EUID" -ne "0" ] && [ -f "$CONFIG_DIR/$SERVICE_NAME-script.conf" ]; then #Check if script executed as root, if not generate missing config fields
	touch $CONFIG_DIR/$SERVICE_NAME-script.conf
	CONFIG_FIELDS="script_tmpfs,script_commands,script_bckp_delold,script_log_delold,script_log_game_delold,script_dump_game_delold,script_timeout_save,script_update_ignore_failed_startups"
	IFS=","
	for CONFIG_FIELD in $CONFIG_FIELDS; do
		if ! grep -q $CONFIG_FIELD $CONFIG_DIR/$SERVICE_NAME-script.conf; then
			if [[ "$CONFIG_FIELD" == "script_bckp_delold" ]]; then
				echo "$CONFIG_FIELD=14" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
			elif [[ "$CONFIG_FIELD" == "script_log_delold" ]]; then
				echo "$CONFIG_FIELD=14" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
			elif [[ "$CONFIG_FIELD" == "script_log_game_delold" ]]; then
				echo "$CONFIG_FIELD=14" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
			elif [[ "$CONFIG_FIELD" == "script_dump_game_delold" ]]; then
				echo "$CONFIG_FIELD=14" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
			elif [[ "$CONFIG_FIELD" == "script_timeout_save" ]]; then
				echo "$CONFIG_FIELD=120" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
			else
				echo "$CONFIG_FIELD=0" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
			fi
		fi
	done
fi

#---------------------------
#Script help page
case "$1" in
	help)
		echo -e "${CYAN}Time: $(date +"%Y-%m-%d %H:%M:%S") ${NC}"
		echo -e "${CYAN}$NAME server script by 7thCore${NC}"
		echo "Version: $VERSION"
		echo ""
		echo "Basic script commands:"
		echo -e "${GREEN}diag   ${RED}- ${GREEN}Prints out package versions and if script files are installed.${NC}"
		echo -e "${GREEN}status ${RED}- ${GREEN}Display status of server.${NC}"
		echo ""
		echo "Configuration and installation:"
		echo -e "${GREEN}install         ${RED}- ${GREEN}Installs all the needed configuration for the script to run, the wine prefix and the game.${NC}"
		echo -e "${GREEN}install_steam   ${RED}- ${GREEN}Configures steamcmd, automatic updates and installs the game server files.${NC}"
		echo -e "${GREEN}install_discord ${RED}- ${GREEN}Configures discord integration.${NC}"
		echo -e "${GREEN}install_email   ${RED}- ${GREEN}Configures email integration. Due to postfix configuration files being in /etc this has to be executed as root.${NC}"
		echo -e "${GREEN}install_tmpfs   ${RED}- ${GREEN}Configures tmpfs/ramdisk. Due to it adding a line to /etc/fstab this has to be executed as root.${NC}"
		echo ""
		echo "Server services managment:"
		echo -e "${GREEN}add_server                      ${RED}- ${GREEN}Adds a server instance.${NC}"
		echo -e "${GREEN}remove_server                   ${RED}- ${GREEN}Removes a server instance.${NC}"
		echo -e "${GREEN}enable_services <server number> ${RED}- ${GREEN}Enables all services dependant on the configuration file of the script.${NC}"
		echo -e "${GREEN}disable_services                ${RED}- ${GREEN}Disables all services. The server and the script will not start up on boot anymore.${NC}"
		echo -e "${GREEN}reload_services                 ${RED}- ${GREEN}Reloads all services, dependant on the configuration file.${NC}"
		echo ""
		echo "Server and console managment:"
		echo -e "${GREEN}start <server number>           ${RED}- ${GREEN}Start the server. If the server number is not specified the function will start all servers.${NC}"
		echo -e "${GREEN}start_no_err <server number>    ${RED}- ${GREEN}Start the server but don't require confimation if in failed state.${NC}"
		echo -e "${GREEN}stop <server number>            ${RED}- ${GREEN}Stop the server. If the server number is not specified the function will stop all servers.${NC}"
		echo -e "${GREEN}restart <server number>         ${RED}- ${GREEN}Restart the server. If the server number is not specified the function will restart all servers.${NC}"
		echo -e "${GREEN}save                            ${RED}- ${GREEN}Issue the save command to the server.${NC}"
		echo -e "${GREEN}sync                            ${RED}- ${GREEN}Sync from tmpfs to hdd/ssd.${NC}"
		echo -e "${GREEN}attach <server number>          ${RED}- ${GREEN}Attaches to the tmux session of the specified server.${NC}"
		echo -e "${GREEN}attach_commands <server number> ${RED}- ${GREEN}Attaches to the tmux session of the commands script for the specified server.${NC}"
		echo ""
		echo "Backup managment:"
		echo -e "${GREEN}backup        ${RED}- ${GREEN}Backup files, if server running or not.${NC}"
		echo -e "${GREEN}autobackup    ${RED}- ${GREEN}Automaticly backup files when server running.${NC}"
		echo -e "${GREEN}delete_backup ${RED}- ${GREEN}Delete old backups.${NC}"
		echo ""
		echo "Steam managment:"
		echo -e "${GREEN}update        ${RED}- ${GREEN}Update the server, if the server is running it will save it, shut it down, update it and restart it.${NC}"
		echo -e "${GREEN}verify        ${RED}- ${GREEN}Verifiy game server files, if the server is running it will save it, shut it down, verify it and restart it.${NC}"
		echo -e "${GREEN}change_branch ${RED}- ${GREEN}Changes the game branch in use by the server (public,experimental,legacy and so on).${NC}"
		echo ""
		echo "Game specific functions:"
		echo -e "${GREEN}crash_kill  ${RED}- ${GREEN}If the aluna crash handler is running and is frozen, this function kills it.${NC}"
		echo -e "${GREEN}delete_save ${RED}- ${GREEN}Delete the server's save game with the option for deleting/keeping the server.json and other server files.${NC}"
		echo ""
		echo "Wine functions:"
		echo -e "${GREEN}rebuild_prefix ${RED}- ${GREEN}Reinstalls the wine prefix. Usefull if any wine prefix updates occoured.${NC}"
		;;
#---------------------------
#Basic script functions
	diag)
		script_diagnostics
		;;
	status)
		script_status
		;;
#---------------------------
#Configuration and installation
	install)
		script_install
		;;
	install_steam)
		script_install_steam
		;;
	install_discord)
		script_install_discord
		;;
	install_email)
		script_install_email
		;;
	install_tmpfs)
		script_install_tmpfs
		;;
#---------------------------
#Server services managment
	add_server)
		script_add_server
		;;
	remove_server)
		script_remove_server
		;;
	enable_services)
		script_enable_services_manual
		;;
	disable_services)
		script_disable_services_manual
		;;
	reload_services)
		script_reload_services
		;;
#---------------------------
#Server and console managment
	start)
		script_start $2
		;;
	start_no_err)
		script_start_ignore_errors $2
		;;
	stop)
		script_stop $2
		;;
	restart)
		script_restart $2
		;;
	save)
		script_save
		;;
	sync)
		script_sync
		;;
	attach)
		script_attach $2
		;;
	attach_commands)
		script_attach_commands $2
		;;
#---------------------------
#Backup managment
	backup)
		script_backup
		;;
	autobackup)
		script_autobackup
		;;
	delete_backup)
		script_deloldbackup
		;;

#---------------------------
#Steam managment
	update)
		script_update
		;;
	verify)
		script_verify_game_integrity
		;;
	change_branch)
		script_change_branch
		;;
#---------------------------
#Game specific functions
	crash_kill)
		script_crash_kill
		;;
	delete_save)
		script_delete_save
		;;
#---------------------------
#Wine functions
	rebuild_prefix)
		script_install_prefix
		;;
#---------------------------
#Hidden functions meant for systemd service use
	move_wine_log)
		script_move_wine_log $2
		;;
	send_notification_start_initialized)
		script_send_notification_start_initialized $2
		;;
	send_notification_start_complete)
		script_send_notification_start_complete $2
		;;
	send_notification_stop_initialized)
		script_send_notification_stop_initialized $2
		;;
	send_notification_stop_complete)
		script_send_notification_stop_complete $2
		;;
	send_notification_crash)
		script_send_notification_crash $2
		;;
	server_tmux_install)
		script_server_tmux_install $2
		;;
	server_tmux_commands_install)
		script_commands_tmux_install $2
		;;
	timer_one)
		script_timer_one
		;;
	timer_two)
		script_timer_two
		;;
	*)
#---------------------------
#General output if the script does not recognise the argument provided
	echo -e "${CYAN}Time: $(date +"%Y-%m-%d %H:%M:%S") ${NC}"
	echo -e "${CYAN}$NAME server script by 7thCore${NC}"
	echo ""
	echo "For more detailed information, execute the script with the -help argument"
	echo ""
	echo -e "${GREEN}Basic script commands${RED}: ${GREEN}help, diag, status${NC}"
	echo -e "${GREEN}Configuration and installation${RED}: ${GREEN}install, install_steam, install_discord, install_email, install_tmpfs${NC}"
	echo -e "${GREEN}Server services managment${RED}: ${GREEN}add_server, remove_server, enable_services, disable_services, reload_services${NC}"
	echo -e "${GREEN}Server and console managment${RED}: ${GREEN}start, start_no_err, stop,restart, save, sync, attach, attach_commands${NC}"
	echo -e "${GREEN}Backup managment${RED}: ${GREEN}backup, autobackup, delete_backup${NC}"
	echo -e "${GREEN}Steam managment${RED}: ${GREEN}update, verify, change_branch${NC}"
	echo -e "${GREEN}Game specific functions${RED}: ${GREEN}crash_kill, delete_save${NC}"
	echo -e "${GREEN}Wine functions${RED}: ${GREEN}rebuild_prefix${NC}"
	exit 1
	;;
esac

exit 0