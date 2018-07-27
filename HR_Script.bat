@echo off
setlocal enabledelayedexpansion

rem creating a file in present working directory
set myname=%COMPUTERNAME%
for /f %%x in ('cd') do (
	set pwd=%%x
	)

rem Outfile for service status checks.
set svc_status_outfile=%pwd%\%myname%-svc_status.txt

rem Outfile for file permission checks.
set folder_perm_outfile=%pwd%\%myname%-folder_perm.txt

rem Outfile for registry value checks.
set reg_value_outfile=%pwd%\%myname%-reg_value.txt

rem Outfile for adv audit pol check.
set adv_audpol_outfile=%pwd%\%myname%-adv_audpol.txt

rem Outfile for misc checks.
set misc_check_outfile=%pwd%\%myname%-misc_check.txt

rem Service Checks
set input_svccheck=%pwd%\Lists\services2.txt
for /F "tokens=*" %%A in (%input_svccheck%) do (
	for /F "tokens=*" %%i in ('sc qc %%A ^| findstr "FAILED"') do (
		echo Service %%A not found^(not installed^) >> %svc_status_outfile%
		echo. >> %svc_status_outfile%
		)
	for /F "tokens=*" %%j in ('sc qc %%A ^| findstr "DISPLAY_NAME"') do (
		echo Service %%A >> %svc_status_outfile%
		echo %%j >> %svc_status_outfile%
		)
	for /F "tokens=*" %%k in ('sc qc %%A ^| findstr "START_TYPE"') do (
		echo %%k >> %svc_status_outfile%
		echo. >> %svc_status_outfile%
		)
)

rem Folder Permission Checks
set input_folperm=%pwd%\Lists\Folder_Lookup.txt
for /F "tokens=*" %%A in (%input_folperm%) do (
		set z=%%A
		echo !z! >> %folder_perm_outfile%
		echo --- >> %folder_perm_outfile%
		for /F "tokens=* USEBACKQ" %%j in (`icacls !z!`) do (
			echo %%j >> %folder_perm_outfile%
		)
		echo. >> %folder_perm_outfile%
	)
echo. >> %folder_perm_outfile%
echo 3.4.6.10 >> %folder_perm_outfile%
for /f "tokens=*" %%B in ('icacls c^:') do (
	echo %%B >> %folder_perm_outfile%
	)

rem Registry Value Checks
echo 3.4.2.2 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
for /f %%a in ('reg query HKLM^\SOFTWARE^\CLASSES^\APPID^\') do (
 	reg query %%a /f RunAs >> %reg_value_outfile%
 	)

echo. >> %reg_value_outfile%
echo 3.4.2.2 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SYSTEM\CURRENTCONTROLSET\CONTROL\SECUREPIPESERVERS\WINREG\ALLOWEDPATHS\ /f Machine >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.3.1 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SYSTEM\CURRENTCONTROLSET\SERVICES\LANMANSERVER\PARAMETERS\ /f NullSessionShares >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.3.2 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SYSTEM\CURRENTCONTROLSET\SERVICES\LANMANSERVER\PARAMETERS\ /f NullSessionPipes >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.4.1 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SYSTEM\CURRENTCONTROLSET\SERVICES\TCPIP\PARAMETERS\ /f SynAttackProtect >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.4.5 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SYSTEM\CURRENTCONTROLSET\CONTROL\LSA\ /f SubmitControl >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.4.6 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SOFTWARE\MICROSOFT\WINDOWSNT\CURRENTVERSION\WINLOGON\ /f DefaultPassword >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.6.1 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKCU\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\POLICIES\SYSTEM\ /f DisableTaskMgr >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.6.5 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SYSTEM\CURRENTCONTROLSET\CONTROL\CRASHCONTROL\ /f AutoReboot >> %reg_value_outfile%

echo. >> %reg_value_outfile%
echo 3.4.6.8 >> %reg_value_outfile%
echo "-----" >> %reg_value_outfile%
reg query HKLM\SYSTEM\CURRENTCONTROLSET\SERVICES\CDROM\ /f AutoRun >> %reg_value_outfile%

rem On-top of the gpresult output, we will include the effective audit policy for advanced audit policies
gpresult /H %COMPUTERNAME%-GPO.html
echo. >> %adv_audpol_outfile%
echo Advanced Audit Policies >> %adv_audpol_outfile%
echo -----------------------
for /f "tokens=*" %%c in ('auditpol ^/get ^/category^:^*') do (
	echo %%c  >> %adv_audpol_outfile%
	)

rem Leave all misc checks here please
rem 3.3.1 Ensure volumes are using the NTFS file system
echo. >> %misc_check_outfile%
echo 3.3.1 >> %misc_check_outfile%
echo ---- >> %misc_check_outfile%
for /f "tokens=*" %%y in ('wmic logicaldisk get volumename^,filesystem^,deviceid') do (
	echo %%y >> %misc_check_outfile%
	)
rem 3.4.4.4 & 3.4.6.6
echo. >> %misc_check_outfile%
echo 3.4.4.4  >> %misc_check_outfile%
echo -------  >> %misc_check_outfile%
for /f "tokens=*" %%a in ('bcdedit') do (
	echo %%a  >> %misc_check_outfile%
	)
echo.  >> %misc_check_outfile%
echo 3.4.6.6 >> %misc_check_outfile%
echo ------- >> %misc_check_outfile%
for /f "tokens=*" %%z in ('bcdedit ^| findstr timeout') do (
	echo %%z >> %misc_check_outfile%
	)
echo. >> %misc_check_outfile%
echo 3.4.5.1 and 3.4.5.2 >> %misc_check_outfile%
echo ------------------- >> %misc_check_outfile%
for /f "tokens=*" %%d in ('net view %COMPUTERNAME% ^/all') do (
	echo %%d >> %misc_check_outfile%
	)