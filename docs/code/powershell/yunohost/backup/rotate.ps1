<#
    Rotates the backups in the specified folder.
    Desgined for YunoHost backups, but can be used for any folder, it's assumed there are two files for each backup (one .tar.gz and one .info.json)
#>
[cmdletbinding()]
param (
    # Number of backups to keep
    [int]$BackupsToKeep = 10,
    # Path to the folder to rotate
    [string]$BackupFolder = '/backups/yunohost/'
)

Function Write-Timestamped {
    param (
        [string]$Message
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): PS - $Message"
}

if ( -Not (Test-Path -Path $BackupFolder) ) {
    Write-Error "Backup folder $BackupFolder does not exist, or access denied"
    exit 1
}

Write-Timestamped "Listing files in $BackupFolder"
[System.IO.FileInfo[]]$BackUpFiles = Get-ChildItem -Path $BackupFolder
[int]$NbBackUpFiles = $BackUpFiles.Count
[int]$NbBackups = $NbBackUpFiles / 2
Write-Timestamped "Found $NbBackups backups"
Write-Timestamped "Want to keep $BackupsToKeep backups"
# There are two files for each backup (one .tar.gz and one .info.json)
[int]$NbBackupFilesToKeep = $BackupsToKeep * 2
if ( $NbBackUpFiles -lt $NbBackupFilesToKeep) {
    Write-Timestamped "No need to rotate backup files"
    exit 0
}
[int]$NbFilesToDelete = $NbBackUpFiles - $NbBackupFilesToKeep
[int]$NbBackupsToDelete = $NbFilesToDelete / 2
Write-Timestamped "Number of backups to delete: $NbBackupsToDelete"
$BackUpFiles `
| Sort-Object -Property LastWriteTime `
| Select-Object -First $NbFilesToDelete `
| ForEach-Object { Write-Timestamped "Deleting $PSItem.FullName" }
| Remove-Item -Force

Write-Timestamped "Done"
exit 0