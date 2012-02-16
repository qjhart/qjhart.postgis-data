#! /usr/bin/make -f

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
greenbk.mk:=1

down:=www.epa.gov/oaqps001/greenbk/shapefile
shp.ozone:=ozone_8hr_1997std_naa_shapefile
fn.ozone:=Ozone_8hr_1997Std_naa
fn.pm25:=PM25_2006Std_NAA
shp.pm25:=pm25_2006std_naa_shapefile
greenbk.data:=$(patsubst %,db/greenbk.%,ozone pm25)
greenbk.zips:=$(patsubst %,${down}/%.zip,${shp.ozone} ${shp.pm25})

INFO::
	@echo greenbk.mk imports shapefiles for Air Quality.  
	@echo The 8-hr ozone and PM Standard are used for EPA ambient air quality non attainment areas
	@echo zips: ${greenbk.zips}

.PHONY:db mirror
db::db/greenbk ${greenbk.data}

db/greenbk:
	[[ -d db ]] || mkdir db
	${PG} -f greenbk.sql
	touch $@


mirror: ${greenbk.zips}

${greenbk.zips}:
	wget -m $(patsubst %,http://%,${greenbk.zips})

# Simple, keep same schema reproject in tool
db/greenbk.ozone: ${down}/${shp.ozone}.zip
	unzip -o $<
	${shp2pgsql} -I -d -r 4269 -g boundary -s ${srid} ${fn.ozone} greenbk.ozone | sed 's/, ${srid}/::geometry, ${srid}/' | ${PG} > /dev/null
	rm -f ${fn.ozone}.*
	touch $@

# Simple, keep same schema reproject in tool
db/greenbk.pm25: ${down}/${shp.pm25}.zip
	unzip -o $<
	${shp2pgsql} -I -d -r 4269 -s ${srid} -g boundary ${fn.pm25} greenbk.pm25 | sed 's/, ${srid}/::geometry, ${srid}/' | ${PG} > /dev/null
	rm -f ${fn.pm25}.*
	touch $@


