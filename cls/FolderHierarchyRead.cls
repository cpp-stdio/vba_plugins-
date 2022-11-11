VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "FolderHierarchyRead"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'==============================================================================================================================
'
'   �t�H���_�̊K�w��ǂݍ��ނ��߂̃N���X
'   �쐬�� : 2017/08/21
'
'==============================================================================================================================
Dim HierarchyLength As Long          '�K�w�t�@�C����(�ċN�����̂��߂ɂ������)
Dim HierarchyFolderLength As Long    '�K�w�t�H���_��(�ċN�����̂��߂ɂ������)
Dim Hierarchical() As String         '�K�w�t�@�C���i�[�̂��߂̈ꎟ���z��
Dim HierarchicalFolder() As String   '�K�w�t�H���_�i�[�̂��߂̈ꎟ���z��
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Initialize()
    Call CloseData '�������̑�p
End Sub
Private Sub Class_Terminate()
    Call CloseData
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   �t�H���_�̊K�w��ǂݍ���
'   DeepHierarchyFlag : ����ɐ[���K�w���擾����H : �v(True).��(False),�����l(False)
'   FullPath          : �t���p�X�Ŏ擾����H       : �v(True).��(False),�����l(True)
'------------------------------------------------------------------------------------------------------------------------------
Public Sub Search(folderName As String, Optional DeepHierarchyFlag As Boolean = False, Optional FullPath As Boolean = True)
    '�K�w�ǂݍ���
    Dim Buf As String
    Buf = Dir(folderName & "\*.*")
    '�t�@�C�������擾
    Do While Buf <> ""
        ReDim Preserve Hierarchical(HierarchyLength)
        If FullPath Then
            Hierarchical(HierarchyLength) = folderName + "\" + Buf
        Else
            Hierarchical(HierarchyLength) = Buf
        End If
        HierarchyLength = HierarchyLength + 1
        Buf = Dir()
    Loop
    
    Dim f As Object
    With CreateObject("Scripting.FileSystemObject")
        For Each f In .getFolder(folderName).SubFolders
            '�t�H���_�̖��O���擾�̖��O
            ReDim Preserve HierarchicalFolder(HierarchyFolderLength)
            HierarchicalFolder(HierarchyFolderLength) = f.path
            HierarchyFolderLength = HierarchyFolderLength + 1
            '����ɐ[���K�w�ɐ���K�v������ꍇ�A�ċN�����J�n
            If DeepHierarchyFlag Then
                Call Search(f.path, DeepHierarchyFlag, FullPath)
            End If
        Next f
    End With
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   ����̊g���q�ɍi�荞�� ����Search���Ɏ��s���ĂȂ��ƈӖ��Ȃ���B(���O��Clone�֐��ĂԂ̂��������߂���)
'   ExtensionName : ��.�e�L�X�g(.txt)�̏ꍇ"txt"�Ɠ��͂��āB�ŏ��̃h�b�g�͂���Ȃ�
'------------------------------------------------------------------------------------------------------------------------------
Public Function ExtensionSearch(ExtensionName As String) As Boolean
    ExtensionSearch = False
    '�f�[�^���Ȃ��ꍇ�͏����ł��Ȃ�
    If HierarchyLength = 0 Then
        Exit Function
    End If
    
    Dim i As Long:
    Dim count As Long: count = 0
    Dim Temporary() As String
    
    For i = 0 To HierarchyLength - 1
        '��ԍŌオ�g���q�Ȃ̂�
        Dim extension As Variant
        extension = Split(Hierarchical(i), ".")
        'OS�̎d�l��A�啶���������͓����g���q
        If StrComp(UCase(ExtensionName), UCase(extension(UBound(extension))), vbBinaryCompare) = 0 Then
            ReDim Preserve Temporary(count)
            Temporary(count) = Hierarchical(i)
            count = count + 1
        End If
    Next i
    '���̊g���q���Ȃ��ꍇ�͍č\�z�͂��Ȃ�
    If count = 0 Then
        Exit Function
    End If
    
    '�f�[�^�̍č\�z
    HierarchyLength = count
    ReDim Hierarchical(HierarchyLength - 1)
    Hierarchical = Temporary
    ExtensionSearch = True
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   �w��t�@�C���̉��̊K�w�̃t�@�C���A�t�H���_�����ׂč폜����
'------------------------------------------------------------------------------------------------------------------------------
Public Function DeleteAll(folderName As String)
    
    Dim Buf As String
    Buf = Dir(folderName & "\*.*")
    '�t�@�C�����폜
    Do While Buf <> ""
        Kill folderName + "\" + Buf
        Buf = Dir()
    Loop
    
    Dim f As Object
    Dim fileSystem As Object
    Set fileSystem = CreateObject("Scripting.FileSystemObject")
    '�t�H���_���폜
    For Each f In fileSystem.getFolder(folderName).SubFolders
            fileSystem.DeleteFolder f.path, True
    Next f
    
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   �t�@�C���Q�b�^�[
'------------------------------------------------------------------------------------------------------------------------------
Public Function getFileLength() As Long
    getFileLength = HierarchyLength - 1
End Function
Public Function getFileDatum(Index As Long) As String
    getFileDatum = Hierarchical(Index)
End Function
Public Function getFileData() As String()
    getFileData = Hierarchical
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   �t�H���_�[�Q�b�^�[
'------------------------------------------------------------------------------------------------------------------------------
Public Function getFolderLength() As Long
    getFolderLength = HierarchyFolderLength - 1
End Function
Public Function getFolderDatum(Index As Long) As String
    getFolderDatum = HierarchicalFolder(Index)
End Function
Public Function getFolderData() As String()
    getFolderData = HierarchicalFolder
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   �N���[������
'------------------------------------------------------------------------------------------------------------------------------
Public Function Clone(Original As FolderHierarchyRead)
    '�K�v�ȗv�f�̎󂯓n��
    HierarchyLength = Original.GetHierarchyLength() + 1
    HierarchyFolderLength = Original.GetHierarchyFolderLength() + 1
    ReDim Hierarchical(HierarchyLength - 1)
    Hierarchical = Original.GetHierarchicalData()
    ReDim HierarchicalFolder(HierarchyFolderLength - 1)
    HierarchicalFolder = GetHierarchicalFolderData()
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   �N���[�Y
'------------------------------------------------------------------------------------------------------------------------------
Public Function CloseData()
    HierarchyLength = 0
    HierarchyFolderLength = 0
    ReDim Hierarchical(HierarchyLength)
    ReDim HierarchicalFolder(HierarchyFolderLength)
End Function
