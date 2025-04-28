#!/bin/bash
# This script is a wrapper used to call the backup.ps1 script using.
# You need to have PowerShell installed on your system to run this script.
# You can install it from https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
# Use absolute paths for the script and the log file (apparently required by crontab).
# This script is intended to be run as a cron job.

# Folder where the backup script is located, and the logs will be written.
folder="/home/derzeppel/scripts"
# Date format for the logs timestamp.
format='+%Y-%m-%d %H:%M:%S'
echo "$(date "$format"): SH - Writing logs to $folder/backup.log (append)"
echo "$(date "$format"): SH ---------------------" >> $folder/backup.log
echo "$(date "$format"): SH - Launching backup.sh" >> $folder/backup.log
/usr/bin/pwsh -File "$folder/backup.ps1" -LogFile "$folder/backup.log" -BackupServer 'zeppel.org' -BackupServerPort 22 -RemoteBackupFolder '/backups/yunohost' -BackupCredentialsFile 'backupcreds.xml'
echo "$(date "$format"): SH - Finished backup.sh" >> $folder/backup.log
echo "$(date "$format"): SH --------------------" >> $folder/backup.log