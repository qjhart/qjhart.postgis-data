Attribute VB_Name = "The_3PG_Model"
Option Explicit
Option Base 1

'____________________________
'
' The code for the 3-PG Model
'____________________________


Public Const ModelVsn = "3-PG Jan2001"


'Changes in March 2000 version:
'
'   1) Accumulating annual stand transpiration
'   2) Introduced minimum avail soil water, with difference made up by
'      irrigation. Can output monthly and annual irrigation.
'   3) Start mid year in southern hemisphere
'   4) Recast alpha(FR) as alpha*fNutr
'   5) Some change in how functions are parameterised to make parameters
'      more meaningful
'   6) Allometric relationships based on DBH in cm
'   7) Partioning parameterised by pFS for DBH = 2 and 20 cm
'   8) Model made strictly state-determined by ensuring that LAI,
'      partitioning, etc determined from current state not a lagged state.
'   9) SLA made stand-age dependent
'  10) Non-closed canopy allowed for (not good!)
'  11) Manner in which modifiers taken into account corrected
'
'Changes in November 2000 version:
'
'   1)  Penman-Monteith equation coded as a function
'   2)  Corrected how metdata from multiple-year arrays is assigned
'   3)  Made changes so monthly stand summary can be output:
'       * introduced outputIsMonthly as Boolean
'       * computed standVol inside monthly loop
'       * call write3PGresults inside monthly loop
'       * MAI & LAI are monthly values or mean of annual means,
'         depending on output frequency
'   4)  Introduced option to specifiy arbitrary starting month:
'       need year and month of planting, and initial age in years and months,
'       and in both cases months defaults to Jan in N and July in S
'   5)  Added climate arrays for rainy days and open pan evaporation - but
'       this data is ignored in 3PG
'   6)  VPD and Tav can be input directly using preferred climate data block
'   7)  Conversion factors & net radiation parameters added to 3PG_Parameters
'   8)  Rainfall interception increases with increasing LAI to some LAI
'   9)  Mortality submodel now has more of its parameters accessible to user
'       and is applied monthly
'   10) Management options now have a monthly time resolution
'
'Changes in January 2001 version:
'
'   1)  Thinning and defoliation events included - BUT these do not work as
'       expected because of limitations in 3-PG


Private Const Pi = 3.141592654
Private Const ln2 = 0.693147181

'Controls and counters
Public StartAge As Integer, EndAge As Integer  'age of trees at start/end of run
Public InitialYear As Integer                  'year and month of initial observation
Public InitialMonth As Integer
Public YearPlanted As Integer                  'year and month trees were planted
Public MonthPlanted As Integer
Public daysInMonth As Variant                  'array for days in months

'Site characteristics, site specific parameters
Public siteName As String                      'name of site
Public Lat As Double                           'site latitude
Public MaxASW As Double, MinASW                'maximum & minimum available soil water
Public FR As Double                            'current site fertility rating
Public soilClass As Integer                    'soil class index
Public SWconst As Double, SWpower As Double    'soil parameters for soil class

'Time variant silvicultural factors or events
Public nThinning As Integer                    'number of thinning events
Public Thinning() As Double                    'residual stem numbers
Public thinWF() As Double                      '% of single-tree mean foliage,
Public thinWR() As Double                      '  root and stem DM on each tree
Public thinWS() As Double                      '  removed by thinning
Public nDefoliation As Integer                 'number of defoliation events
Public Defoliation() As Double                 '% foliage remaining after defoliation
Public nFertility As Integer                   'size of site fertility array
Public Fertility() As Double                   'time-variant site fertility
Public nMinAvailSW As Integer                  'size of MinAvailSW array
Public MinAvailSW() As Double                  'time-variant MinAvailSW (mm)
Public nIrrigation As Integer                  'size of irrigation array
Public Irrigation() As Double                  'time-variant irrigation (ML/y)
Public Irrig As Double                         'current annual irrigation (ML/y)

'Basic weather data set
Public mYears As Integer                       'years of met data available
Public mDayLength() As Double                  'day length
Public mFrostDays() As Integer                 'frost days/month
Public mRainyDays() As Integer                 'rainy days/month
Public mSolarRad() As Double                   'solar radiation (MJ/m2/day)
Public mTx() As Double                         'maximum temperature
Public mTn() As Double                         'minimum temperature
Public mTav() As Double                        'mean daily temperature
Public mVPD() As Double                        'mean daily VPD (mBar)
Public mEpan() As Double                       'mean daily pan evaporation (mm)
Public mRain() As Double                       'total monthly rain + irrigation (mm)
  
