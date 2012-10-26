#! /usr/bin/make -n
#http://www.fsl.orst.edu/~waring/3-PG_Workshops/WorkshopContents.htm
#http://www.fsl.orst.edu/~waring/3-PG_Workshops/3PGpjs(RHW)2004CLASS.xls

ifndef configure.mk
include ../configure.mk
endif

m3pg.mk:=1

#Coefficients in monthly litterfall rate
gammaFx := 0.03
gammaF0 := 0.001
tgammaF := 24
Rttover:= 0.015
#y:= 0.47 #  Assimiliation use Efficiency
#gDM_mol := 24         #'conversion of mol to gDM
#molPAR_MJ := 2.3      #'conversion of MJ to PAR
k:= 0.5
# Not specified
fullCanAge:=4
# Poplar Specific parameters for 3PG
poplar.kG:=0.5 
# /kPa  0.05 in BAS but mBar?
# id'd as 1.9 or 2.5 in original paper.
#Critical" biological temperatures: max, min and optimum. Reset if necessary/appropriate
Tmax := 32
Tmin := 2
Topt := 20

BLcond := 0.2         #Canopy boundary layer conductance, assumed constant

maxAge:=50
rAge:=0.95
nAge:=4

fN0:=1
FR:=0.7

SLA0:=2
SLA1:=4
tSLA:=2.5

MaxCond:=0.02
LAIgcx:=3.33

e20:=2.2
rhoAir:=1.2
lambda:=246000
VPDconv:=0.000622
#intercept of net v. solar radiation relationship (W/m2)
Qa := -90
Qb := 0.8 #slope of net v. solar radiation relationship

m0:=0
pRx:=0.8  #maximum root biomass partitioning
pRn:=0.25 #minimum root biomass partitioning
#pFS2 = 1             'Foliage:stem partitioning ratios for D = 2cm
#pFS20 = 0.15         '  and D = 20cm
#pfsPower = Log(pFS20 / pFS2) / Log(20 / 2)
#pfsConst = pFS2 / 2 ^ pfsPower
pfsPower:=-0.8239
pfsConst:=1.7701

StemConst:=0.095
StemPower:=2.4

wSx1000:= 300
thinPower:=1.5 # 3/2

# Are we currently Running Grass?
ifndef GISRC
  $(error Must be running in GRASS)
endif

GISDBASE:=$(shell g.gisenv get=GISDBASE)
LOCATION_NAME:=$(shell g.gisenv get=LOCATION_NAME)
MAPSET:=$(shell g.gisenv get=MAPSET)

# National Landcover datasets
nlcd.loc:=conterminous_us
nlcd.rast:=${GISDBASE}/${nlcd.loc}/nlcd/cellhd

# Shortcut Directories for the m3pg monthly Mapsets
m3pg.loc:=${GISDBASE}/ahb-pnw
rast:=$(loc)/$(MAPSET)/cellhd

res:=2048 8192


# Calculate the representative days to use
# same as solaR library fBTd(mode = "prom")
months:=01 02 03 04 05 06 07 08 09 10 11 12

m.01.date:=2012-01-17 
m.02.date:=2012-02-14 
m.03.date:=2012-03-15 
m.04.date:=2012-04-15
m.05.date:=2012-05-15 
m.06.date:=2012-06-10 
m.07.date:=2012-07-18 
m.08.date:=2012-08-18
m.09.date:=2012-09-18 
m.10.date:=2012-10-19 
m.11.date:=2012-11-18 
m.12.date:=2012-12-13

# Assoicated months
#doys:=$(foreach d,${dates},$(shell date --date=$d +%j))
m.01.j:=017
m.02.j:=045
m.03.j:=075
m.04.j:=106
m.05.j:=136
m.06.j:=162
m.07.j:=200
m.08.j:=231
m.09.j:=262
m.10.j:=293
m.11.j:=323
m.12.j:=348

m.mapsets:=$(patsubst %,${m3pg.loc}/XXXX-%,${months})

INFO::
	echo "3PG Model"
	echo "${doys}"

.PHONY:db
db:db/m3pg

db/m3pg:
	[[ -d db ]] || mkdir db
	${PG} -f m3pg.sql
	touch $@

# Solar is in own makefile
include solar.mk
# PRISM in own Makefile
include prism.mk

fractions:=poplar.fVPD fAGE fT fFrost fSMR
$(foreach f,${fractions},$(eval m.${f}s:=$(patsubst %,%/cellhd/$f,${m.mapsets})))

.PHONY:poplar.fVPD
poplar.fVPD:${m.poplar.fVPDs}

