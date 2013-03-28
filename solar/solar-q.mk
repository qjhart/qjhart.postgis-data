#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

#raster2pgsql:=/usr/lib/postgresql/9.1/bin/raster2pgsql.py
shp2pgsql:=/home/peterwt/postgis-svn/loader/shp2pgsql

.PHONY:db.solar
db.solar:
	psql ${DB} -f solar.sql 
	touch $@

#####################################################################
# Download all files:
#####################################################################
ghi.zip:=www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/Lower_48_GHI_High_Resolution.zip

dni.zip:=www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/Lower_48_DNI_High_Resolution.zip

${dni.zip}:
	wget --mirror http://${dni.zip}

db/solar.us9805_dni: fn:=us9805_dni
db/solar.us9805_dni: ${dni.zip}
	unzip -o ${dni.zip} ${fn}.*
	${shp2pgsql} -s 4269 -d -S ${fn}.shp $(notdir $@) | ${PG}
	rm ${fn}.*
	touch $@

${ghi.zip}:
	wget --mirror http://${ghi.zip}

db/solar.l48_ghi_10km: fn:=l48_ghi_10km
db/solar.l48_ghi_10km: ${ghi.zip}
	unzip -o ${ghi.zip} ${fn}.*
	${shp2pgsql} -s 4269 -d -S ${fn}.shp $(notdir $@) | ${PG}
	rm ${fn}.*
	touch $@









