Attribute VB_Name = "Data_Input"
'_______________________________
'
' Data input routines for 3PGpjs
'_______________________________


Option Explicit
Option Base 1

'These indicate the nature of variables read via a keyword
Public Const _
  kwSiteFactor = 1, _
  kwInitial = 2, _
  kwParameter = 3, _
  kwError = 99

Public kwClass As Integer

'The following are temporary input variables transformed into 3-PG inputs
Private SeedlingMass As Double



'____________________________________________________
'
' Initialise and check 3PGpjs site and stand input data:
'____________________________________________________

Private Sub Initialise3PGpjsInput()
'Set site factors, etc to 0,
'Give all parameters their built-in default values
  siteName = "No_site"
  SpeciesName = "No_species"
  runTitle = ""
  mYears = 0
  nFertility = 0
  nMinAvailSW = 0
  nIrrigation = 0
  YearPlanted = 0
  MonthPlanted = 0
  InitialYear = -999
  InitialMonth = 0
  StartAge = -999
  EndAge = -999
  FR = -999
  soilClass = -999
  MaxASW = -999
  MinASW = 0
  ASWi = 1E+99
  StemNoi = -999
  WFi = -999
  WRi = -999
  WSi = -999
  outputFrequency = 0
  clearOutput = False
  Call assignDefaultParameters
End Sub

Public Sub Check3PGpjsInput()
'Check for fatal errors
Dim error As Boolean, n As Integer
  If InitialYear < 0 Then
    showError "3PGpjs input error", "Start year must be >= 0"
    error = True
  End If
  If EndAge < 0 Then
    showError "3PGpjs input error", "Start year must be > 0"
    error = True
  End If
  If (FR < 0) Or (FR > 1) Then
    showError "3PGpjs input error", "Fertility rating (site factors block) must be in the range 0-1"
    error = True
  End If
  If (soilClass < -1) Or (soilClass > 4) Then
    showError "3PGpjs input error", "Invalid soil type: soilClass = " & soilClass
    error = True
  End If
  If MaxASW < 0 Then
    showError "3PGpjs input error", "Maximum ASW must be > 0"
    error = True
  End If
  If StemNoi < 0 Then
    showError "3PGpjs input error", "Initial stocking must be > 0"
    error = True
  End If
  If WFi < 0 Then
    showError "3PGpjs input error", "Initial foliage biomass must be > 0"
    error = True
  End If
  If WRi < 0 Then
    showError "3PGpjs input error", "Initial root biomass must be > 0"
    error = True
  End If
  If WSi < 0 Then
    showError "3PGpjs input error", "Initial stem biomass must be > 0"
    error = True
  End If
  If nFertility > 0 Then
    For n = 1 To nFertility
      If (Fertility(2, n) < 0) Or (Fertility(2, n) > 1) Then
        showError _
          "3PGpjs input error", _
          "Fertility rating (age = " & Fertility(1, n) & ") must be in the range 0-1"
        error = True
      End If
    Next n
  End If
  If error Then fatalError "3PGpjs error", "A fatal error in initial data was encountered"
End Sub


'________________________________________________________________
'
' The following assigns values to site factors
'________________________________________________________________


Private Sub setSiteFactor(Name As String, x As Variant)
'Given the name and value for a site factor, assign the value to the
'appropriate variable
  If namesMatch(Name, "latitude") Then
    Lat = x
  ElseIf namesMatch(Name, "FR") Then: FR = x
  ElseIf namesMatch(Name, "maxasw") Then: MaxASW = x
  ElseIf namesMatch(Name, "minasw") Then: MinASW = x
  ElseIf namesMatch(Name, "soilClass") Then: soilClass = parseSoilClass(x)
  ElseIf namesMatch(Name, "wfi") Then: WFi = x
  ElseIf namesMatch(Name, "wri") Then: WRi = x
  ElseIf namesMatch(Name, "wsi") Then: WSi = x
  ElseIf namesMatch(Name, "aswi") Then: ASWi = x
  ElseIf namesMatch(Name, "stemnoi") Then: StemNoi = x
  Else
    kwClass = kwError
    Exit Sub
  End If
  kwClass = kwSiteFactor
End Sub

Private Function isSiteFactor(Name As String) As Boolean
'This is true if "name" is in the parameter names dictionary
Dim x As Variant
  x = 0
  Call setSiteFactor(Name, x)
  isSiteFactor = (kwClass = kwSiteFactor)
