#! /usr/bin/make -f

# Avoid multiple inserts
ifndef configure.mk
include ../configure.mk
endif

national_atlas.mk:=1

dir:=edcftp.cr.usgs.gov/pub/data/nationalatlas

INFO::
	@echo National Atlas Makefile.

db::db/national_atlas.county db/national_atlas.state db/national_atlas.city

db/national_atlas:
	[[ -d db ]] || mkdir db;
	${PG} -f national_atlas.sql
	touch $@


national_atlas.city.tar:=citiesx020.tar.gz
national_atlas.city.shp:=citiesx020.shp

national_atlas.statesp020.tar:=statesp020.tar.gz
national_atlas.statesp020.shp:=statesp020.shp

national_atlas.countyp020.tar:=countyp020.tar.gz
national_atlas.countyp020.shp:=countyp020.shp

db/national_atlas.countyp020 db/national_atlas.statesp020 db/national_atlas.city:db/%:
	[[ -f ${dir}/${$*.tar} ]] || wget --mirror http://${dir}/${$*.tar}; 
	tar -xzf ${dir}/${$*.tar}
	${shp2pgsql} -d -r 4269 -s ${srid} -g boundary -S ${$*.shp} $* | sed -e 's/, ${srid}));$$/::geometry, ${srid}));/' | ${PG} > /dev/null
# Maybe switch to GNIS for ids :)
#	${PG} -c "alter table $* add column qid char(8); update $* set qid='D'||state_fips||fips55;"
	rm $(basename ${$*.shp}).???
	touch $@

# Make some mods to the default versions.
db/national_atlas.county db/national_atlas.state:db/national_atlas.statesp020 db/national_atlas.countyp020
	${PG} -f county_and_state.sql
	touch db/national_atlas.county db/national_atlas.state

#Get hydrography data. this is used to restrict the route of new rail spurs to connect facilities 

db/1Mhydro:
	curl -O http://dds.cr.usgs.gov/pub/data/nationalatlas/hydrogm020_nt00015.tar.gz
	tar -xzf hydrogm020_nt00015.tar.gz
	${shp2pgsql} -S -s 4326 hydrogl020.shp national_atlas.hydrogl020| ${PG}
	${PG} -c "create index idx_hydrogl020 on national_atlas.hydrogl020 using gist(the_geom); select addgeometrycolumn('national_atlas', 'hydrogl020', 'geom',97260,'LINESTRING',2); update national_atlas.hydrogl020 set geom = st_transform(the_geom,97260); alter table national_atlas.hydrogl020 drop column the_geom;"
	rm -r hydro*
	touch $@

