#!/bin/bash

#Interstellar Rift commands script by 7thCore

#Basics
NAME="IsRSrv" #Name of the tmux session
VERSION="1.5-4" #Package and script version

#Server configuration
SERVICE_NAME="isrsrv" #Name of the service files, script and script log

echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] [Server $1] (Commands) Commands script is now active and waiting for input on server $1."

unset lastline
while IFS= read line; do
	if [[ "$line" == "$lastline" ]]; then
		continue
	else
		if [[ "$line" == *"[ServerCommand]"* ]] && [[ "$line" == *"help"* ]] && [[ "$line" != *"[All]"* ]] && [[ "$COMMANDS_SCRIPT" == "1" ]]; then
			(
			#Display command descriptions
			PLAYER=$(echo $line | awk -F '[[ServerCommand]] ' '{print $2}' | awk -F '[ (]' '{print $1}')
			STEAMID=$(echo $line | awk -F"[()]" '{print $2}')
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Display help - help" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleport to HSC Industrial Complex - tp_hsc" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleport to GT Trade Hub - tp_gt" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleport to S3 Fort Bragg - tp_s3" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleport to DFT Black Pit - tp_dft" ENTER
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] [Server $1] (Commands) Player $PLAYER with SteamID64 $STEAMID executed command: help"
			)
			continue
		elif [[ "$line" == *"[ServerCommand]"* ]] && [[ "$line" == *"tp_hsc"* ]] && [[ "$line" != *"[All]"* ]] && [[ "$COMMANDS_SCRIPT" == "1" ]]; then
			#Vectron Syx
			(
			PLAYER=$(echo $line | awk -F '[[ServerCommand]] ' '{print $2}' | awk -F '[ (]' '{print $1}')
			STEAMID=$(echo $line | awk -F"[()]" '{print $2}')
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleporting to HSC Industrial Complex" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "tpts $STEAMID \"Vectron Syx\" \"Industrial Complex\"" ENTER
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] [Server $1] (Commands) Player $PLAYER with SteamID64 $STEAMID executed command: tp_hsc"
			)
			continue
		elif [[ "$line" == *"[ServerCommand]"* ]] && [[ "$line" == *"tp_gt"* ]] && [[ "$line" != *"[All]"* ]] && [[ "$COMMANDS_SCRIPT" == "1" ]]; then
			#Alpha Ventura
			(
			PLAYER=$(echo $line | awk -F '[[ServerCommand]] ' '{print $2}' | awk -F '[ (]' '{print $1}')
			STEAMID=$(echo $line | awk -F"[()]" '{print $2}')
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleporting to GT Trade Hub" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "tpts $STEAMID \"Alpha Ventura\" \"Trade Hub\"" ENTER
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] [Server $1] (Commands) Player $PLAYER with SteamID64 $STEAMID executed command: tp_gt"
			)
			continue
		elif [[ "$line" == *"[ServerCommand]"* ]] && [[ "$line" == *"tp_s3"* ]] && [[ "$line" != *"[All]"* ]] && [[ "$COMMANDS_SCRIPT" == "1" ]]; then
			#Sentinel Prime
			(
			PLAYER=$(echo $line | awk -F '[[ServerCommand]] ' '{print $2}' | awk -F '[ (]' '{print $1}')
			STEAMID=$(echo $line | awk -F"[()]" '{print $2}')
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleporting to S3 Fort Bragg" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "tpts $STEAMID \"Sentinel Prime\" \"Fort Bragg\"" ENTER
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] [Server $1] (Commands) Player $PLAYER with SteamID64 $STEAMID executed command: tp_s3"
			)
			continue
		elif [[ "$line" == *"[ServerCommand]"* ]] && [[ "$line" == *"tp_dft"* ]] && [[ "$line" != *"[All]"* ]] && [[ "$COMMANDS_SCRIPT" == "1" ]]; then
			#Scaverion
			(
			PLAYER=$(echo $line | awk -F '[[ServerCommand]] ' '{print $2}' | awk -F '[ (]' '{print $1}')
			STEAMID=$(echo $line | awk -F"[()]" '{print $2}')
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "whisper $STEAMID Teleporting to DFT Black Pit" ENTER
			tmux -L $SERVICE_NAME-$1-tmux.sock send-keys -t $NAME.0 "tpts $STEAMID \"Scaverion\" \"The Black Pit\"" ENTER
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] [INFO] [Server $1] (Commands) Player $PLAYER with SteamID64 $STEAMID executed command: tp_dft"
			)
			continue
		else
			continue
		fi
	fi
	lastline=$line
done < <(tail -n1 -f /tmp/$SERVICE_NAME-$1-tmux.log)
