# Powershell

## Params

If always forget the name of the `CmdletBinding` attribute that is to be placed before the parameters to support standard parameters like `-Debug`.  
Here is an example:  

```powershell
[CmdletBinding()]
param(
    # Computer name to connect to
    [string[]]$ComputerName = "debian"
)
```

> See the [official documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-7.1)  

## Sudo

There no `sudo` in PowerShell, but you can start a new PowerShell console as an administrator using:  
`Start-Process powershell -Verb runAs`  

> See the [official documentation](https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Management/Start-Process?view=powershell-7.1#example-5--start-powershell-as-an-administrator)  

`Start-Process powershell -Verb runAs` might launch the wrong (older) powershell version on your system.  
You can use an explicit path instead:  
`Start-Process -FilePath 'C:\Program Files\PowerShell\7\pwsh.exe' -Verb runAs`  

It's not as short or as a simple `sudo`, so I like to add an **Alias** in my PowerShell profile. For example:  

```powershell
# Add Sudo Alias to launch new PowerShell console as admin
Function SudoPosh {
    param(
        # Command to launch
        [string]$Command
    )
    [string]$ArgsList = "-NoExit"
    if( $Command.Length -gt 0 ) {
        $ArgsList += " -Command $Command"
    }
    Write-Host "Launching: Start-Process -FilePath 'C:\Program Files\PowerShell\7\pwsh.exe' -Verb runAs -ArgumentList $ArgsList"
    Start-Process -FilePath 'C:\Program Files\PowerShell\7\pwsh.exe' -Verb runAs -ArgumentList $ArgsList
}
Set-Alias sudo SudoPosh
```

> This will open a PowerShell console as an administrator and launch the a simple command if any
> For instance `sudo Get-Process`; but is will **not** work for more complex entries like `sudo get-process *java*`  
> For complex commands, just run `sudo` and then type your posh commands  
> The terminal will not be closed after running (`-NoExit` option)

## Remoting

Examples of PowerShell remoting [here](./remote/remoting.md).  
