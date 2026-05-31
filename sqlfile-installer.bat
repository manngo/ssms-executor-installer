@echo off

echo	SSMSExecutor Installer
echo	================================================

:menu

echo	22	SSMS 22
echo	21	SSMS 21
echo.
echo	20	SSMS 20
echo	19	SSMS 19
echo	18	SSMS 18
echo	17	SSMS 17
echo.
echo	Anything else to exit
echo.

set choice=
set /p choice=Choose a Version:

if '%choice%'=='22' goto ssms22
if '%choice%'=='21' goto ssms21

if '%choice%'=='20' goto ssms20
if '%choice%'=='19' goto ssms19
if '%choice%'=='18' goto ssms18
if '%choice%'=='17' goto ssms17

echo.
echo	Cancelling
echo.

goto exit

rem	Choices

:ssms22
	copy /Y "%~dp0\SQLFile.xql" "C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\SqlWorkbenchProjectItems\Sql\"
	goto exit

:ssms21
	copy /Y "%~dp0\SQLFile.xql" "C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\SqlWorkbenchProjectItems\Sql\"
	goto exit

:ssms20
	copy /Y "%~dp0\SQLFile.xql" "C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\SqlWorkbenchProjectItems\Sql\"
	goto exit

:ssms19
	copy /Y "%~dp0\SQLFile.xql" "C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\SqlWorkbenchProjectItems\Sql\"
	goto exit

:ssms18
	copy /Y "%~dp0\SQLFile.xql" "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\SqlWorkbenchProjectItems\Sql\"
	goto exit

:ssms17
	copy /Y "%~dp0\SQLFile.xql" "C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\SqlWorkbenchProjectItems\Sql\"
	goto exit

:exit
	pause