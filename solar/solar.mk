#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

#raster2pgsql:=/usr/lib/postgresql/9.1/bin/raster2pgsql.py
shp2pg:=/usr/lib/postgresql/9.1/bin/shp2pgsql
meta:=solar.metadata
solUrl:=http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/Lower_48_GHI_High_Resolution.zip
spt:=`psql -d afri -A -t -F " " -c "select st_xmin(st_extent(st_transform(boundary, 4322))), st_ymin(st_extent(st_transform(boundary, 4322))), st_xmax(st_extent(st_transform(boundary, 4322))), st_ymax(st_extent(st_transform(boundary, 4322)))from afri.pixels_8km"`

.PHONY:db.solar
db/solar:
	mkdir db
	${PG}  -f solar.sql 
	touch $@

#####################################################################
# Download all files:
#####################################################################
#NREL solar radiation Global Horizontal data http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/metadata/ghi_metadata.htm
# Wh/m2/day
#http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/Lower_48_GHI_High_Resolution.zip

#
db/ghiHigh: db/solar
	mkdir $@
	mkdir $@/shps
	curl -o $@.zip -v --stderr db/ghi.log ${solUrl}  
	unzip -d $@/shps $@.zip 
	rm $@.zip
	${PG} -c "drop table if exists solar.ghi_1deg_pnw"
#	ogr2ogr -spat ${spt} -t_srs "${proj4}" -skipfailures -f "PostgreSQL" PG:"service=afri" $@/us9805_ghi.shp -nln solar.ghi
	ogr2ogr -spat ${spt} -t_srs "${proj4}" -f "ESRI Shapefile" $@/shps/ghi_pnw.shp $@/shps/*.shp  
	${shp2pg} -s ${srid} -I $@/shps/ghi_pnw.shp solar.ghi_1deg_pnw | psql service=afri 
	rm -r $@
	python solar.py pnw_solar
	touch $@







