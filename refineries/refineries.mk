#! /usr/bin/make -f 
refineries:=1

ifndef db
include configure.mk
endif

ifndef network
include network.mk
endif

INFO::
	@echo Potential Locations Makefile.

db:: ${db}/refineries ${db}/refineries.epa_facility ${db}/refineries.biopower_facility ${db}/refineries.terminals ${db}/refineries.ethanol_facility ${db}/refineries.m_proxy_location ${db}/refineries.edge ${db}/refineries.vertex ${db}/refineries.vertex_source ${db}/refineries.vertex_dest

${db}/refineries:
	${PG} -f make-db/refineries/schema.sql
	touch $@


###########################################################################
# EPA EnviroFacts Facility Registration System

# Not user what this is yet.
#http://www.epa.gov/enviro/html/frs_demo/geospatial_data/EPAFeatureClassDownload.zip

# This is the SQL call to collect all the EPA facility types that use
# determining potential locations for sites.

#http://oaspub.epa.gov/enviro/user_entered_sql.user_sql?csv_output=Output+to+CSV&sqltext=Select++V_LRT_EF_COVERAGE_SRC_SIC_EZ.PGM_SYS_ACRNM,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.FACILITY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.REGISTRY_ID,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.SIC_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.CITY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.COUNTY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.STATE_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.BVFLAG,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.PGM_SYS_LATITUDE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.PGM_SYS_LONGITUDE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.ACCURACY_VALUE+from+V_LRT_EF_COVERAGE_SRC_SIC_EZ++where+(V_LRT_EF_COVERAGE_SRC_SIC_EZ.SIC_CODE+in+('2421','2429','2431','2077','2011','2013','5147','2041','2046','2075','2076','2074','2611','2631'))

# This setup is currently kinda messed up.  It seems like you can
# still usr this URL, but the data never comes back.  However, you can
# later go to http://www.epa.gov/enviro/pickadhoc and find the csv
# file that was created.  Clearly this setup is not workable.  If you
# start from http://www.epa.gov/enviro/html/fii/ez.html, I end up with
# this similar URL.  For now I'll use the old one.

#http://oaspub.epa.gov/enviro/user_entered_sql.user_sql?csv_output=Output+to+CSV&sqltext=Select++V_LRT_EF_COVERAGE_SRC_SIC_EZ.PGM_SYS_ID,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.CODE_DESCRIPTION,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.FACILITY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.SIC_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.PRIMARY_INDICATOR,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.CITY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.COUNTY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.STATE_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.FEDERAL_FACILITY_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.LATITUDE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.LONGITUDE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.SCALE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.HDATUM_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.HDATUM_DESC+from+V_LRT_EF_COVERAGE_SRC_SIC_EZ++where+(V_LRT_EF_COVERAGE_SRC_SIC_EZ.SIC_CODE+in+('2421','2429','2431','2077','2011','2013','5147','2041','2046','2075','2076','2074','2611','2631'))
# This is the one saved in a

# For SIC codes
#http://www.osha.gov/pls/imis/sicsearch.html
#2421,2429,2431,2077,2011,2013,5147,2041,2046
#AK,AZ,CA,CO,HI,ID,KS,MT,NE,NV,NM,ND,OK,OR,SD,TX,UT,WA,WY
##########################################################################
archive_files+=input/epa_facility.csv
${down}/epa_facility.csv:
	echo Please go to the following URL in your browser, then download the output file to epa_facility.csv.
	echo "http://oaspub.epa.gov/enviro/user_entered_sql.user_sql?csv_output=Output+to+CSV&sqltext=Select++V_LRT_EF_COVERAGE_SRC_SIC_EZ.PGM_SYS_ACRNM,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.FACILITY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.REGISTRY_ID,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.SIC_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.CITY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.COUNTY_NAME,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.STATE_CODE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.BVFLAG,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.PGM_SYS_LATITUDE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.PGM_SYS_LONGITUDE,+V_LRT_EF_COVERAGE_SRC_SIC_EZ.ACCURACY_VALUE+from+V_LRT_EF_COVERAGE_SRC_SIC_EZ++where+(V_LRT_EF_COVERAGE_SRC_SIC_EZ.SIC_CODE+in+('2421','2429','2431','2077','2011','2013','5147','2041','2046','2075','2076','2074','2611','2631'))"

${db}/refineries.epa_facility:${db}/%:${db}/refineries ${down}/epa_facility.csv
	sed -e "s|epa_facility.csv|`pwd`/${down}/epa_facility.csv|" make-db/refineries/epa_facility.sql | ${PG} -f -
	touch $@