End Function


'________________________________________________________________
'
' Getting specific data from a single and multi-site worksheets
'________________________________________________________________


'Get specific information about a site and stand

Private Function getSiteName(sheet As String) As String
Dim inpStr As String
  inpStr = searchValue(sheet, "Site", "*", False)
  If errCode <> errOK Then
    inpStr = "No_Site_Name"
    showError _
      "Site name missing", _
      "The sheet " & sheet & " does not specify a site name." & vbCrLf & vbCrLf & _
      "'" & inpStr & "' will be used."
  End If
  getSiteName = inpStr
End Function

Private Function getSpeciesName(sheet As String) As String
Dim r As Integer, c As Integer, s As String
Dim inpStr As String
  inpStr = searchValue(sheet, "Species", "*", False)
  If inpStr = "" Then
    inpStr = "Default"
    showError _
      "Species name missing", _
      "The sheet " & sheet & " does not have a species name." & vbCrLf & vbCrLf & _
      "'Default' will be used"
  End If
  getSpeciesName = inpStr
End Function

Private Function getLatitude(sheet As String) As Double
Dim x As String
  x = searchNumericValue(sheet, "Latitude", "*", True)
'  If errCode <> errOK Then x = "0"
  getLatitude = x
End Function

Private Function getFertitlityRating(sheet As String) As Double
Dim x As String
  x = searchNumericValue(sheet, "Fertility rating", "*", True)
'  If errCode <> errOK Then x = "0"
  getFertitlityRating = x
End Function

Private Function getMaxASW(sheet As String) As Double
Dim x As String
  x = searchNumericValue(sheet, "Maximum ASW", "*", True)
'  If errCode <> errOK Then x = "0"
  getMaxASW = x
End Function

Private Function getMinASW(sheet As String) As Double
Dim x As String
  x = searchNumericValue(sheet, "Minimum ASW", "*", True)
'  If errCode <> errOK Then x = "0"
  getMinASW = x
End Function

Private Function parseSoilClass(soil As Variant) As Integer
Dim x As Integer
  Select Case soil
  Case "?":       x = -1
  Case "0":       x = 0
  Case "1", "S":  x = 1
  Case "2", "SL": x = 2
  Case "3", "CL": x = 3
  Case "4", "C":  x = 4
  Case Else
    showError _
      "Unknown soil type", _
      "'" & soil & "' is an unknown soil type. Valid types are:" & vbCrLf & vbCrLf & _
      "S  = sandy," & vbCrLf & _
      "SL = sandy loam," & vbCrLf & _
      "CL = clay loam, and" & vbCrLf & _
      "C  = clay," & vbCrLf & _
      "0  = no effect of soil water on production or conductance" & vbCrLf & _
      "or use '?' for an unknown soil type." & vbCrLf & vbCrLf & _
      "The values for SWconst and SWpower used for this run" & vbCrLf & _
      "will be those given in the 3PG parameter list. This is" & vbCrLf & _
      "also the case when the soil type is given as '?'."
    x = -1
  End Select
  parseSoilClass = x
End Function

Private Function getSoilClass(sheet As String) As Integer
Dim soil As String
  soil = UCase(searchValue(sheet, "Soil class", "*", True))
  getSoilClass = parseSoilClass(soil)
End Function

Private Function getEndAge(sheet As String) As Integer
'Detects end age, otherwise endage = 20 years
Dim x As Variant
  x = searchNumericValue(sheet, "End age", "*", True)
  If x <= 0 Then
    showError _
      "Input error", _
      "'" & x & "' is an invalid value for End Age : 20 years is assumed"
    x = 20
  End If
  getEndAge = x
End Function

Private Function getYearPlanted(sheet As String) As Integer
Dim x As String
  x = searchValue(sheet, "Year planted", "*", True)
'  If errCode <> errOK Then x = "0"
  getYearPlanted = x
End Function

Private Function getMonthPlanted(sheet As String) As Integer
Dim x As String
  x = searchValue(sheet, "Month planted", "*", True)
'  If errCode <> errOK Then x = "0"
  getMonthPlanted = monthNbr(x)
End Function

Private Function getInitialYear(sheet As String) As Integer
Dim x As String
  x = searchValue(sheet, "Initial year", "*", True)
'  If errCode <> errOK Then x = "0"
  getInitialYear = x
