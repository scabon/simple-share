#!/bin/bash
# This script is a wrapper used to call the rotate.ps1 script using.
# You need to have PowerShell installed on your system to run this script.
# You can install it from https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
# Use absolute paths for the script and the log file (apparently required by crontab).
# This script is intended to be run as a cron job.

# Folder where the backup script is located, and the logs will be written.
folder="/home/der/scripts"
# Date format for the logs timestamp.
format='+%Y-%m-%d %H:%M:%S'
echo "$(date "$format"): SH - Writing logs to $folder/rotate.log (append)"
echo "$(date "$format"): SH ---------------------" >> $folder/rotate.log
echo "$(date "$format"): SH - Launching rotate.sh" >> $folder/rotate.log
/usr/bin/pwsh -File "$folder/rotate.ps1" -LogFile "$folder/rotate.log" -BackupFolder '/backups/yunohost' -BackupsToKeep 10
echo "$(date "$format"): SH - Finished rotate.sh" >> $folder/rotate.log
echo "$(date "$format"): SH --------------------" >> $folder/rotate.log