#----- Definition -----#
$DeploymentShare = "DeploymentShare"
$DeploymentSharePath = "D:\$DeploymentShare"
$SMBShare ="$DeploymentShare$"
$NetworkPath =  “\\$env:computerName\$DeploymentShare$" 
$PSDrive = "DS001"

#------ Create Folder -----#
New-Item -Path D:\ -Name $DeploymentShare -Type Directory
New-SMBShare –Name $SMBShare –Path $DeploymentSharePath –FullAccess "Domain Admins" 

#------ Create and Configure Deployment Share -----#
Add-PSSnapIn Microsoft.BDD.PSSnapIn
new-PSDrive -Name $PSDrive -PSProvider “MDTProvider” -Root $DeploymentSharePath -Description “MDT Deployment Share” -NetworkPath $NetworkPath -Verbose | add-MDTPersistentDrive -Verbose
Set-ItemProperty $PSDrive":" -name EnableMulticast -value "True"
Set-ItemProperty $PSDrive":" -name supportx86 -value "False"
Set-ItemProperty $PSDrive":" -name MonitorHost -value $env:computerName

#------ Create Folder Structure for Application deployement -----#
new-item -path $DeploymentShareName":\Applications" -enable “True” -Name “Core Apps” -Comments “For Any devices” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Applications" -enable “True” -Name “Notebook” -Comments “” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Applications" -enable “True” -Name “Desktop” -Comments “” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Applications" -enable “True” -Name “FOH” -Comments "Front of House” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Applications" -enable “True” -Name “BOH” -Comments “Back of House” -ItemType “folder” –Verbose

#------ Create Folder Structure for Driver (x64) -----#
new-item -path $DeploymentShareName":\Out-of-Box Drivers” -enable “True” -Name “Win10 x64” -Comments "” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Out-of-Box Drivers\Win10 x64” -enable “True” -Name “HP ProDesk 600 G4 DM” -Comments "” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Out-of-Box Drivers\Win10 x64” -enable “True” -Name “HP ProDesk 600 G3 DM” -Comments "” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Out-of-Box Drivers\Win10 x64” -enable “True” -Name “HP ElitBook 840 G5” -Comments "” -ItemType “folder” –Verbose

#------ Create Folder Structure for Driver (x86) -----#
new-item -path $DeploymentShareName":\Out-of-Box Drivers” -enable “True” -Name “Win10 x86” -Comments "” -ItemType “folder” –Verbose
new-item -path $DeploymentShareName":\Out-of-Box Drivers\Win10 x86” -enable “True” -Name “HP ProDesk 600 G3 DM” -Comments "” -ItemType “folder” –Verbose

#------ Inject Driver -----#
import-mdtdriver -path $DeploymentShareName":\Out-of-Box Drivers\Win10 x64\HP ProDesk 600 G4 DM” -SourcePath "D:\Source\Out-of-Box\Win10 x64\HP ProDesk 600 G4 DM”
import-mdtdriver -path $DeploymentShareName":\Out-of-Box Drivers\Win10 x64\HP ProDesk 600 G3 DM” -SourcePath "D:\Source\Out-of-Box\Win10 x64\HP ProDesk 600 G3 DM”
import-mdtdriver -path $DeploymentShareName":\Out-of-Box Drivers\Win10 x86\HP ProDesk 600 G3 DM” -SourcePath "D:\Source\Out-of-Box\Win10 x86\HP ProDesk 600 G3 DM”

#------ Create Applications -----#
import-MDTApplication -path $DeploymentShareName":\Applications\Core Apps”  -enable “True” -Name “Adobe Acrobat Reader DC” -ShortName “Acrobat Reader” -Version “2017.012.20093” -Publisher “Adobe”  -ApplicationSourcePath “D:\Source\Applications\Adobe Reader” -WorkingDirectory “.\Applications\Adobe Acrobat Reader DC” -DestinationFolder “Adobe Acrobat Reader DC” –Verbose -CommandLine “msiexec /i AcroRead.msi PATCH=AcroRdrDCUpd1901020098.msp”
import-MDTApplication -path $DeploymentShareName":\Applications\Core Apps”  -enable “True” -Name “7-Zip” -ShortName “7-Zip” -Version “19” -Publisher “” -ApplicationSourcePath “D:\Source\Applications\7zip”  -WorkingDirectory “.\Applications\7-zip” -DestinationFolder “7-Zip” –Verbose  -CommandLine "msiexec /i 7z1900_x86.msi /qn /norestart"
import-MDTApplication -path $DeploymentShareName":\Applications\Core Apps”  -enable “True” -Name “Java SE Runtime Environment” -ShortName “Java” -Version “8 Update 201” -Publisher “Oracle” -ApplicationSourcePath “D:\Source\Applications\Java” -WorkingDirectory “.\Applications\Java” -DestinationFolder “Java” –Verbose  -CommandLine "msiexec /i jre-8u201-windows-i586.msi /qn /norestart"
import-MDTApplication -path $DeploymentShareName":\Applications\Core Apps”  -enable “True” -Name “Office Scan x64” -ShortName “Office Scan x64” -Version “12.0.1708” -Publisher “Trend Micro” -ApplicationSourcePath “D:\Source\Applications\Office Scan”  -WorkingDirectory “.\Applications\Office Scan x64” -DestinationFolder “Office Scan x64” –Verbose  -CommandLine "msiexec /i agent_cloud_x64.msi /q /norestart"
import-MDTApplication -path $DeploymentShareName":\Applications\Core Apps”  -enable “True” -Name “Silverlight x64” -ShortName “Silverlight x64” -Version “5.1.50907..” -Publisher “Microsoft” -ApplicationSourcePath “D:\Source\Applications\Silverlight”  -WorkingDirectory “.\Applications\Silverlight x64” -DestinationFolder “Silverlight x64” –Verbose  -CommandLine "msiexec /i Silverlight_x64.exe /q /norestart"




