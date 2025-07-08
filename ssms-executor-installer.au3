#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ssms-executor.ico
#AutoIt3Wrapper_Outfile_x64=ssms-executor-installer.exe
#AutoIt3Wrapper_Res_Comment=See https://github.com/devvcat/ssms-executor/ https://github.com/tkwj/ssms-executor

#AutoIt3Wrapper_Res_Description=Installer for SSMS Executor
#AutoIt3Wrapper_Res_Fileversion=0.1.0.10
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
#include <GUIConstantsEx.au3>
#include <ColorConstants.au3>
#include <FileConstants.au3>
#include <FontConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
;#include <WinAPI.au3>

Opt('GUIOnEventMode', 1)					;	use events instead of loop
AutoitSetOption('ExpandVarStrings',1)		;	enable ' … $var$ … '

Func dbug($data)
	ConsoleWrite($data & @CRLF)
EndFunc
Func say($message, $title="Message")
	MsgBox($MB_SYSTEMMODAL, $title, $message)
EndFunc

;	Config
	Global Const $buttonWidth = 60
	Global Const $labelButtonWidth = 240
	Global Const $padding = 20
	Global Const $lineHeight = 24
	Global Const $CRLF = @CRLF

	Global Const $guiWidth = 300
	Global Const $guiHeight = 144 + $lineHeight*8

	Global $destinations[]

	$destinations['C: SSMS 17'] = 'C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Extensions\'
	$destinations['C: SSMS 18'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Extensions\'
	$destinations['C: SSMS 19'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\Extensions\'
	$destinations['C: SSMS 20'] = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\Extensions\'
	$destinations['C: SSMS 21'] = 'C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\Extensions\'

	Local $ini = "install.ini"

	If FileExists($ini) Then
		Local $values = IniReadSection($ini, 'Install')
		If Not @error Then
			For $j = 1 to $values[0][0]
				$key = $values[$j][0];
				$value = $values[$j][1]
				$destinations[$key] = $value
			Next
		EndIf
	EndIf

;	Globals
	Global $gui
	Global $checkBixen[]

;	Create GUI
	$gui = GUICreate("Install SSMS Executor", $guiWidth)
	WinSetTitle($gui, '', 'Install SSMS Executor');

;	#include <APIThemeConstants.au3>
;	#include <GUIConstantsEx.au3>

;	#include <WinApiTheme.au3>
;	#include <SendMessage.au3>

;	_WinAPI_SetThemeAppProperties(0)
;	_WinAPI_SetThemeAppProperties($STAP_ALLOW_NONCLIENT)
;	_SendMessage($gui, $WM_THEMECHANGED)


	GUISetBkColor($COLOR_WHITE)

	;	Adjust WIndow
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
		Local $tabControl = GUICtrlCreateTab(10, $padding + 20, $guiWidth - $padding, 196)

	;	SSMS Tabs
		$tabs['ssms'] = GUICtrlCreateTabItem("SSMS Versions")
		AutoItSetOption('GUICoordMode', 0)
		GUICtrlCreateLabel('', 6, 6)

	;	Create Items
		GUISetFont (9, $FW_NORMAL)
		For $key In MapKeys($destinations)
			$destination = $destinations[$key]
			$checkbox = GUICtrlCreateCheckbox(FileExists($destination) = 1 ? '$key$' : '$key$ ?', 0, $lineheight, $guiWidth - 2*$padding)
			If FileExists('$destination$\SSMSExecutor') Then GUICtrlSetFont($checkbox, 9, $FW_BOLD)
			If Not FileExists($destination) Then GUICtrlSetColor($checkbox, $COLOR_RED)
			Local $cb[]
			$cb['key'] = $key
			$cb['destination'] = $destination
			$checkbixen[$checkbox] = $cb

			$item += 1
		Next
		AutoItSetOption('GUICoordMode', Default)

	;	About

		$tabs['about'] = GUICtrlCreateTabItem("About")
		GUISetFont (12, $FW_BOLD)
		GUICtrlCreateLabel('', $padding, 72)
		AutoItSetOption('GUICoordMode', 0)

		GUICtrlCreateLabel("Installs SSMS Executor", 0, 0)
		GUISetFont (9, $FW_NORMAL)

		GUICtrlCreateLabel("For information about SSMS Executor:", 0, $lineHeight*1.5)

		$ssmsOldLabel = GUICtrlCreateLabel("Original SSMS Executor ", $padding, $lineHeight*1.5)
		GUICtrlSetColor($ssmsOldLabel, $COLOR_BLUE)
		;	GUICtrlSetBkColor($ssmsOldLabel, $COLOR_WHITE)
		GUICtrlSetFont($ssmsOldLabel, 9, $FW_NORMAL, $GUI_FONTUNDER)
		GUICtrlSetOnEvent($ssmsOldLabel, "runLabel")

		$ssmsNewLabel = GUICtrlCreateLabel("SSMS Executor (v21)", 0, $lineHeight)
		GUICtrlSetColor($ssmsNewLabel, $COLOR_BLUE)
		;	GUICtrlSetBkColor($ssmsNewLabel, $COLOR_WHITE)
		GUICtrlSetFont($ssmsNewLabel, 9, $FW_NORMAL, $GUI_FONTUNDER)
		GUICtrlSetOnEvent($ssmsNewLabel, "runLabel")

;		$ssmsLink = GUICtrlCreateLabel("SSMS Executor…", $padding+52 , 12, $guiWidth - 2*$padding)
;		GUICtrlSetOnEvent($ssmsLink, "runLabel")
;		GUICtrlSetColor($ssmsLink, $COLOR_BLUE)


		AutoItSetOption('GUICoordMode', Default)
		GUICtrlCreateTabItem('');

	;	OK & Cancel Buttons
		GUISetFont (9, $FW_NORMAL)
		Local $cancelButton = GUICtrlCreateButton("Cancel", $padding, $guiHeight-$lineHeight*3, $buttonWidth)
		GUICtrlSetOnEvent($cancelButton, "cancelButton")
		Local $okButton = GUICtrlCreateButton("OK",  $guiWidth-$buttonWidth-$padding, $guiHeight-$lineHeight*3, $buttonWidth)
		GUICtrlSetOnEvent($okButton, "okButton")

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
	Func okButton()
		For $i In MapKeys($checkBixen)
			Local $cb = $checkBixen[$i]
			If GUICtrlRead($i) = $GUI_CHECKED Then doit($cb)
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
		EndSelect
	EndFunc

;	Do It
	Func doit($cb)
		Local $destination = $cb['destination']
		Local $key = $cb['key']

		Local $ok = true

		If FileExists("$destination$\SSMSExecutor\") Then
			dbug("$destination$\SSMSExecutor exists")
		Else
			$ok = DirCreate("$destination$\SSMSExecutor")
			dbug("DirCreate: $ok$")
		EndIf

		If $ok Then
			If FileExists("$destination$\SSMSExecutor\Resources") Then
				ConsoleWrite("$destination$\SSMSExecutor\Resources exists")
			Else
				$ok = DirCreate("$destination$\SSMSExecutor\Resources")
				ConsoleWrite("DirCreate: $ok$")
			EndIf
		EndIf

		If $ok Then
			Switch $key
				Case 'C: SSMS 17', 'C: SSMS 18', 'C: SSMS 19', 'C: SSMS 20'
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorOld\SSMSExecutor.dll.config", "$destination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorOld\SSMSExecutor.pkgdef", "$destination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorOld\extension.vsixmanifest", "$destination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorOld\Microsoft.SqlServer.TransactSql.ScriptDom.dll", "$destination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorOld\SSMSExecutor.dll", "$destination$\SSMSExecutor\", $FC_OVERWRITE)

					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorOld\Resources\license.txt", "$destination$\SSMSExecutor\Resources\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorOld\Resources\Command1Package.ico", "$destination$\SSMSExecutor\Resources\", $FC_OVERWRITE)
				Case 'C: SSMS 21'
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorNew\extension.vsixmanifest", "$destination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorNew\SSMSExecutor.dll", "$destination$\SSMSExecutor\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorNew\SSMSExecutor.pkgdef", "$destination$\SSMSExecutor\", $FC_OVERWRITE)

					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorNew\Resources\license.txt", "$destination$\SSMSExecutor\Resources\", $FC_OVERWRITE)
					$ok = $ok and FileInstall("S:\ssms-executor-installer\SSMSExecutorNew\Resources\Command1Package.ico", "$destination$\SSMSExecutor\Resources\", $FC_OVERWRITE)
			EndSwitch
		EndIf

		say($ok ? "Install to $destination$ $crlf$ $crlf$Successful" : "Install to $destination$ $crlf$ $crlf$Failed", "Install $key$")
		if $ok then GUICtrlSetData($cancelButton, 'Quit')
	EndFunc

