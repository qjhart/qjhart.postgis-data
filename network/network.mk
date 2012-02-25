#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehenisve makefile.

network.mk:=1
network:=1

ifndef db
include configure.mk
endif

ifndef refineries
include refineries.mk
endif

ifndef msw
include msw.mk
endif

ifndef inl
include inl.mk
endif


bts.url:=http://www.bts.gov/publications/national_transportation_atlas_database/2008/zip


INFO::
	@echo BTS Network Data
	@echo   from ${bts.url}

db:: network
.PHONY: network
network: ${db}/network ${db}/network.place ${db}/network.vertex ${db}/network.edge ${db}/network.vertex

${db}/network:${db}/public
#	Right now we don't use the connectors
#	${PG} -f make-db/network/schema.sql
	${PG} -c 'drop schema if exists network cascade; create schema network;'
	touch $@

${db}/network.vertex ${db}/network.edge ${db}/network.vertex_source ${db}/network.vertex_dest ${db}/network.liquid_vertex_source: ${db}/inl.model ${db}/network.roads ${db}/network.railway ${db}/network.waterway ${db}/network.place_roads ${db}/network.place_railwaynode ${db}/network.place_waterway ${db}/network.road_rail_im ${db}/network.road_waterway_im  ${db}/network.facility_roads ${db}/network.facility_railwaynode ${db}/network.facility_waterway ${db}/network.county_roads ${db}/refineries.epa_facility ${db}/network.epa_facility_roads ${db}/refineries.m_proxy_location ${db}/msw.msw_by_city ${db}/refineries.terminals ${db}/refineries.terminal_railwaynode ${db}/refineries.terminal_waterway ${db}/feedstock.feedstock
	${PG} -f make-db/network/routing.sql
	touch ${db}/network.vertex ${db}/network.edge ${db}/network.vertex_sourde ${db}/network.vertex_dest ${db}/network.liquid_vertex_source

########################################################################
# BTS Data Railways, highways, intermodal_facilities, and ports all
# come from BTS.  There data is nicely enough organized that the
# defined function can import them all.  state_fips and fips55 are
# added in preparation for joins to city parameters
########################################################################

define bts_point_data
	$(call fetch_zip,${bts.url},$2)
	${shp2pgsql} -d -s 4326 -S -g nad83 -S -I ${down}/$1.shp network.$1 | ${PG} > /dev/null;
	$(PG) -c "alter table network.$1 add column qid varchar(8); select AddGeometryColumn('network','$1','centroid',$(srid),'POINT',2); update network.$1 set centroid=transform(nad83,${srid}); create index $1_centroid on network.$1(centroid); create index $1_centriod_gist on network.$1 using gist(centroid gist_geometry_ops);";
endef

define bts_point_rule
${db}/network.$1:
	$(call bts_point_data,$1,$2)
	touch $$@
endef

define bts_line_data
	$(call fetch_zip,${bts.url},$2)
	${shp2pgsql} -d -s 4326 -S -g nad83 -S -I ${down}/$3.shp network.$1 | ${PG} > /dev/null;
	${PG} -c "select AddGeometryColumn('network','$1','centerline',$(srid),'LINESTRING',2); update network.$1 set centerline=transform(nad83,${srid}); create index $1_centerline_gist on network.$1 using gist(centerline gist_geometry_ops);"
endef

define bts_line_rule
${db}/network.$1:
	$(call bts_line_data,$1,$2,$3)
	touch $$@
endef

${db}/network.railwaynode:
	${PG} -c "drop table if exists network.railwaynode cascade"
	$(call fetch_zip,${bts.url},railwaylines)
	${shp2pgsql} -d -s 4326 -S -g nad83 -S -I ${down}/railwaynode.shp network.railwaynode | perl -p -e 's/"franodeid" int4/"franodeid" serial/' | ${PG} > /dev/null;
	$(PG) -c "alter table network.railwaynode add column qid varchar(8); select AddGeometryColumn('network','railwaynode','centroid',$(srid),'POINT',2); update network.railwaynode set centroid=transform(nad83,${srid});";
	${PG} -c "create index railwaynode_centroid_gist on network.railwaynode using gist(centroid gist_geometry_ops);"
	touch $@

${db}/network.place_railwaynode:${db}/network.place ${db}/network.railwaynode
	${PG} -f make-db/network/place_railwaynode.sql
	touch $@;

