<#
.SYNOPSIS
Create backup of yunohost instance and copy it to remote servers.
.DESCRIPTION
Create backup of yunohost instance and copy it to remote servers.
You need a Credential file with the password for each remote server.
The remote servers are listed in a configuration file (JSON format).
.PARAMETER ConfigFile
Path to the configuration file. Default is './BackupConf.json'.
/!\ Use the full path if the script is run from another folder (or from cron). /!\
Sample file (with one backup target, add as many as needed):
{
    "Targets": [
        {
            "BackupServer": "zeppel.com",
            "BackupServerPort": 22,
            "RemoteBackupFolder": "/backups",
            "BackupCredentialsFile": "backupcreds.xml",
            "enabled": true
        }
    ]
}
.PARAMETER NbLocalBackups
The number of backups to keep on the local server. Set to 0 to disable local backup rotation.
There are two files for each backup.
.EXAMPLE
    ./backup.ps1 ConfigFile './MyBackupConf.json' NbLocalBackups 5 LogFile './mybackup.log'
#>

[CmdletBinding()]
param (
    # Config file
    [string]$ConfigFile = './BackupConf.json',
    # Number of backups to keep on the local server (0 to disable)
    [int]$NbLocalBackups = 3,
    # Log file path
    [string]$LogFile = './backup.log'
)

<# Script variables #>
# Info file
[string]$InfoFile = ''
[string]$InfoFileName = ''
# TGZ file
[string]$TGZFile = ''
[string]$TGZFileName = ''

Function Write-Timestamped {
    param (
        [string]$Message
    )
    [string]$Msg = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): PS - $Message"
    Write-Host $Msg
    $Msg | Out-File -FilePath $LogFile -Append
}

Write-Timestamped "[Info] Writing logs to $LogFile (append)"

# Create a new backup
function New-YounohostBackup {
    # Launch the yunohost backup command and capture the output
    Write-Timestamped "[Backup] Creating backup with 'sudo yunohost backup create'"
    [string[]]$BackupConsole = & sudo yunohost backup create 2>> $script:LogFile
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
    $script:InfoFileName = "$BackupName.info.json"
    $script:InfoFile = "$LocalBackupFolder/$script:InfoFileName"
    Write-Timestamped "[Backup] Info file: $script:InfoFile"
    # Check if the info file exists
    If( -Not (Test-Path $script:InfoFile)) {
        Write-Timestamped '[Backup] Info file not found'
        exit 1
    }
    # TGZ file
    $script:TGZFileName = "$BackupName.tar.gz"
    $script:TGZFile = "$LocalBackupFolder/$script:TGZFileName"
    Write-Timestamped "[Backup] TGZ file: $script:TGZFile"
    # Check if the tgz file exists
    If( -Not (Test-Path $script:TGZFile)) {
        Write-Timestamped '[Backup] TGZ file not found'
        exit 1
    }
    Write-Timestamped '[Backup] Done'
}

<# Test connection to remote server #>
function Test-ConnectionToServer {
    param(
        # Remote server to copy the backup to
        [string]$BackupServer,
        # Port to use for the remote server connection (ssh)
        [int]$BackupServerPort
    )
    Write-Timestamped "[Copy] Testing connection to remote server ($($BackupServer):$BackupServerPort)"
    $TestConnection = Test-Connection -ComputerName $BackupServer -TcpPort $BackupServerPort -Count 1 -Quiet
    if ( $TestConnection -eq $True ) {
        Write-Timestamped "[Copy] Connection to $BackupServer port $BackupServerPort successful"
    } else {
        Write-Error "[Copy] Unable to connect to $BackupServer on port $BackupServerPort"
        exit 1
    }
}

<# Copy backup files to remote server #>
function Copy-BackupFilesToRemoteServer {
    param (
        # Credentials file with username and password for the remote server
        [string]$BackupCredentialsFile,
        # Remote server to copy the backup to
        [string]$BackupServer,
        # Port to use for the remote server connection (ssh)
        [int]$BackupServerPort,
        # Folder on the remote server to copy the backup to
        [string]$RemoteBackupFolder
    )
    Write-Timestamped '[Copy] Copying backup files to remote server'
    # Check if the backup credentials file exists
    If( -Not (Test-Path $BackupCredentialsFile)) {
        Write-Timestamped "ERROR: [Copy] Backup credentials file not found ($BackupCredentialsFile)"
        Write-Timestamped '[Copy] Please create the file with the following commands: '
        Write-Timestamped '    $Credentials = Get-Credential'
        Write-Timestamped '    $Credentials | Export-Clixml backupcreds.xml'
        exit 1
    }
    [PSCredential]$BackupCredentials = Import-Clixml $BackupCredentialsFile
    # Copy backup files to remote server
    [string]$BackupUser = $BackupCredentials.UserName
    Write-Timestamped "[Copy] scp -P $BackupServerPort $script:TGZFile $script:InfoFile $BackupUser@$($BackupServer):$RemoteBackupFolder"
    [string[]]$SCPConsole = & sshpass -p $BackupCredentials.GetNetworkCredential().password scp -P $BackupServerPort $script:TGZFile $script:InfoFile "$BackupUser@$($BackupServer):$RemoteBackupFolder" 2>> $script:LogFile
    if ( $SCPConsole.Count -gt 0 ) {
        Write-Timestamped 'ERROR: [Copy] Something went wrong with the SCP command'
        Write-Timestamped $SCPConsole
        exit 1
    }
}

