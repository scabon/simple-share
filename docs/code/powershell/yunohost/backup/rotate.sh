#!/bin/bash
# Rotates the local backups of a YuNoHost server.
# It requires the following parameters:
# - BackupFolder: The folder containing the backups.
# - BackupsToKeep: The maximum number of backups to keep.
echo "$(date '+%Y-%m-%d %H:%M:%S'): SH ---------------------" >> ./rotate.log
echo "$(date '+%Y-%m-%d %H:%M:%S'): SH - Launching rotate.sh" >> ./rotate.log
pwsh -File ./rotate.ps1 -BackupFolder '/backups/yunohost' -BackupsToKeep 10 >> ./rotate.log
echo "$(date '+%Y-%m-%d %H:%M:%S'): SH - Finished rotate.sh" >> ./rotate.log
echo "$(date '+%Y-%m-%d %H:%M:%S'): SH --------------------" >> ./rotate.log