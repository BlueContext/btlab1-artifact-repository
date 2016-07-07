#Configuration for a domain controller in a new domain and forest

configuration ADDCConfiguration
{
	param
	(
		[string]$targetNode,
        [Parameter(Mandatory)]
        [pscredential]$domainCred
	)

    Import-DscResource -ModuleName xTimeZone
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xDnsServer
    Import-DscResource -ModuleName PSDesiredStateConfiguration
	
	Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
	{
        LocalConfigurationManager            
        {
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }

        xTimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = "Central Standard Time"
        }
            
        File ADFiles
        {
            DestinationPath = 'C:\NTDS'
            Type = 'Directory'
            Ensure = 'Present'
        }

        xADDomain FirstDS
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $domainCred
            DatabasePath = 'C:\NTDS'
            LogPath = 'C:\NTDS'
            DependsOn = "[File]ADFiles"            
        }

        xDnsServerForwarder RemoveAllForwarders
        {
            IsSingleInstance = 'Yes'
            IPAddresses = @()
            DependsOn = "[xADDomain]FirstDS"
        }

        xDnsServerForwarder SetForwarders
        {
            IsSingleInstance = 'Yes'
            IPAddresses = '8.8.8.8','8.8.4.4'
            DependsOn = "[xDnsServerForwarder]RemoveAllForwarders"
        }
	}
}