[CmdletBinding()]
param()

# Running Linux updates
Function LinuxUpdates() {
    Write-Debug "Updating"
    sudo apt-get update
    Write-Debug "Upgrading"
    sudo apt-get upgrade --assume-yes
    Write-Debug "Autoremoving"
    sudo apt-get autoremove --assume-yes
}

# Running Windows Updates
Function WindowsUpdates() {
    Import-Module PSWindowsUpdate
    if ( (Get-Module PSWindowsUpdate).Count -gt 0) {
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll
    } else {
        Write-Host "Module required to install updates not installed (PSWindowsUpdate)"
    }
}

[String]$SystemHost = [System.Net.Dns]::GetHostName()
Write-Host "Current system: $SystemHost"
Write-Debug "Starting updates script"
if( $IsLinux ) {
    Write-Debug "Running Linux Updates"
    LinuxUpdates
} elseif ( $IsWindows ) {
    Write-Debug "Running Windows Updates"
    WindowsUpdates
}
Write-Host "Done updating $SystemHost"
Write-Host ""