${db}/network.railway:${db}/%:
	$(call bts_line_data,railway,railwaylines,railway)
	${PG} -c "create index railway_tofranode on network.railway(tofranode)"
	${PG} -c "create index railway_frfranode on network.railway(frfranode)"
	${PG} -c "create index railway_startpoint on network.railway(startpoint(centerline))"
	touch $@

# CUrrently not used
#${db}/network.railway+im:${db}/%:${db}/network.place ${db}/network.intermodal
#	${PG} -c "select network.add_railway_connector('network.road_rail_im','gid',10000,92);"
#$	touch $@

${out}/network/railway.shp:${out}/%: ${db}/network.railway
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ ${database} -g centerline network.railway
#	${pgsql2shp} -f $@ ${database} -g centerline 'select gid,fraarcid,stateab,statefips,cntyfips,stcntyfips,fraregion,rrowner1,rrowner2,rrowner3,trkrghts1,trkrghts2,trkrghts2,trkrghts2,trkrghts2,trkrghts2,trkrghts2,trkrghts2,trkrghts2,stracnet,sigsys,tracks,frfranode,tofranode,net,passngr,den06code,subdiv,centerline from network.roads n left join network.roads_2data d using (id)'


${db}/network.waterway:
	$(call bts_line_data,waterway,usacewaterwayedges,waterway)
#	${PG} -c "select network.add_waterway_connector('network.fuel_ports',5000::float,'F');"
#	${PG} -c "select network.add_waterway_connector('network.road_waterway_im',10000.0::float,'IM');"
#	${PG} -c "create index waterway_startpoint on network.waterway(startpoint(centerline))"
	touch $@

${out}/network/waterway.shp:${out}/%: ${db}/network.waterway
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ ${database} -g centerline network.waterway

${db}/network.place_waterway:${db}/network.place ${db}/network.waterway
	${PG} -f make-db/network/place_waterway.sql
	touch $@;

${db}/network.place_port ${db}/network.place_fuel_port:${db}/network.place ${db}/network.waterway ${db}/network.ports
	${PG} -f make-db/network/place_port.sql
	touch ${db}/network.place_port ${db}/network.place_fuel_port


${db}/network.roads:${db}/%:
	$(call bts_line_data,roads,fafzipped.zip,faf2_network)
	${PG} -c "drop table if exists network.road_info;"
	$(call add_dbf_cmd,network.roads_info,${down}/faf2_2data.dbf)
	${PG} -c "create index road_startpoint on network.roads(startpoint(centerline)); create index road_endpoint on network.roads(endpoint(centerline));"
	touch $@

${db}/network.place_roads:${db}/network.place ${db}/network.roads
	${PG} -f make-db/network/place_roads.sql
	touch $@;

${out}/network/roads.shp:${out}/%: ${db}/network.roads
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ ${database} -g centerline $(notdir $<)
#	${pgsql2shp} -f $@ ${database} -g centerline 'select id,dir,recid,state,sign1,sign2,sign3,lname,rucode,fclass,status,nhs,link_type,stfips,ctfips,btsversion,d.speed02,d.speed35,(d.speed02+d.speed35)/2 as speed15,centerline from network.roads n left join network.roads_2data d using (id)'


# This is the same as the national atlas city
${db}/network.place:${db}/%:
	$(call bts_point_data,place,place)
	${PG} -c "update $* set qid='D'||stfips||fips55; create index network_qid on $*(qid);"
	touch $@

$(eval $(call bts_point_rule,facility,terminals))

${db}/network.facility_roads ${db}/network.facility_railwaynode ${db}/network.facility_waterway:${db}/network.facility ${db}/network.roads ${db}/network.railwaynode ${db}/network.waterway
	${PG} -f make-db/network/facility.sql
	touch ${db}/network.facility_roads ${db}/network.facility_railwaynode ${db}/network.facility_waterway

$(eval $(call bts_point_rule,ports,ports))

${db}/network.commodi:
	$(call fetch_zip,${bts.url},terminals)
	$(call add_dbf_cmd,network.commodi,${down}/Commodi.dbf)
	touch $@

${db}/network.road_rail_im ${db}/network.road_waterway_im ${db}/network.fuel_ports: ${db}/network.facility ${db}/network.commodi ${db}/network.ports
	${PG} -f 'make-db/network/intermodal.sql'
	touch ${db}/network.road_rail_im ${db}/network.road_waterway_im ${db}/network.fuel_ports

