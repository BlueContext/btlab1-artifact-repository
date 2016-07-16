[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]$Pointless
)

Set-ExecutionPolicy Unrestricted -Force

.\create-ad-groups.ps1 -Source "csv_groups.csv" -Wait
.\create-ad-svcaccts.ps1 -Source "csv_svcaccts.csv" -Wait
.\create-ad-users.ps1 -Source "csv_users.csv" -Wait

Set-ExecutionPolicy RemoteSigned -Force