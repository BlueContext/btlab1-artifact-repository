[CmdletBinding()]

Param(
    [Parameter(Mandatory=$true)]$domainName,
    [Parameter(Mandatory=$true)]$userName,
    [Parameter(Mandatory=$true)]$password
)

$targetNode = $env:COMPUTERNAME
$outputPath = "C:\DSC"

Import-Module PackageManagement
Import-Module PowerShellGet
Import-Module PSDesiredStateConfiguration
Import-Module ServerManager
Import-Module ServerCore

Set-PackageSource PSGallery

#install-package xDnsServer -Force
#Install-Package xActiveDirectory -Force

#Install-WindowsFeature AD-Domain-Services -Restart
#Install-WindowsFeature RSAT-ADDS -Restart
#Install-WindowsFeature RSAT-AD-PowerShell -Restart
#Install-WindowsFeature RSAT-ADDS-Tools -Restart

$pwrd = ConvertTo-SecureString -String $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($userName, $pwrd)

$cd = @{
    AllNodes = @(
        @{
            NodeName = $targetNode            
            #Role = "Primary DC"             
            DomainName = $domainName             
            RetryCount = 20              
            RetryIntervalSec = 30            
            PsDscAllowPlainTextPassword = $true
            PsDscAllowDomainUser = $true
         }
    )
}

. .\member-server-configuration.ps1
MemberServerConfiguration -targetNode $targetNode -domainCred $cred -ConfigurationData $cd -OutputPath $outputPath

Start-Sleep -s 60
Start-DscConfiguration -Path "C:\DSC\" -ComputerName $targetNode -Wait