# Need connectors to the epa facilities as well 
${db}/network.epa_facility_roads ${db}/network.epa_facility_railwaynode ${db}/network.epa_facility_waterway:${db}/refineries.epa_facility ${db}/network.roads ${db}/network.railwaynode ${db}/network.waterway
	${PG} -f make-db/network/epa_facility.sql
	touch ${db}/network.epa_facility_roads ${db}/network.epa_facility_railwaynode ${db}/network.epa_facility_waterway

${out}/network/facility.shp:${out}/%: ${db}/network.intermodal
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ ${database} -g centroid network.facility

${out}/network/place.shp:${out}/%:
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ ${database} -g centroid network.place

${db}/network.county_roads:${db}/network.county ${db}/network.roads
	${PG} -f make-db/network/county_roads.sql
	touch $@;


${out}/mui.zip: $(patsubst %,${out}/network/%.*, place facility roads railway waterway)
	zip $@ $^

${out}/network.zip: ${out}/network.vertex.shp ${out}/network.vertex_source.shp ${out}/network.vertex_dest.shp ${out}/network.edge.shp ${out}/network.liquid_vertex_source.shp
	zip $@ ${out}/network.vertex.* ${out}/network.edge.* ${out}/network.vertex_source.* ${out}/network.vertex_dest.* ${out}/network.liquid_vertex_source.*

${out}/network.vertex.shp:%.shp:${db}/network.vertex
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ -g point ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/network.edge.shp:%.shp:${db}/network.edge
	[[ -d $(dir $@) ]] || mkdir -p $(dir $@)
	${pgsql2shp} -f $@ -g segment ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

${out}/network.vertex_dest.shp ${out}/network.vertex_source.shp ${out}/network.liquid_vertex_source.shp:${out}/%.shp:${db}/%
	[[ -d $(dir $@) ]] || mkdir -p ${out}
	${pgsql2shp} -f $@ -g point ${database} $(notdir $*)
	echo '${srid-prj}' > $*.prj

# Needs to be rewritten to be speedier
na-odcosts.dbf:=$(patsubst %,${down}/%,bale_odcost_1_298.dbf  bale_odcost_2000-3827.dbf  bale_odcost_299-1999.dbf)
#na-odcosts.dbf:=$(patsubst %,${down}/%,bale_odcost_2000-3827.dbf)

${db}/network.feedstock_odcosts:${db}/%:${na-odcosts.dbf}
	${PG} -c 'drop table if exists $*; create table $* (src_qid varchar(8),dest_qid varchar(8),cost float,road_mi float,rail_mi float,water_mi float,road_hrs float);'
	for i in ${na-odcosts.dbf}; do \
	  ${ogr_dbf} -select name,total_bale,total_road,total_rail,total_mari,total_hour $$i -nln network.temp; \
	  ${PG} -c "insert into $* select distinct trim(substr(name,1,position(' - ' in name)))::varchar(8) as src_qid,trim(substr(name,position(' - ' in name)+3,100))::varchar(8) as dest_qid,total_bale as cost,total_road,total_rail as rail_mi,total_mari as water_mi,total_hour as road_hours from network.temp;"; \
	done
	touch $@

na-liq-odcosts.dbf:=$(patsubst %,${down}/%,liquid_odcost.dbf)

${db}/network.liquid_odcosts:${db}/%:${na-odcosts.dbf}
	${PG} -c 'drop table if exists $*; create table $* (src_qid varchar(8),dest_qid varchar(8),cost float,road_mi float,rail_mi float,water_mi float,road_hrs float);'
	for i in ${na-liq-odcosts.dbf}; do \
	  ${ogr_dbf} -select name,total_liqu,total_road,total_rail,total_mari,total_hour $$i -nln network.temp; \
	  ${PG} -c "insert into $* select distinct trim(substr(name,1,position(' - ' in name)))::varchar(8) as src_qid,trim(substr(name,position(' - ' in name)+3,100))::varchar(8) as dest_qid,total_liqu as cost,total_road,total_rail as rail_mi,total_mari as water_mi,total_hour as road_hours from network.temp;"; \
	done
	touch $@

${db}/network.terminal_odcosts:${db}/network.%:${down}/refineries_liquid_odcost.dbf
	${ogr_dbf} -select name,total_liqu,total_mari,total_rail $< -nln network.temp_terminal
	${PG} -c "create table network.$* as select distinct trim(substr(name,1,position(' - ' in name)))::varchar(8) as src_qid,trim(substr(name,position(' - ' in name)+3,100))::varchar(8) as dest_qid,total_liqu as cost,total_mari as water_mi,total_rail as rail_mi from network.temp_terminal;"
	touch $@