${m.poplar.fVPDs}:${m3pg.loc}/%/cellhd/poplar.fVPD:${m3pg.loc}/%/cellhd/tmin ${m3pg.loc}/%/cellhd/tmax ${m3pg.loc}/%/cellhd/tdmean
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
        r.mapcalc 'VPD=(0.6108/2*(exp(tmin*17.27/(tmin + 237.3))+ exp(tmax*17.27/(tmax+237.3))))-(0.6108*exp(tdmean)*17.27/((tdmean+237.3)))'; \
	r.support map=VPD units=kPa source1='Derived from PRISM' \
	  description='Mean vapor pressure deficit';\
	r.mapcalc 'poplar.fVPD=exp(${poplar.kG}*VPD)'; \
	r.support map=poplar.fVPD units=unitless source1='3PG Model' \
	  description='Vapor Pressure Deficit Modifier (Poplar)';\
	r.colors map=poplar.fVPD colors=grey1.0;

fFrost:${m.fFrosts}
${m.fFrosts}:${m3pg.loc}/%/cellhd/fFrost:${m3pg.loc}/%/cellhd/tmin
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.mapcalc 'fFrost=0.5*(1.0+if(tmin>=0,1.0,-1.0)*sqrt(1-exp(-1*(0.17*tmin)^2*(4/3.14159+.14*(0.17*tmin)^2)/(1+0.14*(0.17*tmin)^2))))'
	r.support map=fFrost units=unitless source1='3PG Model' \
	  source2='Estimated from tmin' \
	  description='Number of Freeze Days Modifier';\
	r.colors map=fFrost colors=grey1.0;

fT:${m.fTs}
${m.fTs}:${m3pg.loc}/%/cellhd/fT:${m3pg.loc}/%/cellhd/tdmean
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.mapcalc  'fT=if((tdmean <= ${Tmin} || tdmean >= ${Tmax}),0,((tdmean - ${Tmin}) / (${Topt} - ${Tmin})) * ((${Tmax} - tdmean) / (${Tmax} - ${Topt})) ^ ((${Tmax} - ${Topt}) / (${Topt} - ${Tmin})))'; \
	r.support map=fT units=unitless source1='3PG Model' \
	  source2='Estimated from tdmean' \
	  description='Temperature modifier';\
	r.colors map=fT colors=grey1.0;


# Starting mapset
start:=2012-03

.PHONY:${start}
${start}:${m3pg.loc}/${start}/cellhd/WF

# Seedlings = 1gm * 12000 trees/ha
${m3pg.loc}/${start}/cellhd/WF:${m3pg.loc}/%/cellhd/WF:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=${*}; \
	g.region rast=Z@m3pg;
	r.mapcalc StandAge=1.0/12;
	r.mapcalc WF= 0.5*12000/10000;
	r.mapcalc WR=0.25*12000/10000;
	r.mapcalc WS=0.25*12000/10000;
	r.mapcalc ASW=0.8*maxAWS@statsgo;
	r.mapcalc 'LAI=WF*0.1*(${SLA1}+(${SLA0} - ${SLA1}) * exp(-0.693147180559945 * (StandAge / ${tSLA}) ^ 2))'
	r.mapcalc StemNo=12000.0;
	r.mapcalc Count=12000.0;

define add_month 

.PHONY:$1

$1:${m3pg.loc}/$1/cellhd/WF ${m3pg.loc}/$1/cellhd/ASW ${m3pg.loc}/$1/cellhd/LAI

${m3pg.loc}/$1/cellhd:
	g.mapset -c "$1" || true
	g.region rast=Z@m3pg;

${m3pg.loc}/$1/cellhd/fAge:${m3pg.loc}/$2/cellhd/StandAge
	g.mapset "$1"|| true
	g.region rast=Z@m3pg;
	r.mapcalc 'fAge=(1/(1+(("StandAge@$2"/${maxAge}) / ${rAge})^${nAge}))'

${m3pg.loc}/$1/cellhd/ASW:${m3pg.loc}/$2/cellhd/ASW ${m3pg.loc}/$1/cellhd/ET
	g.mapset "$1"|| true
	g.region rast=Z@m3pg;
	r.mapcalc 'ASW = min(maxAWS@statsgo,max("ASW@$2" + "ppt@$3"/10.0 - ET,0))'

${m3pg.loc}/$1/cellhd/fSW:${m3pg.loc}/$2/cellhd/ASW
	g.mapset "$1"|| true
	g.region rast=Z@m3pg;
	r.mapcalc 'fSW = 1 / (1 + ((1 - ("ASW@$2"/maxAWS@statsgo)) / swconst@statsgo) ^ swpower@statsgo)'

