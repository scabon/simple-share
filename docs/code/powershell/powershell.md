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

It's not as short as a simple `sudo`, so I like to add an Alias in  my PowerShell profile. For example:  

```powershell
# Add Sudo Alias to launch new PowerShell console as admin
Function SudoPosh {
    Start-Process powershell -Verb runAs
}
Set-Alias sudo SudoPosh
```

## Remoting

Examples of PowerShell remoting [here](./remote/remoting.md).  
