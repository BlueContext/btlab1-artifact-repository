[CmdletBinding()]

Param(
    [Parameter(Mandatory=$true)]$domainName,
    [Parameter(Mandatory=$true)]$machineName,
#    [Parameter(Mandatory=$true)]$machineIp,
    [Parameter(Mandatory=$true)]$outputPath
)

$outputFileName = "odjblob_" + $machineName

$check = Test-Path -Path $outputPath

if($check -eq $true)
{
    $fullPath = $outputPath + "\" + $outputFileName
    djoin.exe /provision /domain $domainName /machine $machineName /saveFile $fullPath
}
