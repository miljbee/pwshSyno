# pwshSyno
powershell module to interact with your Synology NAS via webapi

```
PS XX> Import-Module ./syno.psm1
PS XX> $bu = 'http://mySyno:5000'
PS XX> $cred = get-credential
PS XX> $sid = Get-SynoSid -baseUrl $bu -cred $cred
PS XX> Get-SynoResUsage -sid $sid -baseUrl $bu | % cpu

15min_load  : 153
1min_load   : 134
5min_load   : 169
device      : System
other_load  : 8
system_load : 4
user_load   : 6

PS XX> Set-SynoLedBrightness -sid $sid -baseUrl $bu -brightness 3

api                               method success version
---                               ------ ------- -------
SYNO.Core.Hardware.Led.Brightness set       True       1
SYNO.Core.Hardware.Led.Brightness get       True       1

PS XX> Revoke-SynoId -baseUrl $bu -sid $sid

success
-------
   True
```
