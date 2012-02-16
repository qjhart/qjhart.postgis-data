#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehenisve makefile.
ifndef db
include configure.mk
endif

forest.mk:=1

INFO::
	@echo Make Forest and pulpmills

db:: ${db}/forest.feedstock

${db}/forest:
	${PG} -f forest/schema.sql
	touch ${db}/forest ${db}/forest.feedstock

 ${db}/forest.feedstock: ${down}/forest.all.csv ${down}/forest.non-fed.csv ${down}/forest.pulpwood.csv ${db}/forest 
	cat forest/add_forest.sql | sed -e "s|forest.csv|`pwd`/${down}/forest.all.csv|" -e 's|unknown_scenario|all forest|' | ${PG} -f -
	cat forest/add_forest.sql | sed -e "s|forest.csv|`pwd`/${down}/forest.non-fed.csv|" -e 's|unknown_scenario|non-fed forest|' | ${PG} -f -
	cat forest/pulpwood.sql | sed -e "s|forest.pulpwood.csv|`pwd`/${down}/forest.pulpwood.csv|" | ${PG} -f -
	touch $@

${db}/forest.urban: ${down}/forest.urban.csv ${db}/forest
	cat forest/urban.sql | sed -e "s|forest.urban.csv|`pwd`/${down}/forest.urban.csv|" | ${PG} -f -
	touch $@


# Pulpmills from FS.USDA

#Fs:=mill2005s.zip Ft:=mill2005t.zip Fw:=mill2005w.zip Fnc:=mills_nc.zip Fne:=mills_ne.zip
# Only using continental US
pm:=mill2005p

db::${db}/forest.pulpmills
pulpmills:${db}/forest.pulpmills

${db}/forest.pulpmills:${down}/${pm}.shp
	${shp2pgsql} -d -S -s 4269 $< forest.pulpmills | ${PG} > /dev/null
	${PG} -f forest/pulpmills.sql
	touch $@

${down}/${pm}.shp:ftp:=http://www.srs.fs.usda.gov/econ/data/mills
${down}/${pm}.shp:${down}/%.shp:
	[[ -f ${down}/$*.zip ]] || wget -O ${down}/$*.zip ${ftp}/$*.zip
	cd $(dir $@); \
	unzip $*.zip
