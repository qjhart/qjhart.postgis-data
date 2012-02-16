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

db:: db/refineries db/refineries.biopower db/refineries.terminals db/refineries.ethanol db/refineries.m_proxy_location db/refineries.edge db/refineries.vertex db/refineries.vertex_source db/refineries.vertex_dest

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

db/refineries.m_potential_location db/refineries.m_proxy_location:db/refineries.epa_facility db/refineries.ethanol_facility db/refineries.biopower_facility db/refineries.terminals db/refineries.epa_facility db/network.place_railwaynode db/network.place_fuel_port db/forest.pulpmills
	${PG} -f make-db/refineries/potential_locations.sql
	touch db/refineries.m_potential_location db/refineries.m_proxy_location

#${out}/usda.proxy_locations.shp:
#	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
#	${pgsql2shp} -f $@ ${database} -g centroid refineries.m_proxy_location;
#	echo '${srid-prj}' > $*.prj

#${out}/inl.edge.shp:${out}/%.shp:

#${out}/usda.feedstock_locations.shp:


db/refineries.terminal_waterway db/refineries.terminal_railwaynode:db/refineries.%:db/network.place db/network.railwaynode db/refineries.terminals
	${PG} -f make-db/refineries/$*.sql
	touch $@;

db/refineries.vertex db/refineries.edge db/refineries.vertex_source db/refineries.vertex_dest: db/network.edge db/network.vertex
	${PG} -f make-db/refineries/routing.sql
	touch db/refineries.vertex db/refineries.edge db/refineries.vertex_source db/refineries.vertex_dest

${out}/refineries.vertex.shp:%.shp:db/refineries.vertex
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ -g point ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/refineries.edge.shp:%.shp:db/refineries.edge
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ -g segment ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/refineries.vertex_dest.shp ${out}/refineries.vertex_source.shp:${out}/%.shp:db/%
	[[ -d $(dir $@) ]] || mkdir -p ${out}
	${pgsql2shp} -f $@ ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/refineries_network.zip:${out}/refineries.vertex_dest.shp ${out}/refineries.vertex_source.shp ${out}/refineries.vertex.shp ${out}/refineries.edge.shp
	zip $@ ${out}/refineries.vertex_dest.* ${out}/refineries.vertex_source.* ${out}/refineries.vertex.* ${out}/refineries.edge.*
