#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehenisve makefile.

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
pur.mk:=1

years:=2008 2009
udcs:=$(patsubst %,db/pur.udc%,${years})

INFO::
	@echo This makefile is for creating data products from the PUC database.

.PHONY:db 
db:: db/pur db/pur.pls-data ${udcs}

db/pur:
	[[ -d db ]] || mkdir db
	${PG} -f pur.sql
	touch $@

clean:
	rm -rf down/*

archive:=ftp://pestreg.cdpr.ca.gov/pub/outgoing/pur_archives

${udcs}:db/pur.udc%:db/pur 
	[[ -f ${down}/pur$*.zip ]] || (cd ${down}; wget ${archive}/pur$*.zip;)
	[[ -d ${down}/pur$* ]] || mkdir -p ${down}/pur$*
	[[ -f ${down}/pur$*/county.txt ]] || (cd ${down}/pur$*; unzip ../pur$*.zip) 
	${PG} -c "delete from pur.udc where extract(year from applic_dt)='$*'"
	for i in ${down}/pur$*/udc*.txt; do \
	  echo $$i; \
	  ${PG} -c "\copy pur.udc from $$i CSV HEADER"; \
	done
	touch $@

# These are the GIS data used for the locating the pesticides.
pur.pls.url:=https://projects.atlas.ca.gov/frs/download.php/663/State_pls.ZIP
pur.pls.shp:=plsnet_nad83.shp

db/pur.pls-data:db/%-data:db/pur
	$(call fetch_zip,${$*.url},${$*.shp})
	${shp2pgsql} -D -d -s 3310 -S down/${$*.shp} pur.temp | ${PG} > /dev/null
	${PG} -c 'insert into $* (county_cd,base_ln_mer,township,range,section,boundary) select county_cd,base_ln_me,township,range,section,st_multi(st_union(transform(geom,${srid}))) as boundary from pur.temp group by county_cd,base_ln_me,township,range,section;'
	${PG} -c "drop table pur.temp";
	touch $@






