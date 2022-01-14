# isrsrv-script
Bash script for running Interstellar Rift on a linux server

-------------------------

# What does this script do?

This script creates a new non-sudo enabled user and installes the game in a folder called server in the user's home folder. It also installs systemd services for starting and shutting down the game server when the computer starts up, shuts down or reboots and also installs systemd timers so the script is executed on timed intervals (every 15 minutes) to do it's work like automatic game updates, backups and syncing from ramdisk to hdd. It will also create a config file in the script folder that will save the configuration you defined between the installation process. The reason for user creation is to limit the script's privliges so it CAN NOT be used with sudo when handeling the game server. Sudo is only needed for installing the script (for user creation) and installing packages (if the script supports the distro you are running).

-------------------------

**Features:**

- auto backups

- auto updates

- script logging

- auto restart if crashed

- delete old backups

- delete old logs

- run from ramdisk

- sync from ramdisk to hdd/ssd

- start on os boot

- shutdown gracefully on os shutdown

- can run multiple servers

- script auto update from github (optional)

- send email notifications when SSK.txt near end of life (optional)

- send email notifications after 3 crashes within a 5 minute time limit (optional)

- send email notifications when server updated (optional)

- send email notifications on server startup (optional)

- send email notifications on server shutdown (optional)

- send discord notifications when SSK.txt near end of life or expired (optional)

- send discord notifications after 3 crashes within a 5 minute time limit (optional)

- send discord notifications when server updated (optional)

- send discord notifications on server startup (optional)

- send discord notifications on server shutdown (optional)

- supports multiple discord webhooks

-------------------------

# Available commands:

| Command | Description |
| ------- | ----------- |
| Basic script commands: ||
| `help` | Prints out available commands and their description
| `diag` | Prints out package versions and if script files are installed. |
| `status` | Display status of server. |
|||
| Configuration and installation: ||
| `install` | Installs all the needed configuration for the script to run, the wine prefix and the game. |
| `install_steam` | Configures steamcmd, automatic updates and installs the game server files. |
| `install_discord` | Configures discord integration. |
| `install_email` | Configures email integration. Due to postfix configuration files being in /etc this has to be executed as root. |
| `install_tmpfs` | Configures tmpfs/ramdisk. Due to it adding a line to /etc/fstab this has to be executed as root. |
|||
| Server services managment: ||
| `add_server` | Adds a server instance. |
| `remove_server` | Removes a server instance. |
| `enable_services <server number>` | Enables all services dependant on the configuration file of the script. |
| `disable_services` | Disables all services. The server and the script will not start up on boot anymore. |
| `reload_services` | Reloads all services, dependant on the configuration file. |
|||
| Server and console managment: ||
| `start <server number>` | Start the server. If the server number is not specified the function will start all servers. |
| `start_no_err <server number>` | Start the server but don't require confimation if in failed state. |
| `stop <server number>` | Stop the server. If the server number is not specified the function will stop all servers. |
| `restart <server number>` | Restart the server. If the server number is not specified the function will restart all servers. |
| `save` | Issue the save command to the server. |
| `sync` | Sync from tmpfs to hdd/ssd. |
| `attach <server number>` | Attaches to the tmux session of the specified server. |
| `attach_commands <server number>` | Attaches to the tmux session of the commands script for the specified server. |
|||
| Backup managment: ||
| `backup` | Backup files, if server running or not. |
| `autobackup` | Automaticly backup files when server running. |
| `delete_backup` | Delete old backups. |
|||
| Steam managment: ||
| `update` | Update the server, if the server is running it will save it, shut it down, update it and restart it. |
| `verify` | Verifiy game server files, if the server is running it will save it, shut it down, verify it and restart it. |
| `change_branch` | Changes the game branch in use by the server (public,experimental,legacy and so on). |
|||
| Game specific functions: ||
| `crash_kill` | If the aluna crash handler is running and is frozen, this function kills it. |
| `delete_save` | Delete the server's save game with the option for deleting/keeping the server.json and other server files. |
|||
| Wine functions: ||
| `rebuild_prefix` | Reinstalls the wine prefix. Usefull if any wine prefix updates occoured. |

-------------------------

# WARNING

- Steam: A Steam username and password owning the game in question is needed to download all the needed files (workshop items and DLCs) and allow automated updates. If you want for automated updates for the game enabled you are advised to enable Steam 2 factor authentication via email because Steam Guard via phone will ask for the authentication password every time the script runs a function using SteamCMD and will break certain functions. Your steam credentials will be stored in the script's configuration file. If you are not comfortable with this you can disable auto updates for the game and mods. You will be however required to manually log in to the server and manually update each time an update is released and each time you will be prompted to enter your Steam credentials wich will not be saved on the server.

You also have the option to not use SteamCMD and copy the files manually to the server.




-------------------------

# Installation

**Required packages**

- xvfb

- rsync

- tmux

- wine

- winetricks

- steamcmd

- curl

- wget

- cabextract

- postfix (optional for email notifications. When asked for configuration type you can select no configuration)

- zip (optional but required if using the email feature)

-------------------------

**Debian based distro users**

Do yourself a favor and don't install wine from the official distro repository. Go to the wine wiki and add the repository for your distro. The packages in the distro repositories are out of date. Also install winetricks.

[Wine Wiki - Debian](https://wiki.winehq.org/Debian)

[Wine Wiki - Ubuntu](https://wiki.winehq.org/Ubuntu)


-------------------------

**Manual installation:**

Log in to your server with ssh and execute:

`git clone https://github.com/7thCore/isrsrv-script`


Copy the two isrsrv scripts to /usr/bin

`cp ./isrsrv-script.bash /usr/bin/isrsrv-script`
`cp ./isrsrv-commands.bash /usr/bin/isrsrv-commands`


Create the isrsrv user

`useradd --system -g users -d /srv/isrsrv/ -s /bin/bash isrsrv`


Create the folder structure for the server:

`mkdir -p /srv/isrsrv/{server,config,updates,backups,logs}`
`mkdir -p /srv/isrsrv/.config/systemd/user`


Copy all the .service and .timer files to the user directory

`cp ./*.service /srv/isrsrv/.config/systemd/user/`
`cp ./*.timer /srv/isrsrv/.config/systemd/user/`


Copy the bash profile to the isrsrv directory

`cp ./bash_profile /srv/isrsrv/.bash_profile`


Give file permissions to the user

`chown -R isrsrv:users srv/isrsrv`


Start the user service and enable linger

`loginctl enable-linger isrsrv`
`systemctl start user@$(id -u isrsrv).service`


Login to the user and start the script configuration

`sudo -i -u isrsrv`
`isrsrv-script install`

-------------------------

**Package installation:**

Download the package for your system and install it. It will install all the needed dependancies for the script.

After the installation finishes log in to the newly created user and set `AutoSaveDelay` and `BackupSaveDelay` in server_01.json to `0` to disable the integrated saves and backups. The script will take care of saving and backups. This is required if using the script so the game won't save mid script-backup or sync from RamDisk to hdd/ssd.

-------------------------

# Add or remove additional servers

The script takes full advantage of the -serverAddition argument of Interstellar Rift. This means you can start additional server from the same installation and the script will take care of all of them. To add additional server type the following command:

`-add_server`

You will be promped to enter a server number. These can range from 1-99 (single digit numbers must have a 0 before them, for example 09). Once the server is enabled it will automaticly start as the first server. Server 01 is the default.

To remove a server (this just turns off the service without deleting any data/saves) you can execute the following command:

`-remove_server`

You will be promped to enter a server number. These can range from 1-99 (single digit numbers must have a 0 before them, for example 09).

-------------------------
