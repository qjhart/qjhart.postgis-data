#! /usr/bin/make -f

ifndef configure.mk
include ../configure.mk
endif

# Are we currently Running Grass?
ifndef GISRC
  $(error Must be running in GRASS)
endif

GISDBASE:=$(shell g.gisenv get=GISDBASE)
LOCATION_NAME:=$(shell g.gisenv get=LOCATION_NAME)
MAPSET:=$(shell g.gisenv get=MAPSET)

cdl.loc:=conterminous_us
cdl.loc.rast:=${GISDBASE}/${cdl.loc}/cdl/cellhd

# Shortcut Directories
loc:=$(GISDBASE)/$(LOCATION_NAME)
rast:=$(loc)/$(MAPSET)/cellhd

cdl.years:=2011
cdl.zips:=$(patsubst %,www.nass.usda.gov/research/Cropland/Release/%_30m_cdls.zip,${cdl.years})

cdl.loc.rasters:=$(patsubst %,${cdl.loc.rast}/%_30m_cdls,${cdl.years})
cdl.rasters:=$(patsubst %,${cdl.rast}/%_30m_cdls,${cdl.years})

INFO::
	@echo NASS Cropland Data Layer


db/cdl:
	[[ -d db ]] || mkdir db
	${PG} -f cdl.sql
	touch $@


.PHONY: zips
zips: ${cdl.zips}

${cdl.zips}:
	wget --mirror $@

.PHONY: cdl.loc.rasters

cdl.loc.rasters:${cdl.loc.rasters}

${cdl.loc.rasters}:${cdl.loc.rast}/%: %.img
	[[ `g.gisenv MAPSET` == 'cdl' ]] || g.mapset location=${cdl.loc} mapset=cdl
	r.in.gdal input=$< output=$(notdir $@)

.PHONY:cdl.rasters
cdl.rasters:${cdl.rasters}

${cdl.rasters}:${cdl.rast}/%:${cdl.loc.rast}/%
	g.mapset location=${LOCATION_NAME} mapset=cdl || true
	g.region -d
	r.proj location=${cdl.loc} input=$* method=nearest

cover_types:=1 2 3 4 5 6 10 12 13 14 21 22 23 24 27 28 29 30 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 49 50 52 53 54 55 56 57 58 59 60 61 62 66 67 68 69 70 71 72 74 75 76 77 92 111 112 121 122 123 124 131 141 142 143 152 171 181 190 195 204 205 206 207 208 209 210 211 212 213 214 216 217 218 219 220 221 222 223 224 225 226 227 229 236 242 243 244 246 247 249 250

#null_cover_type:=0

exps:=1 2 3 4 5 6 7 8

pre_1:=0
pre_2:=1
pre_3:=2
pre_4:=3
pre_5:=4
pre_6:=5
pre_7:=6
pre_8:=7

res_0:=32
res_1:=64
res_2:=128
res_3:=256
res_4:=512
res_5:=1024
res_6:=2048
res_7:=4096
res_8:=8192


# This is how you get smaller versions
define r.halve
.PHONY:cdl_$1_$2 cdl_??_$2 cdl_??_??
cdl_$1_$2 cdl_??_$2 cdl_$1_?? cdl_??_??:${rast}/cdl_$1_$2

${rast}/cdl_$1_$2:${rast}/cdl_$1_${pre_$2}
	g.region -d res=${res_$2}
	r.resamp.stats -w --overwrite method=sum input=$$(notdir $$<) output=tmphalve
	r.mapcalc $$(notdir $$@)=tmphalve/4.0;
	g.remove tmphalve

endef

.PHONY:cdl_??_0

define do_area_cover_type
.PHONY:cdl_$1_0

cdl_??_0::${rast}/cdl_$1_0

${rast}/cdl_$1_0:${rast}/2011_30m_cdls
	g.region rast=$$(notdir $$<)
	r.mapcalc "$$(notdir $$@)=if($$(notdir $$<)==$1,1.0,0.0)";

$(foreach i,${exps},$(call r.halve,$1,$i))
endef

cdl_??_0::${rast}/cdl_XX_0

${rast}/cdl_XX_0:${rast}/2011_30m_cdls
	g.region rast=$$(notdir $$<)
	r.mapcalc "$(notdir $@)=if(isnull($(notdir $<)),0.0,1.0)";


$(foreach c,${cover_types},$(eval $(call do_area_cover_type,$c)))
$(foreach i,${exps},$(eval $(call r.halve,XX,$i)))

# sum of CDL over pid match
#	 r.stats -n -g -1 fs=',' input=cdl_XX_8 | grep -v ',0$$' |\
#	 ${PG} -c 'copy cdl.cdl(east,north,amt) from STDIN CSV;';
db/cdl.cdl: cdl_??_8
	${PG} -c 'truncate cdl.cdl'
	for c in `g.mlist type=rast pattern=cdl_[0-9]*_8`; do \
	 echo $$c; n=`echo $$c | sed -e 's/cdl_//; s/_8$$//'`; \
	 r.stats -n -g -1 fs=',' input=$$c | grep -v ',0$$' |\
	 sed -e "s/\$$/,$$n/" | \
	 ${PG} -c 'copy cdl.cdl(east,north,amt,cat_id) from STDIN CSV;'; \
	done
	${PG} -c 'create temp table pixel_centers as select pid,st_x(st_centroid(boundary)) as east,st_y(st_centroid(boundary)) as north from afri.pixels where size=8192; update cdl.cdl c set pid=p.pid from pixel_centers p where c.east=p.east and c.north=p.north'
	touch $@

cmz_total_hectares.csv:
	${PG} -c '\COPY cdl.cmz_total_hectares to $@ CSV HEADER'

cdl_crop_hectares.csv:
	${PG} -c '\COPY cdl.cdl_crop_hectares to $@ CSV HEADER'

