param
(
    [string]$pointless = " "
)

# MODULES
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
$newpath  = $path + "\csv_users.csv"
$log      = $path + "\create_ad_users.log"
$date     = Get-Date
$addn     = (Get-ADDomain).DistinguishedName
$dnsroot  = (Get-ADDomain).DNSRoot
$i        = 1

#START FUNCTIONS
Function Start-Commands
{
  Create-Users
}

Function Create-Users
{
  "Processing started (on " + $date + "): " | Out-File $log -append
  "--------------------------------------------" | Out-File $log -append
  Import-CSV $newpath | ForEach-Object {
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
        If (($_.DomainAdmin.ToLower()) -eq "true") { $domainAdmin = $True} Else {$domainAdmin = $False}

        $replace = $_.Lastname.Replace(".","")
        $lastname = $replace
        # Create sAMAccountName according to this 'naming convention':
        # <FirstLetterInitials><LastName> 
        $sam = $_.GivenName.substring(0,1).ToLower() + $lastname.ToLower()
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
#            Write-Host "[INFO]`t Creating user : $($sam)"
            "[INFO]`t Creating user : $($sam)" | Out-File $log -append
            New-ADUser $sam -GivenName $_.GivenName `
            -Surname $_.LastName -DisplayName ($_.LastName + "," + " " + $_.GivenName) `
            -Description $_.Description -EmailAddress $_.Mail `
            -UserPrincipalName ($sam + "@" + $dnsroot) `
            -AccountPassword $setpass  `
            -Enabled $enabled -PasswordNeverExpires $expires
#            Write-Host "[INFO]`t Created new user : $($sam)"
            "[INFO]`t Created new user : $($sam)" | Out-File $log -append
       
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
       
            # Rename the object to a good looking name (otherwise you see
            # the 'ugly' shortened sAMAccountNames as a name in AD. This
            # can't be set right away (as sAMAccountName) due to the 20
            # character restriction
            $newdn = (Get-ADUser $sam).DistinguishedName
            Rename-ADObject -Identity $newdn -NewName ($_.GivenName + " " + $_.LastName)
#            Write-Host "[INFO]`t Renamed $($sam) to $($_.GivenName) $($_.LastName)`r`n"
            "[INFO]`t Renamed $($sam) to $($_.GivenName) $($_.LastName)`r`n" | Out-File $log -append
            #Add-AdGroupMember -Identity Administrators -Members $sam
            If($domainAdmin -eq $True)
            {
                Add-DomainAdmin -sam $sam
            }
            
          }
          Catch
          {
#            Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n"
          }
        }
        Else
        {
#          Write-Host "[SKIP]`t User $($sam) ($($_.GivenName) $($_.LastName)) already exists or returned an error!`r`n"
          "[SKIP]`t User $($sam) ($($_.GivenName) $($_.LastName)) already exists or returned an error!" | Out-File $log -append
        }
      }
    }
    Else
    {
#      Write-Host "[SKIP]`t User ($($_.GivenName) $($_.LastName)) will be skipped for processing!`r`n"
      "[SKIP]`t User ($($_.GivenName) $($_.LastName)) will be skipped for processing!" | Out-File $log -append
    }
    $i++
  }
  "--------------------------------------------" + "`r`n" | Out-File $log -append
}



Function Add-DomainAdmin
{
    param
    (
            [string]$sam
    )
    
    Add-AdGroupMember -Identity "Domain Admins" -Member $sam
}

#Write-Host "STARTED SCRIPT`r`n"
Start-Commands
#Write-Host "STOPPED SCRIPT"  