#! /usr/bin/make -f 

ifndef configure.mk
include ../configure.mk
endif

ifndef envirofacts.mk
include ../envirofacts/envirofacts.mk
endif 

# If included somewhere else
refineries.mk:=1

INFO::
	@echo Potential Refinery Locations derived from various data sources.

db:: db/refineries db/refineries.biopower db/refineries.terminals db/refineries.ethanol db/refineries.m_proxy_location

db/refineries:
	${PG} -f refineries.sql
	touch $@

##########################################################################
# Summary of terminal database - From private db?
##########################################################################
db/refineries.terminals:db/%:db/refineries terminals.csv
	${PG} -f terminals.sql
	${PG} -c "delete from refineries.terminals where state not in ($(subst ${space},${comma},$(patsubst %,'%',${states})))"
	touch $@

########################################################################
# Antares - US BioPower Facilities
# There are locations that need to be fixed.
########################################################################
db/refineries.biopower:db/%:us-biopower-facilities.csv db/refineries
	${PG} -f biopower.sql
	${PG} -c "delete from refineries.biopower where state not in ($(subst ${space},${comma},$(patsubst %,'%',${states})))"
	touch $@

#########################################################################
# Existing ethanol facilities from Antares
#########################################################################
refineries.ethanol.csv:gcsv:=http://spreadsheets.google.com/pub?key=t9MFzewsuMk6Rlv5bz7AOjQ&single=true&gid=0&output=csv
refineries.ethanol.csv:
	wget -O $@ '${gcsv}'

db/refineries.ethanol:refineries.ethanol.csv
	${PG} -f ethanol_facility.sql
	touch $@

##########################################################################
# USDA destinations
##########################################################################
# db/network.place_fuel_port db/forest.pulpmills
db/refineries.m_potential_location db/refineries.m_proxy_location:../envirofacts/db/environfacts.epa_facility db/refineries.ethanol db/refineries.biopower db/refineries.terminals ../bts/db/bts.place_railwaynode db/forest.pulpmills
	${PG} -f make-db/refineries/potential_locations.sql
	touch db/refineries.m_potential_location db/refineries.m_proxy_location


