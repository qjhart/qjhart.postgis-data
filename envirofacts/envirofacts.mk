#! /usr/bin/make -f 

ifndef configure.mk
include ../configure.mk
endif

#URL for national FRS shapefile which does not contain NAICS/SIC codes
nationalShp:=http://www.epa.gov/enviro/html/frs_demo/geospatial_data/EPAShapefileDownload.zip

# EPA url for state "Combined" files which have a SIC, NAICS and 
stCbUrl:=http://www.epa.gov/enviro/html/frs_demo/geospatial_data/state_files/state_combined_

# If included somewhere else
envirofacts.mk:=1

states:=CA WA OR ID MT
sp:=
sp+=
stq:= $(patsubst %,'%',${states})
stQ:=$(subst ${sp},${comma},${stq})



# For SIC codes, see http://www.osha.gov/pls/imis/sicsearch.html
sic_codes:=2011 2015 2041 2046 2062 2063 2074 2075 2076 2077 2079 2421 2429 2431 2611 2631 2911 4221 5171 5159 8731
sicC:=$(subst ${sp},${comma},${sic_codes})

install: db/sic_naics db/frs_naics getData db/epaSites

db/sic_naics:db/frs_naics
	curl -o xwalk.zip http://www.census.gov/epcd/ec97brdg/E97B_DBF.zip
	unzip xwalk.zip -x E97B1.DBF
	psql service=afri -c "drop table if exists envirofacts.ic_xwalk" 
	shp2pgsql -n E97B2.DBF envirofacts.ic_xwalk | psql service=afri
	psql service=afri -c "comment on table envirofacts.ic_xwalk is 'crosswalk table from us census bureau for determining NAICS 2007 code from 1997 SIC. There is a current (2012) NAICS which hopefully doesnt diverge significantly from 2007 codes'"
	psql service=afri -c "alter table envirofacts.ic_xwalk add column sic_code int; update envirofacts.ic_xwalk set sic_code=btrim(sic::text,foo::text)::int from (select string_agg(distinct(substring(sic,1,1)),'') from envirofacts.ic_xwalk) foo where btrim(sic::text,foo::text)<>''"
	rm *.DBF
	rm xwalk.zip
	touch $@

#create the table for NAICS codes by reg_id
db/frs_naics:
	psql service=afri -f envirofacts.sql
	touch $@


#Get frs spatial data
db/epaSites: db/frs_naics
	mkdir $@
	curl -o  $@/sites.zip ${nationalShp}
	unzip $@/sites.zip -d $@
	shp2pgsql -W LATIN1 -s '4269:97260' $@/*.shp envirofacts.us_frs |\
	psql service=afri
	psql service=afri -c "set search_path=envirofacts, public; delete from us_frs where loc_state not in (${stQ});create index us_frs_gist on envirofacts.us_frs using GIST(the_geom); comment on table us_frs is 'this table contains spatial data from all the EPA FRS locations in ${states}'";
	rm -r $@
	touch $@


define naics_frs
getData::db/frs.$1
db/frs.$1: db/frs_naics db/epaSites
	psql service=afri -c "set search_path=public, envirofacts; delete from epa_naics using us_frs where epa_naics.reg_id=us_frs.reg_id and us_frs.loc_state='$1' " 
	mkdir frs_$1
	curl -o frs_$1/$1.zip ${stCbUrl}$(shell echo $1 | tr A-Z a-z).zip
	unzip -p  frs_$1/$1.zip $1_NAICS_FILE.CSV |\
	psql -c "copy envirofacts.epa_naics from stdin with csv header" service=afri 
	touch $$@
	rm -r frs_$1
endef

$(foreach s,${states},$(eval $(call naics_frs,$s))) 

db/views:db/frs_naics  db/sic_naics db/epaSites getData
	psql service=afri -v codes=${sicC} -f env_views.sql

target_codes.tex: db/sic_naics  db/frs_naics  db/sic_naics db/epaSites getData
	psql -c '\pset --format=latex select sic, naics, name' > $@