Attribute VB_Name = "Data_Output"
'___________________________________________________________________________
'
' Data output routines for 3PG
'___________________________________________________________________________


Option Explicit
Option Base 1


Private oRow As Integer
Private oCol As Integer
Private yRow As Integer


Private opVars As Integer             'Number/names of current output variables
Private opVarNames() As String

Private OutputRow As Integer          'Current row for stand output


Private Function isNewVar(v As Variant, vars As Variant, noVars As Integer) As Boolean
Dim n As Integer, b As Boolean
  b = False
  n = 1
  Do While n <= noVars
    b = (LCase(v) = LCase(vars(n)))
    n = n + 1
    If b Then Exit Do
  Loop
  isNewVar = Not b
End Function

Private Sub copyArray _
  (noVarOld As Integer, varOld As Variant, noVarNew As Integer, varNew As Variant)
'Append the array varOld to varNew, ignoring elements that are already in varNew.
'It is tacitly assumed that varOld and varNew contain strings
Dim n As Integer, v As Variant
  For n = 1 To noVarOld
    v = varOld(n)
    If isNewVar(v, varNew, noVarNew) Then
      noVarNew = noVarNew + 1
      ReDim Preserve varNew(noVarNew)
      varNew(noVarNew) = v
    End If
  Next n
End Sub
  
  

'______________________________________
'
' Dictionary of possible output results
'______________________________________

Private Function hasInitialValue(Name As String) As Boolean
'Return TRUE if name has an initial value
Dim b As Boolean
  'Basic stand attributes
  If namesMatch(Name, "standage") _
  Or namesMatch(Name, "StemNo") _
  Or namesMatch(Name, "ASW") _
  Or namesMatch(Name, "WF") _
  Or namesMatch(Name, "WR") _
  Or namesMatch(Name, "WS") _
  Or namesMatch(Name, "TotalW") _
  Or namesMatch(Name, "BasArea") _
  Or namesMatch(Name, "avDBH") _
  Or namesMatch(Name, "StandVol") _
  Or namesMatch(Name, "AvStemMass") _
  Or namesMatch(Name, "AvStemMass") _
  Or namesMatch(Name, "LAI") _
  Or namesMatch(Name, "MAI") Then b = True Else b = False
  hasInitialValue = b
End Function

