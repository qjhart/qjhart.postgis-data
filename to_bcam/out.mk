#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif


.PHONY:db
db:db/cmz db/cmz_bounds db/managements

db/out_tables: 
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

db/managements:db/cmz db/cmz_bounds
	python mgt_table.py ${dbUrl}
	python managements.py ${dbUrl}
	for d in tmp*/*.gdb; do	\
	  echo -e '.mode insert\nselect * from managements;' | sqlite "$$d" | sed s/table/cmz.managements/ |${PG} ;\
	done
	${PG} -c "set search_path=cmz; alter table managements add column cmz varchar(255);update managements set cmz=substring from (select distinct substring(path,'CMZ...') from managements) foo where substring(path,'CMZ...')=foo.substring;"
	rm -r tmp*
	touch $@


#include foo.mk

#foo.mk:
#	python mgt_table.py ${dbUrl}
#	python managements.py ${dbUrl}
#	echo tfiles:=`ls tmp_*/*.gdb` > $@

#tFiles:=$(shell echo tmp_*/*.gdb)

