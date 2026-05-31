#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ssms-executor.ico
#AutoIt3Wrapper_Outfile_x64=ssms-executor-installer.exe
#AutoIt3Wrapper_Res_Comment=See https://github.com/devvcat/ssms-executor/ https://github.com/tkwj/ssms-executor

#AutoIt3Wrapper_Res_Description=Installer for SSMS Executor
#AutoIt3Wrapper_Res_Fileversion=0.1.0.56
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© Mark Simon
#AutoIt3Wrapper_Res_Language=3081
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;#RequireAdmin


;#AutoIt3Wrapper_outfile=.\NewTest.exe
;#AutoIt3Wrapper_Compression=4
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <ColorConstants.au3>
#include <FileConstants.au3>
#include <FontConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <StaticConstants.au3>
#include <WinAPIEx.au3>
;#include <WinAPI.au3>




Opt('GUIOnEventMode', 1)					;	use events instead of loop
AutoitSetOption('ExpandVarStrings',1)		;	enable ' … $var$ … '

Func dbug($data=Default, $lineNumber=@ScriptLineNumber)
	If $data=Default Then $data=''
	If $lineNumber and $lineNumber>0 Then
		$lineNumber = '$lineNumber$: '
	Else
		$lineNumber = ''
	EndIf
	ConsoleWrite('$lineNumber$$data$@CRLF@')
EndFunc

Func say($message=Default, $title=Default, $lineNumber=@ScriptLineNumber)
	If $message=Default Then $message=''
	If $title=Default Then $title=''
	If $lineNumber and $lineNumber>0 Then
		$lineNumber = '$lineNumber$: '
	Else
		$lineNumber = ''
	EndIf
	MsgBox($MB_SYSTEMMODAL, $title, '$lineNumber$$message$')
EndFunc

Func ask($message, $title="Message")
	Return MsgBox($MB_SYSTEMMODAL+$MB_YESNO, $title, $message) == $IDYES
EndFunc

