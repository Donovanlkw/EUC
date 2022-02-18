#----- Declare variables -----#
$DomainName= "lab.local"
$DomaninNetBIOSName= "LAB"
$DomainDN="DC=LAB,DC=local"
$DomainAdmin = "Administrator"
$SQLServer="SCCMSQL"
$SQLServerName =  "SCCMSQL.lab.local"
$WSUSServerName = "WSUS.lab.local"
$SCCMServerName =  "SCCMMEM.lab.local"
$SDKServerName =  "SCCMMEM.lab.local"

$Sitecode = "HQ1"
$SqlServiceAccountName= "svc-sql-01$"

# for Client Push, required local admin of SCCM and SQL. , local admin of desktop?
$SCCMServiceAccountName= "svc-sccm-01$"


#----- Init -----#
CD "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\"
Import-Module .\ConfigurationManager.psd1
cd $sitecode':'
Get-CMSite  
Get-CMManagementPoint
Get-CMDistributionPoint
Get-CMSoftwareUpdate -Fast

#----- Prerequisite  for SCCM/MEM -----#
Install-windowsfeature NET-Framework-Features -IncludeAllSubFeature
Install-windowsfeature BITS -IncludeAllSubFeature
Install-windowsfeature Web-WMI -IncludeAllSubFeature
Install-windowsfeature RDC -IncludeAllSubFeature
Install-windowsfeature WDS -IncludeAllSubFeature
Install-windowsfeature UpdateServices-RSAT -IncludeAllSubFeature

#----- windows requirement, ADK 
.\adksetup.exe /features OptionId.ApplicationCompatibilityToolkit OptionId.DeploymentTools OptionId.ICDConfigurationDesigner OptionId.UserStateMigrationTool OptionId.WindowsPerformanceToolkit  OptionId.VolumeActivationManagementTool  OptionId.UEVTools OptionId.AppmanSequencer OptionId.IpOverUsb  /installpath "C:\Program Files (x86)\Windows Kits\10" /quiet

#----- Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10
.\adkwinpesetup.exe /features OptionId.WindowsPreinstallationEnvironment  /installpath "C:\Program Files (x86)\Windows Kits\10" /quiet

#----- Run Prerequisite Checker from a command prompt to use options
#----- <Configuration Manager installation media>\SMSSETUP\BIN\X64
./SMSSETUP\BIN\X64\prereqchk.exe /PRI /SQL $sqlserverName /sdk $sdkserverName



#----- Add Account
$Secure = ConvertTo-SecureString -String "Password1" -AsPlainText -Force
New-CMAccount -Name "$env:USERDOMAIN\$SCCMServiceAccountName"  -Password $secure -SiteCode $sitecode

#----- Add Administrative Account
New-CMAdministrativeUser -Name "LAB\CMS-Fulladmin" -RoleName "Full Administrator"
#New-CMAdministrativeUser -Name "LAB\CMS-SUMAdmin" -RoleName "Software Update Manager"







#----- Get and install SCCM update -----#
Invoke-CMSiteUpdateCheck
$update = Get-cmsiteupdate |select name
$update.name  |foreach {
Write-Output $_
Write-Output $patch
$patch = Get-CMSiteUpdate -Name "$_" -Fast
$patch| Invoke-CMSiteUpdateDownload
$patch| Invoke-CMSiteUpdatePrerequisiteCheck 
$patch| Install-CMSiteUpdate -SkipPrerequisiteCheck -Force
}


#----- Site Role configuration
#----- Add Fallback server point 
Add-CMFallbackStatusPoint -sitecode $sitecode -SiteSystemServerName $WSUSServerName

#----- Add reporting server point 
Add-CMReportingServicePoint -sitecode $sitecode -SiteSystemServerName $SQLServerName -UserName "$env:USERDOMAIN\$DomainAdmin"

#----- Add Software Update Point  & configure for download patching
New-CMSiteSystemServer -SiteCode $SiteCode -SiteSystemServerName $WSUSServerName 
Add-CMSoftwareUpdatePoint -sitecode $sitecode -SiteSystemServerName $WSUSServerName  
Set-CMSoftwareUpdatePoint -SiteCode $sitecode -SiteSystemServerName $WSUSServerName -HttpPort "8530" -HttpsPort "8531"

# Create new sync schedule
$supSchedule = New-CMSchedule  -Start 0:00:00 -RecurInterval Days -RecurCount 7

# Remove all default languages except english
$removeLang = @(
 'French',
 'German',
 'Chinese (Simplified, PRC)',
 'Russian',
 'Japanese'
)

