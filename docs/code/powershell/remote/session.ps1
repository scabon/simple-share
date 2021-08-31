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
    [string]$UpdateFilePath,
    # Try to wake up host
    [switch]$Wake
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

# Test connection to host & try to wake up if option is set
function Test-ConnectionAndWake {
    param(
         # Hostname
         [string]$CurrentHost
    )
    [string]$HostName
    # If the Current host contains an @, extract trailing chararacters as hostname
    if( $CurrentHost.Contains("@")) {
        $HostName = $CurrentHost.Substring( $CurrentHost.LastIndexOf('@') )
    } else {
        $HostName = $CurrentHost
    }
    # Should be [TestNetConnectionResult]$ConnectionResult, but gives the following error:
    # Unable to find type [TestNetConnectionResult]
    $ConnectionResult = Test-NetConnection -ComputerName $HostName -Port 22
    if ( -not ( $true -eq $ConnectionResult.TcpTestSucceeded ) ) {
        if( $wake ) {
            [string]$IPAddress = $ConnectionResult.RemoteAddress
            [string[]]$MacInfo = & arp -a $IPAddress
            Write-Debug "Mac info: $MacInfo"
            if( "No ARP Entries Found." -eq $MacInfo[0] ) {
                Write-Debug "Could not wake up host $Hostname, MAC Address not known in ARP table"
            } else {
                # Extract MAC Address
                [string]$MacAddr
                foreach ($MacI in $MacInfo) {
                    [string]$Line = $MacInfo -match '([a-fA-F0-9]{2}-){5}[a-fA-F0-9]{2}'
                    if ( -not ( $null -eq $Line ) ) {
                        $MacAddr = $Matches[0]
                        Write-Debug "Found MAC: $MacAddr"
                    }
                }
                if ( -Not ( $null -eq $MacAddr ) ) {
                    # Send magic packet
                    # Courtesy of: https://www.pdq.com/blog/wake-on-lan-wol-magic-packet-powershell/
                    [Byte[]]$MacByteArray = $MacAddr -split "-" | ForEach-Object { [Byte] "0x$_"}
                    [Byte[]]$MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)
                    $UdpClient = New-Object System.Net.Sockets.UdpClient
                    $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),7)
                    $UdpClient.Send($MagicPacket,$MagicPacket.Length)
                    $UdpClient.Close()
                }
            }
        }
    } else {
        Write-Debug "Connection to $Hostname succeeded"
    }
}

# Run for sessions if any
if( -Not $null -eq $SSHConnection ) {
    Write-Debug "Connecting using SSHConnection parameter"
    foreach ($SSHC in $SSHConnection) {
        Test-ConnectionAndWake -CurrentHost $SSHC.Hostname
        Write-Debug "Running: New-PSSession -SSHConnection $($SSHC.Hostname)"
        $Session = New-PSSession -SSHConnection $SSHC
        RunForSession -Session $Session -CurrentHost $SSHC.Hostname   
    }
}

# Run for hosts if any
if ( -Not $null -eq $HostName ) {
    Write-Debug "Connecting using Hostname parameter"
    foreach( $CurrentHost in $HostName ) {
        Test-ConnectionAndWake -CurrentHost $CurrentHost
        Write-Debug "Running: New-PSSession -HostName $CurrentHost"
        $Session = New-PSSession -HostName $CurrentHost
        RunForSession -Session $Session -CurrentHost $CurrentHost
    }
}