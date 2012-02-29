#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehensive makefile.

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
zipcode.mk:=1

# Only 2000 and 2010 exist
yr:=00 10
states:=06

down:=ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5
zipcode.data:=$(foreach y,${yr},$(patsubst %,db/zipcode.zip5.$y.%,${states}))

zipcode.zips:=$(foreach y,${yr},$(patsubst %,${down}/20$y/tl_2010_%_zcta5$y.zip,${states}))

INFO::
	@echo This makefile recreates zipcodes from CENSUS.
	@echo db: ${zipcode.data}
	@echo zipfiles: ${zipcode.zips}
	@echo run with make db

.PHONY:db 
db:: db/zipcode ${zipcode.data}

db/zipcode:
	[[ -d db ]] || mkdir db
	${PG} -f zipcode.sql
	touch $@

clean:
	rm -rf ${down}

mirror:
	wget -m $(patsubst %,ftp://%,${zipcode.zips})

${zipcode.data}:db/zipcode.zip5.%:db/zipcode 
	${PG} -c 'truncate zipcode.zip5;';
	for f in ${zipcode.zips}; do \
	  b=`basename $$f .zip`; \
	  yr=$${b#*zcta5}; \
	  unzip $$f; \
	  ${shp2pgsql} -D -d -s 4269 $$b.shp zipcode.temp | ${PG} > /dev/null; \
	  ${PG} -c "insert into zipcode.zip5 (year,zipcode,geoid,boundary) select 2000+$${yr},zcta5ce$${yr},geoid$${yr},transform(the_geom,${srid}) as boundary from zipcode.temp"; \
#	  ${PG} -c "drop table zipcode.temp"; \
	  rm $$b.*; \
	done
	touch $@











