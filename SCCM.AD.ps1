#----- Declare variables -----#
$DomainName= "lab.local"
$DomaninNetBIOSName= "LAB"
$DomainDN="DC=LAB,DC=local"
$DomainAdmin = "Administrator"
$SQLServer="DC"
$sqlServerName =  "DC.lab.local"
$WSUSServerName = "WSUS.lab.local"
$SCCMServerName =  "SCCM.lab.local"
$SDKServerName =  "SCCM.lab.local"
$Sitecode = "HQ1"
$SqlServiceAccountName= "svc-sql-01$"
$SqlServiceAccount= "$Domainname\$SqlServiceAccountName"




#----- AD preparation
#----- Extend scheme, run below command from SCCM CD
.\extadsch.exe

regsvr32 schmmgmt.dll
get-adrootdse |select schema*
$schemaPath = (Get-ADRootDSE).schemaNamingContext

#Check class 
$SCCMClass= Get-ADObject -filter * -SearchBase $schemaPath -Properties * | where lDAPDisplayName -like "MSSMSSite"
$SCCMClass.mayContain
$SCCMClass= Get-ADObject -filter * -SearchBase $schemaPath -Properties * | where lDAPDisplayName -like "mSSMSManagementPoint "
$SCCMClass.mayContain
$SCCMClass= Get-ADObject -filter * -SearchBase $schemaPath -Properties * | where lDAPDisplayName -like "mSSMSServerLocatorPoint"
$SCCMClass.mayContain
$SCCMClass= Get-ADObject -filter * -SearchBase $schemaPath -Properties * | where lDAPDisplayName -like "mSSMSRoamingBoundaryRange"
$SCCMClass.mayContain

<#
#check attributes
$SCCMAttributes= Get-ADObject -filter * -SearchBase $schemaPath -Properties * | where lDAPDisplayName -like $xxxxx

$xxxx include bleow itmes
mSSMSAssignmentSiteCode
mSSMSCapabilities
mSSMSDefaultMP
mSSMSDeviceManagementPoint
mSSMSHealthState
mSSMSMPAddress
mSSMSMPName
mSSMSRangedIPHigh
mSSMSRangedIPLow
mSSMSRoamingBoundaries
mSSMSSiteBoundaries
mSSMSSiteCode
mSSMSSourceForest
mSSMSVersion
#>

#----- Create Container in ADSI for SCCM Check -----#
# Get the distinguished name of the Active Directory domain
$DomainDn = ([adsi]"").distinguishedName
# Build distinguished name path of the System container
$SystemDn = "CN=System," + $DomainDn
# Retrieve a reference to the System container using the path we just built
$SysContainer = [adsi]"LDAP://$SystemDn"
# Create a new object inside the System container called System Management, of type "container"
$SysMgmtContainer = $SysContainer.Create("Container", "CN=System Management")
# Commit the new object to the Active Directory database
$SysMgmtContainer.SetInfo()

#----- Grant ther AD Group permission to dedicated ADSI container -----#
$Group = New-ADGroup -Name 'SCCM_Site_Servers' -GroupScope Universal -PassThru
$CN="CN=System Management," + $SystemDn
$ACL = Get-Acl AD:$CN
$ACL = Get-Acl AD:$CN
$SID = New-Object System.Security.Principal.SecurityIdentifier $Group.SID
$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID, "GenericAll", "Allow", "00000000-0000-0000-0000-000000000000", "All", "00000000-0000-0000-0000-000000000000"
$ACL.AddAccessRule($ACE)
Set-Acl ad:$CN -AclObject $ACL


#----- create Managed service Account for SQL server
#To create the KDS root key in a test environment for immediate effectiveness 
$a=Get-Date
$b=$a.AddHours(-10)
Add-KdsRootKey -EffectiveTime $b
New-ADServiceAccount -Name $SqlServiceAccountName -Enabled $true -Description "Managed Service Account for SQL Server" -DisplayName $SqlServiceAccountName -PrincipalsAllowedToRetrieveManagedPassword $SQLServer$ -DNSHostName $SQLServer
Test-ADServiceAccount $SqlServiceAccountName
