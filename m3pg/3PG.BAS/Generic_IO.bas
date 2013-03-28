Attribute VB_Name = "Generic_IO"
Option Explicit
Option Base 1

'______________________________________________________________________
'
' Module : Generic_IO - Generic spreadsheet helper routines
'
'
' This module provides generic tools for handling error message, input
' and output to and from worksheets, and so on.
'
' The intent is to divorce other modules from the specifics of Excel,
' and to make the code more readable!
'______________________________________________________________________



'These are error codes returned by generic input routines

Public Const _
  errOK = 0, _
  errLocateFail = 1, _
  errBlankCell = 2

Public errCode As Integer     'input error code from last cell input


'Variables associated with data i/o to spreadsheets

Public inputSheet As String                'Name of current input sheet
Public outputSheet As String               'Name of current output sheet
Public inRow As Integer, inCol As Integer  'Last input cell referenced
                                           
'The cell found by locateCell
Public cellFound As Object

'______________________________________________________________________
'
' Some generally useful procedures
'______________________________________________________________________

Function monthName(month As Integer) As String
'Return a string for the names of the months
Dim s As String
  If month > 12 Then month = month - 12
  Select Case month
    Case 1: s = "Jan"
    Case 2: s = "Feb"
    Case 3: s = "Mar"
    Case 4: s = "Apr"
    Case 5: s = "May"
    Case 6: s = "Jun"
    Case 7: s = "Jul"
    Case 8: s = "Aug"
    Case 9: s = "Sep"
    Case 10: s = "Oct"
    Case 11: s = "Nov"
    Case 12: s = "Dec"
    Case Else: s = "???"
  End Select
  monthName = s
End Function

Public Function monthNbr(month As String) As Integer
'Convert a month name into an integer
Dim s As String, i As Integer
  s = LCase(Left(Trim(month), 3))
  Select Case s
  Case "0":         i = 0
  Case "1", "jan":  i = 1
  Case "2", "feb":  i = 2
  Case "3", "mar":  i = 3
  Case "4", "apr":  i = 4
  Case "5", "may":  i = 5
  Case "6", "jun":  i = 6
  Case "7", "jul":  i = 7
  Case "8", "aug":  i = 8
  Case "9", "sep":  i = 9
  Case "10", "oct": i = 10
  Case "11", "nov": i = 11
  Case "12", "dec": i = 12
  Case Else
    i = 0
    showError _
      "Invalid month", _
      "'" & month & "' was not interpreted as the" & vbCrLf & _
      "name or number of a month."
  End Select
  monthNbr = i
End Function


'______________________________________________________________________
'
' Display of error messages
'______________________________________________________________________

Public Sub fatalError(title As String, message As String)
'Display message and terminate run when user acknowledges
  MsgBox message, vbCritical, title
  End
End Sub

Public Sub abortOnYes(title As String, message As String)
'Display message and terminate run when user acknowledges
Dim ans As String
  ans = MsgBox(message, vbYesNo + 32, title)
  If ans = vbYes Then End
End Sub

Public Sub abortOnNo(title As String, message As String)
'Display message and terminate run when user acknowledges
Dim ans As String
  ans = MsgBox(message, vbYesNo + 32 + 256, title)
  If ans = vbNo Then End
End Sub

Public Sub showError(title As String, message As String)
'Display message and continue run when user acknowledges
  MsgBox message, vbInformation, title
End Sub


'______________________________________________________________________
'
' Addressing cells
'______________________________________________________________________

Private Function colStr(col As Integer) As String
'Converts a column number into its alphabetic address
Dim c As Integer, s As String
  s = ""
  c = col
  Do While c > 0
    s = Chr(64 + c - 26 * Int((c - 1) / 26)) & s
    c = Int(c / 26)
  Loop
  colStr = s
End Function

Private Function cellAddress(row As Integer, col As Integer) As String
'Format the address of cell(row,col)
  cellAddress = "$" & colStr(col) & "$" & val(row)
End Function


'______________________________________________________________________
'
' A generic spreadsheet search facility ...
'______________________________________________________________________

Public Sub locateCell _
  (sheet As String, startFrom As Variant, keyWord As String, _
   row As Integer, col As Integer)
'Locate the first cell on a worksheet containing a specified string.
'Parameters are:
'  sheet    = name of target worksheet
'  keyWord  = target string
'  row, col = location of the cell
  With Sheets(sheet).Cells
    If startFrom = "" Then
      Set cellFound = .Find _
        (What:=keyWord, LookIn:=xlValues, LookAt:=xlWhole, _
         SearchOrder:=xlByRows, SearchDirection:=xlNext, MatchCase:=False)
    Else
      Set cellFound = .Find _
        (What:=keyWord, after:=Range(startFrom), LookIn:=xlValues, LookAt:=xlWhole, _
         SearchOrder:=xlByRows, SearchDirection:=xlNext, MatchCase:=False)
    End If
    If cellFound Is Nothing Then
      errCode = errLocateFail
      row = 0
      col = 0
    Else
      errCode = errOK
      row = cellFound.row
      col = cellFound.Column
    End If
  End With
