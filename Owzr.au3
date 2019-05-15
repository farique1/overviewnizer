;~ Overviewnizer v1.0
;~ Read text files on a folder and converts them to the Attract Mode overview format and vice-versa.
;~ Overviewnizer can also convert from the old to the new format.
;~
;~ Copyright (C) 2018 - Fred Rique (farique) https://github.com/farique1

#include <Array.au3>
#include <File.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#Region GUI
$_idOwzr = GUICreate("Ovrwnzr", 212, 470, -1, -1)
$_idPic = GUICtrlCreatePic("Data\Logo.gif", 8, 8, 192, 42)
$Label1 = GUICtrlCreateLabel("Folder", 8, 62, 30, 17)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idFolderB = GUICtrlCreateButton("Pick", 7, 78, 38, 23)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idFolderI = GUICtrlCreateInput("", 48, 79, 152, 21)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$Label2 = GUICtrlCreateLabel("Extensions - semicolon separeted", 8, 108, 161, 17)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idExts = GUICtrlCreateInput(".txt;.cfg", 8, 126, 192, 21)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idNFiles = GUICtrlCreateLabel("Files", 8, 156, 40, 17)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idFileList = GUICtrlCreateList("", 8, 174, 192, 178, BitOR($LBS_NOTIFY,$LBS_SORT,$WS_VSCROLL))
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$_idViewFile = GUICtrlCreateButton("View File", 7, 353, 90, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKHEIGHT+$GUI_DOCKBOTTOM)
GUICtrlCreateLabel("Convert to", 80, 386)
$_idNewOvrwnzr = GUICtrlCreateButton("New Overview", 7, 405, 90, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idOvrwnzr = GUICtrlCreateButton("Old Overview", 7, 435, 90, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idDeOvrwnzr = GUICtrlCreateButton("Text", 111, 405, 90, 25) ; 111, 383
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
$_idDoN = GUICtrlCreateCheckbox("Add ""\n""", 112, 439)
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
;~ 	GUICtrlSetState(-1, $GUI_CHECKED)
$_idHelp = GUICtrlCreateButton("Help", 111, 353, 90, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKHEIGHT+$GUI_DOCKTOP)
GUISetState(@SW_SHOW)
#EndRegion

#Region Variables
Local $sOvrvwFolder = ""; $sOvrvwFolder = "F:\FrontEnd\attract-v2.3.0-win64\romlists\"
Local $sFileContent, $bDebug = False, $sTempFolder = ""
Local $aFileList[0], $aFileListTemp[0], $aFileContent[0]
Local $_idViewFileForm, $_idFileName, $_idContentBox
Local $_idTstOvrwnzr = 9999, $_idTstDeOvrwnzr = 9999, $_idSave = 9999, $_idTstNewOvrwnzr = 9999
if not FileExists($sOvrvwFolder) Then $sOvrvwFolder = ""

;Debug
;~ $bDebug = True
;~ $sOvrvwFolder = "K:\SkyDrive\Desktop\Virtual Boy"
;~ GUICtrlSetData($_idFolderI, $sOvrvwFolder)
;~ OvrvwFolder()
;end debug
#EndRegion

While 1
	$nMsg = GUIGetMsg(1)
	Switch $nMsg[1]
		Case $_idOwzr
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					Exit
				Case $_idFolderB
					OvrvwFolder()
				Case $_idFolderI
					$sTempFolder = GUICtrlRead($_idFolderI)
					if FileExists($sTempFolder) Then
						$sOvrvwFolder = $sTempFolder
						PopulateList()
					Else
						MsgBox(0,"Error", "Folder not found")
						GUICtrlSetData($_idFolderI, $sOvrvwFolder)
					EndIf
				Case $_idViewFile
					ViewFile()
				Case $_idNewOvrwnzr
					NewOvrwnzr()
				Case $_idOvrwnzr
					Ovrwnzr()
				Case $_idDeOvrwnzr
					DeOvrwnzr()
				Case $_idHelp
					If FileExists("Readme.txt") Then
						Run("notepad.exe " & "Readme.txt")
					Else
						MsgBox($MB_SYSTEMMODAL, "File not found", "Readme.txt was not found.")
					EndIf
			EndSwitch
		Case $_idViewFileForm
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					GUICtrlSetState($_idNewOvrwnzr ,$GUI_ENABLE)
					GUICtrlSetState($_idOvrwnzr ,$GUI_ENABLE)
					GUICtrlSetState($_idDeOvrwnzr ,$GUI_ENABLE)
;~ 					GUICtrlSetState($_idDoN ,$GUI_ENABLE)
					GUICtrlSetState($_idFolderB ,$GUI_ENABLE)
					GUICtrlSetState($_idFolderI ,$GUI_ENABLE)
					GUICtrlSetState($Label2 ,$GUI_ENABLE)
					GUICtrlSetState($_idExts ,$GUI_ENABLE)
					GUICtrlSetState($_idNFiles ,$GUI_ENABLE)
					GUICtrlSetState($_idFileList ,$GUI_ENABLE)
					GUICtrlSetState($_idViewFile ,$GUI_ENABLE)
					GUIDelete($_idViewFileForm)
				Case $_idTstNewOvrwnzr
					NewOverviewnize()
				Case $_idTstOvrwnzr
					Overviewnize()
				Case $_idTstDeOvrwnzr
					Deoverviewnize()
				Case $_idSave
					SaveTeste()
			EndSwitch
	EndSwitch
WEnd

Func NewOvrwnzr()
	if UBound($aFileListTemp)-1 < 1 Then
		ToolTip("Folder empty")
		Sleep(500)
		ToolTip("")
		Return
	EndIf
	$idButtun = MsgBox(1,"Overviewnize", "Overviewnizing " & UBound($aFileList)-1 & " files."&@CRLF&"This will replace them and cannot be undone.")
	if $idButtun = 2 then Return
	for $f = 0 to UBound($aFileList)-1
		_FileReadToArray($sOvrvwFolder&"\"&$aFileList[$f], $aFileContent)
		_ArrayDelete($aFileContent, 0)
		$sFileContent = _ArrayToString($aFileContent, @CRLF)
		NewOverviewnize()
		FileDelete($sOvrvwFolder&"\"&$aFileList[$f])
		$iPos = StringInStr($aFileList[$f], ".", 0, -1) - 1
		$sNuString = StringMid($aFileList[$f], 1, $iPos)
		$sNuString = $sNuString & ".txt"
		FileWrite($sOvrvwFolder&"\"&$sNuString, $sFileContent)
	Next
	PopulateList()
EndFunc

Func Ovrwnzr()
	if UBound($aFileListTemp)-1 < 1 Then
		ToolTip("Folder empty")
		Sleep(500)
		ToolTip("")
		Return
	EndIf
	$idButtun = MsgBox(1,"Overviewnize", "Overviewnizing " & UBound($aFileList)-1 & " files."&@CRLF&"This will replace them and cannot be undone.")
	if $idButtun = 2 then Return
	for $f = 0 to UBound($aFileList)-1
		_FileReadToArray($sOvrvwFolder&"\"&$aFileList[$f], $aFileContent)
		_ArrayDelete($aFileContent, 0)
		$sFileContent = _ArrayToString($aFileContent, @CRLF)
		Overviewnize()
		FileDelete($sOvrvwFolder&"\"&$aFileList[$f])
		$iPos = StringInStr($aFileList[$f], ".", 0, -1) - 1
		$sNuString = StringMid($aFileList[$f], 1, $iPos)
		$sNuString = $sNuString & ".cfg"
		FileWrite($sOvrvwFolder&"\"&$sNuString, $sFileContent)
	Next
	PopulateList()
EndFunc

Func DeOvrwnzr()
	if UBound($aFileListTemp)-1 < 1 Then
		ToolTip("Folder empty")
		Sleep(500)
		ToolTip("")
		Return
	EndIf
	$idButtun = MsgBox(1,"Deoverviewnize", "Deoverviewnizing " & UBound($aFileList)-1 & " files."&@CRLF&"This will replace them and cannot be undone.")
	if $idButtun = 2 then Return
	for $f = 0 to UBound($aFileList)-1
		_FileReadToArray($sOvrvwFolder&"\"&$aFileList[$f], $aFileContent)
		_ArrayDelete($aFileContent, 0)
		$sFileContent = _ArrayToString($aFileContent, @CRLF)
		Deoverviewnize()
		FileDelete($sOvrvwFolder&"\"&$aFileList[$f])
		$iPos = StringInStr($aFileList[$f], ".", 0, -1) - 1
		$sNuString = StringMid($aFileList[$f], 1, $iPos)
		$sNuString = $sNuString & ".txt"
		FileWrite($sOvrvwFolder&"\"&$sNuString, $sFileContent)
	Next
	PopulateList()
EndFunc

Func OvrvwFolder()
	$sTempFolder = $sOvrvwFolder
	if not $bDebug Then $sOvrvwFolder = FileSelectFolder ( "Overviews folder ",$sOvrvwFolder,2)
	$bDebug = False
	If not @error Then
		PopulateList()
	EndIf
EndFunc

Func PopulateList()
	$sExts = GUICtrlRead($_idExts)
	$sExtsOk = StringReplace($sExts,".","*.")
	$aFileListTemp = _FileListToArrayMultiSelect($sOvrvwFolder, $sExtsOk, ";")
	if UBound($aFileListTemp)-1 < 1 Then
		$sOvrvwFolder = $sTempFolder
		GUICtrlSetData($_idFolderI, $sOvrvwFolder)
		MsgBox(0,"Error", "No appropriate file found")
		Return
	Else
		$aFileList = $aFileListTemp
		_GUICtrlListBox_ResetContent($_idFileList)
		_ArrayDelete($aFileList, 0)
		$sFileList = _ArrayToString($aFileList, "|")
		GUICtrlSetData($_idFileList, $sFileList)
		GUICtrlSetData($_idNFiles, UBound($aFileList)-1&" files")
		GUICtrlSetData($_idFolderI, $sOvrvwFolder)
	EndIf
EndFunc

Func ViewFile()
	$sFileName = GUICtrlRead($_idFileList)
	if $sFileName = "" Then
		ToolTip("No file selected")
		Sleep(500)
		ToolTip("")
		Return
	EndIf
	GUICtrlSetState($_idNewOvrwnzr ,$GUI_DISABLE)
	GUICtrlSetState($_idOvrwnzr ,$GUI_DISABLE)
	GUICtrlSetState($_idDeOvrwnzr ,$GUI_DISABLE)
;~ 	GUICtrlSetState($_idDoN ,$GUI_DISABLE)
	GUICtrlSetState($_idFolderB ,$GUI_DISABLE)
	GUICtrlSetState($_idFolderI ,$GUI_DISABLE)
	GUICtrlSetState($Label2 ,$GUI_DISABLE)
	GUICtrlSetState($_idExts ,$GUI_DISABLE)
	GUICtrlSetState($_idNFiles ,$GUI_DISABLE)
	GUICtrlSetState($_idFileList ,$GUI_DISABLE)
	GUICtrlSetState($_idViewFile ,$GUI_DISABLE)

	$_idViewFileForm = GUICreate("File View", 450, 353,-1,-1, BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_SIZEBOX,$WS_THICKFRAME,$WS_TABSTOP,$WS_EX_MDICHILD))
	$_idFileName = GUICtrlCreateLabel($sFileName, 8, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	$_idContentBox = GUICtrlCreateEdit("", 8, 38, 434, 254, BitOR($LBS_NOTIFY,$WS_VSCROLL,$ES_MULTILINE,$ES_RIGHT,$ES_READONLY))
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	GUICtrlCreateLabel("Convert to", 12, 300)
	$_idTstNewOvrwnzr = GUICtrlCreateButton("New Overview", 7, 320, 80, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT+$GUI_DOCKBOTTOM)
	$_idTstOvrwnzr = GUICtrlCreateButton("Old Overview", 97, 320, 80, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT+$GUI_DOCKBOTTOM)
	$_idTstDeOvrwnzr = GUICtrlCreateButton("Text", 187, 320, 80, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT+$GUI_DOCKBOTTOM)
	$_idSave = GUICtrlCreateButton("Save As", 322, 320, 120, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT+$GUI_DOCKBOTTOM)

	_FileReadToArray($sOvrvwFolder&"\"&$sFileName, $aFileContent)
	_ArrayDelete($aFileContent, 0)
	$sFileContent = _ArrayToString($aFileContent, @CRLF)
	GUICtrlSetData($_idContentBox, $sFileContent)

	GUISetState(@SW_SHOW)
EndFunc

Func NewOverviewnize()
	$sDoN = ""
	if StringLeft($sFileContent, 9) = "overview " Then
		$sFileContent = StringTrimLeft($sFileContent, 9)
	EndIf
	if _IsChecked($_idDoN) and StringLeft($sFileContent, 2) <> "\n" Then $sDoN = "\n"
	$sFileContent = $sDoN & $sFileContent
	if Not _IsChecked($_idDoN) and StringLeft($sFileContent, 2) = "\n" Then $sFileContent = StringTrimLeft($sFileContent, 2)
	$sFileContent = StringReplace($sFileContent, @CRLF, "\n")
	GUICtrlSetData($_idContentBox, $sFileContent)
EndFunc

Func Overviewnize()
	$sDoN = ""
	if _IsChecked($_idDoN) and StringLeft($sFileContent, 2) <> "\n" Then $sDoN = "\n"
	if StringLeft($sFileContent, 9) <> "overview " Then
		$sFileContent = "overview " & $sDoN & $sFileContent
	EndIf
	$sFileContent = StringReplace($sFileContent, @CRLF, "\n")
	GUICtrlSetData($_idContentBox, $sFileContent)
EndFunc

Func Deoverviewnize()
	if StringLeft($sFileContent, 11) = "overview \n" Then $sFileContent = StringTrimLeft($sFileContent, 11)
	if StringLeft($sFileContent, 9) = "overview " Then $sFileContent = StringTrimLeft($sFileContent, 9)
	if StringLeft($sFileContent, 8) = "overview" Then $sFileContent = StringTrimLeft($sFileContent, 8)
	While StringLeft($sFileContent, 2) = "\n"
		$sFileContent = StringTrimLeft($sFileContent, 2)
	WEnd
	$sFileContent = StringReplace($sFileContent, "\n", @CRLF)
	GUICtrlSetData($_idContentBox, $sFileContent)
EndFunc

Func SaveTeste()
    Local $sFileSaveDialog = FileSaveDialog("Save Test", "", "CFG (*.cfg)|Text (*.txt)")
    If @error Then
        ; Display the error message.
        MsgBox(0, "", "No file was saved.")
    Else
		FileWrite($sFileSaveDialog, $sFileContent)
	EndIf
EndFunc

Func _FileListToArrayMultiSelect($dir, $searchlist, $Separator, $iFlag = 0, $iExt = 0)
	Local $FileList[1] = [0], $Filelist1, $iN, $Num, $search

	$search = StringSplit($searchlist, $Separator)
	If $search[0] > 0 Then
		For $iN = 1 To $search[0]
			$Filelist1 = _FileListToArray($dir, $search[$iN], $iFlag)
			If Not @error Then
				$Num = UBound($FileList)
				_ArrayConcatenate($FileList, $Filelist1)
				$FileList[0] = $FileList[0] + $FileList[$Num]
				_ArrayDelete($FileList, $Num)
			EndIf
		Next
		if $iExt = 1 Then
			For $i = 1 to UBound($FileList) - 1
				$iPos = StringInStr($FileList[$i], ".", 0, -1) - 1
				$sNuString = StringMid($FileList[$i], 1, $iPos)
				$FileList[$i] = $sNuString
			Next
		EndIf
	EndIf
	Return $FileList;could be [0]

EndFunc;==>_FileListToArrayMultiSelect

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked
