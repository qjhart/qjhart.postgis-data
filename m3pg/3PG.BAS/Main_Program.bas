Attribute VB_Name = "Main_Program"
Option Explicit
Option Base 1


Public Const InterfaceVsn = "3PGpjs 2 beta"
Public Const InterfaceDate = "January 2001"


'_____________________________________________________________________________________
'
'
' Main program for 3PG - PJ Sands
'
' It uses the following modules:
'
'   Climate         Handles climatic input and calculation of daylength, VPD, etc.
'
'   Data-Input      Handles all site-data input - parses single-site and sensitivity
'                   analysis worksheets.
'
'   Data_Output     Handles all data output - detailed monthly intermediate output;
'                   annual summary of stand development, the primary output from 3PG;
'                   specific output from multi-site runs and sensitivity analyses.
'
'   Generic_IO      Contains some procedures and functions that assist with generic
'                   input and output to and from worksheets.
'
'   Interface       Sets up the user interface - disclaimer, about screen, hot-keys
'                   tool bars and menu items.
'
'   Parameters      Reads parameter values from the parameter definition worksheet,
'                   and from single-site and sensitivity analysis worksheets.
'
'   The_3PG_Model   The core code of 3PG.
'
'
'_____________________________________________________________________________________
'
' Changes in 3PGpjs vsn 1.01, April 2000
'
'   1) Units of VPD stated as mBar rather than kPa
'
'_____________________________________________________________________________________
'
' Changes in 3PGpjs vsn 2, January 2001
'
'   1)  Introduced SiteSeries and MultiSite runs
'   2)  Added 3PGpjs options section to 3PG_Parameters sheet.
'       Current options are:
'       * "Clear output (Yes/No)" controls clearing of output regions
'       * "Monthly output (Yes/No)" controls monthly or annual stand output
'   3)  Added user-defined list of output for all 3PGpjs run types, and added
'       more variables to the output dictionary. Use 3-PG variable names but
'       more meaningful headings
'       titles or 3PG variable names
'   4)  Changed various keywords: see Table 1 in manual for all keywords
'   5)  Added facility to get monthly output for all years
'       * "Output frequency" on site data sheet now selects output frequency
'       * This also required the need to input the month of planting and the
'         month of the stand initialisation - so the month a run is initialised
'         is now arbitrary but defaults to December or June
'   6)  Keyword search now based on Excel 'Find' method. As a consequence
'       the keyword must be the first contiguous characters in the cell.
'       E.g. the keyword 'Output' is matched by 'Output' or 'Outputs :',
'       but not by 'Model output'.
'   7)  Added more units to output labels on "3PG_Results" sheet
'   8)  Introduced 3PGpjs hot keys, menu items and toolbars
'   9)  Added optional title field on single-site data sheets
'  10)  Sensitivity analysis sheet can now have multiple data blocks flagged
'       by the Sites keyword.
'  11)  Multisite and sensitivity runs can write detailed stand data to a
'       distinct sheet
'  12)  Added climate databases
'  13)  Quite a bit of general recoding and tinkering of output procedures.
'_____________________________________________________________________________________


Public vsnCode As String


'Identification of type of currently active 3PGpjs run
Public Const _
  rtSingleSite = "SINGLESITE", _
  rtSensitivity = "SENSITIVITY", _
  rtMultiSite = "MULTISITE", _
  rtSiteSeries = "SITESERIES"

Public runType As String

'Names of input and output worksheets
Public Const MonthlyOutputSheet = "3PG_Results"  'detailed monthly & annual output
Public Const ParameterSheet = "3PG_Parameters"   'standard parameter definitions
Public SiteInputSheet As String                  'single-site input data sheet
Public SiteOutputSheet As String                 'output sheet for stand summary
Public MultisiteInputSheet As String             'multisite input sheet
Public MultisiteOutputSheet As String            'multisite Output sheet
Public MetdataSheet As String                    'multisite metdata input sheet

'Variables controlling generation of output
Public outputDetails As Boolean            'TRUE ==> output detailed results
Public clearOutput As Boolean              'TRUE ==> clear output block first
Public defOutputFrequency As Integer       'default output frequency for all runs
Public ssOutputFrequency As Integer        'output frequency for single-site runs
Public msOutputFrequency As Integer        'output frequency for multi-site runs

'Location of i/o data blocks
Public dColM As Integer, dRowM As Integer  'MultisiteInputSheet data block origin
Public oRowD As Integer                    'Single-Site output origin

'Number and names of various input and output data
Public runTitle As String                  'Title for current run
Public siteNames() As String
Public noPrmtrs As Integer                 'Parameters to be controlled
Public prmtrNames() As String
Public defVars As Integer                  'Default variables to display
Public defVarNames() As String
Public msVars As Integer                   'Multi-site variables to display
Public msVarNames() As String
Public ssVars As Integer                   'Single-site variables to display
Public ssVarNames() As String

Public noSites As Integer                  'Number of sites to be run
Public SiteNo As Integer                   'Number of current site
Public BlockNo As Integer                  'Number of current data block


'______________________________________________
'
' The routines to run 3PG in the available modes
'______________________________________________


Private Function getRunType(sheet As String) As String
'Get the type of the run defined by the worksheet "sheet"
Dim row As Integer, col As Integer, s As String
  s = ""
  Call locateCell(sheet, "A1", "Run type*", row, col)
  If errCode = errOK Then
    s = Sheets(sheet).Cells(row, col + 1).Value
    If s = "" Then errCode = errBlankCell
  End If
  getRunType = UCase(s)
