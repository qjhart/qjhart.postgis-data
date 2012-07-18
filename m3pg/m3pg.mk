#! /usr/bin/make -n
#http://www.fsl.orst.edu/~waring/3-PG_Workshops/WorkshopContents.htm
#http://www.fsl.orst.edu/~waring/3-PG_Workshops/3PGpjs(RHW)2004CLASS.xls

ifndef configure.mk
include ../configure.mk
endif

m3pg.mk:=1

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
dates:=2012-01-17 2012-02-14 2012-03-15 2012-04-15 \
       2012-05-15 2012-06-10 2012-07-18 2012-08-18 \
       2012-09-18 2012-10-19 2012-11-18 2012-12-13
doys:=$(foreach d,${dates},$(shell date --date=$d +%j))

# Assoicated months
j017.m:=01
j045.m:=02
j075.m:=03
j106.m:=04
j136.m:=05
j162.m:=06
j200.m:=07
j231.m:=08
j262.m:=09
j293.m:=10
j323.m:=11
j348.m:=12

j.mapsets:=$(patsubst %,${m3pg.loc}/j%,${doys})


# Poplar Specific parameters for 3PG
poplar.kD:=0.05 # id'd as 1.9 or 2.5 in original paper.


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

fractions:=poplar.fD fAGE fT fSMR
$(foreach f,${fractions},$(eval j.$f:=$(patsubst %,%/cellhd/$f,${j.mapsets})))
$(warning ${j.fT})

.PHONY:poplar.fD
poplar.fD:${j.poplar.fD}

#        r.mapcalc 'es=(0.6108/2*(exp(tmin*17.27/(tmin + 237.3))+ exp(tmax*17.27/(tmax+237.3)))'; \
#	r.support map=es units=kPa source1='Derived from PRISM' \
#	  description='Mean saturation vapor pressure from PRISM data';\
#        r.mapcalc 'ea=0.6108*exp(tdmean)*17.27/((tdmean+237.3)))';
#	r.support map=ea units=kPa source1='Derived from PRISM' \
#	  description='Actual vapor pressure from PRISM data';\
#	r.mapcalc 'D=es-ea'; \

${j.poplar.fDs}:${m3pg.loc}/%/cellhd/poplar.fD:${m3pg.loc}/%/cellhd/tmin ${m3pg.loc}/%/cellhd/tmax ${m3pg.loc}/%/cellhd/tdmean
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
        r.mapcalc 'D=(0.6108/2*(exp(tmin*17.27/(tmin + 237.3))+ exp(tmax*17.27/(tmax+237.3))))-(0.6108*exp(tdmean)*17.27/((tdmean+237.3)))'; \
	r.support map=D units=kPa source1='Derived from PRISM' \
	  description='Mean vapor pressure deficit';\
	r.mapcalc 'poplar.fD=exp(${poplar.kG}*D)'; \
	r.support map=poplar.fD units=unitless source1='3PG Model' \
	  description='Vapor Pressure Deficit Modifier (Poplar)';\

fT:${j.fT}
${j.fT}:${m3pg.loc}/%/cellhd/fT:${m3pg.loc}/%/cellhd/tmin
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.mapcalc 'fT=0.5*(1.0+if(tmin>=0,1.0,-1.0)*sqrt(1-exp(-1*(0.17*tmin)^2*(4/3.14159+.14*(0.17*tmin)^2)/(1+0.14*(0.17*tmin)^2))))'
	r.support map=fT units=unitless source1='3PG Model' \
	  source2='Estimated from tmin' \
	  description='Number of Freeze Days Modifier';



