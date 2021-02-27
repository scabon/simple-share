<#
    It is recommended to load the ssh keys using ssh-agent to avoid passphrase prompt for all hosts
    For example:  
    ssh-add "C:\Users\derze\.ssh\id_rsa"
#>

[CmdletBinding()]
param(
    # Host name(s) to connect to (so 'user@hostname') - you can also use SSHConnection
    [string[]]$HostName,
    # SSH Connection(s) information (hashmaps with HostName, Port, UserName, KeyFilePath)- you can also use Hostname
    [System.Collections.Hashtable[]]$SSHConnection,
    # Script to run on remotes
    [Parameter(Mandatory=$true)]
    [string]$UpdateFilePath
)

if( -Not (Test-Path $UpdateFilePath) ) {
    Write-Error "Invalid path to update file: $UpdateFilePath"
    Exit 1
}

# Run script for session
Function RunForSession {
    param(
        # Remote PS Session
        [System.Management.Automation.Runspaces.PSSession]$Session,
        # Hostname
        [string]$CurrentHost
    )
    if ( -not ( "Opened" -ieq $Session.State ) ) {
        Write-Error "Session could not be Opened on host $CurrentHost"
        Exit 1
    } else {
        Write-Debug "Running script $UpdateFilePath on Session $($Session.Name) for host $CurrentHost"
        Invoke-Command -Session $Session -FilePath $UpdateFilePath
        Write-Debug "Closing PSSession $($Session.Name) to host $CurrentHost"
        Remove-PSSession -Session $Session
    }
}

# Run for sessions if any
if( -Not $null -eq $SSHConnection ) {
    Write-Debug "Connecting using SSHConnection parameter"
    foreach ($SSHC in $SSHConnection) {
        $Session = New-PSSession -SSHConnection $SSHC
        RunForSession -Session $Session -CurrentHost $SSHC.Hostname   
    }
}

# Run for hosts if any
if ( -Not $null -eq $HostName ) {
    Write-Debug "Connecting using Hostname parameter"
    foreach( $CurrentHost in $HostName ) {
        Write-Debug "Running: New-PSSession -HostName $CurrentHost"
        $Session = New-PSSession -HostName $CurrentHost
        RunForSession -Session $Session -CurrentHost $CurrentHost
    }
}