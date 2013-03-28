#! /usr/bin/make -f

ifndef m3pg.mk
include m3pg.mk
endif

INFO::
	echo 'Soil parameters'

# statsgo soil parameters
statsgo.rast:=${m3pg.loc}/statsgo/cellhd


.PHONY:maxAWS swpower swconst soils

soils:maxAWS swpower swconst

maxAWS:${statsgo.rast}/maxAWS

${statsgo.rast}/maxAWS:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=statsgo; \
	g.region rast=Z@m3pg; \
	${PG} -c "copy (select st_x(st_centroid(boundary)),st_y(st_centroid(boundary)),maxAWS from afri.pixels join m3pg.pixel_maxAWS using (pid)) to stdout delimiter '|'" | r.in.xyz input=- output=$(notdir $@) method=mean
	r.support map=$(notdir $@) units=cm \
	 source1='Derived from statsgo.muaggatt.aws0100wta' \
	 title='Maximum Available Water Capacity 1m depth [cm]' \
	 description='Maximum Available Water Capacity 1m depth [cm]';

swpower:${statsgo.rast}/swpower
swconst:${statsgo.rast}/swconst

${statsgo.rast}/swpower ${statsgo.rast}/swconst: ${statsgo.rast}/%:
	g.mapset -c location=$(notdir ${m3pg.loc}) mapset=statsgo; \
	g.region rast=Z@m3pg; \
	${PG} -c "copy (select st_x(st_centroid(boundary)),st_y(st_centroid(boundary)),$* from afri.pixels join m3pg.pixel_sw using (pid)) to stdout delimiter '|'" | r.in.xyz input=- output=$(notdir $@) method=mean
	r.support map=$(notdir $@) units=cm \
	 source1='Derived from statsgo soil class by torture' \
	 title='$*' \
	 description='SWconst and SWpower soil capacity parameters';