${m3pg.loc}/$1/cellhd/fNutr:${m3pg.loc}/$1/cellhd
	g.mapset "$1"|| true
	g.region rast=Z@m3pg;
	r.mapcalc 'fNutr = ${fN0} + (1 - ${fN0}) * ${FR}'

${m3pg.loc}/$1/cellhd/PhysMod:${m3pg.loc}/$3/cellhd/poplar.fVPD ${m3pg.loc}/$1/cellhd/fSW ${m3pg.loc}/$1/cellhd/fAge 
	g.mapset "$1"|| true;\
	g.region rast=Z@m3pg;\
	r.mapcalc 'PhysMod=min("poplar.fVPD@$3",fSW)*fAge';\
	r.support map=PhysMod units=unitless description='Physiological Modifier to conductance and APARu';

${m3pg.loc}/$1/cellhd/LAI:${m3pg.loc}/$2/cellhd/WF ${m3pg.loc}/$2/cellhd/StandAge
	g.mapset "$1"|| true;\
	g.region rast=Z@m3pg;\
	r.mapcalc 'LAI="WF@$2"*0.1*(${SLA1}+(${SLA0} - ${SLA1}) * exp(-0.693147180559945 * ("StandAge@$2" / ${tSLA}) ^ 2))'
	r.support map=LAI units='m2/m2' description='Leaf Area Index';\

${m3pg.loc}/$1/cellhd/CanCond:${m3pg.loc}/$1/cellhd/LAI ${m3pg.loc}/$1/cellhd/PhysMod
	g.mapset "$1"|| true;\
	g.region rast=Z@m3pg;\
	r.mapcalc 'CanCond=max(0.0001,${MaxCond}*PhysMod*min(1,LAI/${LAIgcx}))';\
	r.support map=CanCond units='gc,m/s' description='Canopy Conductance';\

${m3pg.loc}/$1/cellhd/ET:${m3pg.loc}/$3/cellhd/nrel ${m3pg.loc}/$3/cellhd/daylight ${m3pg.loc}/$3/cellhd/VPD ${m3pg.loc}/$1/cellhd/CanCond 
#${m3pg.loc}/$1/cellhd/ET:${m3pg.loc}/$3/cellhd/nrel ${m3pg.loc}/$3/cellhd/VPD ${m3pg.loc}/$1/cellhd/CanCond 
	g.mapset "$1"|| true;\
	g.region rast=Z@m3pg;\
	r.mapcalc 'ET = 30.4*(${e20}*(${Qa}+${Qb}*("nrel@$3"/"daylight@$3")) + (${rhoAir}*${lambda}*${VPDconv}*"VPD@$3"*${BLcond})) / (1+${e20}+${BLcond}/CanCond)';\
	r.support map=ET units='m/mon' description='Canopy Monthly Evapotranspiration';

${m3pg.loc}/$1/cellhd/WF:${m3pg.loc}/$2/cellhd/WF ${m3pg.loc}/$1/cellhd/fSW ${m3pg.loc}/$1/cellhd/fAge ${m3pg.loc}/$1/cellhd/fNutr ${m3pg.loc}/$2/cellhd/LAI ${m3pg.loc}/$1/cellhd/PhysMod
	g.mapset "$1"|| true
	g.region rast=Z@m3pg;
	r.mapcalc 'CanCover=if("StandAge@$2"<${fullCanAge},"StandAge@$2"/${fullCanAge},1)'
	r.mapcalc 'NPP = "xPP@$3" * 1-(exp(-${k}*"LAI@$2")) * CanCover * min("poplar.fVPD@$3",fSW) * fAge * fNutr * "fT@$3" * "fFrost@$3"'
	r.mapcalc 'delLitter = ${gammaFx} * ${gammaF0} / (${gammaF0} + (${gammaFx} - ${gammaF0}) *  exp(-12 * log(1 + ${gammaFx} /${gammaF0}) * "StandAge@$2" / ${tgammaF}))* "WF@$2"'
	r.mapcalc 'delRoots=${Rttover}*"WR@$2"'
	r.mapcalc 'delStemsTmp="StemNo@$2" - 1000*(${wSx1000} * "StemNo@$2"/"WS@$2"/ 1000) ^ (1 / ${thinPower})'

	# End of Month Biomass
	r.mapcalc pR='${pRx} * ${pRn} / (${pRn} + (${pRx} - ${pRn}) * PhysMod * (${m0}+(1-${m0})*${FR}))';

	r.mapcalc avDBH='(("WS@$2"*1000/"StemNo@$2")/${StemConst})^(1/${StemPower})';

	r.mapcalc pS='(1-pR)/(1+((${pfsConst})*avDBH^${pfsPower}))'
	r.mapcalc pF=1-pR-pS;

	r.mapcalc WF='"WF@$2"+NPP*pF-delLitter';
	r.mapcalc WR='"WR@$2"+NPP*pR-delRoots';
	r.mapcalc WS='"WS@$2"+NPP*pS';
	r.mapcalc W='WF+WR+WS';
	r.mapcalc StandAge='"StandAge@$2"+1.0/12';
	r.mapcalc StemNo='"StemNo@$2"-delStemsTmp';

