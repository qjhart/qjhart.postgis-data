Attribute VB_Name = "Parameters"
'_______________________________
'
' Parameter input routines for 3PGpjs
'_______________________________


Option Explicit
Option Base 1


'______________________________________________________________
'
' The following read parameters from the 3PG_Parameters sheet
'______________________________________________________________


Private Sub locateParameterNames(Name As String, row0 As Integer, col0 As Integer)
  Call locateCell(ParameterSheet, "A1", Name, row0, col0)
  If errCode <> errOK Then
    fatalError _
      "Invalid parameter sheet", _
      "I could not locate the parameter name column." & vbCrLf & vbCrLf & _
      "The parameter block is corupt, or " & ParameterSheet & vbCrLf & _
      "is not the 3PG default parameter sheet."
  End If
End Sub

Private Sub checkParameterSheetFormat(Name As String, row As Integer, col As Integer)
'Used to check if a cell contains a specific value
Dim s As String, i As Integer
  s = getName(inputSheet, row, col)
  i = InStr(1, LCase(s), LCase(Name), 1)
  If i = 0 Then
    fatalError _
      "Invalid parameter sheet", _
      "I could not locate " & UCase(Name) & " on " & ParameterSheet & "." & _
      vbCrLf & vbCrLf & _
      "The parameter block is corrupt, or " & ParameterSheet & vbCrLf & _
      "is not the 3PG default parameter sheet."
  End If
End Sub

Private Sub readDefaultOptions()
'Read default options from the parameters sheet
Dim row As Integer, col As Integer, Name As String
  inputSheet = ParameterSheet
  Call locateCell(inputSheet, "A1", "Standard 3PGpjs options", row, col)
  row = row + 2
  col = col + 1
  defOutputFrequency = parseOutputFrequency(getColValue(row, col))
  clearOutput = isTrue(getColValue(row, col))
  Call checkParameterSheetFormat("Output variables", row, col - 1)
  'scan along the current row to get variable names (quit if blank)
  Name = getName(inputSheet, row, col)
  defVars = 0
  Do While Name <> ""
    defVars = defVars + 1
    ReDim Preserve defVarNames(defVars)
    defVarNames(defVars) = Name
    col = col + 1
    Name = getName(inputSheet, row, col)
  Loop
End Sub

Public Sub readDefaultParameters()
'This procedure assigns or reads the values of the parameters
Dim row0 As Integer, col0 As Integer
Dim rowN As Integer, colN As Integer
Dim row As Integer, col As Integer
  inputSheet = ParameterSheet
  'if ParameterSheet does not exist, use the internal default parameter values
  If Not validSheetName(ParameterSheet) Then
    showError _
      "Missing parameter sheet", _
      "The parameter sheet " & ParameterSheet & " does not exist." & vbCrLf & vbCrLf & _
      "3-PG's built-in default parameters will be used."
    Call assignDefaultParameters
    Exit Sub
  End If
  'OK, ParameterSheet does exist, now read parameters from it.
  'First, locate the "Name" column and check the first entry ...
  Call locateParameterNames("Name", rowN, colN)
  Call checkParameterSheetFormat("pfs2", rowN + 2, colN)
  '... and then find the values column for the current species ...
  Call locateCell(ParameterSheet, "A1", SpeciesName, row0, col0)
  If errCode <> errOK Then
    showError _
      "Unknown species", _
      ParameterSheet & " does not have parameters for the species " & _
      UCase(SpeciesName) & "." & vbCrLf & vbCrLf & _
      "The 3-PG inbuilt default parameters will be used."
    Call assignDefaultParameters
    Exit Sub
  End If
  'So, everything is fine so far. Read the parameters ...
  row = row0 + 2
  col = col0
  'allometric relationships & partitioning
  pFS2 = getColNumericValue(row, col)
  pFS20 = getColNumericValue(row, col)
  StemConst = getColNumericValue(row, col)
  StemPower = getColNumericValue(row, col)
  pRx = getColNumericValue(row, col)
  pRn = getColNumericValue(row, col)
  row = row + 1
  'temperature modifier (cardinal temperatures)
  Tmin = getColNumericValue(row, col)
  Topt = getColNumericValue(row, col)
  Tmax = getColNumericValue(row, col)
  row = row + 1
  'frost modifier
  kF = getColNumericValue(row, col)
  row = row + 1
  'soil water modifier (soil characteristics)
  SWconst0 = getColNumericValue(row, col)
  SWpower0 = getColNumericValue(row, col)
  row = row + 1
  'fertility effects
  m0 = getColNumericValue(row, col)
  fN0 = getColNumericValue(row, col)
  row = row + 1
  'age modifier
  MaxAge = getColNumericValue(row, col)
  nAge = getColNumericValue(row, col)
  rAge = getColNumericValue(row, col)
  row = row + 1
  'litterfall & root turnover
  gammaFx = getColNumericValue(row, col)
  gammaF0 = getColNumericValue(row, col)
  tgammaF = getColNumericValue(row, col)
  Rttover = getColNumericValue(row, col)
  row = row + 1
  'conductances
  MaxCond = getColNumericValue(row, col)
  LAIgcx = getColNumericValue(row, col)
  CoeffCond = getColNumericValue(row, col)
  BLcond = getColNumericValue(row, col)
  row = row + 1
  'stem mortality
  wSx1000 = getColNumericValue(row, col)
  thinPower = getColNumericValue(row, col)
  mF = getColNumericValue(row, col)
  mR = getColNumericValue(row, col)
  mS = getColNumericValue(row, col)
  row = row + 1
  'canopy structure and processes
  SLA0 = getColNumericValue(row, col)
  SLA1 = getColNumericValue(row, col)
  tSLA = getColNumericValue(row, col)
  k = getColNumericValue(row, col)
  fullCanAge = getColNumericValue(row, col)
  MaxIntcptn = getColNumericValue(row, col)
  LAImaxIntcptn = getColNumericValue(row, col)
  alpha = getColNumericValue(row, col)
  row = row + 1
  'branch & bark fraction
  fracBB0 = getColNumericValue(row, col)
  fracBB1 = getColNumericValue(row, col)
  tBB = getColNumericValue(row, col)
  row = row + 1
  'various
  y = getColNumericValue(row, col)
  Density = getColNumericValue(row, col)
  row = row + 1
  'conversions
  Qa = getColNumericValue(row, col)
  Qb = getColNumericValue(row, col)
  gDM_mol = getColNumericValue(row, col)
  molPAR_MJ = getColNumericValue(row, col)
  'This should have been the last parameter, so check the last name ...
  Call checkParameterSheetFormat("molPAR_MJ", row - 1, colN)
  'Now assign the default 3PGpjs run-time options ...
  Call readDefaultOptions