Private Function varValue(Name As String) As Variant
'Given the name of a variable, return its value
Dim y As Variant
  'Basic stand attributes
  If namesMatch(Name, "sitename") Then
    y = siteName
  ElseIf namesMatch(Name, "FR") Then: y = FR
  ElseIf namesMatch(Name, "minASW") Then: y = MinASW
  ElseIf namesMatch(Name, "Irrig") Then: y = Irrig
  'Basic stand attributes
  ElseIf namesMatch(Name, "standage") Then: y = StandAge
  ElseIf namesMatch(Name, "LAI") Then: y = avLAI
  ElseIf namesMatch(Name, "MAI") Then: y = MAI
  ElseIf namesMatch(Name, "CVI") Then: y = CVI
  ElseIf namesMatch(Name, "WF") Then: y = WF
  ElseIf namesMatch(Name, "WR") Then: y = WR
  ElseIf namesMatch(Name, "WS") Then: y = WS
  ElseIf namesMatch(Name, "TotalW") Then: y = TotalW
  ElseIf namesMatch(Name, "AvStemMass") Then: y = AvStemMass
  ElseIf namesMatch(Name, "StemNo") Then: y = StemNo
  ElseIf namesMatch(Name, "BasArea") Then: y = BasArea
  ElseIf namesMatch(Name, "StandVol") Then: y = StandVol
  ElseIf namesMatch(Name, "avDBH") Then: y = avDBH
  ElseIf namesMatch(Name, "ASW") Then: y = ASW
  'Annual totals or values
  ElseIf namesMatch(Name, "LAIx") Then: y = LAIx
  ElseIf namesMatch(Name, "ageLAIx") Then: y = ageLAIx
  ElseIf namesMatch(Name, "MAIx") Then: y = MAIx
  ElseIf namesMatch(Name, "ageMAIx") Then: y = ageMAIx
  ElseIf namesMatch(Name, "abvgrndEpsilon") Then: y = abvgrndEpsilon
  ElseIf namesMatch(Name, "totalEpsilon") Then: y = totalEpsilon
  ElseIf namesMatch(Name, "cumEvapTransp") Then: y = cumEvapTransp
  ElseIf namesMatch(Name, "cumTransp") Then: y = cumTransp
  ElseIf namesMatch(Name, "cumIrrig") Then: y = cumIrrig
  ElseIf namesMatch(Name, "cumNPP") Then: y = cumNPP
  ElseIf namesMatch(Name, "TotalLitter") Then: y = TotalLitter
  'Growth modifiers
  ElseIf namesMatch(Name, "fAge") Then: y = fAge
  ElseIf namesMatch(Name, "fVPD") Then: y = fVPD
  ElseIf namesMatch(Name, "fT") Then: y = fT
  ElseIf namesMatch(Name, "fFrost") Then: y = fFrost
  ElseIf namesMatch(Name, "fSW") Then: y = fSW
  ElseIf namesMatch(Name, "fNutr") Then: y = fNutr
  ElseIf namesMatch(Name, "PhysMod") Then: y = PhysMod
  'Biomass partitioning
  ElseIf namesMatch(Name, "pR") Then: y = pR
  ElseIf namesMatch(Name, "pS") Then: y = pS
  ElseIf namesMatch(Name, "pF") Then: y = pF
  ElseIf namesMatch(Name, "pFS") Then: y = pFS
  'Stem mortality
  ElseIf namesMatch(Name, "wSmax") Then: y = wSmax
  ElseIf namesMatch(Name, "delStemNo") Then: y = delStemNo
  'Explicitly age-dependent variables
  ElseIf namesMatch(Name, "SLA") Then: y = SLA
  ElseIf namesMatch(Name, "Littfall") Then: y = Littfall
  ElseIf namesMatch(Name, "fracBB") Then: y = fracBB
  ElseIf namesMatch(Name, "SLA") Then: y = SLA
  ElseIf namesMatch(Name, "CanCover") Then: y = CanCover
  'Monthly values
  ElseIf namesMatch(Name, "m") Then: y = m
  ElseIf namesMatch(Name, "alphaC") Then: y = alphaC
  ElseIf namesMatch(Name, "CanCond") Then: y = CanCond
  ElseIf namesMatch(Name, "monthlyIrrig") Then: y = monthlyIrrig
  ElseIf namesMatch(Name, "delLitter") Then: y = delLitter
  ElseIf namesMatch(Name, "EvapTransp") Then: y = EvapTransp
  ElseIf namesMatch(Name, "Transp") Then: y = Transp
  ElseIf namesMatch(Name, "NPP") Then: y = NPP
  'Climatic factors
  ElseIf namesMatch(Name, "h") Then: y = DayLength
  ElseIf namesMatch(Name, "Frostdays") Then: y = FrostDays
  ElseIf namesMatch(Name, "SolarRad") Then: y = SolarRad
  ElseIf namesMatch(Name, "Tav") Then: y = Tav
  ElseIf namesMatch(Name, "VPD") Then: y = VPD
  ElseIf namesMatch(Name, "Rain") Then: y = Rain
  Else
    y = "Unknown"
  End If
  varValue = y
End Function

