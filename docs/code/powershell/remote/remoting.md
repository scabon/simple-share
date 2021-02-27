# PowerhShell Remoting

## Example / Sample code

Here is some sample code to use powershell & remoting to update target systems (Windows or Linux) using ssh:  

* [session.ps1](./session.ps1): create a session to a list of targets & runs an update script
* [session_call.ps1](./session_call.ps1): calls the `session` script with a list of hosts
* [update.ps1](./update.ps1): updates the hosts (Windows or Linux)
  * Requires a Powershell module for Windows hosts

## Via SSH

Follow [this guide](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-7.1#:~:text=SSH%20remoting%20lets%20you%20do%20basic%20PowerShell%20session,to%20WinRM,%20to%20support%20endpoint%20configuration%20and%20JEA.) to setup powershell remoting via SSH.

### Windows Host

The guide above seems incomplete for a Windows host (see [stackoverflow](https://superuser.com/questions/1445976/windows-ssh-server-refuses-key-based-authentication-from-client)).  
Edit the `%ProgramData%/ssh/sshd_config` file:  

* Allow authentication using keys: `PubkeyAuthentication yes`
* Allow password authentication: `PasswordAuthentication yes`
* Comment the following lines:  

    ```txt
    #Match Group administrators
    #       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
    ```

> Note: this is not recommended for a production environment (at home should be fine)  
> Don't forget to restart the sshd server: `Restart-Service sshd`  

You should now be able to connect to your Windows server, here with an msn account:  
`ssh jdoe@msn.com@192.168.0.99`  

### SSH Troubleshooting

#### unable to start ssh-agent service, error :1058

When trying to run `ssh-agent`, if you have:  
`unable to start ssh-agent service, error :1058`  
Run the following PoserShell as an Administrator:  
`Set-Service ssh-agent -StartupType Manual`  
You should then be able to start `ssh-agent` without error.  

#### warning: agent returned different signature type ssh-rsa (expected rsa-sha2-512)

The error belows seems to be bug in the ssh client released as a Windows feature (see [here](https://github.com/PowerShell/Win32-OpenSSH/issues/1551)).  
`warning: agent returned different signature type ssh-rsa (expected rsa-sha2-512)`  

Here is a fix from the thread:  

```bash
ssh-keygen -t ed25519 -a 100
ssh-add [path/to/id_ed25519]
```

#### The SSH client session has ended with error message: subsystem request failed on channel 0

If you get the following error:  
`New-PSSession: [someserver] The background process reported an error with the following message: The SSH client session has ended with error message: subsystem request failed on channel 0.`

It's because powershell remoting has not been setup correclty (assuming powershell is installed in the target system).  
You need somthing like this in the `/etc/ssh/sshd_config` file in the **subsystem** section:  
`Subsystem powershell /usr/bin/pwsh -sshs -NoLogo`  
But powershell is not always installed there (when installed as a dotnet global tool for instance).  
In my case, the correct value is:  
`Subsystem powershell /home/debian/.dotnet/tools/pwsh -sshs -NoLogo`  

> Don't forget to **restart** the SSH service after making the changes:  
> `sudo service ssh restart`  