End Sub



'________________________________________________________________
'
' The following assigns values to parameters
'________________________________________________________________


Public Sub setParameter(Name As String, x As Variant)
'Given the name and value for a parameter, assign the value to the
'appropriate parameter
  If namesMatch(Name, "pfs2") Then
    pFS2 = x
  ElseIf namesMatch(Name, "pfs20") Then: pFS20 = x
  ElseIf namesMatch(Name, "stemconst") Then: StemConst = x
  ElseIf namesMatch(Name, "stempower") Then: StemPower = x
  ElseIf namesMatch(Name, "prx") Then: pRx = x
  ElseIf namesMatch(Name, "prn") Then: pRn = x
  ElseIf namesMatch(Name, "tmax") Then: Tmax = x
  ElseIf namesMatch(Name, "tmin") Then: Tmin = x
  ElseIf namesMatch(Name, "topt") Then: Topt = x
  ElseIf namesMatch(Name, "kF") Then: kF = x
  ElseIf namesMatch(Name, "gammafx") Then: gammaFx = x
  ElseIf namesMatch(Name, "gammaF0") Then: gammaF0 = x
  ElseIf namesMatch(Name, "tgammaF") Then: tgammaF = x
  ElseIf namesMatch(Name, "rttover") Then: Rttover = x
  ElseIf namesMatch(Name, "maxcond") Then: MaxCond = x
  ElseIf namesMatch(Name, "laigcx") Then: LAIgcx = x
  ElseIf namesMatch(Name, "coeffcond") Then: CoeffCond = x
  ElseIf namesMatch(Name, "blcond") Then: BLcond = x
  ElseIf namesMatch(Name, "m0") Then: m0 = x
  ElseIf namesMatch(Name, "fN0") Then: fN0 = x
  ElseIf namesMatch(Name, "alpha") Then: alpha = x
  ElseIf namesMatch(Name, "swconst") Then: SWconst0 = x
  ElseIf namesMatch(Name, "swpower") Then: SWpower0 = x
  ElseIf namesMatch(Name, "maxage") Then: MaxAge = x
  ElseIf namesMatch(Name, "wSx1000") Then: wSx1000 = x
  ElseIf namesMatch(Name, "thinpower") Then: thinPower = x
  ElseIf namesMatch(Name, "mf") Then: mF = x
  ElseIf namesMatch(Name, "mr") Then: mR = x
  ElseIf namesMatch(Name, "ms") Then: mS = x
  ElseIf namesMatch(Name, "nage") Then: nAge = x
  ElseIf namesMatch(Name, "rage") Then: rAge = x
  ElseIf namesMatch(Name, "sla0") Then: SLA0 = x
  ElseIf namesMatch(Name, "sla1") Then: SLA1 = x
  ElseIf namesMatch(Name, "tsla") Then: tSLA = x
  ElseIf namesMatch(Name, "fullcanage") Then: fullCanAge = x
  ElseIf namesMatch(Name, "fracbb0") Then: fracBB0 = x
  ElseIf namesMatch(Name, "fracbb1") Then: fracBB1 = x
  ElseIf namesMatch(Name, "tbb") Then: tBB = x
  ElseIf namesMatch(Name, "k") Then: k = x
  ElseIf namesMatch(Name, "y") Then: y = x
  ElseIf namesMatch(Name, "maxintcptn") Then: MaxIntcptn = x
  ElseIf namesMatch(Name, "laimaxintcptn") Then: LAImaxIntcptn = x
  ElseIf namesMatch(Name, "density") Then: Density = x
  ElseIf namesMatch(Name, "qa") Then: Qa = x
  ElseIf namesMatch(Name, "qb") Then: Qb = x
  ElseIf namesMatch(Name, "gdm_mol") Then: gDM_mol = x
  ElseIf namesMatch(Name, "molpar_mj") Then: molPAR_MJ = x
  Else
    kwClass = kwError
    Exit Sub
  End If
  kwClass = kwParameter
End Sub

Public Function isParameter(Name As String) As Boolean
'This is true if "name" is in the parameter names dictionary
Dim x As Variant
  Call setParameter(Name, x)
  isParameter = (kwClass = kwParameter)
End Function

