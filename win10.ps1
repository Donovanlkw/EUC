# delete windows build-in app

Get-AppxPackage *xboxapp* | Remove-AppxPackage
Get-AppxPackage *bingsports* | Remove-AppxPackage
Get-AppxPackage *windowsstore* | Remove-AppxPackage
Get-AppxPackage *windowsphone* | Remove-AppxPackage
Get-AppxPackage *bingnews* | Remove-AppxPackage
Get-AppxPackage *zunevideo* | Remove-AppxPackage
Get-AppxPackage *bingfinance* | Remove-AppxPackage
Get-AppxPackage *solitairecollection* | Remove-AppxPackage
Get-AppxPackage *zunemusic* | Remove-AppxPackage
Get-AppxPackage *3dbuilder* | Remove-AppxPackage
Get-AppxPackage *officehub* | Remove-AppxPackage
Get-AppxPackage *skype* | Remove-AppxPackage
Get-AppxPackage *wallet* | Remove-AppxPackage
Get-AppxPackage *HPJumpStart* | Remove-AppxPackage
Get-AppxPackage *feedback* | Remove-AppxPackage
Get-AppxPackage *getstarted* | Remove-AppxPackage
Get-AppxPackage *onenote* | Remove-AppxPackage
Get-Appxpackage *oneconnect* | Remove-Appxpackage
Get-Appxpackage *people* | Remove-Appxpackage
Get-Appxpackage *messaging* | Remove-Appxpackage
Get-Appxpackage *LinkedIn* | Remove-Appxpackage
Get-Appxpackage "Microsoft.Office.Desktop" | Remove-Appxpackage
Get-AppxPackage *Microsoft.WindowsCamera* | Remove-AppxPackage
Get-AppxPackage *Microsoft.xboxGameOverlay* | Remove-AppxPackage
Get-AppxPackage *Microsoft.xboxGamingOverlay* | Remove-AppxPackage
Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage
Get-AppxPackage *Microsoft.Microsoft3DViewer* | Remove-AppxPackage
Get-AppxPackage *Microsoft.MixedReality.Portal* | Remove-AppxPackage
Get-AppxPackage *Microsoft.MSPaint* | Remove-AppxPackage
Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage
Get-AppxPackage *Microsoft.WindowsMaps* | Remove-AppxPackage
Get-AppxPackage *Microsoft.windowscommunicationsapps* | Remove-AppxPackage
Get-AppxPackage *Microsoft.WindowsSoundRecorder* | Remove-AppxPackage
Get-AppxPackage *Microsoft.BingWeather* | Remove-AppxPackage
get-appxpackage *Microsoft.XboxSpeechToTextOverlay* | remove-appxpackage
get-appxpackage *Microsoft.XboxIdentityProvider* | remove-appxpackage
get-appxpackage *Microsoft.Xbox.TCUI* | remove-appxpackage

# disable Edge shortcut

reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer /v "DisableEdgeDesktopShortcutCreation" /t REG_DWORD /d "1" /f
 
# disable notification

Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-310093Enabled -value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-338389Enabled -value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications -Name ToastEnabled -value 0

# set default language and region

$UserLanguageList = New-WinUserLanguageList -Language en-us 
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
$OldList = Get-WinUserLanguageList
$OldList.Add("zh-Hant-TW")
$OldList[1].InputMethodTips.Clear()
$OldList[1].InputMethodTips.Add('0404:{531FDEBF-9B4C-4A43-A2AA-960E8FCDC732}{4BDF9F03-C7D3-11D4-B2AB-0080C882687E}')
$OldList[1].InputMethodTips.Add('0404:{531FDEBF-9B4C-4A43-A2AA-960E8FCDC732}{6024B45F-5C54-11D4-B921-0080C882687E}')
Set-WinUserLanguageList -LanguageList $OldList -Force
Set-WinHomeLocation -GeoId 0x97

# untick the People on taskbar 

$Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" 
$PeopleBand_Name = "PeopleBand" 
Set-ItemProperty -Path $key -Name $PeopleBand_Name -Value 0

# remove the onedrive shortcut in startmenu. for SSD Start-Sleep is 30, for HD Start-Sleep is 90.

Start-Sleep -s 30
Remove-Item "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

# remove the vb file in startup folder

Remove-Item "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Setlanguagemo.vbs"







:: Export a default app xml
dism /online /Export-DefaultAppAssociations:"%path%\DefaultAppAssociations_ver3.xml"

:: Remove default App assoication
Dism.exe /Online /Remove-DefaultAppAssociations

:: Import a default app xml
dism /online /Import-DefaultAppAssociations:"C:\Windows\StartMenu\DefaultAppAssociations_ver3.xml"


:: Export the User Interface Layout
Export-StartLayout - Path C:\Windows\StartMenu\USM.xml

:: Import the User Interface Layout
Import-StartLayout -LayoutPath C:\Windows\StartMenu\USM.xml

:: check the Edition of Windows 10 ISO
Dism /get-WimInfo /Wimfile:F:\sources\install.wim /index:1

:: Windows 	Windows OS version upgrade	
Dism /Online /Get-TargetEditions
Dism /online /Set-Edition: <edition name> /AcceptEula /ProductKey:1

::Identify the Installed license key
wmic path softwarelicensingservice get OA3xOriginalProductKey






:: Install .NET Framework 3.x	
Dism /online /enable-feature /featurename:NetFX3 /All /Source:XX:\sources\sxs /LimitAccess								

:: Windows	Use of WMIC	
help wmic								

:: List the installed software
wmic product list brief
wmic process list brief
wmic startup list brief		



:: Other
wmic /namespace:\\root\CIMV2\TerminalServices PATH Win32_TerminalServiceSetting WHERE (__CLASS !="") CALL GetGracePeriodDays								
wmic 	/node:remoteserver 	qfe list	https://support.microsoft.com/en-hk/help/3057448/-the-update-is-not-applicable-to-your-computer-error-when-you-install						




Description:Control Panel


Microsoft.InternetOptions 
Microsoft.RegionAndLanguage 
Microsoft.FolderOptions 
Microsoft.DevicesAndPrinters 
MLCFG32.cpl 
Java