##########################################################################
# Summary of terminal database
##########################################################################
${db}/refineries.terminals:${db}/%:${db}/refineries ${down}/terminals.csv
	sed -e "s|terminals.csv|`pwd`/${down}/terminals.csv|" make-db/refineries/terminals.sql | ${PG} -f -
	touch $@

########################################################################
# Antares
# US BioPower Facilities
# I combined the two into one, and saved as a DBF file.  There are 
# locations that need to be fixed.
########################################################################
${db}/refineries.biopower_facility:${db}/%:${down}/US-Biopower-Facilities.dbf ${db}/refineries
	${PG} -c 'drop table if exists refineries.biopower_facility cascade;'
	$(call add_dbf_cmd,$*,$<)
	${PG} -c "select add_nad83('refineries','biopower_facility','longitude','latitude'); select add_centroid('refineries','biopower_facility'); select add_qid('refineries','biopower_facility','state','city');"
	touch $@

#########################################################################
# Existing ethanol facilities from Antares
#########################################################################
# ${db}/refineries.ethanol_facility:${db}/%:${db}/refineries ${down}/wga_etoh_fac.shp
# 	${PG} -c 'drop table if exists refineries.ethanol_facility cascade;'
# 	shp2pgsql -d -s 4326 -S -g nad83 -S -I ${down}/wga_etoh_fac.shp $* | ${PG} > /dev/null;
# 	${PG} -c "select add_centroid('refineries','ethanol_facility'); select add_qid('refineries','ethanol_facility','state','city');"
# 	# Fixup the capacity
# 	${PG} -c "alter table $* rename column capacity to cap_str; alter table $* add column capacity float; update $* set capacity=cast(replace(cap_str,',','') as float); delete from $* where gid in (select max(gid) from $* group by bg_lat,bg_long having count(*) > 1);"
# 	touch $@

${down}/refineries.ethanolfacility.csv:gcsv:=http://spreadsheets.google.com/pub?key=t9MFzewsuMk6Rlv5bz7AOjQ&single=true&gid=0&output=csv
${down}/refineries.ethanolfacility.csv:
	wget -O $@ '${gcsv}'

${db}/refineries.ethanol_facility:${down}/refineries.ethanolfacility.csv
	cat refineries/ethanol_facility.sql | sed -e "s|ethanolfacility.csv|`pwd`/${down}/refineries.ethanolfacility.csv|" | ${PG} -f -
	touch $@


##########################################################################
# USDA destinations
##########################################################################

${db}/refineries.m_potential_location ${db}/refineries.m_proxy_location:${db}/refineries.epa_facility ${db}/refineries.ethanol_facility ${db}/refineries.biopower_facility ${db}/refineries.terminals ${db}/refineries.epa_facility ${db}/network.place_railwaynode ${db}/network.place_fuel_port ${db}/forest.pulpmills
	${PG} -f make-db/refineries/potential_locations.sql
	touch ${db}/refineries.m_potential_location ${db}/refineries.m_proxy_location

#${out}/usda.proxy_locations.shp:
#	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
#	${pgsql2shp} -f $@ ${database} -g centroid refineries.m_proxy_location;
#	echo '${srid-prj}' > $*.prj

#${out}/inl.edge.shp:${out}/%.shp:

#${out}/usda.feedstock_locations.shp:


${db}/refineries.terminal_waterway ${db}/refineries.terminal_railwaynode:${db}/refineries.%:${db}/network.place ${db}/network.railwaynode ${db}/refineries.terminals
	${PG} -f make-db/refineries/$*.sql
	touch $@;

${db}/refineries.vertex ${db}/refineries.edge ${db}/refineries.vertex_source ${db}/refineries.vertex_dest: ${db}/network.edge ${db}/network.vertex
	${PG} -f make-db/refineries/routing.sql
	touch ${db}/refineries.vertex ${db}/refineries.edge ${db}/refineries.vertex_source ${db}/refineries.vertex_dest

${out}/refineries.vertex.shp:%.shp:${db}/refineries.vertex
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ -g point ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/refineries.edge.shp:%.shp:${db}/refineries.edge
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ -g segment ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/refineries.vertex_dest.shp ${out}/refineries.vertex_source.shp:${out}/%.shp:${db}/%
	[[ -d $(dir $@) ]] || mkdir -p ${out}
	${pgsql2shp} -f $@ ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/refineries_network.zip:${out}/refineries.vertex_dest.shp ${out}/refineries.vertex_source.shp ${out}/refineries.vertex.shp ${out}/refineries.edge.shp
	zip $@ ${out}/refineries.vertex_dest.* ${out}/refineries.vertex_source.* ${out}/refineries.vertex.* ${out}/refineries.edge.*
