#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehenisve makefile.

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
zipcode.mk:=1

# Only 2000 and 2010 exist
year:=2010
states:=06

zipcode.data:=$(patsubst %,db/zipcode.zip5.%,${states})

down:=ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/${year}

INFO::
	@echo This makefile recreates zipcodes from CENSUS
	@echo years: ${years}
	@echo db: ${zipcode.data}

.PHONY:db 
db:: db/zipcode ${zipcode.data}

db/zipcode:
	[[ -d db ]] || mkdir db
	${PG} -f zipcode.sql
	touch $@

clean:
	rm -rf ${down}

mirror:ftp:=ftp://${down}
mirror:
	wget -m $(patsubst %,${ftp}/tl_${year}_%_zcta510.zip,${states})

${zipcode.data}:db/zipcode.zip5.%:db/zipcode 
	${PG} -c 'truncate zipcode.zip5;';
	for f in $(patsubst %,${down}/tl_${year}_%_zcta510.zip,${states}); do \
	  b=`basename $$f .zip`; \
	  unzip $$f; \
	  ${shp2pgsql} -D -d -s 4269 $$b.shp zipcode.temp | ${PG} > /dev/null; \
	  ${PG} -c 'insert into zipcode.zip5 (zipcode,geoid,boundary) select zcta5ce10,geoid10,transform(geom,${srid}) as boundary from zipcode.temp'; \
	  ${PG} -c "drop table zipcode.temp"; \
	  rm $$b.*; \
	done
	touch $@











