# Windows

## WSL

### Configuration

The WSL configuration can be set using a file in your home directory: `.wslconfig`.
For example:

```txt
[wsl2]
memory=2GB # Limits VM memory in WSL 2 to 2 GB
processors=4 # Makes the WSL 2 VM use 4 virtual processors
```

## Remote desktop with Microsoft account

To be able to use remote desktop with a Microsoft account, see [here](https://cmdrkeene.com/remote-desktop-with-microsoft-account-sign-in/).

Or in short, launch:

 ```cmd
runas /u:MicrosoftAccount\username@example.com winver
```
