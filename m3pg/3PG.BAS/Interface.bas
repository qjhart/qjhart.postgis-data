Attribute VB_Name = "Interface"
Option Explicit
Option Base 1

'____________________________________________________________________
'
' Routines establishing the user interface:
'
'   show and act upon the Disclaimer
'   show the About screen
'   create and remove the 3PGpjs hot keys, menu and toolbar
'____________________________________________________________________


' 3PGpjs hotkeys
Private Const runKey = "{F12}"
Private Const helpKey = "{F11}"
Private Const aboutKey = "{F10}"
Private Const quitKey = "%{x}"


'________________________________________________________________________
'
'Routines to setup and close down the 3PGpjs hotkeys, menu and toolbar
'________________________________________________________________________


Public Sub CloseWB()
Dim i As Integer, nMBs As Integer
'Remove the 3PGpjs hot keys
  Application.OnKey key:=runKey
  Application.OnKey key:=helpKey
  Application.OnKey key:=aboutKey
  Application.OnKey key:=quitKey
'Remove the 3PGpjs menu items
  nMBs = MenuBars(xlWorksheet).Menus.count
  For i = nMBs To 1 Step -1
    With MenuBars(xlWorksheet).Menus(i)
      If .Caption = "&3PGpjs" Then .Delete
    End With
  Next i
'Remove the 3PGpjs toolbar buttons
  On Error Resume Next
  Toolbars("3PGpjs").Delete
End Sub

Public Sub OpenWB()
Dim newMenu As Menu, newMenuItem As MenuItem
'Set up 3PGpjs hot keys
  Application.OnKey key:=runKey, procedure:="run3PGpjs"
  Application.OnKey key:=helpKey, procedure:="showHelp"
  Application.OnKey key:=aboutKey, procedure:="showAbout"
  Application.OnKey key:=quitKey, procedure:="quit3PGpjs"
'Set up 3PGpjs menu items
  Set newMenu = MenuBars(xlWorksheet).Menus.Add(Caption:="&3PGpjs")
  Set newMenuItem = newMenu.MenuItems.Add("Run 3PG" & Space(14) & "F12", "run3PGpjs")
  Set newMenuItem = newMenu.MenuItems.Add("Help" & Space(21) & "F11", "showHelp")
  Set newMenuItem = newMenu.MenuItems.Add("About" & Space(18) & "F10", "showAbout")
  Set newMenuItem = newMenu.MenuItems.Add("Quit 3PGpjs" & Space(9) & "alt_X", "quit3PGpjs")
'Set up 3PGpjs toolbar buttons
  On Error GoTo Done
  Toolbars.Add "3PGpjs"
  With Toolbars("3PGpjs")
    .Visible = True
    .Position = xlBottom
    .ToolbarButtons.Add _
        Button:=237, _
        OnAction:="run3PGpjs"
    .ToolbarButtons.Add _
        Button:=220, _
        OnAction:="showHelp"
    .ToolbarButtons.Add _
        Button:=211, _
        OnAction:="showAbout"
  End With
Done:
End Sub


'____________________________________________________
'
'Routines to define the About form and the Disclaimer
'____________________________________________________


