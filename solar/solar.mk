#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

#raster2pgsql:=/usr/lib/postgresql/9.1/bin/raster2pgsql.py
shp2pg:=/usr/lib/postgresql/9.1/bin/shp2pgsql
meta:=solar.metadata
solUrl:=http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/Lower_48_DNI_High_Resolution.zip
spt:=`psql -d afri -A -t -F " " -c "select st_xmin(st_extent(st_transform(boundary, 4322))), st_ymin(st_extent(st_transform(boundary, 4322))), st_xmax(st_extent(st_transform(boundary, 4322))), st_ymax(st_extent(st_transform(boundary, 4322)))from afri.pixels_8km"`

.PHONY:db.solar
db.solar:
	psql ${DB} -f solar.sql 
	touch $@

#####################################################################
# Download all files:
#####################################################################
#NREL solar radiation Direct Normal data http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/metadata/dni_metadata.htm
#http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/Lower_48_DNI_High_Resolution.zip

#
dniHigh:
	curl -o $@.zip -v --stderr $@.log ${solUrl}  
	unzip -d $@ $@.zip 
	rm $@.zip
	${PG} -c "drop table if exists solar.$@_pnw"
#	ogr2ogr -spat ${spt} -t_srs "${proj4}" -skipfailures -f "PostgreSQL" PG:"service=afri" $@/us9805_dni.shp -nln solar.dni
	ogr2ogr -spat ${spt} -t_srs "${proj4}" -f "ESRI Shapefile" $@_pnw.shp $@/us9805_dni.shp  
	${shp2pg} -s ${srid} -I $@_pnw.shp solar.$@_pnw | ${PG} 
	rm $@/*
	mv $@.* $@/
	mv $@_* $@/









