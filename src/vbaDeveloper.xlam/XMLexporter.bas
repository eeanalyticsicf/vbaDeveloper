Attribute VB_Name = "XMLexporter"
Public Const XML_FOLDER_NAME = "XMLsource\"
Public Const TEMP_ZIP_NAME = "temp.zip"

Sub test_unpackXML()
    Call unpackXML("tempDevFile.xlsm")
    MsgBox ("Done")
End Sub

Public Sub unpackXML(fileShortName As String)

Dim fileName As String, exportPath As String, exportPathXML As String
fileName = Workbooks(fileShortName).FullName
exportPath = getSourceDir(fileName, createIfNotExists:=True)
exportPathXML = exportPath & XML_FOLDER_NAME

Dim FSO As New Scripting.FileSystemObject
If Not FSO.FolderExists(exportPathXML) Then
    FSO.CreateFolder exportPathXML
    Debug.Print "Created Folder " & exportPathXML
End If

'Copy file to temp zip file
Dim tempZipFileName As String
tempZipFileName = exportPath & TEMP_ZIP_NAME
'FileCopy fileName, tempZipFileName
FSO.CopyFile fileName, tempZipFileName, True

'unzip the temp zip file to the folder
Call Unzip(tempZipFileName, exportPathXML)

'delete the temp zip file
Kill tempZipFileName

End Sub

Sub Unzip(Fname As Variant, DefPath As String)
'Code modified from example found here: http://www.rondebruin.nl/win/s7/win002.htm
    Dim FSO As Object
    Dim oApp As Object
    Dim FileNameFolder As Variant

    If Fname = False Then
        'Do nothing
    Else
        If Right(DefPath, 1) <> "\" Then
            DefPath = DefPath & "\"
        End If

        FileNameFolder = DefPath

        'Delete all the files in the folder DefPath first if you want
        On Error Resume Next
        Clear_All_Files_And_SubFolders_In_Folder (DefPath)
        On Error GoTo 0

        'Extract the files into the Destination folder
        Set oApp = CreateObject("Shell.Application")
        oApp.Namespace("" & FileNameFolder).CopyHere oApp.Namespace("" & Fname).Items 'The ""&  is to address a bug - for some reason VBA doesn't like to use the passed strings in this situation. Found discussion on this here: http://forums.codeguru.com/showthread.php?443782-CreateObject(-quot-Shell-Application-quot-)-Error

        MsgBox "You find the files here: " & FileNameFolder

        On Error Resume Next
        Set FSO = CreateObject("scripting.filesystemobject")
        FSO.DeleteFolder Environ("Temp") & "\Temporary Directory*", True
    End If
End Sub
 

Sub Clear_All_Files_And_SubFolders_In_Folder(MyPath As String)
'Delete all files and subfolders
'Be sure that no file is open in the folder
    If Right(MyPath, 1) = "\" Then
        MyPath = Left(MyPath, Len(MyPath) - 1)
    End If
    
    Dim FSO As Object
    Set FSO = CreateObject("scripting.filesystemobject")
    
    If FSO.FolderExists(MyPath) = False Then
        MsgBox MyPath & " doesn't exist"
        Exit Sub
    End If

    On Error Resume Next
    'Delete files
    FSO.DeleteFile MyPath & "\*.*", True
    'Delete subfolders
    FSO.DeleteFolder MyPath & "\*.*", True
    On Error GoTo 0

End Sub

Sub test_rebuildXML()
Dim destinationFileName As String, containingFolderName As String, errorFlag As Boolean, errorMessage As String
destinationFolder = "C:\_files\Git\vbaDeveloper"
containingFolderName = "C:\_files\Git\vbaDeveloper\src\tempDevFile.xlsm"
errorFlag = False

Call rebuildXML(destinationFolder, containingFolderName, errorFlag, errorMessage)

If errorFlag = False Then
    MsgBox ("Uh oh, didn't work")
Else
    MsgBox ("Done!")
End If

End Sub

Sub rebuildXML(destinationFolder As String, containingFolderName As String, errorFlag As Boolean, errorMessage As String)

'input format cleanup
If Right(containingFolderName, 1) <> "\" Then
    containingFolderName = containingFolderName & "\"
End If

'Make sure that the containingFolderName has an XML subfolder
Dim xmlFolderName As String
xmlFolderName = containingFolderName & XML_FOLDER_NAME
Set FSO = CreateObject("scripting.filesystemobject")
If FSO.FolderExists(xmlFolderName) = False Then
    errorMessage = "We couldn't find XML data in that folder!"
    errorFlag = True
    Exit Sub
End If

'Set what some items should be named
Dim fileExtension As String, strDate As String, fileShortName As String, fileName As String, zipFileName As String
strDate = format(Now, " yyyy-mm-dd hh-mm-ss")
fileExtension = "." & Right(containingFolderName, Len(containingFolderName) - InStrRev(containingFolderName, "."))
fileShortName = "tempDevFile" 'TODO need to parse the containingFolderName here using logic
fileName = containingFolderName & fileShortName & "-rebuilt" & strDate & fileExtension

zipFileName = containingFolderName & TEMP_ZIP_NAME

'Zip the folder into the FileNameZip
'Rename the zipFileName to be the fileName (this effectively removes the zip file)

errorFlag = False
End Sub



Sub Zip_All_Files_in_Folder(FolderName As Variant, FileNameZip As Variant)
'Code modified from example found here: http://www.rondebruin.nl/win/s7/win001.htm
    Dim strDate As String, DefPath As String
    Dim oApp As Object

    DefPath = Application.DefaultFilePath
    If Right(DefPath, 1) <> "\" Then
        DefPath = DefPath & "\"
    End If


    'Create empty Zip File
    NewZip (FileNameZip)

    Set oApp = CreateObject("Shell.Application")
    'Copy the files to the compressed folder
    oApp.Namespace(FileNameZip).CopyHere oApp.Namespace(FolderName).Items

    'Keep script waiting until Compressing is done
    On Error Resume Next
    Do Until oApp.Namespace(FileNameZip).Items.Count = _
       oApp.Namespace(FolderName).Items.Count
        Application.Wait (Now + TimeValue("0:00:01"))
    Loop
    On Error GoTo 0

    MsgBox "You find the zipfile here: " & FileNameZip
End Sub

Sub NewZip(sPath)
'Create empty Zip File
'Changed by keepITcool Dec-12-2005
    If Len(Dir(sPath)) > 0 Then Kill sPath
    Open sPath For Output As #1
    Print #1, Chr$(80) & Chr$(75) & Chr$(5) & Chr$(6) & String(18, 0)
    Close #1
End Sub
