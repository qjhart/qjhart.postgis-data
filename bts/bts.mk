#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehenisve makefile.

ifndef configure.mk
include ../configure.mk
endif

bts.mk:=1

bts.url:=www.bts.gov/publications/national_transportation_atlas_database/2011/zip

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
	${shp2pgsql} -d -r 4326 -s ${srid} -S -g centroid -S -I $2/$1.shp bts.$1 | sed 's/, ${srid}/::geometry, ${srid}/' | ${PG} > /dev/null;
	${PG} -c 'update bts.$1 set centroid=st_snapToGrid(centroid,${snap})'
	rm -rf $2
endef

define bts_point_rule
db/bts.$1:
	$(call bts_point_data,$1,$2)
	touch $$@
endef

define bts_line_data
	$(call fetch_zip,${bts.url},$2)
	${shp2pgsql} -d -s 4326 -S -g nad83 -S -I ${down}/$3.shp bts.$1 | ${PG} > /dev/null;
	${PG} -c "select AddGeometryColumn('bts','$1','centerline',$(srid),'LINESTRING',2); update bts.$1 set centerline=transform(nad83,${srid}); create index $1_centerline_gist on bts.$1 using gist(centerline gist_geometry_ops);"
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
	$(call bts_line_data,railway,railwaylines,railway)
	${PG} -c "create index railway_tofranode on bts.railway(tofranode)"
	${PG} -c "create index railway_frfranode on bts.railway(frfranode)"
	${PG} -c "create index railway_startpoint on bts.railway(startpoint(centerline))"
	touch $@

db/bts.waterway:
	$(call bts_line_data,waterway,usacewaterwayedges,waterway)
	touch $@

db/bts.roads:db/%:
	$(call bts_line_data,roads,fafzipped.zip,faf2_bts)
	${PG} -c "drop table if exists bts.road_info;"
	$(call add_dbf_cmd,bts.roads_info,${down}/faf2_2data.dbf)
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

