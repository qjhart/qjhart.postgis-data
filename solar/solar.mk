#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

#raster2pgsql:=/usr/lib/postgresql/9.1/bin/raster2pgsql.py
shp2pg:=/usr/lib/postgresql/9.1/bin/shp2pgsql
nrel.srid:=4322
afri.srid:=97260
down:=.


.PHONY:db
db:db/prism
	${PG} -f solar.sql
	touch $@

#####################################################################
# Download all files:
#####################################################################
#NREL solar radiation Direct Normal data http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/metadata/dni_metadata.htm
#http://www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/Lower_48_DNI_High_Resolution.zip

solUrl:=/www.nrel.gov/gis/cfm/data/GIS_Data_Technology_Specific/United_States/Solar/High_Resolution/
zName:=Lower_48_DNI_High_Resolution.zip

$dniHigh::
	cd ${down}
	wget -o $@.log -O $@.zip ${solUrl}/${zName}
	unzip $@.zip $@
	rm $@.zip

# ${down}${solUrl}us_25m.dem:
# 	cd ${down};\
# 	wget -m http:/$*.zip
# 	unzip $*.zip $@
# 	rm $<


