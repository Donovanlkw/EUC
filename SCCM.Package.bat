:: Install 7Zip
msiexec /i "%~dp07z1900_x86.msi" /qn /norestart

:: silent Install Adobe Reader DC
msiexec /i "%~dp0AcroRead.msi" PATCH="%~dp0AcroRdrDCUpd1901020098.msp" /qn /L*v "C:\Windows\Logs\AdobeReaderInstall.log"

:: Install Java
msiexec /i "%~dp0jre-8u201-windows-i586.msi" /qn /norestart 
reg add "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /V EnableJavaUpdate /T REG_DWORD /D 0 /F

:: Install Silverlight
"%~dp0Silverlight_x64.exe" /q /norestart




pushd "%~dp0"
IF "%PROCESSOR_ARCHITECTURE%"=="x86" goto INSTALL32
GOTO INSTALL64

:INSTALL32
certutil -addstore "CA" "%~dp0webhybrid_ca.cer"
"%~dp0FP_DLP_Agent.exe" /s /v"/qn /norestart WSCONTEXT=2f0da3428b2ef1caa0cfd1f1cf6d3a50-1"
EXIT 0

:INSTALL64
certutil -addstore "CA" "%~dp0webhybrid_ca.cer"
"%~dp0FP_DLP_Agent.exe" /s /v"/qn /norestart WSCONTEXT=2f0da3428b2ef1caa0cfd1f1cf6d3a50-1"
EXIT 0


pushd "%~dp0"
IF "%PROCESSOR_ARCHITECTURE%"=="x86" goto 32bit
goto 64bit

:64bit
"%~dp0agent_cloud_x64.msi" /q /norestart
exit 0

:32bit
"%~dp0agent_cloud_x64.msi" /q /norestart
exit 0


pushd "%~dp0"
IF "%PROCESSOR_ARCHITECTURE%"=="x86" goto INSTALL32
GOTO INSTALL64

:INSTALL32
certutil -addstore "CA" "%~dp0webhybrid_ca.cer"
"%~dp0FP_Web_Agent.exe" /s /v"/qn /norestart WSCONTEXT=2f0da3428b2ef1caa0cfd1f1cf6d3a50-1"
EXIT 0

:INSTALL64
certutil -addstore "CA" "%~dp0webhybrid_ca.cer"
"%~dp0FP_Web_Agent.exe" /s /v"/qn /norestart WSCONTEXT=2f0da3428b2ef1caa0cfd1f1cf6d3a50-1"
EXIT 0