'Current monthly met data
Public DayLength As Double                     'day length
Public FrostDays As Integer                    'frost days/month
Public SolarRad As Double                      'solar radiation (MJ/m2/day)
Public Tav As Double                            'mean daily temperature
Public VPD As Double                           'mean daily VPD (mBar)
Public Rain As Double                          'total monthly rain + irrigation

'Stand data
Public SpeciesName As String                   'name of species
Public StandAge As Double                      'stand age
Public ASWi As Double, ASW As Double           'available soil water
Public StemNoi As Double, StemNo As Double     'stem numbers
Public WFi As Double, WF As Double             'foliage biomass
Public WRi As Double, WR As Double             'root biomass
Public WSi As Double, WS As Double             'stem biomass
Public avLAI As Double                         'canopy leaf area index (averaged over time step)
Public MAI As Double                           'mean volume increment
Public avDBH As Double                         'average stem DBH
Public TotalW As Double                        'total biomass
Public BasArea As Double                       'basal area
Public StandVol As Double                      'stem volume
Public TotalLitter As Double                   'total litter produced
Public LAIx As Double, ageLAIx As Double       'peak LAI and age at peak LAI
Public MAIx As Double, ageMAIx As Double       'peak MAI and age at peak MAI

'Stand factors that are specifically age dependent
Public SLA As Double
Public Littfall As Double
Public fracBB As Double
Public CanCover As Double

'Intermediate results (mainly monthly)
Public LAI As Double
Public m As Double, alphaC As Double
Public RAD As Double, PAR As Double
Public lightIntcptn As Double
Public fAge As Double, fT As Double, fFrost As Double
Public fVPD As Double, fSW As Double, fNutr As Double
Public PhysMod As Double
Public CanCond As Double
Public Transp As Double
Public EvapTransp As Double
Public AvStemMass As Double, wSmax As Double, delStemNo As Double
Public APAR As Double, APARu As Double
Public GPPmolc As Double, GPPdm As Double, NPP As Double
Public pR As Double, pS As Double, pF As Double, pFS As Double
Public delWF As Double, delWR As Double, delWS As Double, delStems As Double
Public delLitter As Double, delRoots As Double
Public monthlyIrrig As Double
Public CVI As Double, Litter As Double

'Annual results
Public cumGPP As Double, cumNPP As Double, cumWabvgrnd As Double
Public abvgrndEpsilon As Double, totalEpsilon As Double
Public cumdelWF As Double, cumdelWR As Double, cumdelWS As Double
Public cumAPARU As Double, cumARAD As Double
Public cumTransp As Double                     'annual stand transpiration
Public cumEvapTransp As Double                 'annual stand evapotransporation
Public cumIrrig As Double                      'annual irrig. to maintain MinASW

'Parameter values
Public MaxAge As Integer
Public gammaFx As Double, gammaF0 As Double, tgammaF As Double
Public Rttover As Double
Public SLA0 As Double, SLA1 As Double, tSLA As Double
Public fullCanAge As Double
Public k As Double
Public pFS2 As Double, pFS20 As Double
Public StemConst As Double, StemPower As Double
Public SWconst0 As Double, SWpower0 As Double
Public MaxIntcptn As Double, LAImaxIntcptn As Double
Public BLcond As Double, LAIgcx As Double
Public MaxCond As Double, CoeffCond As Double
Public y As Double
Public Tmax As Double, Tmin As Double, Topt As Double
Public wSx1000 As Double, thinPower As Double
Public mF As Double, mR As Double, mS As Double
Public m0 As Double, fN0 As Double
Public alpha As Double
Public pRx As Double, pRn As Double
Public nAge As Double, rAge As Double
Public kF As Double
Public fracBB0 As Double, fracBB1 As Double, tBB As Double
Public Density As Double
Public pfsConst As Double, pfsPower As Double      'derived from pFS2, pFS20

'Conversion factors
Public Qa As Double, Qb As Double
Public gDM_mol As Double
Public molPAR_MJ As Double

