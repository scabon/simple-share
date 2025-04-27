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

if ( -Not (Test-Path -Path $BackupFolder) ) {
    Write-Error "Backup folder $BackupFolder does not exist, or access denied"
    exit 1
}

Write-Host "Listing files in $BackupFolder"
[System.IO.FileInfo[]]$BackUpFiles = Get-ChildItem -Path $BackupFolder
[int]$NbBackUpFiles = $BackUpFiles.Count
[int]$NbBackups = $NbBackUpFiles / 2
Write-Host "Found $NbBackups backups"
Write-Host "Want to keep $BackupsToKeep backups"
# There are two files for each backup (one .tar.gz and one .info.json)
[int]$NbBackupFilesToKeep = $BackupsToKeep * 2
if ( $NbBackUpFiles -lt $NbBackupFilesToKeep) {
    Write-Host "No need to rotate backup files"
    exit 0
}
[int]$NbFilesToDelete = $NbBackUpFiles - $NbBackupFilesToKeep
[int]$NbBackupsToDelete = $NbFilesToDelete / 2
Write-Host "Number of backups to delete: $NbBackupsToDelete"
$BackUpFiles `
| Sort-Object -Property LastWriteTime `
| Select-Object -First $NbFilesToDelete `
| ForEach-Object { Write-Host "Deleting $PSItem.FullName" }
| Remove-Item -Force

Write-Host "Done"
exit 0