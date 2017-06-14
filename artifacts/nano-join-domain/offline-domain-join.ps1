[CmdletBinding()]

Param(
    [Parameter(Mandatory=$true)]$blobPath
)

$check = Test-Path -Path $blobPath

if($check -eq $true)
{
    djoin.exe /requestodj /loadfile $blobPath /windowspath $env:SystemRoot /localos
}

Start-sleep -s 30

Restart-Computer -Force