Public Sub About3PGpjs()
Const lineHeight = 15
'This is the welcome screen displayed when a workbook is opened. It must be called
'by Sub Workbook_Open()in the ThisWorkbook section of the project.
  With frmAbout3PGpjs
    'title and version
    .lblTitle1 = "3PGpjs"
    .lblTitle2 = "a user interface for 3-PG, a forest growth model"
    .lblVersion = _
      "Version IDs : " & InterfaceVsn & ", " & ModelVsn & vbCrLf & _
      "Date : " & InterfaceDate
    .lblTitle1.Top = 5
    .lblTitle1.Width = .Width - 40
    .lblTitle1.Left = 0
    .lblTitle1.Height = 1.25 * lineHeight
    .lblTitle1.BackColor = .frameTitle.BackColor
    .lblTitle2.Top = .lblTitle1.Top + .lblTitle1.Height
    .lblTitle2.Width = .lblTitle1.Width
    .lblTitle2.Left = 0
    .lblTitle2.Height = 1.25 * lineHeight
    .lblTitle2.BackColor = .frameTitle.BackColor
    .lblVersion.Top = .lblTitle2.Top + .lblTitle2.Height
    .lblVersion.Width = .lblTitle2.Width
    .lblVersion.Left = 0
    .lblVersion.Height = 1.5 * lineHeight
    .lblVersion.BackColor = .frameTitle.BackColor
    'title frame
    .frameTitle.Top = 5
    .frameTitle.Width = .lblTitle1.Width
    .frameTitle.Left = 0.5 * (.Width - .frameTitle.Width) - 3
    .frameTitle.Height = .lblVersion.Top + .lblVersion.Height + 5
    'credits
    .lblCredit1 = "Design and programming :"
    .lblCredit2 = _
      "Peter Sands" & vbCrLf & _
      "CSIRO Forestry and Forest Products & CRC for Sustainable Production Forestry" & vbCrLf & _
      "GPO Box 252-12, Hobart, Tasmania, AUSTRALIA 7001" & vbCrLf & _
      "Email: Peter.Sands@ffp.csiro.au"
    .lblCredit3 = "For information about 3-PG :"
    .lblcredit4 = _
      "Joe Landsberg" & vbCrLf & _
      "22 Mirning Crescent, Aranda, ACT, AUSTRALIA 2614" & vbCrLf & _
      "Email: Joe.Landsberg@landsberg.com.au"
    .lblCredit1.Top = 5
    .lblCredit1.Width = .Width - 30
    .lblCredit1.Left = 0
    .lblCredit1.Height = 1 * lineHeight
    .lblCredit1.BackColor = .frameCredit.BackColor
    .lblCredit2.Top = .lblCredit1.Top + .lblCredit1.Height
    .lblCredit2.Width = .lblCredit1.Width
    .lblCredit2.Left = 0
    .lblCredit2.Height = 3 * lineHeight
    .lblCredit2.BackColor = .frameCredit.BackColor
    .lblCredit3.Top = .lblCredit2.Top + .lblCredit2.Height
    .lblCredit3.Width = .lblCredit1.Width
    .lblCredit3.Left = 0
    .lblCredit3.Height = 1 * lineHeight
    .lblCredit3.BackColor = .frameCredit.BackColor
    .lblcredit4.Top = .lblCredit3.Top + .lblCredit3.Height
    .lblcredit4.Width = .lblCredit1.Width
    .lblcredit4.Left = 0
    .lblcredit4.Height = 2 * lineHeight
    .lblcredit4.BackColor = .frameCredit.BackColor
    'credit frame
    .frameCredit.Top = .frameTitle.Top + .frameTitle.Height + 5
    .frameCredit.Width = .lblCredit1.Width
    .frameCredit.Left = 0.5 * (.Width - .frameCredit.Width) - 3
    .frameCredit.Height = .lblcredit4.Top + .lblcredit4.Height + 5
    'logos
    .imgCSIRO.Top = .frameCredit.Top + .frameCredit.Height + 5
    .imgCSIRO.Left = .frameCredit.Left + 10
    .imgCRC.Top = .imgCSIRO.Top
    .imgCRC.Left = .frameCredit.Left + .frameCredit.Width - .imgCRC.Width - 10
    'continue button
    .btnContinue.Top = .imgCSIRO.Top + 0.5 * (.imgCSIRO.Height - .btnContinue.Height)
    .btnContinue.Left = 0.5 * (.Width - .btnContinue.Width)
    'about form
    .Top = 100
    .Height = .imgCSIRO.Top + .imgCSIRO.Height + 25
  End With
End Sub

Public Sub showDisclaimer()
  If MsgBox( _
    "DISCLAIMER" & vbCrLf & _
    vbCrLf & _
    "Neither CSIRO nor the CRC for Sustainable Production Forestry accept" & vbCrLf & _
    "any responsibility for the use of 3PGpjs or of the model 3-PG in the form" & vbCrLf & _
    "supplied or as subsequently modified by third parties." & vbCrLf & _
    vbCrLf & _
    "3PGpjs does not constitute an endorsement of 3-PG." & vbCrLf & _
    vbCrLf & _
    "CSIRO and the CRC for Sustainable Production Forestry disclaim liability" & vbCrLf & _
    "for all losses, damages and costs incurred by any person as a result of" & vbCrLf & _
    "relying on this software." & vbCrLf & _
    vbCrLf & vbCrLf & _
    "If you agree to these conditions of use: type Y or click on YES to continue.", _
    vbYesNo + 256, "Disclaimer") <> vbYes Then Workbooks(ThisWorkbook.Name).Close
End Sub


Public Sub showAbout()
  frmAbout3PGpjs.show
End Sub

Public Sub showHelp()
  MsgBox _
    "Help for 3PGpjs has not been implimented yet." & vbCrLf & vbCrLf & _
    "Workbook = " & ActiveWorkbook.Name & Space(10) & vbCrLf & _
    "Worksheet = " & ActiveSheet.Name & Space(10), vbInformation, "3PGpjs Help"
End Sub

Public Sub quit3PGpjs()
  Workbooks(ThisWorkbook.Name).Close
End Sub
