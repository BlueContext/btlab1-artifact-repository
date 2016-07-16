#Downloads toe Windows Management Framework 5.0 installer for Windows Server 2012 R2/Win 8.1 and installs on the new machine

[CmdletBinding()]

Param(
    [Parameter(Mandatory=$true)]$accessKey
)

Set-ExecutionPolicy Bypass -Force

md C:\ArtifactLogs
$logString = @()
$logString += "AccessKey value is $accessKey"

$storageName = "labfileserver"
$storageRootAddress = "file.core.windows.net"
$shareName = "installers"
$subFolder = "wmf-5"
$fileName = "Win8.1AndW2K12R2-KB3134758-x64.msu"

#$shortPath = $storageName + "." + $storageRootAddress
#cmdkey /add:$shortPath /user:$storageName /pass:$accessKey

$path = "\\" + $storageName + "." + $storageRootAddress + "\" + $shareName 
net use m: $path /u:$storageName $accessKey


$check = Test-Path -Path M:\$subFolder

if($check -eq $true)
{
    cd M:\$subFolder
    wusa Win8.1AndW2K12R2-KB3134758-x64.msu /quiet /forcerestart | out-null
}

$logString | Out-File -FilePath C:\ArtifactLogs\Log.txt
Set-ExecutionPolicy RemoteSigned -Force