endef

$(eval $(call add_month,2012-04,2012-03,XXXX-04))
$(eval $(call add_month,2012-05,2012-04,XXXX-05))
$(eval $(call add_month,2012-06,2012-05,XXXX-06))
$(eval $(call add_month,2012-07,2012-06,XXXX-07))
$(eval $(call add_month,2012-08,2012-07,XXXX-08))
$(eval $(call add_month,2012-09,2012-08,XXXX-09))
$(eval $(call add_month,2012-10,2012-09,XXXX-10))
$(eval $(call add_month,2012-11,2012-10,XXXX-11))
$(eval $(call add_month,2012-12,2012-11,XXXX-12))

$(eval $(call add_month,2013-01,2012-12,XXXX-01))
$(eval $(call add_month,2013-02,2013-01,XXXX-02))
$(eval $(call add_month,2013-03,2013-02,XXXX-03))
$(eval $(call add_month,2013-04,2013-03,XXXX-04))
$(eval $(call add_month,2013-05,2013-04,XXXX-05))
$(eval $(call add_month,2013-06,2013-05,XXXX-06))
$(eval $(call add_month,2013-07,2013-06,XXXX-07))
$(eval $(call add_month,2013-08,2013-07,XXXX-08))
$(eval $(call add_month,2013-09,2013-08,XXXX-09))
$(eval $(call add_month,2013-10,2013-09,XXXX-10))
$(eval $(call add_month,2013-11,2013-10,XXXX-11))
$(eval $(call add_month,2013-12,2013-11,XXXX-12))

$(eval $(call add_month,2014-01,2013-12,XXXX-01))
$(eval $(call add_month,2014-02,2014-01,XXXX-02))
$(eval $(call add_month,2014-03,2014-02,XXXX-03))
$(eval $(call add_month,2014-04,2014-03,XXXX-04))
$(eval $(call add_month,2014-05,2014-04,XXXX-05))
$(eval $(call add_month,2014-06,2014-05,XXXX-06))
$(eval $(call add_month,2014-07,2014-06,XXXX-07))
$(eval $(call add_month,2014-08,2014-07,XXXX-08))
$(eval $(call add_month,2014-09,2014-08,XXXX-09))
$(eval $(call add_month,2014-10,2014-09,XXXX-10))
$(eval $(call add_month,2014-11,2014-10,XXXX-11))
$(eval $(call add_month,2014-12,2014-11,XXXX-12))

$(eval $(call add_month,2015-01,2014-12,XXXX-01))
$(eval $(call add_month,2015-02,2015-01,XXXX-02))
$(eval $(call add_month,2015-03,2015-02,XXXX-03))
$(eval $(call add_month,2015-04,2015-03,XXXX-04))
$(eval $(call add_month,2015-05,2015-04,XXXX-05))
$(eval $(call add_month,2015-06,2015-05,XXXX-06))
$(eval $(call add_month,2015-07,2015-06,XXXX-07))
$(eval $(call add_month,2015-08,2015-07,XXXX-08))
$(eval $(call add_month,2015-09,2015-08,XXXX-09))
$(eval $(call add_month,2015-10,2015-09,XXXX-10))
$(eval $(call add_month,2015-11,2015-10,XXXX-11))
$(eval $(call add_month,2015-12,2015-11,XXXX-12))

$(eval $(call add_month,2016-01,2015-12,XXXX-01))
$(eval $(call add_month,2016-02,2016-01,XXXX-02))
$(eval $(call add_month,2016-03,2016-02,XXXX-03))
$(eval $(call add_month,2016-04,2016-03,XXXX-04))
$(eval $(call add_month,2016-05,2016-04,XXXX-05))
$(eval $(call add_month,2016-06,2016-05,XXXX-06))
$(eval $(call add_month,2016-07,2016-06,XXXX-07))
$(eval $(call add_month,2016-08,2016-07,XXXX-08))
$(eval $(call add_month,2016-09,2016-08,XXXX-09))
$(eval $(call add_month,2016-10,2016-09,XXXX-10))
$(eval $(call add_month,2016-11,2016-10,XXXX-11))
$(eval $(call add_month,2016-12,2016-11,XXXX-12))


