Import-Module 'C:\temp\smsclictr.automation.dll'
$RemoteSMSClient = New-Object -TypeName smsclictr.automation.SMSClient($($Env:Computername))
$adv = $RemoteSMSClient.SoftwareDistribution.Advertisements | ? {$_.PKG_Name -like '*Monthly Software Update*' -and $_.ADV_ADF_Published -eq $true} `
    | Sort-Object $_.PKG_Name -Descending | Select-Object -First 1
$returnCode = $RemoteSMSClient.SoftwareDistribution.RerunAdv($Adv.ADV_AdvertisementID,$Adv.PKG_PackageID,$Adv.PRG_ProgramID)
