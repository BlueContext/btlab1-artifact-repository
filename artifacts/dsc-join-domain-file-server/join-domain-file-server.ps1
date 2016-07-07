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
Install-Package xSmbShare -Force
Install-Module xSmbShare
Install-Package xDFS -MinimumVersion 3.0.0.0 -Force
Install-Module xDFS

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

. .\member-file-server-configuration.ps1
MemberFileServerConfiguration -targetNode $targetNode -domainCred $cred -ConfigurationData $cd -OutputPath $outputPath

Start-Sleep -s 60
Start-DscConfiguration -Path "C:\DSC\" -ComputerName $targetNode -Wait

