#! /usr/bin/make -f 

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
refineries.mk:=1



db/cluster_cities:
	python -c "import potential_locations;\
		bw_m=2500;\
		ms=MeanShift(bw_m);\
		popMin=100;\
		cp=db.query('select qid, st_x(centroid), st_y(centroid) from place, afri_pbound  where pop_2000>%s and geom ~ centroid;'%popMin, search_path='afri,bts, public');\
		placsDf=pd.DataFrame(cp);\
		clusterPoints(placsDf,bw_m,'city_cluster');"
	touch $@




INFO::
	@echo Potential Refinery Locations derived from various data sources.

db:: db/refineries db/refineries.biopower db/refineries.caBiopower db/refineries.terminals db/refineries.ethanol db/refineries.m_proxy_location

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

db/refineries.caBiopower: qft:=www.google.com/fusiontables/api/query
db/refineries.caBiopower: docid:=1KrY-vkqIptJ0-nlMPlLkTsZnA6aK8lNmjy9nkWQ
db/refineries.caBiopower: sel:=status,name,city,county,longitude,latitude,ptype,MWgross,cogen
db/refineries.caBiopower:
	wget -m 'https://${qft}?sql=select+${sel}+from+${docid}' '${qft}?sql=DESCRIBE+${docid}'
	cat '${qft}?sql=select+${sel}+from+${docid}' | ${PG} -f ca-biopower.sql
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
db/refineries.potential_location:../envirofacts/db/envirofacts.epa_facility db/
refineries.ethanol db/refineries.biopower db/refineries.terminals ../bts/db/bts.rail_node ../forest/db/forest.mills
	${PG} -f potential_locations.sql
	touch $@

refineries.potential_location.csv:db/refineries.potential_location
	${PG} -c '\COPY (select qid,populated,terminal,epa,biopower,ethanol,railway,o3,pm25,score,is_proxy,proxy,proxy_score,proxy_distance,st_asKML(centroid) as centroid from refineries.potential_location) to $@ CSV HEADER'



