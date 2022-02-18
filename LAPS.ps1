#----- Definition -----#
$OUofWindows10Prod = "LAPS"
$DNOUofWindows10Prod = "OU=LAPS,OU=Win10,DC=LAB,DC=localdomain"
$LAPSAdminGroup = "LAPSAdmin"


#----- Setup LAPS -----#
Import-module AdmPwd.PS
Update-AdmPwdADSchema -Verbose
Find-AdmPwdExtendedrights -identity $OUofWindows10Prod | Format-Table
Set-AdmPwdComputerSelfPermission -OrgUnit $OUofWindows10Prod 
Set-AdmPwdComputerSelfPermission -Identity $DNOUofWindows10Prod -Verbose
Set-AdmPwdReadPasswordPermission -OrgUnit $OUofWindows10Prod -AllowedPrincipals $LAPSAdminGroup
Set-AdmPwdResetPasswordPermission -OrgUnit $OUofWindows10Prod -AllowedPrincipals $LAPSAdminGroup
Set-AdmPwdAuditing –OrgUnit $OUofWindows10Prod -AuditedPrincipals $LAPSAdminGroup

