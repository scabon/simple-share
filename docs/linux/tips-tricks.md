# Linux Tips & Tricks

## OS

Find **Operating system** version using the command line (courtesy of [Cyberciti](https://www.cyberciti.biz/faq/how-to-check-os-version-in-linux-command-line/)):
`cat /etc/os-release`
Should output something like:

```bash
pi@raspberrypi:~ $ cat /etc/os-release
PRETTY_NAME="Raspbian GNU/Linux 10 (buster)"
NAME="Raspbian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
VERSION_CODENAME=buster
ID=raspbian
ID_LIKE=debian
HOME_URL="http://www.raspbian.org/"
SUPPORT_URL="http://www.raspbian.org/RaspbianForums"
BUG_REPORT_URL="http://www.raspbian.org/RaspbianBugs"
```

## MSSQL on WSL

Microsoft SQL Server updates will fail on WSL because `systemctl` is not available.

THe error logs are:

```bash
Preparing to unpack .../mssql-server_15.0.4249.2-1_amd64.deb ...
Unpacking mssql-server (15.0.4249.2-1) over (15.0.4198.2-10) ...
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
dpkg: warning: old mssql-server package post-removal script subprocess returned error exit status 1
dpkg: trying script from the new package instead ...
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
dpkg: error processing archive /var/cache/apt/archives/mssql-server_15.0.4249.2-1_amd64.deb (--unpack):
 new mssql-server package post-removal script subprocess returned error exit status 1
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
dpkg: error while cleaning up:
 new mssql-server package post-removal script subprocess returned error exit status 1
Errors were encountered while processing:
 /var/cache/apt/archives/mssql-server_15.0.4249.2-1_amd64.deb
E: Sub-process /usr/bin/dpkg returned an error code (1)
```

You can workarroud this by editing the post install script:
`/var/lib/dpkg/info/mssql-server.postrm`

> Just comment the following line: `systemctl daemon-reload`
