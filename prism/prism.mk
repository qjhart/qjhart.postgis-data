#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

raster2pgsql:=/usr/lib/postgresql/9.1/bin/raster2pgsql.py
prism.srid:=4322

years:=$(shell seq 1990 2009)
months:=$(shell seq -f %02.0f 1 12)

.PHONY:db
db:db/prism

db/prism:
	${PG} -f prism.sql
	touch $@

#####################################################################
# Download all files:
#####################################################################
define download

.PHONY: download
download::prism.oregonstate.edu/pub/prism/us/grids/$1/$2

prism.oregonstate.edu/pub/prism/us/grids/$1/$2:
	wget -m ftp://prism.oregonstate.edu/pub/prism/us/grids/$1/$2

endef
#$(foreach v,tmin tmax ppt,$(foreach d,1920-1929 1930-1939 1940-1949 1950-1959 1960-1969 1970-1979 1980-1989 1990-1999 2000-2009,$(eval $(call download,$v,$d))))
# Start w/ 20 year average
$(foreach v,tmin tmax ppt,$(foreach d,1990-1999 2000-2009,$(eval $(call download,$v,$d))))

###################################################################
# Prism Elevation matches prism data
###################################################################
dem:=prism.oregonstate.edu/pub/prism/maps/Other/U.S./us_25m.dem.gz

download::${dem}

${dem}:
	wget -m ftp://${dem}

db/prism.static:
	zcat ${dem} > dem
	${raster2pgsql} --filename --raster=dem -d -s 4322 --table=prism.temp | ${PG};
	${PG} -c "delete from prism.static where layer='dem'; insert into prism.static (layer,rast) select 'dem',prism.us_to_template(rast,default_rast(),'NearestNeighbor') from prism.temp";
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@); touch $@
	rm -f dem

#####################################################################
# Monthly Mapset files - US data
# http://prism.oregonstate.edu/docs/meta/ppt_realtime_monthly.htm gives
# info on the projection information, etc.
#####################################################################
.PHONY: prism-us

prism-dir:=prism.oregonstate.edu/pub/prism/us/grids
define prism-dec
$(shell echo $2 | cut -b 1-3)0-$(shell echo $2 | cut -b 1-3)9
endef

define prism-fn
${prism-dir}/$1/$(shell echo $2 | cut -b 1-3)0-$(shell echo $2 | cut -b 1-3)9/us_$1_$2.$3.gz
endef

define prism-us
$(warning prism-us $1.$2)
prism-us::db/prism.us/$1.$2
db/prism.us/$1.$2: $(call prism-fn,tmin,$1,$2) $(call prism-fn,tmax,$1,$2)  $(call prism-fn,ppt,$1,$2) 
	zcat $(call prism-fn,tmin,$1,$2) > us_tmin_$1.$2
	zcat $(call prism-fn,tmax,$1,$2) > us_tmax_$1.$2
	zcat $(call prism-fn,ppt,$1,$2) > us_ppt_$1.$2
	${raster2pgsql} --filename --raster=us_*_$1.$2 -d -s 4322 --table=prism.temp | ${PG};
	${PG} -c "delete from prism.us where year=$1 and month=$2; insert into prism.us (year,month,tmin,tmax,ppt) select $1,$2,tmin.rast,tmax.rast,ppt.rast from prism.temp tmin,prism.temp tmax,prism.temp ppt where tmin.filename='us_tmin_$1.$2' and tmax.filename='us_tmax_$1.$2' and ppt.filename='us_ppt_$1.$2'";
	[[ -d db/prism.us ]] || mkdir -p db/prism.us; touch $$@
	rm -f us_*_$1.$2

endef
#$(foreach y,${years},$(foreach m,${months},$(eval $(call prism-us,$y,$m))))

db/prism.climate:
	${PG} -c "select prism.new_from_template('prism','climate',default_rast())";
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@); touch $@

define prism-climate
$(warning prism-climate $1.$2)
prism.climate::db/prism.climate.$1.$2
db/prism.climate.$1.$2: db/prism.climate $(call prism-fn,tmin,$1,$2) $(call prism-fn,tmax,$1,$2)  $(call prism-fn,ppt,$1,$2) 
	zcat $(call prism-fn,tmin,$1,$2) > us_tmin_$1.$2
	zcat $(call prism-fn,tmax,$1,$2) > us_tmax_$1.$2
	zcat $(call prism-fn,ppt,$1,$2) > us_ppt_$1.$2
	${raster2pgsql} --filename --raster=us_*_$1.$2 -d -s 4322 --table=prism.temp | ${PG};
	${PG} -c "delete from prism.climate where year=$1 and month=$2; insert into prism.climate (year,month,tmin,tmax,ppt) select $1,$2,prism.us_to_template(tmin.rast,default_rast(),'NearestNeighbor'),prism.us_to_template(tmax.rast,default_rast(),'NearestNeighbor'),prism.us_to_template(ppt.rast,default_rast(),'NearestNeighbor') from prism.temp tmin,prism.temp tmax,prism.temp ppt where tmin.filename='us_tmin_$1.$2' and tmax.filename='us_tmax_$1.$2' and ppt.filename='us_ppt_$1.$2'";
	touch $$@
	rm -f us_*_$1.$2

endef

$(foreach y,${years},$(foreach m,${months},$(eval $(call prism-climate,$y,$m))))

# This creates monthly averages on a number of time scales;
prism.avg::db/prism.avg

db/prism.avg:
	${PG} -c "set search_path=prism,public; select * from create_avg();"
	touch $@;