#! /usr/bin/make -f

ifndef configure.mk
include ../configure.mk
endif

forest.mk:=1

INFO::
	@echo Make Forest and pulpmills

db:: db/forest.feedstock

db/forest:
	${PG} -f forest.sql
	touch db/forest db/forest.feedstock

 db/forest.feedstock: ${down}/forest.all.csv ${down}/forest.non-fed.csv ${down}/forest.pulpwood.csv db/forest 
	cat forest/add_forest.sql | sed -e "s|forest.csv|`pwd`/${down}/forest.all.csv|" -e 's|unknown_scenario|all forest|' | ${PG} -f -
	cat forest/add_forest.sql | sed -e "s|forest.csv|`pwd`/${down}/forest.non-fed.csv|" -e 's|unknown_scenario|non-fed forest|' | ${PG} -f -
	cat forest/pulpwood.sql | sed -e "s|forest.pulpwood.csv|`pwd`/${down}/forest.pulpwood.csv|" | ${PG} -f -
	touch $@

db/forest.urban: ${down}/forest.urban.csv db/forest
	cat forest/urban.sql | sed -e "s|forest.urban.csv|`pwd`/${down}/forest.urban.csv|" | ${PG} -f -
	touch $@


# Pulpmills from FS.USDA
# Only using continental US

db::db/forest.pulpmills

db/forest.pulpmills:pm:=mill2005p
db/forest.pulpmills:loc:=www.srs.fs.usda.gov/econ/data/mills
db/forest.pulpmills:db/%:db/forest
	wget -m http://${loc}/${pm}.zip
	unzip -o ${loc}/${pm}.zip
	${shp2pgsql} -d -r 4326 -s ${srid} -S -g centroid -S -I ${pm}.shp $* | sed 's/, ${srid}/::geometry, ${srid}/' | ${PG} > /dev/null;
	${PG} -c 'update $* set centroid=st_snapToGrid(centroid,${snap})'
	${PG} -c "select * from bts.add_and_find_qid('$*','state','town')";
	${PG} -c "delete from $* where state not in ($(subst ${space},${comma},$(patsubst %,'%',${states})))"
	${PG} -c "alter table $* drop column area; alter table $* drop column perimeter;";
	rm -rf ${pm}.*
	touch $@

# Only the western US is retrieved here. For a comprehenive set, you'd need to download multiple files.
db::db/forest.mills

db/forest.mills:m:=mill2005w
db/forest.mills:loc:=www.srs.fs.usda.gov/econ/data/mills
db/forest.mills:db/%:db/forest
	wget -m http://${loc}/${m}.zip
	unzip -o ${loc}/${m}.zip
	${shp2pgsql} -d -r 4326 -s ${srid} -S -g centroid -S -I ${m}.shp $* | sed 's/, ${srid}/::geometry, ${srid}/' | ${PG} > /dev/null;
	${PG} -c 'update $* set centroid=st_snapToGrid(centroid,${snap})'
	${PG} -c "select * from bts.add_and_find_qid('$*','state','town')";
	${PG} -c "delete from $* where state not in ($(subst ${space},${comma},$(patsubst %,'%',${states})))"
	${PG} -c "alter table $* drop column area; alter table $* drop column perimeter;";
	rm -rf ${m}.*
	touch $@

