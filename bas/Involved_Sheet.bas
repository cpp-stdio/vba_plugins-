Attribute VB_Name = "Involved_Sheet"
Option Explicit
'##############################################################################################################################
'
'   シート関連
'
'   新規作成日 : 2017/08/30
'   最終更新日 : 2022/11/11
'
'   新規作成エクセルバージョン : Office Professional Plus 2010 , 14.0.7145.5000(32ビット)
'   最終更新エクセルバージョン : Office Professional Plus 2016 , 16.0.5.56.1000(32ビット)
'
'##############################################################################################################################

'==============================================================================================================================
'   その名前がシート名に適切な名前であるか検査する
'
'   戻り値 : OK(True), NG(False)
'
'   sheetName : シート名
'==============================================================================================================================
Public Function checkSheetName(ByVal sheetName As String) As Boolean
    checkSheetName = False
    '条件その1 : 空の名前ではない。
    If StrComp(sheetName, "", vbBinaryCompare) = 0 Then Exit Function
    '条件その2 : 含んではいけない文字列がない。
    Dim textFor As Variant
    For Each textFor In Array(":", "\", "/", "?", "*", "[", "]")
        If InStr(sheetName, CStr(textFor)) > 0 Then Exit Function
    Next textFor
    '条件その3 : 名前は31文字以内である。
    If Len(sheetName) > 31 Then Exit Function
    '条件その4 : 同名のシートは存在出来ない。
    'aNewSheetにて不具合が発生したので分割する。
    checkSheetName = True
End Function

'==============================================================================================================================
'   等しい名前のシートを探す
'
'   戻り値 : 等しい名前を持つシート。ない場合は、Nothingが返却される
'
'   sheetName : シート名
'   book : 対象のブック（任意）
'==============================================================================================================================
Public Function sheetToEqualsName(ByVal sheetName As String, Optional ByRef book As Workbook = Nothing) As Worksheet

    Dim searchBook As Workbook
    If book Is Nothing Then
        Set searchBook = ThisWorkbook
    Else
        Set searchBook = book
    End If

    Dim sheet As Worksheet
    For Each sheet In searchBook.Sheets
        If StrComp(sheet.name, sheetName, vbBinaryCompare) = 0 Then
            Set sheetToEqualsName = sheet
            Exit Function
        End If
    Next
    Set sheetToEqualsName = Nothing
End Function

'==============================================================================================================================
'   新たなシートを作成
'
'   戻り値 :新規作成されたWorksheetが返却され、作成済の場合はそのWorksheetが返却される。
'           作成出来なかった場合はNothingが返却される
'
'   sheetName : シート名
'   book : 対象のブック（任意、未入力の場合ThisWorkbook）
'==============================================================================================================================
Public Function aNewSheet(ByVal sheetName As String, Optional ByRef book As Workbook = Nothing) As Worksheet
    Set aNewSheet = Nothing
    '適切な名前でない場合
    If Not checkSheetName(sheetName) Then Exit Function
    '対象のブックが入力されていない場合
    Dim addBook As Workbook
    If book Is Nothing Then
        Set addBook = ThisWorkbook
    Else
        Set addBook = book
    End If
    '作成済みかを検索
    Dim sheet As Worksheet
    Set sheet = sheetToEqualsName(sheetName, addBook)
    If Not sheet Is Nothing Then
        Set aNewSheet = sheet
        Exit Function
    End If
    '新たなシートを作成
    Set sheet = addBook.Sheets.Add()
    sheet.name = sheetName
    sheet.Activate 'アクティブ化しておいた方が見た目は良い。
    Set aNewSheet = sheet
End Function

'==============================================================================================================================
'   シートを削除する
'
'   戻り値 : 成功(True), 失敗(False)
'
'   sheet : 削除するシート。成功した場合、アクセス不可になるので注意が必要
'   book  : 対象のブック（任意）
'==============================================================================================================================
Public Function aDeletedSheet(ByRef sheet As Worksheet, Optional ByRef book As Workbook = Nothing) As Boolean
    aDeletedSheet = False
    
    If sheet Is Nothing Then
        'Nothingなので、既に削除済みと仮定する。
        aDeletedSheet = True
        Exit Function
    End If
    
    Dim deleteBook As Workbook
    If book Is Nothing Then
        Set deleteBook = ThisWorkbook
    Else
        Set deleteBook = book
    End If
    
    '削除するタイミングでメッセージが表示されるが機能的に不必要なので非表示にしておく
    Application.DisplayAlerts = False
    
    Dim deleteSheet As Worksheet
    For Each deleteSheet In deleteBook.Sheets
        If StrComp(sheet.name, deleteSheet.name, vbBinaryCompare) = 0 Then
            Call deleteBook.Sheets(sheet.name).delete
            Set sheet = Nothing  'シートを削除する
            aDeletedSheet = True '戻り値を変更
            Exit For
        End If
    Next
    
    'メッセージを表示状態に戻す
    Application.DisplayAlerts = True
End Function
'==============================================================================================================================
'   シートの情報を全て削除する
'
'   sheet : 対象シート
'==============================================================================================================================
Public Function aInfoErasureSheet(ByRef sheet As Worksheet)
    Dim i As Long: i = 0
    'セルを全て削除
    sheet.cells.Clear
    sheet.Columns.Clear
    sheet.Rows.Clear
    'テーブルの情報を削除
    For i = sheet.ListObjects.Count To 1 Step -1
        Call sheet.ListObjects.item(i).delete
    Next i
    '埋め込みグラフを削除
    For i = sheet.ChartObjects.Count To 1 Step -1
        Call sheet.ChartObjects(i).delete
    Next i
    '印刷時のページ区切りを削除
    'sheet.DisplayPageBreaks = False
    'ピボットテーブルを削除
    For i = sheet.PivotTables.Count To 1 Step -1
        Call sheet.PivotTables(i).ClearTable
    Next i
    '図、クリップアート、図形、SmartArtの削除
    For i = sheet.Shapes.Count To 1 Step -1
        Call sheet.Shapes.item(i).delete
    Next i
    'ヘッター、フッターは完全に削除することは不可能らしい
    With sheet.PageSetup
        For i = .Pages.Count To 1 Step -1
            .Pages.item(i).CenterFooter = ""
            .Pages.item(i).CenterHeader = ""
            .Pages.item(i).LeftFooter = ""
            .Pages.item(i).LeftHeader = ""
            .Pages.item(i).RightFooter = ""
            .Pages.item(i).RightHeader = ""
        Next i
        .LeftHeader = ""
        .CenterHeader = ""
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = ""
        .RightFooter = ""
        .DifferentFirstPageHeaderFooter = True
    End With
    
End Function
'==============================================================================================================================
'   シート内で入力されている数式を値に変換する
'   ※1　利用する場合は「Involved_Other.bas」のインポートをお願いします
'   ※2　数式部分の自動再計算を行うので動作が重くなる可能性があります
'   ※3　「Involved_Call」に単一セルの数式を値に変換するプログラムがあります。
'
'   戻り値 : 変換完了(True), NG(False)
'
'   sheetName : シート名
'==============================================================================================================================
Public Function aSheetDeleteFormula(ByVal sheetName As String) As Boolean
    aSheetDeleteFormula = False
    Dim sheet As Worksheet
    Set sheet = sheetToEqualsName(sheetName)
    aSheetDeleteFormula = aSheetDeleteFormulaDx(sheet)
    Set sheet = Nothing
End Function

Public Function aSheetDeleteFormulaDx(ByRef sheet As Worksheet) As Boolean
    aSheetDeleteFormulaDx = False
    If sheet Is Nothing Then Exit Function
    
    Dim base As Range
    Dim cell As Range
    Dim row As Long
    Dim rowMax As Long
    Dim column As Long
    Dim columnMax As Long
    Dim text As String
    Dim value As Variant
    
    Set base = sheet.UsedRange.Range("A1")
    rowMax = sheet.UsedRange.Rows.Count - 1
    columnMax = sheet.UsedRange.Columns.Count - 1
    
    For row = rowMax To 0 Step -1
        For column = columnMax To 0 Step -1
            Set cell = base.Offset(row, column)
            
            If WorksheetFunction.IsFormula(cell) Then
                cell.Calculate '再計算
                text = cell.value
                '数値の場合はそのまま"数値"として表示させる（日付、金額等は対象外）
                If checkNumericalValue(text, value) Then
                    cell.value = value
                Else
                    cell.NumberFormatLocal = "@"
                    cell.value = text
                End If
            End If
        Next
    Next
    
    Set base = Nothing
    Set cell = Nothing
    aSheetDeleteFormulaDx = True
End Function





