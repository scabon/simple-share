# When running in VSCode, the integrated powershell terminal does not load the powershell profile
# This can cause issues with the ssh-agent: run it manually in the VSCode terimnal console
[CmdletBinding()]
param()

# SSH Connection information : list of hashmaps
# Each hashmap contains: HostName, UserName, [Port], [KeyFilePath]
[System.Collections.Hashtable[]]$SSHConnection = @()
$SSHConnection += @{
    HostName = 'DESKTOP-NXI'
    UserName = 'derzeppel@msn.com'
}
$SSHConnection += @{
    HostName = '192.168.0.19'
    UserName = 'derzeppel'
}

# Call main script
./session.ps1 `
    -HostName 'debian@ns330150.ip-5-196-66.eu', 'pi@raspberrypi' `
    -SSHConnection $SSHConnection `
    -UpdateFilePath './update.ps1' `
    -Wake
# WSL 'zeppel@127.0.0.1'
