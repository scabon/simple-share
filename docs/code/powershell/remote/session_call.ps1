# When running in VSCode, the integrated powershell terminal does not load the powershell profile
# This can cause issues with the ssh-agent: run it manually in the VSCode terimnal console
[CmdletBinding()]
param()

# SSH Connection information : list of hashmaps
# Each hashmap contains: HostName, UserName, [Port], [KeyFilePath]
[System.Collections.Hashtable[]]$SSHConnection = @()
$SSHConnection += @{
    HostName = 'host1'
    UserName = 'userA'
}
$SSHConnection += @{
    HostName = 'host2'
    UserName = 'userB'
}

# Call main script
./session.ps1 `
    -HostName 'userC@host3', 'userN@hostX' `
    -SSHConnection $SSHConnection `
    -UpdateFilePath './update.ps1'