'Variables controlling generation of output

Public Const opfNone = 0               'Constants for output frequency
Public Const opfRotation = 1
Public Const opfAnnual = 2
Public Const opfMonthly = 3

Public outputFrequency As Integer      'Current output frequency

Public Const opStart = 0               'Constants for stage in run at
Public Const opEndMonth = 1            'which write3PGResults called
Public Const opEndYear = 2
Public Const opEndRun = 3


'The following procedures are used here but must be declared externally:
'
'Private Sub write3PGresults (action As Integer, year as integer, month As Integer)
'End Sub
'
'Private Sub fatalError(title As String, msg As String)
'End Sub


Public Sub assignDefaultParameters()
  'Parameter values
  MaxAge = 50          'Determines rate of "physiological decline" of forest
  SLA0 = 4             'specific leaf area at age 0 (m^2/kg)
  SLA1 = 4             'specific leaf area for mature trees (m^2/kg)
  tSLA = 2.5           'stand age (years) for SLA = (SLA0+SLA1)/2
  fullCanAge = 0       'Age at full canopy cover
  k = 0.5              'Radiation extinction coefficient
  gammaFx = 0.03       'Coefficients in monthly litterfall rate
  gammaF0 = 0.001
  tgammaF = 24
  Rttover = 0.015      'Root turnover rate per month
  SWconst0 = 0.7       'SW constants are 0.7 for sand,0.6 for sandy-loam,
                       '  0.5 for clay-loam, 0.4 for clay
  SWpower0 = 9         'Powers in the eqn for SW modifiers are 9 for sand,
                       '  7 for sandy-loam, 5 for clay-loam and 3 for clay
  MaxIntcptn = 0.15    'Max proportion of rainfall intercepted by canopy
  LAImaxIntcptn = 0    'LAI required for maximum rainfall interception
  MaxCond = 0.02       'Maximum canopy conductance (gc, m/s)
  LAIgcx = 3.33        'LAI required for maximum canopy conductance
  BLcond = 0.2         'Canopy boundary layer conductance, assumed constant
  CoeffCond = 0.05     'Determines response of canopy conductance to VPD
  y = 0.47             'Assimilate use efficiency
  Tmax = 32            '"Critical" biological temperatures: max, min
  Tmin = 2             '  and optimum. Reset if necessary/appropriate
  Topt = 20
  kF = 1               'Number of days production lost per frost days
  pFS2 = 1             'Foliage:stem partitioning ratios for D = 2cm
  pFS20 = 0.15         '  and D = 20cm
  StemConst = 0.095    'Stem allometric parameters
  StemPower = 2.4
  pRx = 0.8            'maximum root biomass partitioning
  pRn = 0.25           'minimum root biomass partitioning
  m0 = 0               'Value of m when FR = 0
  fN0 = 1              'Value of fN when FR = 0
  alpha = 0.055        'Canopy quantum efficiency
  wSx1000 = 300        'Max tree stem mass (kg) likely in mature stands of 1000 trees/ha
  thinPower = 3 / 2    'Power in self-thinning law
  mF = 0               'Leaf mortality fraction
  mR = 11 / 54         'Root mortality fraction
  mS = 11 / 54         'Stem mortality fraction
  nAge = 4             'Parameters in age-modifier
  rAge = 0.95
  fracBB0 = 0.15       'branch & bark fraction at age 0 (m^2/kg)
  fracBB1 = 0.15       'branch & bark fraction for mature trees (m^2/kg)
  tBB = 1.5            'stand age (years) for fracBB = (fracBB0+fracBB1)/2
  Density = 0.5        'basic density (t/m3)
  'Conversion factors
  Qa = -90             'intercept of net v. solar radiation relationship (W/m2)
  Qb = 0.8             'slope of net v. solar radiation relationship
  gDM_mol = 24         'conversion of mol to gDM
  molPAR_MJ = 2.3      'conversion of MJ to PAR
End Sub