End Function

Private Function getInitialMonth(sheet As String) As Integer
Dim x As String
  x = searchValue(sheet, "Initial month", "*", True)
'  If errCode <> errOK Then x = "0"
  getInitialMonth = monthNbr(x)
End Function

Private Function getInitialFoliage(sheet As String) As Double
Dim x As String
  x = searchValue(sheet, "Initial WF", "*", True)
'  If errCode <> errOK Then x = "0"
  getInitialFoliage = x
End Function

Private Function getInitialRoots(sheet As String) As Double
Dim x As String
  x = searchValue(sheet, "Initial WR", "*", True)
'  If errCode <> errOK Then x = "0"
  getInitialRoots = x
End Function

Private Function getInitialStem(sheet As String) As Double
Dim x As String
  x = searchValue(sheet, "Initial WS", "*", True)
'  If errCode <> errOK Then x = "0"
  getInitialStem = x
End Function

Private Function getInitialStocking(sheet As String) As Double
Dim x As String
  x = searchValue(sheet, "Initial stocking", "*", True)
'  If errCode <> errOK Then x = "0"
  getInitialStocking = x
End Function

Private Function getInitialASW(sheet As String) As Double
Dim x As String
  x = searchValue(sheet, "Initial ASW", "*", True)
'  If errCode <> errOK Then x = "0"
  getInitialASW = x
End Function


Private Sub getSiteFactors()
'Get site factors
  Lat = getLatitude(inputSheet)
  FR = getFertitlityRating(inputSheet)
  MaxASW = getMaxASW(inputSheet)
  MinASW = getMinASW(inputSheet)
  soilClass = getSoilClass(inputSheet)
End Sub

Private Sub getInitialConditions()
'Get initial conditions
  YearPlanted = getYearPlanted(inputSheet)
  MonthPlanted = getMonthPlanted(inputSheet)
  InitialYear = getInitialYear(inputSheet)
  InitialMonth = getInitialMonth(inputSheet)
  EndAge = getEndAge(inputSheet)
  WFi = getInitialFoliage(inputSheet)
  WRi = getInitialRoots(inputSheet)
  WSi = getInitialStem(inputSheet)
  StemNoi = getInitialStocking(inputSheet)
  ASWi = getInitialASW(inputSheet)
  If InitialYear < YearPlanted Then InitialYear = YearPlanted + InitialYear
End Sub


'Get site-specific changes to current 3-PG parameter values

Private Sub getParameterValues()
Dim row As Integer, col As Integer
Dim Name As String, x As Double
  Call locateCell(inputSheet, "A1", "Parameters", row, col)
  If errCode <> errOK Then
    Exit Sub    'the parameter block is not mandatory
  End If
  row = row + 1
  col = col
  Name = getName(inputSheet, row, col)
  Do While Name <> ""
    'if you change soil chracteristics, these must overide the soil class
    If namesMatch(Name, "swconst") _
    Or namesMatch(Name, "swpower") Then soilClass = -1
    'now read a value and assign it to the parameter
    x = getNumericValue(row, col + 1)
    Call setParameter(Name, x)
    If kwClass <> kwParameter Then
      showError _
        "Unknown parameter name", _
        UCase(Name) & " is not a valid parameter name"
    End If
    row = row + 1
    Name = getName(inputSheet, row, col)
  Loop
  row = row - 1
End Sub


'Get the stand-age dependent silvilcutural factors

Private Sub getTable _
  (row0 As Integer, col0 As Integer, _
   colTable As Integer, rowTable As Integer, fTable As Variant, Name As String)
Dim s As String, row As Integer, col As Integer
Dim year As String, oldx As Double, x As Double, m As Integer, n As Integer
  rowTable = 0
  row = row0 + 1
  col = col0
  n = 0
  s = getName(inputSheet, row, col)
  If Not namesMatch(s, "AGE") Then
    fatalError _
      "Badly formatted table", _
      "The key word AGE must be immediately below the keyword " & Name
  End If
  row = row + 1
  x = -9999
  s = getName(inputSheet, row, col)
  Do While s <> ""
    oldx = x
    x = val(s)
    If x < oldx Then
      fatalError _
        "Ages not in chronological order", _
        "The ages in the table for " & Name & " are not in chronological order."
    End If
    n = n + 1
    ReDim Preserve fTable(colTable, n)
    fTable(1, n) = x
    For m = 1 To colTable - 1
      fTable(1 + m, n) = getNumericValue(row, col + m)
    Next m
    row = row + 1
    s = getName(inputSheet, row, col)
  Loop
  rowTable = n
  row = row - 1