# Check if the files were copied to the remote server
function Test-BackUpFilesCreated {
    param(
        # Credentials file with username and password for the remote server
        [string]$BackupCredentialsFile,
        # Remote server to copy the backup to
        [string]$BackupServer,
        # Port to use for the remote server connection (ssh)
        [int]$BackupServerPort,
        # Folder on the remote server to copy the backup to
        [string]$RemoteBackupFolder
    )
    Write-Timestamped '[Copy] Checking if the files were copied to the remote server: '
    [PSCredential]$BackupCredentials = Import-Clixml $BackupCredentialsFile
    [string]$BackupUser = $BackupCredentials.UserName
    Write-Timestamped "[Copy] ssh -p $BackupServerPort $BackupUser@$BackupServer ls -1t $RemoteBackupFolder | head -n 2"
    [string[]]$SSHConsole = & sshpass -p $BackupCredentials.GetNetworkCredential().password ssh -p $BackupServerPort $BackupUser@$BackupServer ls -1t $RemoteBackupFolder | head -n 2 2>> $script:LogFile
    if ( $SSHConsole.Count -lt 2 ) {
        Write-Timestamped 'ERROR: [Copy] Something went wrong with the SSH command'
        Write-Timestamped $SSHConsole
        exit 1
    } elseif( $SSHConsole -contains $script:TGZFileName -and $SSHConsole -contains $script:InfoFileName ) {
        Write-Timestamped '[Copy] Backup files were copied to the remote server'
    } else {
        Write-Timestamped '[Copy] Something went wrong, please check the return of the ls command on the target:'
        Write-Timestamped $SSHConsole
        exit 2
    }
    Write-Timestamped '[Copy] Done'
}

# Rotate local backups (remove old ones)
function Remove-LocalBackups {
    param(
        # Folder on the local server where the backups are stored
        [string]$LocalBackupFolder,
        # Number of backups to keep on the local server (0 to disable)
        [int]$NbLocalBackups
    )
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
}

# Load configuration file
Write-Timestamped "[Info] Loading configuration file: $ConfigFile"
if( -Not (Test-Path $ConfigFile ) ) {
    Write-Timestamped "[Error] Configuration file not found: $ConfigFile"
    exit 42
}
$Config = Get-Content $ConfigFile | ConvertFrom-Json
$Targets = $Config.Targets
Write-Timestamped "[Info] Found $($Targets.Count) targets in configuration file"

# Create new backup files
New-YounohostBackup

# Backup files to each target
foreach( $Target in $targets ){
    # Current target
    Write-Timestamped "[Info] Backing up to target: $($Target.BackupServer)"
    if( -Not $Target.enabled ) {
        Write-Timestamped "[Info] Target is disabled, skipping"
        continue
    }
    # Test connection to remote server
    Write-Timestamped "[Info] Testing connection to target: $($Target.BackupServer)"
    Test-ConnectionToServer `
        -BackupServer $Target.BackupServer `
        -BackupServerPort $Target.BackupServerPort
    # Copy files
    Write-Timestamped "[Info] Copying files to target: $($Target.BackupServer)"
    Copy-BackupFilesToRemoteServer `
        -BackupCredentialsFile $Target.BackupCredentialsFile `
        -BackupServer $Target.BackupServer `
        -BackupServerPort $Target.BackupServerPort `
        -RemoteBackupFolder $Target.RemoteBackupFolder
    # Check files copied to target
    Write-Timestamped "[Info] Checking files created on target: $($Target.BackupServer)"
    Test-BackUpFilesCreated `
        -BackupCredentialsFile $Target.BackupCredentialsFile `
        -BackupServer $Target.BackupServer `
        -BackupServerPort $Target.BackupServerPort `
        -RemoteBackupFolder $Target.RemoteBackupFolder
    Write-Timestamped "[Info] Done for target: $($Target.BackupServer)"
}

# Remove old local backups
Remove-LocalBackups -LocalBackupFolder '/home/yunohost.backup/archives' -NbLocalBackups $NbLocalBackups

Write-Timestamped 'Done'
exit 0