Private Sub Initialisation()
  'Assign the SWconst and SWpower parameters for this soil class
  If soilClass > 0 Then
    'standard soil type
    SWconst = 0.8 - 0.1 * soilClass
    SWpower = 11 - 2 * soilClass
  ElseIf soilClass < 0 Then
    'use supplied parameters
    SWconst = SWconst0
    SWpower = SWpower0
  Else
    'no soil-water effects
    SWconst = 999
    SWpower = SWpower0
  End If
  'Derive some parameters
  pfsPower = Log(pFS20 / pFS2) / Log(20 / 2)
  pfsConst = pFS2 / 2 ^ pfsPower
  'Initial ASW must be between min and max ASW
  If ASWi <= MinASW Then ASWi = MinASW Else _
  If ASWi >= MaxASW Then ASWi = MaxASW
  Irrig = 0
  'Initialise ages
  MAIx = 0
  LAIx = 0
End Sub

Private Sub getStandAge()
'This procedure gets the starting month and intial stand age
  'Determine starting month for each year
  If InitialMonth = 0 Then
    If Lat > 0 Then InitialMonth = 0 Else InitialMonth = 6
  End If
  If MonthPlanted = 0 Then
    If Lat > 0 Then MonthPlanted = 0 Else MonthPlanted = 6
  End If
  'Assign initial stand age
  If InitialYear < YearPlanted Then InitialYear = YearPlanted + InitialYear
  StandAge = (InitialYear + InitialMonth / 12) - (YearPlanted + MonthPlanted / 12)
  'get and check StartAge
  StartAge = Int(StandAge)
  If StartAge < 0 Then
    fatalError _
      "Invalid age limits", _
      "The starting age (" & StartAge & ") must be greater than 0!"
  ElseIf StartAge > EndAge Then
    fatalError _
      "Invalid age limits", _
      "The starting age (" & StartAge & ") is greater than" & vbCrLf & _
      "the ending age (" & EndAge & ")."
  End If
End Sub
  
Private Function getMortality(oldN As Double, oldW As Double) As Double
'This function determines the number of stems to remove to ensure the
'self-thinning rule is satisfied. It applies the Newton-Rhapson method
'to solve for N to an accuracy of 1 stem or less. To change this,
'change the value of "accuracy".
'This was the old mortality function:
'  getMortality = oldN - 1000 * (wSx1000 * oldN / oldW / 1000) ^ (1 / thinPower)
'which has been superceded by the following ...
Const accuracy = 1 / 1000
Dim i As Integer, fN As Double, dfN As Double
Dim dN As Double, n As Double, x1 As Double, x2 As Double
  n = oldN / 1000
  x1 = 1000 * mS * oldW / oldN
  i = 0
  Do
    i = i + 1
    x2 = wSx1000 * n ^ (1 - thinPower)
    fN = x2 - x1 * n - (1 - mS) * oldW
    dfN = (1 - thinPower) * x2 / n - x1
    dN = -fN / dfN
    n = n + dN
  If (Abs(dN) <= accuracy) Or (i >= 5) Then Exit Do
  Loop
  getMortality = oldN - 1000 * n
 End Function

Private Function CanopyTranspiration _
  (Q As Double, VPD As Double, h As Double, gBL As Double, gC As Double) As Double
'Penman-Monteith equation for computing canopy transpiration
'in kg/m2/day, which is conmverted to mm/day.
'The following are constants in the PM formula (Landsberg & Gower, 1997)
Const e20 = 2.2          ' rate of change of saturated VP with T at 20C
Const rhoAir = 1.2       ' density of air, kg/m3
Const lambda = 2460000#  ' latent heat of vapourisation of H2O (J/kg)
Const VPDconv = 0.000622 ' convert VPD to saturation deficit = 18/29/1000
Dim netRad As Double, defTerm As Double, div As Double, Etransp As Double
  netRad = Qa + Qb * (Q * 10 ^ 6 / h)                ' Q in MJ/m2/day --> W/m2
  defTerm = rhoAir * lambda * (VPDconv * VPD) * gBL
  div = (1 + e20 + gBL / gC)
  Etransp = (e20 * netRad + defTerm) / div           ' in J/m2/s
  CanopyTranspiration = Etransp / lambda * h         ' converted to kg/m2/day
End Function