End Sub

Public Sub getSilvicuturalEvents()
Dim row As Integer, col As Integer, col0 As Integer, n As Integer
  nFertility = 0
  nMinAvailSW = 0
  nIrrigation = 0
  nThinning = 0
  nDefoliation = 0
  'check for a defoliation block
  Call locateCell(inputSheet, "A1", "Defoliation", row, col)
  If errCode = errOK Then
    Call getTable(row, col, 2, nDefoliation, Defoliation, "DEFOLIATION")
  End If
  'check for a thinning block
  Call locateCell(inputSheet, "A1", "Thinning", row, col)
  If errCode = errOK Then
    Call getTable(row, col, 5, nThinning, Thinning, "THINNING")
  End If
  'check for a fertility block
  Call locateCell(inputSheet, "A1", "Fertility", row, col)
  If errCode = errOK Then
    Call getTable(row, col, 2, nFertility, Fertility, "FERTILITY")
  End If
  'check for a MinASW block
  Call locateCell(inputSheet, "A1", "MinASW", row, col)
  If errCode = errOK Then
    Call getTable(row, col, 2, nMinAvailSW, MinAvailSW, "MINASW")
  End If
  'check for an irrigation block
  Call locateCell(inputSheet, "A1", "Irrigation", row, col)
  If errCode = errOK Then
    Call getTable(row, col, 2, nIrrigation, Irrigation, "IRRIGATION")
  End If
End Sub


Public Function getNumberOfSites(sheet As String, BlockNo As Integer)
'Locate the data block identified by SITES and count the sites listed
Dim site As String, n As Integer
Static firstHit As String, thisHit As String
  'locate the data block and save its location (dRowM, dColM)
  n = 0
  If BlockNo = 1 Then
    'first time through
    Call locateCell(sheet, "A1", "Sites", dRowM, dColM)
    If errCode <> errOK Then
      fatalError _
        "Keyword SITES is missing", _
        "The keyword SITES is required to locate the list of sites" & vbCrLf & _
        "to be run and the data block supplying data for this run."
    End If
    thisHit = cellFound.Address
    firstHit = thisHit
    'count the sites
    site = getName(sheet, dRowM + n + 1, dColM)
    Do While site <> ""
      n = n + 1
      site = getName(sheet, dRowM + n + 1, dColM)
    Loop
    If n = 0 Then
      fatalError _
        "No sites specified", _
        "No sites were listed. There is" & vbCrLf & _
        "no point in making this run!"
    End If
  Else
    'repeating the search
    Call locateCell(sheet, thisHit, "Sites", dRowM, dColM)
    thisHit = cellFound.Address
    If (errCode = errOK) And (firstHit <> thisHit) Then
      'count the sites
      site = getName(sheet, dRowM + n + 1, dColM)
      Do While site <> ""
        n = n + 1
        site = getName(sheet, dRowM + n + 1, dColM)
      Loop
    End If
  End If
  getNumberOfSites = n
End Function

Private Sub getInputVariables(row As Integer, col As Integer)
'Scans current line to get parameter or input variable names
Dim Name As String
  noPrmtrs = 0
  Name = getName(inputSheet, row, col)
  Do While isParameter(Name) Or isSiteFactor(Name)
    noPrmtrs = noPrmtrs + 1
    ReDim Preserve prmtrNames(noPrmtrs)
    prmtrNames(noPrmtrs) = Name
    col = col + 1
    Name = getName(inputSheet, row, col)
  Loop
End Sub


'Get information controlling oputput of 3-PG results

Private Sub getOutputVariables(n As Integer, names As Variant, fatal As Boolean)
'Detects "Output data" and reads list of output variables from same row
Dim Name As String
  Name = searchValue(inputSheet, "Output data", "*", fatal)
  'scan along row to get variable names (quit if blank)
  n = 0
  Do While Name <> ""
    n = n + 1
    ReDim Preserve names(n)
    names(n) = Name
    inCol = inCol + 1
    Name = getName(inputSheet, inRow, inCol)
  Loop
End Sub