;	Config
	Global Const $buttonWidth = 60
	Global Const $labelButtonWidth = 240
	Global Const $padding = 20
	Global Const $lineHeight = 24
	Global Const $CRLF = @CRLF
	Global Const $guiWidth = 360

	Global $extDestinations[]
	$extDestinations['C: SSMS 17'] = 'C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Extensions'
	$extDestinations['C: SSMS 18'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Extensions'
	$extDestinations['C: SSMS 19'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\Extensions'
	$extDestinations['C: SSMS 20'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\Extensions'
	$extDestinations['C: SSMS 21'] = 'C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\Extensions'
	$extDestinations['C: SSMS 22'] = 'C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\Extensions'

	Global $sqlDestinations[]
	$sqlDestinations['C: SSMS 17'] = 'C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\SqlWorkbenchProjectItems\Sql\'
	$sqlDestinations['C: SSMS 18'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\SqlWorkbenchProjectItems\Sql\'
	$sqlDestinations['C: SSMS 19'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\SqlWorkbenchProjectItems\Sql\'
	$sqlDestinations['C: SSMS 20'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\SqlWorkbenchProjectItems\Sql\'
	$sqlDestinations['C: SSMS 21'] = 'C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\SqlWorkbenchProjectItems\Sql\'
	$sqlDestinations['C: SSMS 22'] = 'C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\SqlWorkbenchProjectItems\Sql\'


	;	Possible ini file
		Local $ini = "install.ini"

		If FileExists($ini) Then
			Local $values = IniReadSection($ini, 'Install')
			If Not @error Then
				For $j = 1 to $values[0][0]
					$key = $values[$j][0]
					$value = $values[$j][1]
					$extDestinations[$key] = $value
				Next
			EndIf
		EndIf

;	Globals
	Global Const $tabHeight = $lineHeight*(UBound($extDestinations)+1.5)
	Global Const $guiHeight = $tabHeight + 160
	Global $gui
	Global $checkBixen[]
	Global $sqlFile = ''

;	Create GUI
	$gui = GUICreate("Install SSMS Executor", $guiWidth, -1, -1, -1, -1, $WS_EX_ACCEPTFILES)
	WinSetTitle($gui, '', 'Install SSMS Executor');
	GUISetBkColor($COLOR_WHITE)

;	Alow Drag & Drop for Admin
;	#include <WinAPIEx.au3>
;	see: 	https://www.autoitscript.com/forum/topic/211358-gui_event_dropped-not-working-only-when-script-is-compiled/
;			https://www.autoitscript.com/forum/topic/202196-elevated-drag-drop/

	If IsAdmin() Then
		_WinAPI_ChangeWindowMessageFilterEx($gui, $WM_COPYGLOBALDATA, $MSGFLT_ALLOW)
		_WinAPI_ChangeWindowMessageFilterEx($gui, $WM_DROPFILES, $MSGFLT_ALLOW)
		_WinAPI_ChangeWindowMessageFilterEx($gui, $WM_NCHITTEST, $MSGFLT_ALLOW)
		_WinAPI_ChangeWindowMessageFilterEx ($gui, $WM_COPYDATA, $MSGFLT_ALLOW) ; useless ?
	EndIf

	;	Adjust Window
		Local $guiPos = WinGetPos($gui)
		Local $x = $guiPos[0]
		Local $y = $guiPos[1]
		Local $w = $guiPos[2]
		Local $h = $guiPos[3]

		$w = $guiWidth
		$x = (@DesktopWidth - $w) / 2
		$h = $guiHeight
		$y = (@DesktopHeight - $h) / 2

		WinMove($gui, 'Adjusted', $x, $y, $w, $h)

	;	Cancel Button
		GUISetOnEvent(-3, 'cancelButton')	;	quit on close

	;	Variables
		Local $cbItem[]
		Local $tabs[]
		Local $item = 0

	;	Heading Label
		GUISetFont (12, $FW_BOLD)

		$headingLabel = GUICtrlCreateLabel("Install SSMS Executor", $padding, 12)
		GUICtrlSetBkColor($headingLabel, $COLOR_WHITE)
		GUISetFont (9, $FW_NORMAL)

	;	Tab Control
	;	GUICtrlCreateTab (left, top[, width[, height[, style = -1[, exStyle = -1]]]] )

		Local $tabControl = GUICtrlCreateTab(10, $padding + 20, $guiWidth - $padding, $tabHeight)

	;	SSMS Tabs
		$tabs['ssms'] = GUICtrlCreateTabItem("SSMS Versions")
		AutoItSetOption('GUICoordMode', 0)
		GUICtrlCreateLabel('', 6, 6)

	;	Create Items
		GUISetFont (9, $FW_NORMAL)
		For $key In MapKeys($extDestinations)
			$extDestination = $extDestinations[$key]
			$sqlDestination = $sqlDestinations[$key]

			$checkbox = GUICtrlCreateCheckbox(FileExists($extDestination) = 1 ? '$key$' : '$key$ ?', 0, $lineheight, $guiWidth - 2*$padding)
			If FileExists('$extDestination$\SSMSExecutor') Then GUICtrlSetFont($checkbox, 9, $FW_BOLD)

			Local $cb[]
			$cb['key'] = $key
			$cb['ext-destination'] = $extDestination
			$cb['sql-destination'] = $sqlDestination
			$checkbixen[$checkbox] = $cb

			$item += 1
		Next

		GUISetFont (9, $FW_NORMAL)

		AutoItSetOption('GUICoordMode', Default)
	;	SQLFile Button
;		GUICtrlCreateGraphic($padding, $guiHeight-$lineHeight*2, $guiWidth - 2*$padding, 1, $SS_BLACKRECT)

		$dropControl = GUICtrlCreateInput('', $padding, $tabHeight+$lineheight*2, $guiWidth-$buttonWidth*2, $lineheight, -1, $WS_EX_STATICEDGE)
		GUICtrlSetState ($dropControl, $GUI_DROPACCEPTED)
		GUICtrlSetTip ($dropControl, 'Drag File here …')
		GUICtrlSetFont($dropControl, 10, $FW_NORMAL, $GUI_FONTNORMAL, 'Courier New')
		GUISetOnEvent($GUI_EVENT_DROPPED, 'doDrop')
	;	GUIRegisterMsg($WM_DROPFILES, 'doDrop')

		Func doDrop()
		;	say(@GUI_CtrlId)
		;	say(@GUI_DropId)
		;	say($dropControl)
		;	say(@GUI_DragFile)
		;	say(GUICtrlRead(@GUI_DropId))
			$sqlFile = @GUI_DragFile
		EndFunc

		Local $sqlButton = GUICtrlCreateButton("SQLFile",   $guiWidth-$buttonWidth-$padding, $tabHeight+$lineheight*2, $buttonWidth)
		GUICtrlSetOnEvent($sqlButton, "sqlButton")

	;	Cancel Button
		Local $cancelButton = GUICtrlCreateButton("Cancel", $padding, $tabHeight+$lineheight*3.5, $buttonWidth)
		GUICtrlSetOnEvent($cancelButton, "cancelButton")
	;	Install & Uninstall Buttons
		Local $uninstallButton = GUICtrlCreateButton("Uninistall",  $guiWidth-$buttonWidth*2.5-$padding, $tabHeight+$lineheight*3.5, $buttonWidth+16)
		GUICtrlSetOnEvent($uninstallButton, "uninstallButton")
		Local $installButton = GUICtrlCreateButton("Install",  $guiWidth-$buttonWidth-$padding, $tabHeight+$lineheight*3.5, $buttonWidth)
		GUICtrlSetOnEvent($installButton, "installButton")


		AutoItSetOption('GUICoordMode', Default)

	;	About

		$tabs['about'] = GUICtrlCreateTabItem("About")
		GUISetFont (12, $FW_BOLD)
		GUICtrlCreateLabel('', $padding, 72)
		AutoItSetOption('GUICoordMode', 0)

		GUICtrlCreateLabel("Installs SSMS Executor", 0, 0)
		GUISetFont (9, $FW_NORMAL)

		$GitHubLabel = GUICtrlCreateLabel("Home Page (GitHub)", 0, $lineHeight*1.25)
		GUICtrlSetColor($GitHubLabel, $COLOR_BLUE)
		GUICtrlSetFont($GitHubLabel, 9, $FW_NORMAL, $GUI_FONTUNDER)
		GUICtrlSetOnEvent($GitHubLabel, "runLabel")

		GUICtrlCreateLabel("For information about SSMS Executor:", 0, $lineHeight*1.25)

		$ssmsOldLabel = GUICtrlCreateLabel("Original SSMS Executor", $padding, $lineHeight*1.125)
		GUICtrlSetColor($ssmsOldLabel, $COLOR_BLUE)
		GUICtrlSetFont($ssmsOldLabel, 9, $FW_NORMAL, $GUI_FONTUNDER)
		GUICtrlSetOnEvent($ssmsOldLabel, "runLabel")

		$ssmsNewLabel = GUICtrlCreateLabel("SSMS Executor", 0, $lineHeight)
		GUICtrlSetColor($ssmsNewLabel, $COLOR_BLUE)
		GUICtrlSetFont($ssmsNewLabel, 9, $FW_NORMAL, $GUI_FONTUNDER)
		GUICtrlSetOnEvent($ssmsNewLabel, "runLabel")

		GUICtrlCreateTabItem('');



	GUISetState(@SW_SHOW, $gui)

	local $links[2] = [$ssmsOldLabel, $ssmsNewLabel]


;	Loop
	Local $message = 0
	Local $current = 0
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ConsoleWrite('Exiting …')
		EndSwitch

;		$ctrl = GUIGetCursorInfo($gui)[4]
	;	dbug(_ArraySearch($links, $ctrl))
;		If $current==0 And _ArraySearch($links, $ctrl)>-1 then
;			GUICtrlSetFont($ctrl, 9, $FW_NORMAL, $GUI_FONTUNDER)
;			$current = $ctrl
;			dbug('set')
;		ElseIf $current>0 Then
;			GUICtrlSetFont($current, 9, $FW_NORMAL, $GUI_FONTNORMAL)
;			$current = 0
;			dbug('unset')
;		EndIf

		Sleep(100)
	WEnd

;	Exit
	GUIDelete($gui)

;	Action Buttons
	Func sqlButton()
		For $i In MapKeys($checkBixen)
			Local $cb = $checkBixen[$i]
			If GUICtrlRead($i) = $GUI_CHECKED Then doSQLFile($cb, $i)
		Next
	EndFunc


	Func uninstallButton()
		For $i In MapKeys($checkBixen)
			Local $cb = $checkBixen[$i]
			If GUICtrlRead($i) = $GUI_CHECKED Then doUninstall($cb, $i)
		Next
	EndFunc


	Func installButton()
		For $i In MapKeys($checkBixen)
			Local $cb = $checkBixen[$i]
			If GUICtrlRead($i) = $GUI_CHECKED Then doInstall($cb, $i)
		Next
	EndFunc

	Func cancelButton()
		GUIDelete($gui)
		Exit
	EndFunc

	Func runLabel()
		Select
			Case @GUI_CtrlId = $ssmsOldLabel
				ShellExecute("https://github.com/devvcat/ssms-executor/")
			Case @GUI_CtrlId = $ssmsNewLabel
				ShellExecute("https://github.com/tkwj/ssms-executor/")
			Case @GUI_CtrlId = $GitHubLabel
				ShellExecute("https://github.com/manngo/ssms-executor")

		EndSelect
	EndFunc

;	SQLFile
	Func doSQLFile($cb, $ctrl)
		Local $sqlDestination = $cb['sql-destination']
		Local $key = $cb['key']

		Local $ok = true
		If $ok Then
			If FileExists($sqlFile) Then
				$ok = $ok and FileCopy ($sqlFile, "$sqlDestination$\SQLFile.sql", $FC_OVERWRITE)
				say($ok ? "Copy $sqlFile$ $crlf$ to $sqlDestination$SQLFile.sql $crlf$ $crlf$Successful" : "Copy SQLFile to $sqlDestination$ $crlf$ $crlf$Failed", "Install $key$")
			Else
				$ok = $ok and FileInstall(".\SQLFile.sql", "$sqlDestination$\SQLFile.sql", $FC_OVERWRITE)
				say($ok ? "Copy default SQLFile.sql $crlf$ to $sqlDestination$SQLFile.sql $crlf$ $crlf$Successful" : "Copy SQLFile to $sqlDestination$ $crlf$ $crlf$Failed", "Install $key$")
			EndIf
		EndIf

		GUICtrlSetData($cancelButton, 'Quit')
	EndFunc

;	Uninstall
	Func doUninstall($cb, $ctrl)
		Local $extDestination = $cb['ext-destination']
		Local $key = $cb['key']

		If Not ask("Remove SSMS Executor for $key$ ?") Then Return

		DirRemove("$extDestination$\SSMSExecutor", $DIR_REMOVE)

		Switch $key
			Case 'C: SSMS 17', 'C: SSMS 18', 'C: SSMS 19', 'C: SSMS 20'
			Case 'C: SSMS 21', 'C: SSMS 22'
				$fh = FileOpen("$extDestination$\extensions.configurationchanged", $FO_OVERWRITE)
				FileClose($fh)
			;	FileSetTime("$extDestination$\extensions.configurationchanged", "")
		EndSwitch

		If FileExists('$extDestination$\SSMSExecutor') Then
			GUICtrlSetFont($ctrl, 9, $FW_BOLD)
		Else
			GUICtrlSetFont($ctrl, 9, $FW_NORMAL)
		EndIf

		GUICtrlSetData($cancelButton, 'Quit')
	EndFunc

;	Do It
	Func doInstall($cb, $ctrl)
		Local $extDestination = $cb['ext-destination']
		Local $sqlDestination = $cb['sql-destination']
		Local $key = $cb['key']

		Local $ok = true

		If FileExists("$extDestination$\SSMSExecutor\") Then
			dbug("$extDestination$\SSMSExecutor exists")
		Else
			$ok = DirCreate("$extDestination$\SSMSExecutor")
			dbug("DirCreate: $ok$")
		EndIf

		If $ok Then
			If FileExists("$extDestination$\SSMSExecutor\Resources") Then
				ConsoleWrite("$extDestination$\SSMSExecutor\Resources exists")
			Else
				$ok = DirCreate("$extDestination$\SSMSExecutor\Resources")
				ConsoleWrite("DirCreate: $ok$")
			EndIf
		EndIf

		If $ok Then
			Switch $key
				Case 'C: SSMS 17', 'C: SSMS 18', 'C: SSMS 19', 'C: SSMS 20'
					$ok = $ok and FileInstall(".\SSMSExecutorOld\SSMSExecutor.dll.config", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorOld\SSMSExecutor.pkgdef", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorOld\extension.vsixmanifest", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorOld\Microsoft.SqlServer.TransactSql.ScriptDom.dll", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorOld\SSMSExecutor.dll", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)

					$ok = $ok and FileInstall(".\SSMSExecutorOld\Resources\license.txt", "$extDestination$\SSMSExecutor\Resources\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorOld\Resources\Command1Package.ico", "$extDestination$\SSMSExecutor\Resources\", $FC_OVERWRITE)

				Case 'C: SSMS 21', 'C: SSMS 22'
					$ok = $ok and FileInstall(".\SSMSExecutorNew\extension.vsixmanifest", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorNew\SSMSExecutor.dll", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorNew\SSMSExecutor.pkgdef", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)

					$ok = $ok and FileInstall(".\SSMSExecutorNew\catalog.json", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorNew\manifest.json", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorNew\Microsoft.SqlServer.TransactSql.ScriptDom.dll", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorNew\Microsoft.SqlServer.TransactSql.ScriptDom.pdb", "$extDestination$\SSMSExecutor\", $FC_OVERWRITE)

					$ok = $ok and FileInstall(".\SSMSExecutorNew\Resources\license.txt", "$extDestination$\SSMSExecutor\Resources\", $FC_OVERWRITE)
					$ok = $ok and FileInstall(".\SSMSExecutorNew\Resources\Command1Package.ico", "$extDestination$\SSMSExecutor\Resources\", $FC_OVERWRITE)

					if $ok Then
					;	dbug(FileSetTime("$extDestination$\extensions.configurationchanged", ""))
						$fh = FileOpen("$extDestination$\extensions.configurationchanged", $FO_OVERWRITE)
						FileClose($fh)
					EndIf
			EndSwitch
		EndIf

		say($ok ? "Install to $extDestination$ $crlf$ $crlf$Successful" : "Install to $extDestination$ $crlf$ $crlf$Failed", "Install $key$")
	;	If Not $ok Then say("Install to $extDestination$ $crlf$ $crlf$Failed", "Install $key$")
		If FileExists('$extDestination$\SSMSExecutor') Then
			GUICtrlSetFont($ctrl, 9, $FW_BOLD)
		Else
			GUICtrlSetFont($ctrl, 9, $FW_NORMAL)
		EndIf
		if $ok then GUICtrlSetData($cancelButton, 'Quit')
	EndFunc