Public Sub doThinning(n As Integer, table As Variant)
'If it is time to do a thinning, carry out the thinning (if there are
'stems to remove) and update the thinnning eventNo
Dim delStemNo As Double
  If StandAge >= table(1, n) Then
    If StemNo > table(2, n) Then
      delStemNo = (StemNo - table(2, n)) / StemNo
      
      WF = WF - ((StemNo - table(2, n)) * (WF / StemNo) * table(3, n))
      WR = WR - ((StemNo - table(2, n)) * (WR / StemNo) * table(4, n))
      WS = WS - ((StemNo - table(2, n)) * (WS / StemNo) * table(5, n))
      StemNo = StemNo * (1 - delStemNo)
    End If
    n = n + 1
  End If
End Sub

Public Sub doDefoliation(n As Integer, table As Variant)
'If it is time of a defoliation, and if so carry out the defoliation
'and update the thinnning eventNo
  If StandAge >= table(1, n) Then
    WF = WF * table(2, n) / 100
    n = n + 1
  End If
End Sub


Private Function lookupTable(age As Variant, table As Variant) As Double
'Perform a look-up in a table to determine a value of a function.
'This is used to determine the annual values of management options.
Dim n As Integer, i As Integer
  n = UBound(table, 2)
  i = 1
  Do Until (age <= table(1, i)) Or (i > n - 1)
    i = i + 1
  Loop
  If i <= n Then lookupTable = table(2, i) Else lookupTable = table(2, n)
End Function

Private Function Minimum(a As Double, b As Double) As Double
  If a < b Then Minimum = a Else Minimum = b
End Function

Private Function Maximum(a As Double, b As Double) As Double
  If a > b Then Maximum = a Else Maximum = b
End Function



'This is the main routine for the 3PG model