Function varHeading(Name As String) As String
Dim h As String
  'Basic stand attributes
  If namesMatch(Name, "sitename") Then
    h = "Site name"
  ElseIf namesMatch(Name, "FR") Then: h = "Fert. rating"
  ElseIf namesMatch(Name, "minASW") Then: h = "Min. ASW"
  ElseIf namesMatch(Name, "Irrig") Then: h = "Annual irrigation"
  'Basic stand attributes
  ElseIf namesMatch(Name, "standage") Then: h = "Stand age"
  ElseIf namesMatch(Name, "LAI") Then: h = "LAI"
  ElseIf namesMatch(Name, "MAI") Then: h = "MAI"
  ElseIf namesMatch(Name, "CVI") Then: h = "Vol. incr."
  ElseIf namesMatch(Name, "WF") Then: h = "Foliage DM"
  ElseIf namesMatch(Name, "WR") Then: h = "Root DM"
  ElseIf namesMatch(Name, "WS") Then: h = "Stem DM"
  ElseIf namesMatch(Name, "TotalW") Then: h = "Total DM"
  ElseIf namesMatch(Name, "AvStemMass") Then: h = "Mean stem mass"
  ElseIf namesMatch(Name, "StemNo") Then: h = "Stocking"
  ElseIf namesMatch(Name, "BasArea") Then: h = "Basal area"
  ElseIf namesMatch(Name, "StandVol") Then: h = "Stand volume"
  ElseIf namesMatch(Name, "avDBH") Then: h = "Mean DBH"
  ElseIf namesMatch(Name, "ASW") Then: h = "ASW"
  'Annual totals or values
  ElseIf namesMatch(Name, "LAIx") Then: h = "Max LAI"
  ElseIf namesMatch(Name, "ageLAIx") Then: h = "Age at max LAI"
  ElseIf namesMatch(Name, "MAIx") Then: h = "Peak MAI"
  ElseIf namesMatch(Name, "ageMAIx") Then: h = "Age at peak MAI"
  ElseIf namesMatch(Name, "abvgrndEpsilon") Then: h = "Above ground epsilon"
  ElseIf namesMatch(Name, "totalEpsilon") Then: h = "Total epsilon"
  ElseIf namesMatch(Name, "cumEvapTransp") Then: h = "Annual ET"
  ElseIf namesMatch(Name, "cumTransp") Then: h = "Annual transp."
  ElseIf namesMatch(Name, "cumIrrig") Then: h = "Annual supp. irrig."
  ElseIf namesMatch(Name, "cumNPP") Then: h = "Annual NPP"
  ElseIf namesMatch(Name, "cumLittfall") Then: h = "Annual litterfall"
  'Growth modifiers
  ElseIf namesMatch(Name, "fAge") Then: h = "fAge"
  ElseIf namesMatch(Name, "fVPD") Then: h = "fVPD"
  ElseIf namesMatch(Name, "fT") Then: h = "fTemp"
  ElseIf namesMatch(Name, "fFrost") Then: h = "fFrost"
  ElseIf namesMatch(Name, "fSW") Then: h = "fSoilWater"
  ElseIf namesMatch(Name, "fNutr") Then: h = "fNutrition"
  ElseIf namesMatch(Name, "PhysMod") Then: h = "Phys. modifier"
  'Biomass partitioning
  ElseIf namesMatch(Name, "pR") Then: h = "pR"
  ElseIf namesMatch(Name, "pS") Then: h = "pS"
  ElseIf namesMatch(Name, "pF") Then: h = "pF"
  ElseIf namesMatch(Name, "pFS") Then: h = "pFS"
  'Stem mortality
  ElseIf namesMatch(Name, "wSmax") Then: h = "wSmax"
  ElseIf namesMatch(Name, "delStemNo") Then: h = "delStemNo"
  'Explicitly age-dependent variables
  ElseIf namesMatch(Name, "SLA") Then: h = "SLA"
  ElseIf namesMatch(Name, "Littfall") Then: h = "Litter fall rate"
  ElseIf namesMatch(Name, "fracBB") Then: h = "Fract. as bark & branch"
  ElseIf namesMatch(Name, "CanCover") Then: h = "Fract. canopy cover"
  'Monthly values
  ElseIf namesMatch(Name, "m") Then: h = "m"
  ElseIf namesMatch(Name, "alphaC") Then: h = "Canopy alpha"
  ElseIf namesMatch(Name, "CanCond") Then: h = "Canopy conductance"
  ElseIf namesMatch(Name, "monthlyIrrig") Then: h = "Monthly supp. irrig."
  ElseIf namesMatch(Name, "delLitter") Then: h = "Litter"
  ElseIf namesMatch(Name, "EvapTransp") Then: h = "Monthly ET"
  ElseIf namesMatch(Name, "Transp") Then: h = "Monthly trans."
  ElseIf namesMatch(Name, "NPP") Then: h = "Monthly NPP"
  ElseIf namesMatch(Name, "TotalLitter") Then: h = "Total litter"
  'Climatic factors
  ElseIf namesMatch(Name, "h") Then: h = "Daylength"
  ElseIf namesMatch(Name, "Frostdays") Then: h = "Frost days"
  ElseIf namesMatch(Name, "SolarRad") Then: h = "Solar rad."
  ElseIf namesMatch(Name, "Tav") Then: h = "Mean temp."
  ElseIf namesMatch(Name, "VPD") Then: h = "VPD"
  ElseIf namesMatch(Name, "Rain") Then: h = "Rainfall"
  Else
    h = "Unknown"
  End If
  varHeading = h
