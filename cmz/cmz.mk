#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

pyDir:=../ahb_python/
shp2pg:=/usr/lib/postgresql/9.1/bin/shp2pgsql
meta:=cmz.metadata

bndUrl:=ftp://fargo.nserl.purdue.edu/pub/RUSLE2/Crop_Management_Templates/CMZ%20maps/CMZ%20map%20shape%20files/CMZ110104.zip

#srcPrj4:=`python -c "import sys; sys.path.append('../ahb_python'); import gdal_utilities as gd; print gd.getSR('down/*.shp')['proj4']"`

spt:=`psql -d afri -A -t -F " " -c "select st_xmin(st_extent(boundary)), st_ymin(st_extent(boundary)), st_xmax(st_extent(boundary)), st_ymax(st_extent(boundary))from afri.pixels_8km"`


.PHONY:db
db:db/cmz

db/cmz:
	${PG} -f cmz.sql
	mkdir db
	touch $@


db/cmz_bounds:db/cmz
	curl -o down.zip -v --stderr $@.log ${bndUrl}
	unzip -d down down.zip
	rm down.zip
	${PG} -c "drop table if exists cmz.cmz_pnw"
	ogr2ogr -t_srs "${proj4}" -f "ESRI Shapefile"  down/reproj.shp down/cmz110104.shp
	ogr2ogr -spat ${spt} -f "ESRI Shapefile" down/clp_reproj.shp down/reproj.shp
	${shp2pg} -s ${srid} -I down/clp_reproj.shp cmz.cmz_pnw | psql service=afri 
	rm -r down/
	touch $@