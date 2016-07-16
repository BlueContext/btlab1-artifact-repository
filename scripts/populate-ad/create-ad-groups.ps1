param
(
    [string]$pointless = " "
)

# LOAD ASSEMBLIES AND MODULES
Try
{
  Import-Module ActiveDirectory -ErrorAction Stop
}
Catch
{
#  Write-Host "[ERROR]`t ActiveDirectory Module couldn't be loaded. Script will stop!"
  Exit 1
}

#STATIC VARIABLES

$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$newsvcpath = $path + "\csv_groups.csv"
$log      = $path + "\create_ad_groups.log"
$date     = Get-Date
$dnsroot  = (Get-ADDomain).DNSRoot
$i        = 1

#START FUNCTIONS

Function Start-Commands
{
  Create-AdGroups
}

Function Create-AdGroups 
{
  "Processing started (on " + $date + "): " | Out-File $log -append
  "--------------------------------------------" | Out-File $log -append
  Import-CSV $newsvcpath | ForEach-Object {
    If (($_.Implement.ToLower()) -eq "yes")
    {
      If (($_.Name -eq "") -Or ($_.SamAccountName -eq "") -or ($_.DisplayName -eq "") -or ($_.Description -eq ""))
      {
#        Write-Host "[ERROR]`t Please provide a valid Name, SamAccountName, DisplayName and Description. Processing skipped for line $($i)`r`n"
        "[ERROR]`t Please provide a valid Name, SamAccountName, DisplayName and Description Processing skipped for line $($i)`r`n" | Out-File $log -append
      }
      Else
      {
        # Set the Enabled and PasswordNeverExpires properties
        #If (($_.Enabled.ToLower()) -eq "true") { $enabled = $True } Else { $enabled = $False }
        #If (($_.PasswordNeverExpires.ToLower()) -eq "true") { $expires = $True } Else { $expires = $False }

        $sam = $_.SamAccountName
        Try   { $exists = Get-ADGroup -LDAPFilter "(sAMAccountName=$sam)" }
        Catch { }
        If(!$exists)
        {
          # Set all variables according to the table names in the Excel 
          # sheet / import CSV. The names can differ in every project, but 
          # if the names change, make sure to change it below as well.
          #$setpass = ConvertTo-SecureString -AsPlainText $_.Password -force

          Try
          {
#            Write-Host "[INFO]`t Creating group : $($sam)"
            "[INFO]`t Creating group: $($sam)" | Out-File $log -append
            New-ADGroup -Name $_.Name -SamAccountName $sam -GroupCategory $_.GroupCategory -GroupScope $_.GroupScope -DisplayName $_.DisplayName -Description $_.Description 

#            Write-Host "[INFO]`t Created new group : $($sam)"
            "[INFO]`t Created new group : $($sam)" | Out-File $log -append
          }
          Catch
          {
#            Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n"
          }
        }
        Else
        {
#          Write-Host "[SKIP]`t Group $($sam) already exists or returned an error!`r`n"
          "[SKIP]`t Group $($sam) already exists or returned an error!" | Out-File $log -append
        }
      }
    }
    Else
    {
#      Write-Host "[SKIP]`t Service Account $($_.Name) will be skipped for processing!`r`n"
      "[SKIP]`t Service Account $($_.Name) will be skipped for processing!" | Out-File $log -append
    }
    $i++
  }
  "--------------------------------------------" + "`r`n" | Out-File $log -append
}

#Write-Host "STARTED SCRIPT`r`n"
Start-Commands
#Write-Host "STOPPED SCRIPT"