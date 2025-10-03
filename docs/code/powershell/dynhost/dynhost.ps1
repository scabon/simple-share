<#
.SYNOPSIS
Update OVH DynHost record with current public IP address.
Clone of: https://github.com/yjajkiew/dynhost-ovh
#>

$HOSTNAME='sub.domain.org'
$LOGIN='someuser'
$PASSWORD='mysecretpassword'
# Can be anohter OVH DNS server, e.g. dns102.ovh.net
$DNSSERVER='dns100.ovh.net'

# Check public IP for host
Write-Host "Checking current IP for $HOSTNAME using DNS server $DNSSERVER"
$output = nslookup $HOSTNAME $DNSSERVER
$ipv4 = ($output -split "\n" | Where-Object { $_ -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b" }) -replace "Address: ", ""
$ipv4
Write-Host "Host IP in DNS is $ipv4"

# Get current public IP
$CurrentIp = (Invoke-RestMethod -Uri "https://ipinfo.io/ip").Trim()
Write-Host "Current public IP is $CurrentIp"

if ($ipv4 -eq $CurrentIp) {
    Write-Host "No update needed"
    exit 0
} else {
    Write-Host "IP has changed, updating DNS record"
    $url = "https://www.ovh.com/nic/update?system=dyndns&hostname=$HOSTNAME&myip=$CurrentIp"
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$LOGIN`:$PASSWORD"))
    $headers = @{Authorization = "Basic $base64AuthInfo"}
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    Write-Host "Response from OVH: $response"
    if ($response -match "good|nochg") {
        Write-Host "Update successful"
        exit 0
    } else {
        Write-Host "Update failed"
        exit 1
    }
}
