configuration MemberFileServerConfiguration
{
	param
	(
		[string]$targetNode,
        [Parameter(Mandatory)]
        [pscredential]$domainCred
	)

    Import-DscResource -ModuleName xTimeZone
	#Import-DscResource -Module xNetworking
	Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xSmbShare
    Import-DscResource -Module xDFS
	
	node $targetNode
	{
#		xDNSServerAddress dnsServer
#		{
#			Address = $dnsServerAddress
#			AddressFamily = 'IPv4'
#			InterfaceAlias = 'Ethernet'
#		}

		xTimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = "Central Standard Time"
        }
		
		xComputer JoinComputer
		{
			Name = $targetNode
			DomainName =$domainName
			Credential = $Credential
		}

        #File Server Config
		WindowsFeature File-Services
        {
            Ensure = "Present"
            Name = "File-Services"
        }
        
        WindowsFeature FS-FileServer
        {
            Ensure = "Present"
            Name = "FS-FileServer"    
        }
        
        WindowsFeature FS-DFS-Namespace
        {
            Ensure = "Present"
            Name = "FS-DFS-Namespace"
        }
        
        WindowsFeature FS-DFS-Replication
        {
            Ensure = "Present"
            Name = "FS-DFS-Replication"
        }
        
        WindowsFeature FS-Resource-Manager
        {
            Ensure = "Present"
            Name = "FS-Resource-Manager"
        }
        
        WindowsFeature RSAT-File-Services
        {
            Ensure = "Present"
            Name = "RSAT-File-Services"
        }
        
        WindowsFeature RSAT-DFS-Mgmt-Con
        {
            Ensure = "Present"
            Name = "RSAT-DFS-Mgmt-Con"
        }
        
        WindowsFeature RSAT-FSRM-Mgmt
        {
            Ensure = "Present"
            Name = "RSAT-FSRM-Mgmt"
        }
        
        WindowsFeature RSAT-CoreFile-Mgmt
        {
            Ensure = "Present"
            Name = "RSAT-CoreFile-Mgmt"
        }

                File BizTalk
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares"    
        }
        
        File BizTalk_Apps
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares\BizTalk"
            DependsOn = "[File]BizTalk"
        }
        
        File BizTalk_Apps_ETC.QPTM.ScheduleVolume.BizTalk 
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares\BizTalk\ETC.QPTM.ScheduleVolume.BizTalk"
            DependsOn = "[File]BizTalk_Apps"
        }
        
        File BizTalk_Apps_ETC.QPTM.ScheduleVolume.BizTalk_Inboxes
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares\BizTalk\ETC.QPTM.ScheduleVolume.BizTalk\Inboxes"
            DependsOn = "[File]BizTalk_Apps_ETC.QPTM.ScheduleVolume.BizTalk"
        }
        
#        File BizTalk_Apps_ETC.QPTM.ScheduleVolume.BizTalk_Inboxes_QPTM_ScheduledVolume_28
#        {
#            Ensure = "Present"
#            Type = "Directory"
#            DestinationPath = "C:\FileShares\BizTalk\ETC.QPTM.ScheduleVolume.BizTalk\Inboxes"
#            DependsOn = "[File]BizTalk_Apps_ETC.QPTM.ScheduleVolume.BizTalk"
#        }
        
        File BizTalk_Apps_Lonestar.Tank.TFX.Biztalk 
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares\BizTalk\Lonestar.Tank.TFX.Biztalk"
            DependsOn = "[File]BizTalk_Apps"
        }
        
        File BizTalk_Apps_Lonestar.Reconciliation.Biztalk 
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares\BizTalk\Lonestar.Reconciliation.Biztalk"
            DependsOn = "[File]BizTalk_Apps"
        }
        
        File BizTalk_Apps_LoneStar.Dearman.TruckTickets.BizTalk 
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares\BizTalk\LoneStar.Dearman.TruckTickets.BizTalk"
            DependsOn = "[File]BizTalk_Apps"
        }
        
        File BizTalk_Apps_Lonestar.Flowcal.Entero.Biztalk
        {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\FileShares\BizTalk\Lonestar.Flowcal.Entero.Biztalk"
            DependsOn = "[File]BizTalk_Apps"
        }

        #DFS Namespace Configuration
        

	}
}



