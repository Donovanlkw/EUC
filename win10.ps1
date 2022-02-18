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


