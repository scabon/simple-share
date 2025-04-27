<#
.SYNOPSIS
Create backup of yunohost instance and copy it to a remote server.
.DESCRIPTION
Create backup of yunohost instance and copy it to a remote server.
You need a Credential file with the password for the remote server.
.PARAMETER BackupServer
The remote server to copy the backup to.
.PARAMETER BackupServerPort
The port to use for the remote server connection (ssh). Default is 22.
.PARAMETER RemoteBackupFolder
The folder on the remote server to copy the backup to.
.PARAMETER BackupCredentialsFile
The file containing the username and password for the remote server.
You can create this file with the following commands:
    $Credentials = Get-Credential
    $Credentials | Export-Clixml 'backupcreds.xml'
.PARAMETER NbLocalBackups
The number of backups to keep on the local server. Set to 0 to disable local backup rotation.
There are two files for each backup.
.EXAMPLE
    ./backup.ps1 -BackupServer 'zeppel.org' -RemoteBackupFolder '/backups' -BackupCredentials 'backupcreds.xml'
#>

[CmdletBinding()]
param (
    # Server to copy the backup to
    [string]$BackupServer = 'zeppel.org',
    # Backup server port
    [int]$BackupServerPort = 22,
    # Folder on the remote server to copy the backup to
    [string]$RemoteBackupFolder = '/backups/yunohost',
    # File containing the username and password for the remote server
    [string]$BackupCredentialsFile = 'backupcreds.xml',
    # Number of backups to keep on the local server (0 to disable)
    [int]$NbLocalBackups = 3
)

Function Write-Timestamped {
    param (
        [string]$Message
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): PS - $Message"
}

# Launch the yunohost backup command and capture the output
Write-Timestamped "[Backup] Creating backup with 'sudo yunohost backup create'"
[string[]]$BackupConsole = & sudo yunohost backup create
[bool]$Success = $False
[string]$BackupName = ''
# If the backup worked, we should have something like this in the output:
# SUCCESS Backup created: 20250416-194416
foreach( $Line in $BackupConsole) {
    if( $Line.IndexOf( 'SUCCESS Backup created: ' ) -eq 0 ) {
        $Success = $True
        $BackupName = $Line.Substring( 'SUCCESS Backup created: '.Length )
    }
}
if( -Not $Success ) {
    Write-Timestamped '[Backup] Backup failed'
    exit 1
}
Write-Timestamped "[Backup] Backup created: $BackupName"
# Backups folder
[string]$LocalBackupFolder = '/home/yunohost.backup/archives'
# Info file
[string]$InfoFileName = "$BackupName.info.json"
[string]$InfoFile = "$LocalBackupFolder/$InfoFileName"
Write-Timestamped "[Backup] Info file: $InfoFile"
# Check if the info file exists
If( -Not (Test-Path $InfoFile)) {
    Write-Timestamped '[Backup] Info file not found'
    exit 1
}
# TGZ file
[string]$TGZFileName = "$BackupName.tar.gz"
[string]$TGZFile = "$LocalBackupFolder/$TGZFileName"
Write-Timestamped "[Backup] TGZ file: $TGZFile"
# Check if the tgz file exists
If( -Not (Test-Path $TGZFile)) {
    Write-Timestamped '[Backup] TGZ file not found'
    exit 1
}
Write-Timestamped '[Backup] Done'

<# Test connection to remote server #>
Write-Timestamped '[Copy] Testing connection to remote server'
$TestConnection = Test-Connection -ComputerName $BackupServer -TcpPort $BackupServerPort -Count 1 -Quiet
if ( $TestConnection -eq $True ) {
    Write-Timestamped "[Copy] Connection to $BackupServer port $BackupServerPort successful"
} else {
    Write-Error "[Copy] Unable to connect to $BackupServer on port $BackupServerPort"
    exit 1
}
<# Copy backup files to remote server #>
Write-Timestamped '[Copy] Copying backup files to remote server'
# Check if the backup credentials file exists
If( -Not (Test-Path $BackupCredentialsFile)) {
    Write-Error '[Copy] Backup credentials file not found'
    Write-Timestamped '[Copy] Please create the file with the following commands: '
    Write-Timestamped '    $Credentials = Get-Credential'
    Write-Timestamped '    $Credentials | Export-Clixml backupcreds.xml'
    exit 1
}
[PSCredential]$BackupCredentials = Import-Clixml $BackupCredentialsFile
# Copy backup files to remote server
[string]$BackupUser = $BackupCredentials.UserName
Write-Timestamped "[Copy] scp -P $BackupServerPort $TGZFile $InfoFile "$BackupUser@$($BackupServer):$RemoteBackupFolder
[string[]]$SCPConsole = & sshpass -p $BackupCredentials.GetNetworkCredential().password scp -P $BackupServerPort $TGZFile $InfoFile "$BackupUser@$($BackupServer):$RemoteBackupFolder"
if ( $SCPConsole.Count -gt 0 ) {
    Write-Error '[Copy] Something went wrong with the SCP command'
    Write-Timestamped $SCPConsole
    exit 1
}

# Check if the files were copied to the remote server
Write-Timestamped '[Copy] Checking if the files were copied to the remote server: '
Write-Timestamped "[Copy] ssh -p $BackupServerPort $BackupUser@$BackupServer ls -1t $RemoteBackupFolder | head -n 2"
[string[]]$SSHConsole = & sshpass -p $BackupCredentials.GetNetworkCredential().password ssh -p $BackupServerPort $BackupUser@$BackupServer ls -1t $RemoteBackupFolder | head -n 2
if ( $SSHConsole.Count -lt 2 ) {
    Write-Error '[Copy] Something went wrong with the SSH command'
    Write-Timestamped $SSHConsole
    exit 1
} elseif( $SSHConsole -contains $TGZFileName -and $SSHConsole -contains $InfoFileName ) {
    Write-Timestamped '[Copy] Backup files were copied to the remote server'
} else {
    Write-Timestamped '[Copy] Not sure of the result!'
    Write-Timestamped $SSHConsole
}
Write-Timestamped '[Copy] Done'

# Rotate local backups
Write-Timestamped '[Cleanup] Rotating local backups'
if ( $NbLocalBackups -lt 1 ) {
    Write-Timestamped '[Cleanup] Ignoring local backup rotation'
} else {
    Write-Timestamped "[Cleanup] Keeping $NbLocalBackups local backups"
    [int]$NbFilesToKeep = $NbLocalBackups * 3
    [System.IO.FileInfo[]]$BackUpFiles = Get-ChildItem -Path $LocalBackupFolder
    Write-Timestamped "[Cleanup] Total number of files in backup folder: $($BackUpFiles.Count)"
    [int]$NbFilesToRemove = $BackUpFiles.Count - $NbFilesToKeep
    if ( $NbFilesToRemove -lt 1 ) {
        Write-Timestamped '[Cleanup] No files to remove'
    } else {
        Write-Timestamped "[Cleanup] Number of files to remove: $NbFilesToRemove"
        $BackUpFiles | Sort-Object -Property CreationTime | Select-Object -First $NbFilesToRemove | Remove-Item -Force
        [System.IO.FileInfo[]]$BackUpFiles = Get-ChildItem -Path $LocalBackupFolder
        Write-Timestamped "[Cleanup] Remaining number of files in backup folder: $($BackUpFiles.Count)"
    }
}
Write-Timestamped '[Cleanup] Done'

Write-Timestamped 'Done'
exit 0