# You may want to keep some or add some default values
$supParameters = @{
 'SiteCode' = $SiteCode;
 'RemoveLanguageUpdateFile' = $removeLang;
 'RemoveLanguageSummaryDetail' = $removeLang;
 'ImmediatelyExpireSupersedence' = $true;
 'EnableCallWsusCleanupWizard' = $true;
 'Schedule' = $supSchedule;
 'RemoveProductFamily' = @('Windows');
 'AddUpdateClassification' = 'Critical Updates';
 }

Set-CMSoftwareUpdatePointComponent @supParameters
Set-CMSoftwareUpdatePointComponent -SiteCode $SiteCode -AddProduct 'Windows 10'
Sync-CMSoftwareUpdate -FullSync $true
Get-CMSoftwareUpdateSyncStatus

cd "C:\Program Files\Microsoft Configuration Manager\bin\x64"
./rolesetup.exe /install /siteserver:WSUS SMSWSUS 0^


#----- Discovery Configuration
Get-CMDiscoveryMethod -SiteCode $sitecode
Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -Enabled $true
Set-CMDiscoveryMethod -ActiveDirectorysystemDiscovery -Enabled $true


#----- Discovery Configuration for AD Group
Get-CMDiscoveryMethod -SiteCode $sitecode
# ----- Create a AD group first before below 
$GroupName="XYZ"
$GroupDN="CN=$GroupName,CN=Users,DC=lab,DC=local"
$CMGroupDiscoveryScope=New-CMADGroupDiscoveryScope -name $GroupName -SiteCode $sitecode -GroupDN $GroupDN
$CMGroupDiscoverySchedule = New-CMSchedule -Start '2022/10/20 00:00:00' -RecurInterval Days -RecurCount 7
Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery `
  -AddGroupDiscoveryScope $CMGroupDiscoveryScope `
  -SiteCode $SiteCode `
  -EnableDeltaDiscovery $true `
  -DeltaDiscoveryIntervalMinutes 5 `
  -EnableFilteringExpiredLogon $true `
  -TimeSinceLastLogonDays 90 `
  -EnableFilteringExpiredPassword $true `
  -TimeSinceLastPasswordUpdateDays 90 `
  -PollingSchedule $CMGroupDiscoverySchedule `
  -Enabled $true

#----- Boundary Configuration
Get-CMBoundaryGroup
$BoundaryName="XYZ"
$IPRange= "172.16.54.200-172.16.54.230"
New-CMBoundary -Name $BoundaryName -Type IPRange -Value $IPRange

#----- Client Push configuraiton
$InstallationProperty = "SMSSITECODE=$sitecode SMSMP=$SCCMServerName SMSFSP=$WSUSServerName"
Set-CMClientPushInstallation -SiteCode $Sitecode -ChosenAccount  "$env:USERDOMAIN\$SCCMServiceAccountName" -InstallationProperty $InstallationProperty


#----- set Collection
#New-CMDeviceCollection -Name "All Windows 7 Systems" -LimitingCollectionID SMS00001
#New-CMDeviceCollection -Name "Windows 7" -LimitingCollectionName "All Systems"

Create-Collection $CollectionName
Update-Query $CollectionName
New-QADGroup -Name $CollectionName -ParentContainer $GroupOU -groupScope Global -Description $Description

New-CMSoftwareUpdatePhase `
 -CollectionName "MyCollection" `
 -PhaseName "MySUPhase"`
 -UserNotificationOption DisplaySoftwareCenterOnly
 

######################################################################################################################3333


Set-CMDiscoveryMethod -ActiveDirectorysystemDiscovery -Enabled $true
$Schedule = New-CMSchedule -RecurInterval Minutes -Start "2012/10/20 00:00:00" -End "2013/10/20 00:00:00" -RecurCount 10
Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -Enabled $true -SiteCode $siteCode -PollingSchedule $Schedule
$CMSystemDiscoverySchedule = New-CMSchedule -Start '2012/10/20 00:00:00' -RecurInterval Days -RecurCount 1
 GET-

Others
# Set SQL Service Accounts SPN
# Run on the Site Server or domain controller
setspn -A MSSQLSvc/$SCCMServer.$DNSroot:1433 $SqlServiceAccountName
setspn -A MSSQLSvc/$SCCMServer:1433 $SqlServiceAccountName

<#
$update = Get-CMSiteUpdate -Name "Configuration Manager 2002 Hotfix (KB4567007)" -Fast
$update | Invoke-CMSiteUpdateDownload

$update | Invoke-CMSiteUpdatePrerequisiteCheck 
while($true) {cls
$update | Get-CMSiteUpdateInstallStatus -Step Prerequisite | select orderid, progress, description | ft
sleep 5
}

$update | Install-CMSiteUpdate -IgnorePrerequisiteWarning -Force
while($true) {cls
$update | Get-CMSiteUpdateInstallStatus -Step All -Complete | select orderid, progress, description -Last 10 | ft
sleep 5
}

#>