Public Sub run3PG()

  'The following variables probabaly could be Public so they can be
  'printed as part of the monthly output ...
  Dim RelAge As Double, dayofyr As Double, convert As Double
  Dim MoistRatio As Double, MaxCond1 As Double, Intcptn As Double
  Dim oldVol As Double, oldLitter As Double

  'year and month counters, etc
  Dim year As Integer, month As Integer, monthsInStep As Integer
  Dim monthCounter As Integer, metMonth As Integer
  Dim thinEventNo As Integer, defoltnEventNo As Integer

  Call Initialisation
  If outputFrequency = opfMonthly Then monthsInStep = 1 Else monthsInStep = 12

  'Assign initial state of stand
  
  Call getStandAge
  WS = WSi
  WF = WFi
  WR = WRi
  StemNo = StemNoi
  ASW = ASWi
  TotalLitter = 0
  thinEventNo = 1
  defoltnEventNo = 1


  AvStemMass = WS * 1000 / StemNo                             ' kg/tree
  avDBH = (AvStemMass / StemConst) ^ (1 / StemPower)
  BasArea = (((avDBH / 200) ^ 2) * Pi) * StemNo
  SLA = SLA1 + (SLA0 - SLA1) * Exp(-ln2 * (StandAge / tSLA) ^ 2)
  LAI = WF * SLA * 0.1
  avLAI = LAI

  fracBB = fracBB1 + (fracBB0 - fracBB1) * Exp(-ln2 * (StandAge / tBB))
  StandVol = WS * (1 - fracBB) / Density
  If StandAge > 0 _
    Then MAI = StandVol / StandAge _
    Else MAI = 0

  'Output headings etc
  Call write3PGResults(opStart, 0, 0)
    
  'Do annual calculations
  metMonth = InitialMonth
  For year = 1 To EndAge - StartAge

  'Initialise cumulative variables
    cumdelWF = 0
    cumdelWR = 0
    cumdelWS = 0
    cumAPARU = 0
    cumARAD = 0
    cumGPP = 0
    cumNPP = 0
    cumWabvgrnd = 0
    cumTransp = 0
    cumEvapTransp = 0
    cumIrrig = 0

    'Do monthly calculations

    month = InitialMonth
    For monthCounter = 1 To 12
    
      If (outputFrequency = opfMonthly) Or (monthCounter = 1) Then
        avLAI = 0
        delStemNo = 0
        oldVol = StandVol
        oldLitter = TotalLitter
      End If

    'Assign this months met data

      month = month + 1
      metMonth = metMonth + 1
      If month > 12 Then month = 1
      If metMonth > 12 * mYears Then metMonth = 1
      SolarRad = mSolarRad(metMonth)
      Tav = mTav(metMonth)
      VPD = mVPD(metMonth)
      FrostDays = mFrostDays(metMonth)
      DayLength = mDayLength(metMonth)
      Rain = mRain(metMonth)

    'Set silvicultural parameters for this time step
  
      If nFertility > 0 Then FR = lookupTable(StandAge, Fertility)
      If nMinAvailSW > 0 Then MinASW = lookupTable(StandAge, MinAvailSW)
      If nIrrigation > 0 Then Irrig = lookupTable(StandAge, Irrigation)
      
    'Determine the various environmental modifiers

      'calculate temperature response function to apply to alpha
      If (Tav <= Tmin) Or (Tav >= Tmax) _
        Then fT = 0 _
        Else fT = ((Tav - Tmin) / (Topt - Tmin)) * _
                  ((Tmax - Tav) / (Tmax - Topt)) ^ _
                  ((Tmax - Topt) / (Topt - Tmin))

      'calculate VPD modifier
      fVPD = Exp(-CoeffCond * VPD)

      'calculate soil water modifier
      MoistRatio = ASW / MaxASW
      fSW = 1 / (1 + ((1 - MoistRatio) / SWconst) ^ SWpower)

      'calculate soil nutrition modifier
      fNutr = fN0 + (1 - fN0) * FR

      'calculate frost modifier
      fFrost = 1 - kF * (FrostDays / 30)

      'calculate age modifier
      RelAge = StandAge / MaxAge
      fAge = (1 / (1 + (RelAge / rAge) ^ nAge))

      'calculate physiological modifier applied to conductance and APARu.
      PhysMod = Minimum(fVPD, fSW) * fAge

    'Determine gross and net biomass production

      'canopy cover and light interception.
      CanCover = 1
      If (fullCanAge > 0) And (StandAge < fullCanAge) Then CanCover = StandAge / fullCanAge
      lightIntcptn = (1 - (Exp(-k * LAI)))

      'Calculate PAR, APAR, APARu and GPP
      RAD = SolarRad * daysInMonth(month)        'MJ/m^2
      PAR = RAD * molPAR_MJ                      'mol/m^2
      APAR = PAR * lightIntcptn * CanCover
      APARu = APAR * PhysMod
      alphaC = alpha * fNutr * fT * fFrost
      GPPmolc = APARu * alphaC                   'mol/m^2
      GPPdm = (GPPmolc * gDM_mol) / 100               'tDM/ha
      NPP = GPPdm * y                            'assumes respiratory rate is constant

    'Determine biomass increments and losses

      'calculate partitioning coefficients
      m = m0 + (1 - m0) * FR
      pFS = pfsConst * avDBH ^ pfsPower
      pR = pRx * pRn / (pRn + (pRx - pRn) * PhysMod * m)
      pS = (1 - pR) / (1 + pFS)
      pF = 1 - pR - pS

      'calculate biomass increments
      delWF = NPP * pF
      delWR = NPP * pR
      delWS = NPP * pS

      'calculate litterfall & root turnover -
      Littfall = gammaFx * gammaF0 / (gammaF0 + (gammaFx - gammaF0) * _
                 Exp(-12 * Log(1 + gammaFx / gammaF0) * StandAge / tgammaF))
      delLitter = Littfall * WF
      delRoots = Rttover * WR

    'Calculate end-of-month biomass

      WF = WF + delWF - delLitter
      WR = WR + delWR - delRoots
      WS = WS + delWS
      TotalW = WF + WR + WS
      TotalLitter = TotalLitter + delLitter

    'Now do the water balance ...

      'calculate canopy conductance from stomatal conductance
      CanCond = MaxCond * PhysMod * Minimum(1, LAI / LAIgcx)
      If CanCond = 0 Then CanCond = 0.0001

      'transpiration from Penman-Monteith (mm/day converted to mm/month)
      Transp = CanopyTranspiration(SolarRad, VPD, DayLength, BLcond, CanCond)
      Transp = daysInMonth(month) * Transp

      'do soil water balance
      If LAImaxIntcptn <= 0 _
        Then Intcptn = MaxIntcptn _
        Else Intcptn = MaxIntcptn * Minimum(1, LAI / LAImaxIntcptn)
      EvapTransp = Transp + Intcptn * Rain
      ASW = ASW + Rain + (100 * Irrig / 12) - EvapTransp        ' Irrig is Ml/ha/year
      monthlyIrrig = 0
      If ASW < MinASW Then
        If MinASW > 0 Then 'make up deficit with irrigation
          monthlyIrrig = MinASW - ASW
          cumIrrig = cumIrrig + monthlyIrrig
        End If
        ASW = MinASW
      ElseIf ASW > MaxASW Then
        ASW = MaxASW
      End If


    'Update tree and stand data at the end of this time period,
    'taking mortality, thinning or defoliation into account

      StandAge = StandAge + 1 / 12
      
      'Perform any thinning or defoliation events for this time period
      If thinEventNo <= nThinning Then Call doThinning(thinEventNo, Thinning)
      If defoltnEventNo <= nDefoliation Then Call doDefoliation(defoltnEventNo, Defoliation)
      
      'Calculate mortality
      wSmax = wSx1000 * (1000 / StemNo) ^ thinPower
      AvStemMass = WS * 1000 / StemNo
      delStems = 0
      If wSmax < AvStemMass Then
        delStems = getMortality(StemNo, WS)
        WF = WF - mF * delStems * (WF / StemNo)
        WR = WR - mR * delStems * (WR / StemNo)
        WS = WS - mS * delStems * (WS / StemNo)
        StemNo = StemNo - delStems
        wSmax = wSx1000 * (1000 / StemNo) ^ thinPower
        AvStemMass = WS * 1000 / StemNo
        delStemNo = delStemNo + delStems
      End If
  
      'update age-dependent factors
      SLA = SLA1 + (SLA0 - SLA1) * Exp(-ln2 * (StandAge / tSLA) ^ 2)
      fracBB = fracBB1 + (fracBB0 - fracBB1) * Exp(-ln2 * (StandAge / tBB))
      
      'update stsand characteristics
      LAI = WF * SLA * 0.1
      avDBH = (AvStemMass / StemConst) ^ (1 / StemPower)
      BasArea = (((avDBH / 200) ^ 2) * Pi) * StemNo
      StandVol = WS * (1 - fracBB) / Density
      If StandAge > 0 _
        Then MAI = StandVol / StandAge _
        Else MAI = 0
    
    'Update accumulated totals

      cumTransp = cumTransp + Transp
      cumEvapTransp = cumEvapTransp + EvapTransp
      cumdelWF = cumdelWF + delWF
      cumdelWR = cumdelWR + delWR
      cumdelWS = cumdelWS + delWS
      cumWabvgrnd = cumWabvgrnd + delWF + delWS - delLitter
      cumGPP = cumGPP + GPPdm
      cumNPP = cumNPP + NPP

      'Accumulate intercepted radiation (MJ/m2) and production (t/ha)
      cumARAD = cumARAD + RAD * lightIntcptn * CanCover
      cumAPARU = cumAPARU + APARu

      'Determine annual average and peak LAI & MAI and age at peaks
      '  avLAI = average over time step and is variable for output
      avLAI = avLAI + LAI / monthsInStep
      If (outputFrequency = opfMonthly) Or (monthCounter = 12) Then
        CVI = StandVol - oldVol
        delLitter = TotalLitter - oldLitter
        If avLAI > LAIx Then
          LAIx = avLAI
          ageLAIx = StandAge
        End If
        If MAI > MAIx Then
          MAIx = MAI
          ageMAIx = StandAge
        End If
      End If
      
      'do monthly outputs
      Call write3PGResults(opEndMonth, year, monthCounter)
  
    Next monthCounter

    'Calculate above ground and total Epsilon
    If cumARAD = 0 Then
      fatalError _
        "Stand not growing", _
        "No growth occurred in the year with Standage = " & StandAge & vbCrLf & _
        "To check what might be causing this, repeat the run" & vbCrLf & _
        "with monthly output turned on."
    End If
    abvgrndEpsilon = 100 * cumWabvgrnd / cumARAD    ' 100 converts to gDM/MJ
    totalEpsilon = 100 * cumGPP / cumARAD
    
    'do annual outputs
    Call write3PGResults(opEndYear, year, 12)
    
  Next year

  'end of rotation outputs
  Call write3PGResults(opEndRun, year, monthCounter)
  
End Sub
