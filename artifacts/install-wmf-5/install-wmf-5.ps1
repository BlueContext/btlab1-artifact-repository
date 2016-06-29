#Downloads toe Windows Management Framework 5.0 installer for Windows Server 2012 R2/Win 8.1 and installs on the new machine

[CmdletBinding()]

Param(
    [Parameter(Mandatory=$true)]$accessKey
)

Set-ExecutionPolicy Bypass -Force

$storageName = "labfilesstorage"
$storageRootAddress = "file.core.windows.net"
$shareName = "installers"
$subFolder = "wmf-5.0"
$fileName = "Win8.1AndW2K12R2-KB3134758-x64.msu"

$commandText = "cmdkey /add:" + $storageName + "." + $storageRootAddress + " /user:" + $storageName + " /pass:" + $accessKey
$command = [scriptblock]::create($commandText)
Invoke-Command -ScriptBlock $command 

$path = "\\" + $storageName + "." + $storageRootAddress + "\" + $shareName 
$commandText = "net use m: " + $path
$command = [scriptblock]::Create($commandText)
Invoke-Command -ScriptBlock $command 

$check = Test-Path -Path M:\$subFolder

if($check -eq $true)
{
    cd M:\$subFolder
    $commandText = "wusa " + $fileName + " /quiet /norestart | out-null"
    $command = [scriptblock]::create($commandText)
    Invoke-Command -ScriptBlock $command   
}

Set-ExecutionPolicy RemoteSigned -Force