[CmdletBinding()]

Param(
    [Parameter(Mandatory=$true)]$dnsServer1,
    [Parameter(Mandatory=$true)]$dnsServer2
)

Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses ("$dnsServer1","$dnsServer2")

Set-NetFirewallProfile -Name Domain -Enabled False
Set-NetFirewallProfile -Name Public -Enabled False
Set-NetFirewallProfile -Name Private -Enabled False

Save-Module -Path "$env:ProgramFiles\WindowsPowerShell\Modules" -Name NanoServerPackage -MinimumVersion 1.0.0.0
Import-PackageProvider NanoServerPackage
Install-NanoServerPackage Microsoft-NanoServer-DSC-Package

Restart-Computer -Force

