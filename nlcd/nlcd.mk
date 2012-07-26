#! /usr/bin/make -f

# Are we currently Running Grass?
ifndef GISRC
  $(error Must be running in GRASS)
endif

GISDBASE:=$(shell g.gisenv get=GISDBASE)
LOCATION_NAME:=$(shell g.gisenv get=LOCATION_NAME)
MAPSET:=$(shell g.gisenv get=MAPSET)

nlcd.loc:=conterminous_us
nlcd.rast:=${GISDBASE}/${nlcd.loc}/nlcd/cellhd

# Shortcut Directories
loc:=$(GISDBASE)/$(LOCATION_NAME)
rast:=$(loc)/$(MAPSET)/cellhd

mapzone.zip:=http://www.mrlc.gov/mapzone.zip

cover_types:=11 12 21 22 23 24 31 41 42 43 52 71 81 82 90 95
null_cover_type:=0

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

zip:=gisdata.usgs.gov/TDDS/DownloadFile.php?TYPE=nlcd2006&FNAME=NLCD2006_landcover_4-20-11_se5.zip

nlcd:=nlcd2006_landcover_4-20-11_se5.img

${zip}:
wget --mirror 'http://${zip}'

${nlcd}:${zip}
	unzip $<

${nlcd.loc.rast}/nlcd: ${nlcd}
	g.mapset location=${nlcd.loc} mapset=nlcd
	r.in.gdal input=$< output=$(notdir $@)
	g.mapset location=${LOCATION} mapset=nlcd

nlcd: ${nlcd.loc.rast}/ncld
	r.proj location=${nlcd.loc} input=nlcd method=nearest


# This is how you get smaller versions
define r.halve
.PHONY:nlcd_$1_$2 nlcd_??_$2 nlcd_??_??
nlcd_$1_$2 nlcd_??_$2 nlcd_$1_?? nlcd_??_??:${rast}/nlcd_$1_$2

${rast}/nlcd_$1_$2:${rast}/nlcd_$1_${pre_$2}
	g.region res=${res_$2}
	r.resamp.stats -w --overwrite method=sum input=$$(notdir $$<) output=tmphalve
	r.mapcalc $$(notdir $$@)=tmphalve/4.0;
	g.remove tmphalve

endef

.PHONY:nlcd_??_0

define do_area_cover_type
.PHONY:nlcd_$1_0

nlcd_??_0::${rast}/nlcd_$1_0

nlcd_$1_0:${rast}/nlcd_$1_0
${rast}/nlcd_$1_0:$(rast)/nlcd
	g.region rast=$$(notdir $$<)
	r.mapcalc "$$(notdir $$@)=if($$(notdir $$<)==${null_cover_type},null(),if($$(notdir $$<)==$1,1.0,0.0))";

$(foreach i,${exps},$(call r.halve,$1,$i))
endef

.PHONY:nlcd_XX_0
nlcd_??_0::${rast}/nlcd_XX_0
nlcd_XX_0:$(rast)/nlcd_XX_0

${rast}/nlcd_XX_0:$(rast)/nlcd
	r.mapcalc "$(notdir $@)=if($(notdir $<)==${null_cover_type},0.0,1.0)";


$(foreach c,${cover_types},$(eval $(call do_area_cover_type,$c)))
$(foreach i,${exps},$(eval $(call r.halve,XX,$i)))