End Function

    
Private Function validSingleSiteName(sheet As String) As Boolean
'Check if the sheet "Sheet" is a valid single-site data sheet
  validSingleSiteName = False
  If Not validSheetName(sheet) Then
    showError "Invalid site name", UCase(sheet) & " is not a valid worksheet name"
  ElseIf getRunType(sheet) <> rtSingleSite Then
    showError "Invalid site name", UCase(sheet) & " is not a single-site data sheet"
  Else
    validSingleSiteName = True
  End If
End Function



'______________________________________________
'
' The routines to run 3PG in the available modes
'______________________________________________


Private Sub runSingleSite(sheet As String)
'Run a single site
  SiteInputSheet = sheet
  SiteOutputSheet = SiteInputSheet
  Call readSingleSiteData
  Call Check3PGpjsInput
  Call run3PG
End Sub

Private Sub runSensitivity()
'Run a sensitivity analysis
  MultisiteInputSheet = ActiveSheet.Name
  BlockNo = 1
  noSites = getNumberOfSites(MultisiteInputSheet, BlockNo)
  Do While noSites > 0
    Call readSensitivityData
    SiteNo = 1
    siteName = getName(MultisiteInputSheet, dRowM + SiteNo, dColM)
    Do While siteName <> ""
      Call writeData(MultisiteInputSheet, "Running", dRowM + SiteNo, dColM + noPrmtrs + 1)
      SiteInputSheet = siteName
      If validSingleSiteName(siteName) Then
        Call readSingleSiteData
        Call assignSensitivityData(SiteNo)
        Call Check3PGpjsInput
        Call run3PG
      Else
        Call writeData(MultisiteInputSheet, "Aborted", dRowM + SiteNo, dColM + noPrmtrs + 1)
      End If
      SiteNo = SiteNo + 1
      siteName = getName(MultisiteInputSheet, dRowM + SiteNo, dColM)
    Loop
    BlockNo = BlockNo + 1
    noSites = getNumberOfSites(MultisiteInputSheet, BlockNo)
  Loop
End Sub

Private Sub runMultiSite()
'Run a multi-site run. Met data for each site is read from
'a row on a specified sheet, output is to a single row or
'group of rows on either the input or a separate sheet
  MultisiteInputSheet = ActiveSheet.Name
  Call readMultiSiteData
  BlockNo = 1
  SiteNo = 1
  siteName = getName(MultisiteInputSheet, dRowM + SiteNo, dColM)
  Do While siteName <> ""
    Call writeData(MultisiteInputSheet, "Running", dRowM + SiteNo, dColM + noPrmtrs + 1)
    Call assignMultisiteData(SiteNo)
    Call Check3PGpjsInput
    Call run3PG
    BlockNo = BlockNo + 1
    SiteNo = SiteNo + 1
    siteName = getName(MultisiteInputSheet, dRowM + SiteNo, dColM)
  Loop
End Sub

Private Sub runSiteSeries()
' Run a series of single sites with all input and output from
' and to the single site data sheets
  MultisiteInputSheet = ActiveSheet.Name
  Call readSiteSeriesData
  BlockNo = 1
  SiteNo = 1
  siteName = getName(MultisiteInputSheet, dRowM + SiteNo, dColM)
  Do While siteName <> ""
    If validSingleSiteName(siteName) Then
      Call writeData(MultisiteInputSheet, "Running", dRowM + SiteNo, dColM + 1)
      runSingleSite (siteName)
      Call writeData(MultisiteInputSheet, "", dRowM + SiteNo, dColM + 1)
    Else
      Call writeData(MultisiteInputSheet, "Aborted", dRowM + SiteNo, dColM + 1)
    End If
    SiteNo = SiteNo + 1
  siteName = getName(MultisiteInputSheet, dRowM + SiteNo, dColM)
  Loop
End Sub


'______________________________________________________________________
'
' The main program - determine what kind of run to make for the current
'                    active sheet and call the appropriate procedure.
'______________________________________________________________________


Public Sub run3PGpjs()

  'Do some initialisation
  daysInMonth = Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  vsnCode = InterfaceVsn & " / " & ModelVsn

  'Determine the run type and make the run if it is valid ...

  runType = getRunType(ActiveSheet.Name)

  If runType = rtSensitivity Then
    runSensitivity
  ElseIf runType = rtMultiSite Then
    runMultiSite
  ElseIf runType = rtSiteSeries Then
    runSiteSeries
  ElseIf runType = rtSingleSite Then
    runSingleSite (ActiveSheet.Name)

  '... or report errors if it is not

  ElseIf errCode = errLocateFail Then
    fatalError _
      "Missing RUN keyword", _
      "The RUN key word was not found on the current sheet." & vbCrLf & _
      "Are you sure you meant to run this sheet?"
  ElseIf errCode = errBlankCell Then
    fatalError _
      "Unknown run type", _
      "No run-type was given so I can not determine" & vbCrLf & _
      "the kind of run you wish to make."
  Else
    fatalError _
      "Unknown run type", _
      "The run type " & runType & " on the sheet " & _
      UCase(ActiveSheet.Name) & " was invalid."
  End If

End Sub

