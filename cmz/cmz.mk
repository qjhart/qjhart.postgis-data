#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

shp2pg:=/usr/lib/postgresql/9.1/bin/shp2pgsql
meta:=cmz.metadata

bndUrl:=ftp://fargo.nserl.purdue.edu/pub/RUSLE2/Crop_Management_Templates/CMZ%20maps/CMZ%20map%20shape%20files/CMZ110104.zip

spt:=`psql -d afri -A -t -F " " -c "select st_xmin(st_extent(st_transform(boundary, 4322))), st_ymin(st_extent(st_transform(boundary, 4322))), st_xmax(st_extent(st_transform(boundary, 4322))), st_ymax(st_extent(st_transform(boundary, 4322)))from afri.pixels_8km"`


.PHONY:db
db:db/cmz

db/cmz:
	${PG} -f cmz.sql
	mkdir db
	touch $@

db/cmz_bounds:db
	curl -o $@.zip -v --stderr $@.log ${bndUrl}
	unzip -d $@ $@.zip
	rm $@.zip
	${PG} -d "drop table if exists cmz.$@_pnw"
	ogr2ogr -spat ${spt} -t_srs "${proj4}" -skipfailures -f "PostgreSQL" PG:"service=afri" $@.shp -nln cmz.cmz_bounds