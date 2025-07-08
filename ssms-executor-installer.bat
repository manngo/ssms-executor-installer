@echo off

echo	SSMSExecutor Installer
echo	================================================

:menu

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

:ssms21
	robocopy "%~dp0\SSMSExecutorNew" "C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\Extensions\SSMSExecutor" /e
	goto exit

:ssms20
	robocopy "%~dp0\SSMSExecutorOld" "C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\Extensions\SSMSExecutor" /e
	goto exit

:ssms19
	robocopy "%~dp0\SSMSExecutorOld" "C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\Extensions\SSMSExecutor" /e
	goto exit

:ssms18
	robocopy "%~dp0\SSMSExecutorOld" "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Extensions\SSMSExecutor" /e
	goto exit

:ssms17
	robocopy "%~dp0\SSMSExecutorOld" "C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Extensions\SSMSExecutor" /e
	goto exit

:exit
	pause