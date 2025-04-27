#!/bin/bash
# Rotates the local backups of a YuNoHost server.
# It requires the following parameters:
# - BackupFolder: The folder containing the backups.
# - MaxBackups: The maximum number of backups to keep.
pwsh -File ./rotate.ps1 -BackupFolder '/backups/yunohost' -MaxBackups 10