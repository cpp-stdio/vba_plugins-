VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "OpenCSV"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Type DataCSV
    Index As Long
    LineData() As String
End Type

Dim Data() As DataCSV
Dim Row As Long, Column As Long '�L�[�̈ʒu����f�[�^���擾����^�C�v�p
'------------------------------------------------------------------------------------------------------------------------------
'   �R���X�g���N�^
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Initialize()
    ReDim Data(0)
    Row = 0
    Column = 0
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   �f�X�g���N�^
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Terminate()
    ReDim Data(0)
    Row = 0
    Column = 0
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   CSV�̃f�[�^���J�� : �J����(True)�J���Ȃ�����(False)
'
'   CSV_Name            : �t�@�C����(�t���p�X)
'   Separation          : CVS�ɂ́A","��"vbTab"�ȂǐF�X�Ȏ�ނ����邽�߂���ɍ��킹����؂���g��
'   IndentionKey        : ���s�R�[�h�AExcel��̂�"vbCrLf","vbLf","vbCr "��3��ނ����݂���
'   CharacterCodeName   : �����R�[�h�A"Unicode","UTF-8"�ȂǊJ�����������R�[�h���w��B
'                             ��  �]�k����Excel2010��"CSV(�J���}��؂�)"�ŕۑ������ꍇ�̊�{�����R�[�h��"Shift_JIS"
'------------------------------------------------------------------------------------------------------------------------------
Public Function OpenFile(CSV_Name As String, Optional Separation As String = ",", Optional IndentionKey As String = vbCrLf, Optional CharacterCodeName As String = "Shift_JIS") As Boolean
    '�t�@�C���̑��݃`�F�b�N
    If Not Dir(CSV_Name) <> "" Then
        OpenFile = False
        Exit Function
    End If
    
    '�f�[�^���{����CSV���g���q�𒲂ׂ�B
    Dim PassName() As String
    Dim Extension() As String
    PassName = Split(CSV_Name, "\")
    Extension = Split(PassName(UBound(PassName)), ".")
    If Not StrComp(Extension(UBound(Extension)), "csv", vbTextCompare) = 0 Then 'OS�̊֌W�ő啶���A�������̋�ʂ��t����Ȃ��B
        OpenFile = False
        Exit Function
    End If
    
    '�ǂ���琳�����f�[�^�������炵���̂ł悤�₭�t�@�C�����J��
    Dim Index       As Long
    Dim LineDataLength  As Long: LineDataLength = 0
    Dim EnterRec()  As String
    Dim StrRec()    As String
    Dim Buf         As String
    'CSV�̏����擾����
    With CreateObject("ADODB.Stream")
        .Type = 2   'adTypeText
        .Charset = CharacterCodeName
        .Open
        .LoadFromFile (CSV_Name)
        Buf = .ReadText(-1)
        .Close
        EnterRec = Split(Buf, IndentionKey)
        For Index = 0 To UBound(EnterRec)
            StrRec = Split(EnterRec(Index), Separation) '��{�A�J���}��؂�Ŕz���
            If UBound(StrRec) >= 0 Then
                ReDim Preserve Data(LineDataLength)
                Data(LineDataLength).LineData = StrRec
                Data(LineDataLength).Index = UBound(StrRec)
                LineDataLength = LineDataLength + 1
            End If
        Next Index
    End With
    OpenFile = True
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   ����̂���Ȃ���������폜 : OpenFile���Ă�ł��Ȃ��ƈӖ��͂Ȃ�
'------------------------------------------------------------------------------------------------------------------------------
Public Function DeleteString(Delete As String)
    If StrComp(Delete, "", vbBinaryCompare) = 0 Then Exit Function '���̂��߂ɌĂ񂾂̂�������Ȃ�
    Dim ColumnCount As Long: ColumnCount = 0
    Dim RowCount As Long: RowCount = 0
    '�폜����
    For ColumnCount = 0 To GetColumnLength()
        For RowCount = 0 To GetRowLength(ColumnCount)
            Data(ColumnCount).LineData(RowCount) = Replace(Data(ColumnCount).LineData(RowCount), Delete, "")
        Next RowCount
    Next ColumnCount
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   �Q�b�^�[
'------------------------------------------------------------------------------------------------------------------------------
Public Function GetColumnLength() As Long '�񐔂̎擾
    GetColumnLength = UBound(Data)
End Function
Public Function GetRowLength(ColumnNum As Long) As Long '�s���̎擾
    If ColumnNum < 0 Or ColumnNum > GetColumnLength() Then
        GetRowLength = -&HFF
    Else
        GetRowLength = Data(ColumnNum).Index
    End If
End Function
Public Function GetRowData(ColumnNum As Long) As String() '��̃f�[�^�擾
    If ColumnNum < 0 Or ColumnNum > GetColumnLength() Then
        GetRowData = ""
    Else
        GetRowData = Data(ColumnNum).LineData
    End If
End Function
Public Function GetRowDatum(ColumnNum As Long, RowNum As Long) As String '��̃f�[�^�擾
    If ColumnNum < 0 Or ColumnNum > GetColumnLength() Then
        GetRowDatum = ""
    ElseIf RowNum < 0 Or GetRowLength(ColumnNum) < 0 Or RowNum > GetRowLength(ColumnNum) Then
        GetRowDatum = ""
    Else
        GetRowDatum = Data(ColumnNum).LineData(RowNum)
    End If
End Function

'------------------------------------------------------------------------------------------------------------------------------
'
'   �L�[�̈ʒu����f�[�^���擾����^�C�v�p
'
'------------------------------------------------------------------------------------------------------------------------------
Public Function NextLine() As Boolean '�Ō�܂ŒB�������H�B���܂���(True),�܂�����(false)
    Column = Column + 1   '�s�����X�V
    Row = 0      '�񐔂�������
    If Column > GetColumnLength(Column) Then
        Column = 0
        NextLine = True
        Exit Function
    End If
    NextLine = False
End Function

'��̍ŏ�����ǂ݂����l�p
Public Function StateSearch1(State As String) As Boolean
    StateSearch1 = StateSearch2(State, 0)
End Function

'�f�[�^��r������ǂݍ��݂����l�p
Public Function StateSearch2(State As String, RowNum As Long) As Boolean
    Row = RowNum '�܂��͗񐔂�������
    Dim i As Long
    For i = 0 To GetRowLength(Row)
        If State = GetRowDatum(Column, Row) Then
            Row = Row + 1
            StateSearch2 = True
            Exit Function
        End If
        Row = Row + 1
    Next i
    StateSearch2 = False
End Function

Public Function ToString() As String
    ToString = GetRowDatum(Column, Row)
    Row = Row + 1
    If Column > GetRowLength(Column) Then
        Column = 0
    End If
End Function
Public Function ToBoolean() As Boolean   '�u�[���^(Boolean)�ւ̃f�[�^�ϊ�
    ToBoolean = CBool(ToString())
End Function
Public Function ToByte() As Byte         '�o�C�g�^(Byte)�ւ̃f�[�^�ϊ�
    ToByte = CByte(ToString())
End Function
Public Function ToCurrency() As Currency '�ʉ݌^(Currency)�ւ̃f�[�^�ϊ�
    ToCurrency = CCur(ToString())
End Function
Public Function ToDate() As Date         '���t�^(Date)�ւ̃f�[�^�ϊ�
    ToDate = CDate(ToString())
End Function
Public Function ToDouble() As Date       '�{���x���������_�����^(Double)�ւ̃f�[�^�ϊ�
    ToDouble = CDbl(ToString())
End Function
Public Function ToInteger() As Date      '�����^(Integer)�ւ̃f�[�^�ϊ�
    ToInteger = CInt(ToString())
End Function
Public Function ToLong() As Long         '�������^(Long)�ւ̃f�[�^�ϊ�
    ToLong = CLng(ToString())
End Function
Public Function ToSingle() As Single     '�P���x���������_�����^(Single)�ւ̃f�[�^�ϊ�
    ToSingle = CSng(ToString())
End Function
Public Function ToVariant() As Single     '�o���A���g�^(Variant)�ւ̃f�[�^�ϊ�
    ToVariant = CVar(ToString())
End Function