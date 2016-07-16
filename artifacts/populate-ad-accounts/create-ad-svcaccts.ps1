param
(
    [string]$Source
)

# LOAD ASSEMBLIES AND MODULES
Try
{
  Import-Module ActiveDirectory -ErrorAction Stop
}
Catch
{
  Write-Host "[ERROR]`t ActiveDirectory Module couldn't be loaded. Script will stop!"
  Exit 1
}

#STATIC VARIABLES
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$newsvcpath = $path + "\csv_svcaccts.csv"
$log      = $path + "\create_ad_svcaccts.log"
$date     = Get-Date
#$addn     = (Get-ADDomain).DistinguishedName
$dnsroot  = (Get-ADDomain).DNSRoot
$i        = 1

#START FUNCTIONS
Function Start-Commands
{
  Create-ServiceAccounts
}

Function Create-ServiceAccounts 
{
  "Processing started (on " + $date + "): " | Out-File $log -append
  "--------------------------------------------" | Out-File $log -append
  Import-CSV $newsvcpath | ForEach-Object {
    If (($_.Implement.ToLower()) -eq "yes")
    {
      If (($_.GivenName -eq "") -Or ($_.LastName -eq ""))
      {
#        Write-Host "[ERROR]`t Please provide valid GivenName, LastName and Initials. Processing skipped for line $($i)`r`n"
        "[ERROR]`t Please provide valid GivenName, LastName and Initials. Processing skipped for line $($i)`r`n" | Out-File $log -append
      }
      Else
      {
        # Set the Enabled and PasswordNeverExpires properties
        If (($_.Enabled.ToLower()) -eq "true") { $enabled = $True } Else { $enabled = $False }
        If (($_.PasswordNeverExpires.ToLower()) -eq "true") { $expires = $True } Else { $expires = $False }

        $sam = $_.SamAccountName
        Try   { $exists = Get-ADUser -LDAPFilter "(sAMAccountName=$sam)" }
        Catch { }
        If(!$exists)
        {
          # Set all variables according to the table names in the Excel 
          # sheet / import CSV. The names can differ in every project, but 
          # if the names change, make sure to change it below as well.
          $setpass = ConvertTo-SecureString -AsPlainText $_.Password -force

          Try
          {
#            Write-Host "[INFO]`t Creating service account : $($sam)"
            "[INFO]`t Creating service account : $($sam)" | Out-File $log -append
            New-ADUser $sam -GivenName $_.GivenName -Surname $_.LastName -DisplayName ($_.LastName + "," + " " + $_.GivenName) -Description $_.Description `
            -UserPrincipalName ($sam + "@" + $dnsroot) -AccountPassword $setpass  -Enabled $enabled -PasswordNeverExpires $expires
#            Write-Host "[INFO]`t Created new service account : $($sam)"
            "[INFO]`t Created new service account : $($sam)" | Out-File $log -append
     
            #$dn = (Get-ADUser $sam).DistinguishedName
       
            # Move the user to the OU ($location) you set above. If you don't
            # want to move the user(s) and just create them in the global Users
            # OU, comment the string below
            #If ([adsi]::Exists("LDAP://$($location)"))
            #{
            #  Move-ADObject -Identity $dn -TargetPath $location
            #  Write-Host "[INFO]`t User $sam moved to target OU : $($location)"
            #  "[INFO]`t User $sam moved to target OU : $($location)" | Out-File $log -append
            #}
            #Else
            #{
            #  Write-Host "[ERROR]`t Targeted OU couldn't be found. Newly created user wasn't moved!"
            #  "[ERROR]`t Targeted OU couldn't be found. Newly created user wasn't moved!" | Out-File $log -append
            #}
          }
          Catch
          {
#            Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n"
          }
        }
        Else
        {
#          Write-Host "[SKIP]`t Service Account $($sam) ($($_.GivenName) $($_.LastName)) already exists or returned an error!`r`n"
          "[SKIP]`t Service Account $($sam) ($($_.GivenName) $($_.LastName)) already exists or returned an error!" | Out-File $log -append
        }
      }
    }
    Else
    {
#      Write-Host "[SKIP]`t Service Account ($($_.GivenName) $($_.LastName)) will be skipped for processing!`r`n"
      "[SKIP]`t Service Account ($($_.GivenName) $($_.LastName)) will be skipped for processing!" | Out-File $log -append
    }
    $i++
  }
  "--------------------------------------------" + "`r`n" | Out-File $log -append
}

#Write-Host "STARTED SCRIPT`r`n"
Start-Commands
#Write-Host "STOPPED SCRIPT"