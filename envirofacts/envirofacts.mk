#! /usr/bin/make -f 

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
envirofacts.mk:=1

# For SIC codes, see http://www.osha.gov/pls/imis/sicsearch.html
sic_codes:=2011 2015 2041 2046 2062 2063 2074 2075 2076 2077 2079 \
	   2421 2429 2431 2611 2631 2911 4221 5171 5159 8731

columns:=

space:=
space+=
comma:=,

# We create an SQL call to collect all the EPA facility types for a
# set of SIC Codes and states.  You can replicate this by going to
# http://www.epa.gov/enviro/html/fii/ez.html, and then to 'EPA
# Facility Latitude and Longitude Information Categorized by SIC
# CODE'.  You still need to copy the output by hand:(

# This is the table we use
table:=V_LRT_EF_COVERAGE_SRC_SIC_EZ

# These are the columns.  It's a pain to figure them out.
cols:=PGM_SYS_ACRNM FACILITY_NAME REGISTRY_ID SIC_CODE CITY_NAME COUNTY_NAME STATE_CODE BVFLAG LATITUDE LONGITUDE ACCURACY_VALUE

#cols:=CODE_DESCRIPTION FACILITY_NAME REGISTRY_ID SIC_CODE PRIMARY_INDICATOR COUNTY_NAME STATE_CODE LATITUDE LONGITUDE

# For the ones we need to select by add here:
SIC_CODE-in:=$(subst ${space},%2C,${sic_codes})
STATE_CODE-in:=$(subst ${space},%2C,${states})

col-defs:=$(foreach p,${cols},table_1=${table}.$p&table1_type=In&table1_value=${$p-in}&column_number=&sort_selection=&sort_order=Ascending)

url:=http://oaspub.epa.gov/enviro/ez_build_sql2.get_table?database_type=LRT&where_selection=dummy
url-footer:=group_sequence=test&showsql=true&csv_output=Output+to+CSV+File

INFO::
	@echo EPA EnviroFacts Facility Registration System
	@echo $(subst ${space},${comma},${sic_codes})
	@echo $(subst ${space},${comma},${states})
	@echo '${url}&$(subst ${space},&,${col-defs})&${url-footer}'

.PHONY:db
db::db/envirofacts db/envirofacts.epa_facility

db/envirofacts:
	${PG} -f envirofacts.sql
	touch $@

epa_facility.csv:
	@echo Please go to the following URL in your browser, then copy the output csv file to epa_facility.csv.
	@echo '${url}&$(subst ${space},&,${col-defs})&${url-footer}'

db/envirofacts.epa_facility:db/%:db/envirofacts epa_facility.csv ../bts/db/bts.place
	${PG} -f epa_facility.sql
	touch $@