Public Function parseOutputFrequency(f As String) As Integer
Dim i As Integer
  Select Case LCase(f)
  Case "", "0", "n", "none": i = 0
  Case "1", "r", "rotation": i = 1
  Case "2", "a", "annual":   i = 2
  Case "3", "m", "monthly":  i = 3
  Case Else
    i = 1
    showError _
      "Unknown output frequency", _
      "'" & f & "' is an unknown output frequency. Valid types are:" & vbCrLf & vbCrLf & _
      "0, N, None     ==> no output" & vbCrLf & _
      "1, R, Rotation ==> output at end of rotation" & vbCrLf & _
      "2, A, Annual   ==> output at end of growth season" & vbCrLf & _
      "3, M, Monthly  ==> output at end of monthly time-step"
  End Select
  parseOutputFrequency = i
End Function

Private Function getOutputFrequency(sheet As String) As Integer
Dim f As String
  f = LCase(searchValue(inputSheet, "Output frequency", "*", False))
  If f = "" _
    Then getOutputFrequency = defOutputFrequency _
    Else getOutputFrequency = parseOutputFrequency(f)
End Function

Private Sub getOutputOptions()
Dim row As Integer, col As Integer
  ssOutputFrequency = getOutputFrequency(inputSheet)
  outputDetails = searchBooleanValue(inputSheet, "Detailed output", "*", False)
  Call locateCell(inputSheet, "A1", "#Output*", row, col)
  If errCode <> errOK Then
    fatalError _
      "No output location", _
      "I could not find a location for output on the sheet '" & inputSheet & "'" & _
      vbCrLf & vbCrLf & _
      "Ouput will commence on the row with the keyword '#Output'."
  End If
  oRowD = row
End Sub

Private Function getMetdataSheet(sheet As String) As String
'Detects metdata sheet, otherwise aborts
Dim inpStr As String
  inpStr = UCase(searchValue(sheet, "Climate data", "*", True))
  If Not validSheetName(inpStr) Then
    fatalError _
      "Metdata sheet missing", _
      "The sheet '" & inpStr & "' is not in this workbook." & vbCrLf
  End If
  getMetdataSheet = inpStr
End Function

Private Function getSeedlingMass(sheet As String) As Double
'Detects seedling mass, otherwise seedling mass = 1 gm
Dim x As Variant
  x = searchNumericValue(sheet, "Seedling mass", "*", True)
  If x <= 0 Then
    showError _
      "Input error", _
      "'" & x & "' is an invalid value for Seedling Mass : 1 gm is assumed"
    x = 1
  End If
  getSeedlingMass = x
End Function

Private Function getOutputSheet(sheet As String) As String
'Assign the output sheet
Dim s As String
  s = searchValue(sheet, "Output sheet", "*", True)
  If s = "" Or LCase(s) = "none" _
    Then getOutputSheet = sheet _
    Else getOutputSheet = s
End Function



'____________________________________________________________
'
' Procedure to read and assign data for a single site run
'____________________________________________________________


Public Sub readSingleSiteData()

'Get the various data needed to run 3PG from a site data worksheet

  Call Initialise3PGpjsInput
  siteName = getSiteName(SiteInputSheet)
  SpeciesName = getSpeciesName(SiteInputSheet)
  Call readDefaultParameters

  inputSheet = SiteInputSheet
  runTitle = searchValue(inputSheet, "Title", "*", False)
  Call getSiteFactors
  Call getInitialConditions
  Call getOutputOptions
  Call getParameterValues
  Call getSilvicuturalEvents
  Call getOutputVariables(ssVars, ssVarNames, False)
  Call getSinglesiteClimateData
  outputFrequency = ssOutputFrequency

End Sub



'____________________________________________________________
'
' Procedures to read and assign data for sensitivity analyses
'____________________________________________________________


Public Sub readSensitivityData()
'Read the basic data controlling a sensitivity analsyis from
'the active sheet
  Call Initialise3PGpjsInput
  inputSheet = MultisiteInputSheet
  Call getInputVariables(dRowM, dColM + 1)
  MultisiteOutputSheet = getOutputSheet(inputSheet)
  msOutputFrequency = getOutputFrequency(inputSheet)
  Call getOutputVariables(msVars, msVarNames, True)
End Sub

