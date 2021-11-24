---
layout: post
title: ""
categories: powershell
thumbnail: "/images/thumb/th_lorem.png"
image: "/images/lorem.png"
author: "rpfilomeno"
comments: true
tags:
 - wls
 - troubleshooting
 - windows
---

If your WSL2 Linux is not port forwarding directly to Windows localhost address then use this Powershell script to manually set the ports you need exposed.

```powershell
# Port forwards from WSL virtual machine to Win10 host firewall
# Bind a specific host ip addr or use 0.0.0.0 default
# -- START CONFIGURATION ---------------------------------------
$ports=@(80,443,4000,8080);
$addr='0.0.0.0';
# -- STOP EDITING CONFIGURATION HERE ---------------------------

## Script will request change of execution policy to elavate it to Administrator
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

## ip -o -4 -f inet addr show eth0 | awk '{ split($4, ip_addr, "/"); print ip_addr[1]; }'
##   print out is "4:  eth0  inet  172.20.x.x/20  brd  ..." string
$remoteport = bash.exe -c "ip -o -4 -f inet addr show eth0";
$remoteport = ($remoteport -split "\s+")[3];
$remoteport = $remoteport.substring(0, $remoteport.LastIndexOf("/"));
$found      = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
if(!$found){
  echo "WSL ip address not found";
  exit;
}
echo "WSL ip address $remoteport";

# Remove firewall exception rules, add inbound and outbound rules
$ports_a = $ports -join ",";
echo "Firewall inbound/outbound rules";
iex "Remove-NetFireWallRule -DisplayName 'WSL Firewall Unlock' ";
iex "New-NetFireWallRule -DisplayName 'WSL Firewall Unlock' -Description 'Remote access to WSL services' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL Firewall Unlock' -Description 'Remote access to WSL services' -Direction Inbound  -LocalPort $ports_a -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  echo "portproxy ${addr}:${port} to ${remoteport}:${port}";
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr";
  iex "netsh interface portproxy add    v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport";
}
```