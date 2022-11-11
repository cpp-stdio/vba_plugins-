VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "OpenBook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'------------------------------------------------------------------------------------------------------------------------------
'
'   XLSM,XLSX,XLS���A��{�I�ȃG�N�Z���t�@�C�����J���܂��B
'   �ŏI�m�F : Office Professional Plus 2010 , 14.0.7145.5000(32�r�b�g)
'
'------------------------------------------------------------------------------------------------------------------------------
Private Type sheet
    work As Worksheet   '�V�[�g�̑S�̏��
    name As String      '�V�[�g�̖��O
    cordName As String  '�V�[�g�̃R�[�h��
End Type

Dim book As Workbook     '�u�b�N�f�[�^
Dim bookName As String   '�u�b�N�f�[�^�̖��O
Dim shareFlag As Boolean '���L���[�h�̗v��(�v(True)�A��(False))
Dim sheets() As sheet    '�V�[�g
'------------------------------------------------------------------------------------------------------------------------------
'   �R���X�g���N�^
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Initialize()
    Set book = Nothing
    shareFlag = False
    ReDim sheets(0)
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   �f�X�g���N�^
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Terminate()
    Call CloseFile
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   �t�@�C���I�[�v�� : �J����(True)�J���Ȃ�����(False)
'------------------------------------------------------------------------------------------------------------------------------
Public Function OpenFile(fileNamePath As String, Optional PasswordOrKey As String = "") As Boolean
    '�t�@�C���̑��݃`�F�b�N
    bookName = Dir(fileNamePath) '�u�b�N�̖��O���擾
    If Not bookName <> "" Then
        bookName = ""
        OpenFile = False
        Exit Function
    End If
    
    
    '�����u�b�N���J���Ă���ꍇ�́A���̃u�b�N���g�p����B
    Dim BookFlag As Boolean: BookFlag = False
    For Each book In Workbooks
        If StrComp(book.name, bookName, vbBinaryCompare) = 0 Then
            BookFlag = True
            Exit For
        End If
    Next
     
On Error GoTo ErrorHandler '���L�ŃG���[���������邽��

    If Not BookFlag Then
        '�G�N�Z�����擾
        Set book = Nothing
        '�p�X���[�h���|�����Ă����ꍇ�̏���
        If StrComp(PasswordOrKey, "", vbBinaryCompare) = 0 Then
            Set book = Workbooks.Open(fileNamePath, 3)
        Else
            Workbooks.Open fileName:=fileNamePath, ReadOnly:=False, password:=PasswordOrKey, _
                           WriteResPassword:=PasswordOrKey, IgnoreReadOnlyRecommended:=True
            
            Application.Wait Now + TimeValue("0:00:03") '�O�̂��ߊJ���I���̂�҂�
            Set book = Application.ActiveWorkbook
        End If
    End If
    '���L���[�h�Ȃ̂����m�F
    shareFlag = book.MultiUserEditing
    If shareFlag Then
        'Application.DisplayAlerts = False
        book.ExclusiveAccess
        'Application.DisplayAlerts = True
    End If
    
    '�V�[�g���̎擾
    Dim sheetLength As Long: sheetLength = book.Worksheets.count
    ReDim sheets(sheetLength - 1)
    
    Dim i As Long
    For i = 0 To sheetLength - 1
        Set sheets(i).work = book.sheets(i + 1)
        sheets(i).name = sheets(i).work.name
        sheets(i).cordName = sheets(i).work.CodeName
    Next i
    OpenFile = True
    Exit Function
ErrorHandler:
    OpenFile = False
End Function

'------------------------------------------------------------------------------------------------------------------------------
'   �t�@�C���N���[�Y
'
'   2019/01/16 �ǋL
'   ���L�̏ꍇ�͒N�����J���Ă���ƕۑ��ł����ɃG���[������������A�v���O��������~���܂��B
'   ���͔[�i����Ȃ̂ŁA���̂܂ܕ��u���܂��B
'------------------------------------------------------------------------------------------------------------------------------
Public Function CloseFile()
    '�V�[�g�������
    If UBound(sheets) > 0 Then
        Dim i As Long
        For i = 0 To UBound(sheets)
            Set sheets(i).work = Nothing
        Next
    End If
    '�u�b�N�������
    If Not book Is Nothing Then
        '���L���|�����Ă����ꍇ�A��������
        If shareFlag Then
            'Application.DisplayAlerts = False
            book.SaveAs fileName:=book.FullName, accessMode:=xlShared
            book.Close (False)
            'Application.DisplayAlerts = True
        Else
            book.Close (False)
        End If
        
        Set book = Nothing
    End If
End Function
'------------------------------------------------------------------------------------------------------------------------------
'�V�[�g���ŃV�[�g�������擾
'------------------------------------------------------------------------------------------------------------------------------
Private Function GetSheetIndex(name As String) As Long
    Dim i As Long: i = 0
    GetSheetIndex = -&HFF
    For i = 0 To UBound(sheets)
        If StrComp(sheets(i).name, name, vbBinaryCompare) = 0 Then
            GetSheetIndex = i
            Exit Function
        End If
    Next i
End Function
'------------------------------------------------------------------------------------------------------------------------------
'
'   �Q�b�^�[
'
'------------------------------------------------------------------------------------------------------------------------------
Public Function GetBook() As Workbook
    Set GetBook = book
End Function
Public Function GetBookName() As String
    GetBookName = bookName
End Function

Public Function GetSheetLength() As Long
    GetSheetLength = UBound(sheets)
End Function

Public Function GetSheet(Index As Long) As Worksheet
    Set GetSheetDatum = sheets(Index).work
End Function

Public Function GetSheet2(name As String) As Worksheet
    Dim Index As Long: Index = GetSheetIndex(name)
    If Index = -&HFF Then
        Set GetSheetDatum2 = Nothing
        Exit Function
    End If
    Set GetSheetDatum2 = Me.GetSheet(Index)
End Function

Public Function GetSheetNameDatum(Index As Long) As String
    GetSheetNameDatum = sheets(Index).name
End Function


'���̃u�b�N�͋��L���[�h�������̂�
Public Function GetShare() As Boolean
    GetShare = shareFlag
End Function
'�u�b�N�����Ƃ����L���[�h�ŕۑ����邩
Public Function SetShare(share As Boolean)
    shareFlag = share
End Function