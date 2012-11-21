#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehenisve makefile.

ifndef configure.mk
include ../configure.mk
endif

bts.mk:=1

bts.url:=www.bts.gov/publications/national_transportation_atlas_database/2012/zip

INFO::
	@echo BTS Transportation and Network Data
	@echo   from ${bts.url}

.PHONY:db mirror
db:db/bts db/bts.place

db/bts:
	${PG} -f bts.sql
	touch $@

########################################################################
# BTS Data Railways, highways, intermodal_facilities, and ports all
# come from BTS.  There data is nicely enough organized that the
# defined function can import them all.  state_fips and fips55 are
# added in preparation for joins to city parameters
########################################################################
# shp2pgsql is currently broken, and needs that little geom cast.

define bts_point_data
	wget -m http://${bts.url}/$2.zip
	unzip -o ${bts.url}/$2.zip
	${shp2pgsql}   -d -s 4326 -S -g orig_geom $1.shp bts.$1 | ${PG}
	${PG} -c "select addgeometrycolumn('bts','$1','centroid',${srid},'POINT',2 )"
	${PG} -c "update bts.$1 set centroid=st_transform(orig_geom,${srid});"
	${PG} -c "CREATE INDEX $1_gist ON bts.$1 USING GIST (centroid);" 
	rm -rf $2.*
endef

define bts_point_rule
db/bts.$1:
	$(call bts_point_data,$1,$2)
	touch $$@
endef

define bts_line_data
	wget -m http://${bts.url}/$2.zip
	unzip -o ${bts.url}/$2.zip
	${shp2pgsql}  -d -s 4326 -S -g nad83 -S  $1.shp bts.$1 | ${PG} > /dev/null;
	${PG} -c "select AddGeometryColumn('bts','$1','centerline',$(srid),'LINESTRING',2); update bts.$1 set centerline=st_transform(nad83,${srid}); create index $1_centerline_gist on bts.$1 using gist(centerline);"
endef

define bts_line_rule
db/bts.$1:
	$(call bts_line_data,$1,$2,$3)
	touch $$@
endef

db/bts.rail_nodes:db/%:
	$(call bts_point_data,rail_node,rail)
	${PG} -c "delete from $* where stateab not in ($(subst ${space},${comma},$(patsubst %,'%',${states})))";
	$(PG) -c "select * from bts.add_and_find_qid('$*');"
	[[ -d db ]] || mkdir db; touch $@
	touch $@

db/bts.place_railwaynode:db/bts.place db/bts.railwaynode
	${PG} -f make-db/bts/place_railwaynode.sql
	touch $@;

db/bts.railway:db/%:
	$(call bts_line_data,rail_lines,rail,railway)
	${PG} -c "create index railway_tofranode on bts.rail_lines(tofranode)"
	${PG} -c "create index railway_frfranode on bts.rail_lines(frfranode)"
	${PG} -c "create index railway_startpoint on bts.rail_lines(st_startpoint(centerline))"
	${shp2pgsql}  -d -s 4326 -S -g orig_geom rail_nodes.shp bts.rail_nodes | ${PG}
	${PG} -c "select addgeometrycolumn('bts','rail_nodes','centroid',${srid},'POINT',2 )"
	${PG} -c "update bts.rail_nodes set centroid=st_transform(orig_geom,${srid});"
	${PG} -c "CREATE INDEX rail_nodes_gist ON bts.rail_nodes USING GIST (centroid);" 
	rm -rf rail*
	rm -rf amtrak
	touch $@

db/bts.waterway:
	$(call bts_line_data,waterway,waterway,waterway)
	touch $@

db/bts.roads:db/%:
	$(call bts_line_data,faf3_network,faf3_network,faf3_bts)
	${PG} -c "drop table if exists bts.road_info;"
	$(call add_dbf_cmd,bts.roads_info,faf3_1_1_data.dbf)
	${PG} -c "create index road_startpoint on bts.roads(startpoint(centerline)); create index road_endpoint on bts.roads(endpoint(centerline));"
	touch $@

# This is the same as the national atlas city
db/bts.place:db/%:
	$(call bts_point_data,place,place)
	$(PG) -c "select * from bts.add_qid('$*'); update $* set qid='D'||stfips||fips55; create index bts_qid on $*(qid);"
	[[ -d db ]] || mkdir db; touch $@

$(eval $(call bts_point_rule,facility,terminals))

$(eval $(call bts_point_rule,ports,ports))

db/bts.commodi:
	$(call fetch_zip,${bts.url},terminals)
	$(call add_dbf_cmd,bts.commodi,${down}/Commodi.dbf)
	[[ -d db ]] || mkdir db; touch $@


db/bts.intermodal:
	$(call bts_point_data,facility,facility)
	rm -r Commodi.*
	rm -r Directio.*
	rm -r Shipment.*
	${PG} -c "comment on table bts.facility is 'intermodal facilities from BTS'"
	touch $@

db/bts.ports:
	$(call bts_point_data,ports,ports)
	${PG} -c "comment on table bts.ports is 'US Army Corps of engineers port geodata from BTS'"
	touch $@