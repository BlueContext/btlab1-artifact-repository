[CmdletBinding()]

Param(
    [Parameter(Mandatory=$true)]$pointless
)

Import-Module PackageManagement
Import-Module PowerShellGet
Import-Module PSDesiredStateConfiguration
Import-Module ServerManager
#Install-PackageProvider Chocolatey -Force

Set-PackageSource PSGallery
Install-Package xStorage -Force
Install-Package xNetworking -Force
Install-Package xComputerManagement -Force
Install-Package xTimeZone -Force

#Set-DnsClientServerAddress -InterfaceIndex 5 -ServerAddresses ("10.56.10.6","10.71.15.100")

md c:\DSC