Public Sub assignSensitivityData(site As Integer)
'Get and assign the values for the parameters associated with sites or
'sheets listed in a sensitivity analysis data block
Dim n As Integer, x As Variant, Name As String
  'get parameter and site factors for this run from the multisite sheet
  inputSheet = MultisiteInputSheet
  For n = 1 To noPrmtrs
    Name = prmtrNames(n)
    If namesMatch(Name, "soilClass") _
      Then x = getValue(dRowM + site, dColM + n) _
      Else x = getNumericValue(dRowM + site, dColM + n)
    Call setParameter(Name, x)
    If kwClass <> kwParameter Then
      Call setSiteFactor(Name, x)
      If kwClass = kwError Then
        fatalError _
          "Unknown parameter or site factor", _
          UCase(Name) & " is not a valid parameter or site factor."
      End If
    End If
    'update the site name to include the parameter values
    siteName = siteName & ", " & Name & "=" & Format(x)
  Next n
  'Over-ride any single-site sheet assignment of these variables
  outputFrequency = msOutputFrequency
  outputDetails = False
End Sub



'____________________________________________________________
'
' Procedures to read and assign data for multisite runs
'____________________________________________________________



Public Sub readMultiSiteData()
'Read the basic data controlling a multi-site run from
'the active sheet
Dim stockingName As String
  Call Initialise3PGpjsInput
  'first read the species and get the default parameters
  SpeciesName = getSpeciesName(MultisiteInputSheet)
  Call readDefaultParameters
  'now read the data common to all sites - site specific data is read
  'by assignMultisiteData
  inputSheet = MultisiteInputSheet
  MetdataSheet = getMetdataSheet(inputSheet)
  SeedlingMass = getSeedlingMass(inputSheet)
  MonthPlanted = getMonthPlanted(inputSheet)
  EndAge = getEndAge(inputSheet)
  noSites = getNumberOfSites(inputSheet, 1)
  noPrmtrs = 6   'to take into account the site factors read in
  stockingName = getName(inputSheet, dRowM, dColM + noPrmtrs)
  'checking to see if the data block might be invalid ...
  If Not namesMatch(stockingName, "INITIAL STOCKING") Then
    fatalError _
      "Bad multisite data input block", _
      "The column heading 'Initial stocking' was not found in the correct" & vbCrLf & _
      "place on the row with SITES in column 1." & vbCrLf & vbCrLf & _
      "Check the format of this sheet - is it really a" & vbCrLf & _
      "multisite sheet?"
  End If
  'now assuming the data block is valid, read output controls ...
  MultisiteOutputSheet = getOutputSheet(inputSheet)
  msOutputFrequency = getOutputFrequency(inputSheet)
  If MultisiteOutputSheet = MultisiteInputSheet Then outputFrequency = opfRotation
  Call getOutputVariables(msVars, msVarNames, True)
End Sub

Public Sub assignMultisiteData(site As Integer)
'Get and assign the site factors and initial stand data for sites listed
'on a multi-site sheet
Dim row As Integer, col As Integer
  'First read the site factors
  inputSheet = MultisiteInputSheet
  row = dRowM + site
  col = dColM + 1
  Lat = getRowNumericValue(row, col)
  FR = getRowNumericValue(row, col)
  soilClass = parseSoilClass(getRowValue(row, col))
  MaxASW = getRowNumericValue(row, col)
  MinASW = getRowNumericValue(row, col)
  'Now assign the stand initial conditions
  StemNoi = getRowNumericValue(row, col)
  WFi = 0.5 * SeedlingMass * StemNoi / 10 ^ 6
  WRi = 0.25 * SeedlingMass * StemNoi / 10 ^ 6
  WSi = 0.25 * SeedlingMass * StemNoi / 10 ^ 6
  ASWi = MaxASW
  InitialMonth = MonthPlanted
  InitialYear = 0
  YearPlanted = 0
  '... and now read the metdata
  getMultisiteClimateData (site)
  'Over-ride any single-site sheet assignment of these variables
  outputFrequency = msOutputFrequency
  outputDetails = False
End Sub



'___________________________________________________________________
'
' Procedure to read and assign data for a series of single site runs
'___________________________________________________________________


'Read the sites to be run as a site series - all other data is obtained
'from the single site data sheets, and all output data goes there, too.

Public Sub readSiteSeriesData()
  inputSheet = MultisiteInputSheet
  Call Initialise3PGpjsInput
  noSites = getNumberOfSites(inputSheet, 1)
End Sub
