#! /usr/bin/make -f

ifndef m3pg.mk
include m3pg.mk
endif

#
# Prism Data Sets
# 

# Moving from postgis to Grass is still pretty painful
.PHONY: prism
define prism-v
prism::$(patsubst %,${m3pg.loc}/j%/cellhd/$1,${doys})
$(patsubst %,${m3pg.loc}/j%/cellhd/$1,${doys}):${m3pg.loc}/%/cellhd/$1:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=$$*; \
	${PG} -c "\COPY (SELECT '$1_$$*',encode(ST_astiff($1),'hex') As tif from  prism.avg WHERE startyr=1994 and stopyr=2009 and month=$${$$*.m}) to STDOUT" | ./parse_raster.py;\
	r.in.gdal -o --overwrite input=$1_$$*.tif output=$1;\
	g.region rast=$1; \
	r.mapcalc $1=$1/100.0;\
	r.support map=$1 units=$2 source1=PRISM source2=$1 \
	  history='Imported from AHB-PWN postgis database' description='$3';\
	rm $1_$$*.tif;\

endef
$(eval $(call prism-v,tmin,C,1994-2009 Avg Minimum Temperature))
$(eval $(call prism-v,tmax,C,1994-2009 Avg Maximum Temperature))
$(eval $(call prism-v,tdmean,C,1994-2009 Avg Mean Dew Point))
$(eval $(call prism-v,ppt,mm,1994-2009 Total Monthly Rainfall))

