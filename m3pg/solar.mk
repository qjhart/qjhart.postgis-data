#! /usr/bin/make -f

ifndef m3pg.mk
include m3pg.mk
endif

INFO::
	echo ${m.mapsets}
	echo ${m.sshas}

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


m.sshas:=$(patsubst %,%/cellhd/ssha,${m.mapsets})

.PHONY:ssha
ssha:${m.sshas}

${m.sshas}:${m3pg.loc}/%/cellhd/ssha:${m3pg.loc}/%
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.solpos date=$(shell date --date='2011-12-31 + $(subst j,,$*) days' +%F) ssha=ssha;

m.nrels:=$(patsubst %,%/cellhd/nrel,${m.mapsets})

.PHONY:nrel
nrel:${m.nrels}

define from_nrel
${m3pg.loc}/$1/cellhd/nrel:${nrel.loc}/$2/cellhd/nrel
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$1; \
	g.region rast=Z@m3pg; \
	r.proj --overwrite method=cubic location=nrel mapset=$2 input=nrel

endef

$(foreach m,${months},$(eval $(call from_nrel,$m,j${m.${m}.j})))

# FAO Rso Calculations
m.Rsos:=$(patsubst %,%/cellhd/Rso,${m.mapsets})
.PHONY:Rso
Rso:${m.Rsos}

${m.Rsos}:${m3pg.loc}/%/cellhd/Rso:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
        eval `r.solpos -r date=$(shell date --date='2011-12-31 + $(subst j,,$*) days' +%F)`; \
        r.mapcalc "Rso=(0.0036)*(0.75+0.00002*'Z@m3pg')*$$etrn*24/3.14159*\
        ((ssha*3.14159/180)*sin(Z.lat@m3pg)*sin($$declin)\
        +cos(Z.lat@m3pg)*cos($$declin)*sin(ssha))"

# r.sun calculations
m.beams:=$(patsubst %,%/cellhd/beam,${m.mapsets})

.PHONY:beam
beam:${m.beams}

${m.beams}:${m3pg.loc}/%/cellhd/beam:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.sun --overwrite day=$(subst j,,$*) glob_rad=global beam_rad=beam diff_rad=diffuse elevin=Z@m3pg lin=0

m.Ks:=$(patsubst %,%/cellhd/K,${m.mapsets})

.PHONY:K
K:${m.Ks}

${m.Ks}:${m3pg.loc}/%/cellhd/K:${m3pg.loc}/%/cellhd/global ${m3pg.loc}/%/cellhd/nrel ${m3pg.loc}/%/cellhd/Rso
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.mapcalc K=nrel/global; \
	r.mapcalc K.Rso=nrel/Rso;

#  Assimiliation use Efficiency
y:= 0.47
#'conversion of mol to gDM
gDM_mol := 24
#'conversion of MJ to PAR mols
molPAR_MJ := 2.3

m.xPPs:=$(patsubst %,%/cellhd/xPP,${m.mapsets})

.PHONY:xPP
xPP:${m.xPPs}

${m.xPPs}:${m3pg.loc}/%/cellhd/xPP:${m3pg.loc}/%/cellhd/nrel
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$*; \
	g.region rast=Z@m3pg; \
	r.mapcalc PAR=nrel*0.0036*30.4*${molPAR_MJ}
	r.support map=PAR units=mols title='Monthly PAR in mols / m^2 month' 
	r.mapcalc xPP=${y}*PAR*${gDM_mol}/100; # 10000/10^6 [ha/m2][tDm/gDM] 
	r.support map=xPP units='metric tons Dry Matter/ha' title='maximum potential Primary Production [tDM / ha month]' 

.PHONY:Z.lat
Z.lat:${rast}/Z.lat

${rast}/Z.lat:
	g.region rast=Z; \
	r.mapcalc one=1; \
	r.out.xyz fs=' ' input=one | proj -I -E -f "%.6f"  `g.proj -j` | tr "\t" ' ' | cut -f 1,2,4 -d' ' | r.in.xyz input=- output=Z.lat fs=' ' z=3
	g.remove one






