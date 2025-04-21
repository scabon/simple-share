#!/bin/bash
# This script is used to backup files from a remote server using PowerShell.
# It requires the following parameters:
# - BackupServer: The server to backup from.
# - RemoteBackupFolder: The folder on the server to backup.
# - BackupCredentialsFile: The file containing the credentials to use for the backup.
# You need to have PowerShell installed on your system to run this script.
# You can install it from https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
# You can run this script using the following command:
# ./backup.sh -BackupServer 'zeppel.org' -RemoteBackupFolder '/backups' -BackupCredentialsFile 'backupcreds.xml'
pwsh -File ./backup.ps1 -BackupServer 'zeppel.org' -RemoteBackupFolder '/backups' -BackupCredentialsFile 'backupcreds.xml'