End Sub


'______________________________________________________________________
'
' Checking existence of worksheets
'______________________________________________________________________

Public Function validSheetName(sheetName As String) As Boolean
'Returns TRUE if the worksheet "sheetName" exists
Dim junk As Variant
  On Error GoTo InvalidSheet
  junk = Sheets(sheetName).Cells(1, 1).Value
  On Error GoTo 0
  validSheetName = True
  Exit Function
InvalidSheet:
  validSheetName = False
End Function


'______________________________________________________________________
'
' Formating and checking kewords or names
'______________________________________________________________________

Private Function stripName(Name As String) As String
'Removes trailing "=" or ":" from a string and then trims it
Dim i As Integer
  i = InStr(1, Name, "="):  If i > 0 Then Name = Left(Name, i - 1)
  i = InStr(1, Name, ":"):  If i > 0 Then Name = Left(Name, i - 1)
  stripName = Trim(Name)
End Function

Public Function getName(sheet As String, row As Integer, col As Integer) As String
'Gets and strips the string value in a cell
  getName = stripName(Sheets(sheet).Cells(row, col).Value)
End Function

Public Function namesMatch _
  (ByVal name1 As String, ByVal name2 As String) As Boolean
'Returns TRUE if two stripped names match - matching is NOT case sensitive
' A blank name1 returns false
  name1 = stripName(UCase(name1))
  name2 = stripName(UCase(name2))
  namesMatch = (name1 <> "") And (name1 = name2)
End Function



'______________________________________________________________________
'
' Generic routines for handling input from worksheets, including
' limited error checking.
'______________________________________________________________________


Public Function isTrue(x As String) As Boolean
'Returns TRUE if the string "x" begins with a "y" or "Y"
  isTrue = Left(Trim(UCase(x)), 1) = "Y"
End Function

Private Sub badNumber(x As Variant, row As Integer, col As Integer)
'Display error mesage for badly formatted numerical input
  fatalError _
    "Fatal input error", _
    "Invalid real number : " & x & vbCrLf & vbCrLf & _
    "At " & cellAddress(row, col) & " on sheet " & inputSheet
End Sub

Public Sub emptyCell(row As Integer, col As Integer)
'Display error message when an input cell is blank
  fatalError _
    "Fatal input error", _
    "The cell " & cellAddress(row, col) & " on the sheet " & _
    inputSheet & " is empty"
End Sub


'Functions to read and return values from a spreadsheet by searching
'for a keyword and returning the value in the next cell to the right ...

Public Function searchValue _
  (sheet As String, _
   vblName As String, filter As String, noBlank As Boolean) As Variant
'Locate the first cell containing the string "vblname" and read the
'value in the cell to the right.
'Parameters are:
'  sheet    = name of target worksheet
'  vblName  = target string
'  filter   = the search filter, e.g. "*" to match any string
'  noBlank  = TRUE ==> blank cells give a fatal error
Dim x As String
  x = ""
  Call locateCell(sheet, "A1", vblName + filter, inRow, inCol)
  inCol = inCol + 1
  If errCode = errOK Then
    x = Sheets(sheet).Cells(inRow, inCol).Value
    If x = "" Then errCode = errBlankCell
  ElseIf noBlank Then
    fatalError _
      "Fatal input error", _
      "I could not locate a cell containing " & UCase(vblName) & vbCrLf & _
      "on the sheet '" & sheet & "'."
  End If
  searchValue = x
End Function

Public Function searchNumericValue _
  (sheet As String, _
   vblName As String, filter As String, noBlank As Boolean) As Double
'Locate the first cell containing the string "vblname" and read the
'number in the cell to the right. Parameters as in searchValue.
Dim x As String
  x = searchValue(sheet, vblName, filter, noBlank)
  If errCode = errOK Then
    If x = "" Then Call emptyCell(inRow, inCol)
    If Not IsNumeric(x) Then Call badNumber(x, inRow, inCol)
    searchNumericValue = x
  Else
    searchNumericValue = 0
  End If
End Function

Public Function searchBooleanValue _
  (sheet As String, _
   vblName As String, filter As String, noBlank As Boolean) As Double
'Locate the first cell containing the string "vblname" and read the
'boolean in the next cell to the right. Parameters as in searchValue.
Dim x As String
  x = searchValue(sheet, vblName, filter, noBlank)
  searchBooleanValue = isTrue(x)
End Function


'Functions to get values from a specified cell - and move to the next
'row or column if required ...

