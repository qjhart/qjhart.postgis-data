#! /usr/bin/make -f

ifndef m3pg.mk
include m3pg.mk
endif

INFO::
	echo ${doys}
	echo ${j.sshas}

# NREL Solar radiation
nrel.loc:=${GISDBASE}/nrel
nrel.mapsets:=$(patsubst %,${nrel.loc}/j%,${doys})

nrel.nrel:=$(patsubst %,%/cellhd/nrel,${nrel.mapsets})
.PHONY: nrel
nrel-us:${nrel.nrel}  ${nrel.loc}/annual/cellhd/nrel

${nrel.loc}/annual/cellhd/nrel:
	g.mapset -c location=$(notdir ${nrel.loc}) mapset=annual; \
	g.region -d; \
	${PG-CSV} -t -c 'select lon,lat,ghiann from solar.l48_ghi_10km;' | \
	r.in.xyz --overwrite fs=',' input=- output=nrel;


${nrel.nrel}:${nrel.loc}/%/cellhd/nrel:
	g.mapset -c location=nrel mapset=$*; \
	g.region -d; \
	${PG-CSV} -t -c 'select lon,lat,ghi${$*.m} from solar.l48_ghi_10km;' | \
	r.in.xyz --overwrite fs=',' input=- output=nrel;


j.sshas:=$(patsubst %,%/cellhd/ssha,${j.mapsets})

.PHONY:ssha
ssha:${j.sshas}

${j.sshas}:${m3pg.loc}/%/cellhd/ssha:${m3pg.loc}/%
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.solpos date=$(shell date --date='2011-12-31 + $(subst j,,$*) days' +%F) ssha=ssha;

j.nrels:=$(patsubst %,%/cellhd/nrel,${j.mapsets})

.PHONY:nrel
nrel:${j.nrels}

${j.nrels}:${m3pg.loc}/%/cellhd/nrel:${nrel.loc}/%/cellhd/nrel
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.proj --overwrite method=cubic location=nrel mapset=$* input=nrel

# FAO Rso Calculations
j.Rsos:=$(patsubst %,%/cellhd/Rso,${j.mapsets})
.PHONY:Rso
Rso:${j.Rsos}

${j.Rsos}:${m3pg.loc}/%/cellhd/Rso:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
        eval `r.solpos -r date=$(shell date --date='2011-12-31 + $(subst j,,$*) days' +%F)`; \
        r.mapcalc "Rso=(0.0036)*(0.75+0.00002*'Z@m3pg')*$$etrn*24/3.14159*\
        ((ssha*3.14159/180)*sin(Z.lat@m3pg)*sin($$declin)\
        +cos(Z.lat@m3pg)*cos($$declin)*sin(ssha))"

# r.sun calculations
j.beams:=$(patsubst %,%/cellhd/beam,${j.mapsets})

.PHONY:beam
beam:${j.beams}

${j.beams}:${m3pg.loc}/%/cellhd/beam:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.sun --overwrite day=$(subst j,,$*) glob_rad=global beam_rad=beam diff_rad=diffuse elevin=Z@m3pg lin=0

j.Ks:=$(patsubst %,%/cellhd/K,${j.mapsets})

.PHONY:K
K:${j.Ks}

${j.Ks}:${m3pg.loc}/%/cellhd/K:${m3pg.loc}/%/cellhd/global ${m3pg.loc}/%/cellhd/nrel ${m3pg.loc}/%/cellhd/Rso
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.mapcalc K=nrel/global; \
	r.mapcalc K.Rso=nrel/Rso;


.PHONY:Z.lat
Z.lat:${rast}/Z.lat

${rast}/Z.lat:
	g.region rast=Z; \
	r.mapcalc one=1; \
	r.out.xyz fs=' ' input=one | proj -I -E -f "%.6f"  `g.proj -j` | tr "\t" ' ' | cut -f 1,2,4 -d' ' | r.in.xyz input=- output=Z.lat fs=' ' z=3
	g.remove one