End Function



'_______________________________________________________
'
' Output results of detailed calculations to 3PG_Results
'_______________________________________________________


Private Sub writeDetailedMonthlyData(year As Integer, month As Integer)
'Output all detailed monthly calculations -
'   to get additional outputs, add code in this procedure
Dim writeHeading As Boolean, thisYear As Integer
  writeHeading = (year = 0)
  If writeHeading Then oCol = 1 Else oCol = oCol + 1
  thisYear = Int(YearPlanted + MonthPlanted / 12 + StandAge - 0.001)
  Call writeColData("Year", thisYear, oRow, oCol, writeHeading)
  Call writeColData("Month", monthName(InitialMonth + month), oRow, oCol, writeHeading)
  Call writeColData("Stand age", Format(StandAge, "#0.000"), oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("Frost days", FrostDays, oRow, oCol, writeHeading)
  Call writeColData("Mean temp    (deg C)", Tav, oRow, oCol, writeHeading)
  Call writeColData("Day length   (s/day)", DayLength, oRow, oCol, writeHeading)
  Call writeColData("Irradiance   (MJ/m2)", SolarRad, oRow, oCol, writeHeading)
  Call writeColData("VPD          (mBar)", VPD, oRow, oCol, writeHeading)
  Call writeColData("Rain         (mm/month)", Rain, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("FR                 ", FR, oRow, oCol, writeHeading)
  Call writeColData("Irig               ", Irrig, oRow, oCol, writeHeading)
  Call writeColData("MinASW             ", MinASW, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("WF(t-1)      (t/ha)", WF - delWF + delLitter, oRow, oCol, writeHeading)
  Call writeColData("WR(t-1)      (t/ha)", WR - delWR + delRoots, oRow, oCol, writeHeading)
  Call writeColData("WS(t-1)      (t/ha)", WS - delWS, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("fFrost", fFrost, oRow, oCol, writeHeading)
  Call writeColData("fT", fT, oRow, oCol, writeHeading)
  Call writeColData("fSW", fSW, oRow, oCol, writeHeading)
  Call writeColData("fVPD", fVPD, oRow, oCol, writeHeading)
  Call writeColData("fNutr", fNutr, oRow, oCol, writeHeading)
  Call writeColData("fAge", fAge, oRow, oCol, writeHeading)
  Call writeColData("PhysMod", PhysMod, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("RAD          (MJ/m2)", RAD, oRow, oCol, writeHeading)
  Call writeColData("PAR          (mol/m2)", PAR, oRow, oCol, writeHeading)
  Call writeColData("Canopy cover", CanCover, oRow, oCol, writeHeading)
  Call writeColData("Light interception", lightIntcptn, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("APAR         (mol/m2)", APAR, oRow, oCol, writeHeading)
  Call writeColData("APARu        (mol/m2)", APARu, oRow, oCol, writeHeading)
  Call writeColData("GPP          (mol/m2)", GPPmolc, oRow, oCol, writeHeading)
  Call writeColData("GPP          (t/ha)", GPPdm, oRow, oCol, writeHeading)
  Call writeColData("NPP          (t/ha)", NPP, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("pFS", pFS, oRow, oCol, writeHeading)
  Call writeColData("pF", pF, oRow, oCol, writeHeading)
  Call writeColData("pR", pR, oRow, oCol, writeHeading)
  Call writeColData("pS", pS, oRow, oCol, writeHeading)
  Call writeColData("delWF        (t/ha)", delWF, oRow, oCol, writeHeading)
  Call writeColData("delWR        (t/ha)", delWR, oRow, oCol, writeHeading)
  Call writeColData("delWS        (t/ha)", delWS, oRow, oCol, writeHeading)
  Call writeColData("Littfall     (t/ha)", Littfall, oRow, oCol, writeHeading)
  Call writeColData("delLitter     (t/ha)", delLitter, oRow, oCol, writeHeading)
  Call writeColData("delRoots     (t/ha)", delRoots, oRow, oCol, writeHeading)
  Call writeColData("delStems     (trees/ha)", delStems, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("WF(t)        (t/ha)", WF, oRow, oCol, writeHeading)
  Call writeColData("WR(t)        (t/ha)", WR, oRow, oCol, writeHeading)
  Call writeColData("WS(t)        (t/ha)", WS, oRow, oCol, writeHeading)
  Call writeColData("Total W      (t/ha)", TotalW, oRow, oCol, writeHeading)
  Call writeColData("avDBH        (cm)", avDBH, oRow, oCol, writeHeading)
  Call writeColData("LAI", LAI, oRow, oCol, writeHeading)
  Call writeColData("SLA          (m2/kg)", SLA, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("CanCond      (m/s)", CanCond, oRow, oCol, writeHeading)
  Call writeColData("EvapTransp   (mm/month)", EvapTransp, oRow, oCol, writeHeading)
  Call writeColData("Transp       (mm/month)", Transp, oRow, oCol, writeHeading)
  Call writeColData("Irrigation   (mm/month)", monthlyIrrig, oRow, oCol, writeHeading)
  Call writeColData("Soil water   (mm)", ASW, oRow, oCol, writeHeading)
  oRow = oRow + 1
  Call writeColData("cum delWF    (t/ha)", cumdelWF, oRow, oCol, writeHeading)
  Call writeColData("cum delWR    (t/ha", cumdelWR, oRow, oCol, writeHeading)
  Call writeColData("cum delWS    (t/ha", cumdelWS, oRow, oCol, writeHeading)
  Call writeColData("cum APARu    (mol/m2)", cumAPARU, oRow, oCol, writeHeading)
  Call writeColData("cum ARAD     (MJ/m2)", cumARAD, oRow, oCol, writeHeading)
  Call writeColData("cum GPP      (t/ha)", cumGPP, oRow, oCol, writeHeading)
  Call writeColData("cum Wabvgrnd (t/ha)", cumWabvgrnd, oRow, oCol, writeHeading)
  oRow = oRow + 1
  yRow = oRow
End Sub

Public Sub writeMonthlyDetails(year As Integer, month As Integer)
'Controls the output all detailed monthly calculations
Dim firstTime As Boolean, newSheet As Worksheet
  'if the "3PG_results" sheet does not exist, create it
  If Not validSheetName(MonthlyOutputSheet) Then
    Set newSheet = Worksheets.Add
    newSheet.Move after:=Worksheets(inputSheet)
    newSheet.Name = MonthlyOutputSheet
    Worksheets(inputSheet).Activate
  End If
  outputSheet = MonthlyOutputSheet
  'The first time this sub is called write all row and column headings
  firstTime = (month = 1) And (year = 1)
  If firstTime Then
    If clearOutput Then Call ClearOutputRegion(MonthlyOutputSheet, 0, 0)
    Call writeData(MonthlyOutputSheet, "Detailed monthly output from 3PG", 1, 1)
    Call writeData(MonthlyOutputSheet, "Output from " & vsnCode, 2, 1)
    Call writeData(MonthlyOutputSheet, "Site is       : " & siteName, 4, 1)
    Call writeData(MonthlyOutputSheet, "Data sheet is : " & SiteInputSheet, 5, 1)
    oRow = 7
    oCol = 1
    Call writeDetailedMonthlyData(0, 1)
  End If
  oRow = 7  ' skip over space allocated to headings etc
  'output monthly data only for the last year
  If (outputFrequency = opfMonthly) Or (year = EndAge - StartAge) Then
    If month = 1 Then
      month = month
    End If
    Call writeDetailedMonthlyData(year, month)
  End If
End Sub


Private Sub writeDetailedAnnualData(year As Integer)
'Output all detailed annual stand data -
'   to get additional outputs, add code in this procedure
Dim writeHeading As Boolean, col As Integer
  writeHeading = (year = 0)
  If writeHeading _
    Then col = 1 _
    Else col = year + 2
  Call writeColData("Stand age", StandAge, oRow, col, writeHeading)
  oRow = oRow + 1
  Call writeColData("Fertility Rating", FR, oRow, col, writeHeading)
  Call writeColData("Irrigation           (ML/ha/yr)", Irrig, oRow, col, writeHeading)
  Call writeColData("Minimum ASW          (mm)", MinASW, oRow, col, writeHeading)
  oRow = oRow + 1
  Call writeColData("WF                   (t/ha)", WF, oRow, col, writeHeading)
  Call writeColData("WR                   (t/ha)", WR, oRow, col, writeHeading)
  Call writeColData("WS                   (t/ha)", WS, oRow, col, writeHeading)
  Call writeColData("Stems/ha             (/ha)", StemNo, oRow, col, writeHeading)
  oRow = oRow + 1
  Call writeColData("LAI", LAI, oRow, col, writeHeading)
  Call writeColData("Average DBH          (cm)", avDBH, oRow, col, writeHeading)
  Call writeColData("Basal area           (m2/ha)", BasArea, oRow, col, writeHeading)
  Call writeColData("Stand volume         (m3/ha)", StandVol, oRow, col, writeHeading)
  Call writeColData("MAI                  (m3/ha/yr)", MAI, oRow, col, writeHeading)
  oRow = oRow + 1
  Call writeColData("fAge", fAge, oRow, col, writeHeading)
  Call writeColData("SLA                  (m2/kg)", SLA, oRow, col, writeHeading)
  Call writeColData("Ltterfall rate       (1/month)", Littfall, oRow, col, writeHeading)
  Call writeColData("Branch & bark fraction", fracBB, oRow, col, writeHeading)
  oRow = oRow + 1
  Call writeColData("Available soilwater  (mm)", ASW, oRow, col, writeHeading)
  Call writeColData("Annual transpiration (mm)", cumTransp, oRow, col, writeHeading)
  Call writeColData("Annual irrigation    (mm)", cumIrrig, oRow, col, writeHeading)
  oRow = oRow + 1
  Call writeColData("Above ground epsilon (gDM/MJ)", abvgrndEpsilon, oRow, col, writeHeading)
  Call writeColData("Gross epsilon        (gDM/MJ)", totalEpsilon, oRow, col, writeHeading)
End Sub

Public Sub writeAnnualDetails(year As Integer)
'Controls output of all detailed annual stand data -
Dim col As Integer, savedRow As Integer
  outputSheet = MonthlyOutputSheet
  oRow = yRow
  oRow = oRow + 1
  If year = 1 Then
    'write headings
    Call writeData(MonthlyOutputSheet, "Detailed annual output from 3PG", oRow, 1)
    oRow = oRow + 2
    savedRow = oRow
    Call writeDetailedAnnualData(0)
    'write initial conditions
    oRow = savedRow
    col = 2
    Call writeColData("StandAge", StandAge - 1, oRow, col, False)
    oRow = oRow + 5
    Call writeColData("WF ", WFi, oRow, col, False)
    Call writeColData("WR ", WRi, oRow, col, False)
    Call writeColData("WS ", WSi, oRow, col, False)
    Call writeColData("StemNo", StemNoi, oRow, col, False)
    oRow = savedRow
  Else
    oRow = oRow + 2
  End If
  Call writeDetailedAnnualData(year)
End Sub



'__________________________________________
'
' Write output to a stand summary data block
'__________________________________________


Private Sub writeOutputHeadings()
Dim col As Integer, var As Integer, Name As String
  If clearOutput Then Call ClearOutputRegion(outputSheet, OutputRow, 1)
  'write data-block headers
  Call writeColData("#Output from " & vsnCode, 0, OutputRow, 1, True)
  Call FormatHeading(OutputRow, 1, 1, 12, False)
  Call writeColData("Stand development for " & siteName, 0, OutputRow, 1, True)
  If runTitle <> "" Then Call writeColData(runTitle, 0, OutputRow, 1, True)
  'format and write the column headings
  Call FormatHeading(OutputRow, 1, ssVars + 10, 10, True)
  col = 1
  For var = 1 To opVars + 2
    Select Case var
      Case 1:    Name = "Year & month"
      Case 2:    Name = "Stand age"
      Case Else: Name = varHeading(opVarNames(var - 2))
    End Select
    Call writeRowData(Name, 0, OutputRow, col, True)
  Next var
  OutputRow = OutputRow + 1
End Sub

Private Sub writeOutputData(writeHeading As Boolean, month As Integer)
Dim YearMonth As String, col As Integer, var As Integer, y As Variant
  YearMonth = Format(Int(YearPlanted + MonthPlanted / 12 + StandAge - 0.001), "0") & " - " & _
              monthName(InitialMonth + month)
  col = 1
  For var = 1 To opVars + 2
    Select Case var
      Case 1:    y = YearMonth
      Case 2:    y = StandAge
      Case Else:
        If (month = 0) And Not hasInitialValue(opVarNames(var - 2)) _
          Then y = 0 _
          Else y = varValue(opVarNames(var - 2))
    End Select
    Call writeRowData("", y, OutputRow, col, False)
  Next var
  OutputRow = OutputRow + 1
End Sub

Private Sub writeOutputBlock(Action As Integer, month As Integer)
Dim col As Integer, opVarsOld As Integer
  Select Case Action
  Case opStart
    'Write headings and ...
    Call writeOutputHeadings
    '... and the initial conditions for single-site runs
    '(= the first 8 output variables)
    If runType = rtSingleSite Or runType = rtSiteSeries Then
'      opVarsOld = ssVars
'      opVars = 8
      Call writeOutputData(False, 0)
'      opVars = opVarsOld
    End If
  Case opEndMonth, opEndYear
    'write annual or monthly data
    Call writeOutputData(False, month)
  Case opEndRun
    'Write stuff at the end of a single-site run
    If runType = rtSingleSite Or runType = rtSiteSeries Then
      'currently writes nothing
    End If
    OutputRow = OutputRow + 2
  End Select
End Sub




'_______________________________________________
'
' Write output to a single-site output data block
'_______________________________________________


Private Sub writeSingleSiteOutput _
  (sheet As String, Action As Integer, year As Integer, month As Integer)
'Generate output for a single-site run
  outputSheet = sheet
  If (runType = rtSingleSite Or runType = rtSiteSeries) And (Action = opStart) Then
    OutputRow = oRowD
  End If
  If outputFrequency = opfRotation Then
    Select Case Action
      Case opStart:    Call writeOutputBlock(opStart, 0)
      Case opEndMonth: 'do nothing
      Case opEndYear:  'do nothing
      Case opEndRun:
        Call writeOutputBlock(opEndYear, month)
        Call writeOutputBlock(opEndRun, month)
    End Select
  ElseIf outputFrequency = opfAnnual Then
    Select Case Action
      Case opStart:    Call writeOutputBlock(opStart, 0)
      Case opEndMonth: 'do nothing
      Case opEndYear:  Call writeOutputBlock(opEndYear, month)
      Case opEndRun:   Call writeOutputBlock(opEndRun, month)
    End Select
  ElseIf outputFrequency = opfMonthly Then
    Select Case Action
      Case opStart:    Call writeOutputBlock(opStart, 0)
      Case opEndMonth: Call writeOutputBlock(opEndMonth, month)
      Case opEndYear:  'do nothing
      Case opEndRun:   Call writeOutputBlock(opEndRun, month)
    End Select
  End If
End Sub



'______________________________________________
'
' Write output to a multi-site output data block
'______________________________________________


Private Sub writeMultisiteHeading()
'Write the headings of a multisite output block
Dim col As Integer, var As Integer
  col = dColM + noPrmtrs + 1
  If clearOutput Then Call ClearOutputRegion(outputSheet, dRowM, col)
  For var = 1 To msVars
    Call writeRowData(varHeading(msVarNames(var)), 0, dRowM, col, True)
  Next var
End Sub

Public Sub writeMultisiteData(site As Integer)
'Write the data selected for a multisite output block
Dim col As Integer, row As Integer, var As Integer
  col = dColM + noPrmtrs + 1
  row = dRowM + site
  For var = 1 To msVars
    Call writeRowData("", varValue(msVarNames(var)), row, col, False)
  Next var
End Sub

Private Sub writeMultisiteOutput _
  (Action As Integer, year As Integer, month As Integer)
'Generate output for a multi-site run
Dim newSheet As Worksheet
  If MultisiteOutputSheet <> MultisiteInputSheet Then
    If (BlockNo = 1) And (SiteNo = 1) And (Action = 0) Then
      'create sheet if it doesn't exist
      If Not validSheetName(MultisiteOutputSheet) Then
        Set newSheet = Worksheets.Add
        newSheet.Move after:=Worksheets(MultisiteInputSheet)
        newSheet.Name = MultisiteOutputSheet
        Worksheets(MultisiteInputSheet).Activate
      End If
      'clear it if it might have data on it
      If Sheets(MultisiteOutputSheet).Cells(1, 1) <> "" Then
        Call abortOnNo _
          ("Multi-site output sheet", _
           "The sheet '" & MultisiteOutputSheet & "' has data on it." & vbCrLf & _
           "Shall I erase it and continue?")
        Sheets(MultisiteOutputSheet).Cells.ClearContents
      End If
      OutputRow = 1
    End If
    Call writeSingleSiteOutput(MultisiteOutputSheet, Action, year, month)
  End If
  If Action = opEndRun Then
    outputSheet = MultisiteInputSheet
    If SiteNo = 1 Then Call writeMultisiteHeading
    Call writeMultisiteData(SiteNo)
  End If
End Sub



'_____________________________________________________________________________
'
' write3PGResults
' ~~~~~~~~~~~~~~~
'
' This is the primary output routine called by run3PG. It uses the value of
' "runType" to determine which output procedure to call.
'
' The value of "action" depends on the stage in a run at which the output
' procedure was called, and hence determines what is to be done at that stage.
'_____________________________________________________________________________


Public Sub write3PGResults(Action As Integer, year As Integer, month As Integer)

'This is the run3PG output procedure
  
  'First deal with the output of detailed computations from the run if
  'details have been requested ...
  If outputDetails Then
    Select Case Action
      Case opEndMonth: Call writeMonthlyDetails(year, month)
      Case opEndYear:  Call writeAnnualDetails(year)
    End Select
  End If
  
  'Now copy the output name list to the output array. This only needs to
  'be done the first time this procedure is called for an individual run
  'of 3-PG for a site ...
  If Action = opStart Then
    opVars = 0
    Call copyArray(defVars, defVarNames, opVars, opVarNames)
    Select Case runType
      Case rtSingleSite, rtSiteSeries
        Call copyArray(ssVars, ssVarNames, opVars, opVarNames)
      Case rtSensitivity, rtMultiSite
        Call copyArray(msVars, msVarNames, opVars, opVarNames)
    End Select
  End If
  
  'Finally, generate output specific to the current run type ...
  Select Case runType
    Case rtSingleSite:  Call writeSingleSiteOutput(SiteOutputSheet, Action, year, month)
    Case rtSiteSeries:  Call writeSingleSiteOutput(SiteOutputSheet, Action, year, month)
    Case rtSensitivity: Call writeMultisiteOutput(Action, year, month)
    Case rtMultiSite:   Call writeMultisiteOutput(Action, year, month)
  End Select

End Sub