Public Function getValue(row As Integer, col As Integer) As Variant
'Returns the value in the cell (row,col)
'Fatal error if the cell is blank
Dim x As Variant
  x = Sheets(inputSheet).Cells(row, col).Value
  If x = "" Then Call emptyCell(row, col)
  getValue = x
End Function

Public Function getNumericValue(row As Integer, col As Integer) As Variant
'Returns the value the cell (row,col)
'Fatal error if the cell is not a valid number
Dim x As Variant
  x = getValue(row, col)
  If Not IsNumeric(x) Then Call badNumber(x, row, col)
  getNumericValue = x
End Function

Public Function getRowValue(row As Integer, col As Integer) As Variant
'Returns value from the cell (row,col) and moves the reference cell
'one cell right
  getRowValue = getValue(row, col)
  col = col + 1
End Function

Public Function getRowNumericValue(row As Integer, col As Integer) As Double
'Returns value from the cell (row,col) as a number and moves the
'reference cell one cell right
Dim inpStr As String
  inpStr = getValue(row, col)
  If Not IsNumeric(inpStr) Then Call badNumber(inpStr, row, col)
  getRowNumericValue = inpStr
  col = col + 1
End Function

Public Function getColValue(row As Integer, col As Integer) As Variant
'Returns value from the cell (row,col) and moves the reference cell
'one row down
  getColValue = getValue(row, col)
  row = row + 1
End Function

Public Function getColNumericValue(row As Integer, col As Integer) As Double
'Returns value from the cell (row,col) as a number and moves the
'reference cell one row down
Dim inpStr As String
  inpStr = getValue(row, col)
  If Not IsNumeric(inpStr) Then Call badNumber(inpStr, row, col)
  getColNumericValue = inpStr
  row = row + 1
End Function


'______________________________________________________________________
'
' Generic helper routines for handling output to worksheets
'______________________________________________________________________


Public Sub ClearOutputRegion _
  (sheet As String, row1 As Integer, col1 As Integer)
'Clear the contents from a rectangular region of cells, or if either
'row1 or col1 are zero clear the sheet.
'   (row1, col1) is the top left hand corner.
'   The bottom left hand corner is found by scanning down col1 until
'   a blank cell is found, backing up one row and then scanning right
'   until a blank cell is found.
'   This region is then extended by a row of cells and cleared of
'   contents but not formats.
Dim row As Integer, col As Integer, s As String
  If row1 * col1 = 0 Then
    Sheets(sheet).Cells.ClearContents
  Else
    row = row1
    col = col1
    s = Sheets(sheet).Cells(row, col).Value
    If s = "" Then Exit Sub
    'The top left hand corner is not blank, so find the bottom row.
    Do While s <> ""
      row = row + 1
      s = Sheets(sheet).Cells(row, col).Value
    Loop
    row = row - 1
    s = Sheets(sheet).Cells(row, col).Value
    'Now find the right hand column
    Do While s <> ""
      col = col + 1
      s = Sheets(sheet).Cells(row, col).Value
    Loop
    'Define the region and clear
    row = row + 1
    col = col - 1
    s = colStr(col1) & Trim(Str(row1)) & ":" & colStr(col) & Trim(Str(row))
    Sheets(sheet).Range(s).ClearContents
  End If
End Sub

Public Sub FormatHeading _
(row As Integer, col1 As Integer, col2 As Integer, size As Integer, wrap As Boolean)
'Format a region of cells for a heading
'  row        = row number of region to be formatted
'  col1, col2 = first and last columns of region to be foramtted
  If UCase(ActiveSheet.Name) <> UCase(outputSheet) Then Exit Sub
  With Sheets(outputSheet).Range(Cells(row, col1), Cells(row, col2))
    If wrap _
      Then .HorizontalAlignment = xlCenter _
      Else .HorizontalAlignment = xlLeft
    .VerticalAlignment = xlCenter
    .WrapText = wrap
    .Font.Bold = True
    .Font.size = size
  End With
End Sub

Public Sub writeData(sheet As String, x, row As Integer, col As Integer)
'Write data in cell (row, col) and leave the reference cell in place
  Sheets(sheet).Cells(row, col).Value = x
End Sub

Public Sub writeColData(Name As String, x, row As Integer, col As Integer, showName As Boolean)
'Write data in cell (row, col) and move the reference cell
'one cell down
  If showName _
    Then Sheets(outputSheet).Cells(row, col).Value = Name _
    Else Sheets(outputSheet).Cells(row, col).Value = x
  row = row + 1
End Sub

Public Sub writeRowData(Name As String, x, row As Integer, col As Integer, showName As Boolean)
'Write data in cell (row, col) and move the reference cell
'one cell to the right
  If showName _
    Then Sheets(outputSheet).Cells(row, col).Value = Name _
    Else Sheets(outputSheet).Cells(row, col).Value = x
  col = col + 1
End Sub

