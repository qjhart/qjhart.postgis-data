#! /usr/bin/make -f 

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
refineries.mk:=1

# table names
cClust:=city_cluster
ifClust:=if_cluster
ifCost:=if_sitecosts

# Minimum population
mPop:=100
# Mean Shift bandwidth
bw:=16000
#threshhold to replace urban with frs
th:=10000
#target cmz
cmz:=34
#fusion table ID for CMZ 34 potential locations
cmz34:=1U2BV1Gyfr4w35ukWjQmq4KsgQx6gcL7-GIHwFJI

#collect location information from EPA FRS, Antares biopower, Antares ethanol, USFS wood mills, USFS pulp mills, California Biopower into one view for clustering 
db/industrial:
	${PG} -c "set search_path=refineries, public, envirofacts, forest; create or replace view refineries.industrial_locations as select gid,'biopower' as type ,centroid from biopower union select gid,'ethanol',centroid from ethanol union select gid,'cabiopower', centroid from cabiopower union select gid,'mills',centroid from mills union select gid,'pulpmills',centroid from pulpmills union select gid,'us_frs', geom from pnw_target_frs;"
	${PG} -c "comment on view refineries.industrial_locations is 'this is the superset of industrial facility locations that are used as proxies' "
	touch $@

db/${cClust}:
	python -c "import sys,pandas as pd, potential_locations as pl;\
		sys.path.append('../ahb_python');\
		import db;\
		cp=db.query('select qid, st_x(centroid), st_y(centroid) from place, afri_pbound  where pop_2000>${mPop} and geom ~ centroid;', search_path='afri,bts, public');\
		placsDf=pd.DataFrame(cp);\
		pl.clusterPoints(placsDf,${bw},'${cClust}');"
	${PG} -c 'alter table refineries.${cClust}_${bw}_link add column has_proxy boolean default false;'
	touch $@

##Cluster industrial faciltiy locations
db/${ifClust}: db/industrial
	python -c "import sys, pandas as pd, potential_locations as pl;\
		sys.path.append('../ahb_python');\
		import db;\
		frs=db.query('select t.gid,st_x(t.centroid), st_y(t.centroid) from industrial_locations t, afri_pbound p where p.geom ~ t.centroid', search_path='envirofacts,refineries, public, afri');\
		frsDf=pd.DataFrame(frs);\
		pl.clusterPoints(frsDf,${bw},'${ifClust}');"
	touch $@

db/hasProxy: db/${fClust} db/${cClust}
	${PG} -c "set search_path= refineries, public;\
		update ${cClust}_${bw}_link set has_proxy='t' from (select i.gid dest from ${cClust}s_${bw} c, ${ifClust}s_${bw} f join ${cClust}_${bw}_link i using(clabel ) where st_dwithin(c.geom, f.geom,${th})) as foo where gid=foo.dest;"
	touch $@

db/r_locations: db/hasProxy
	${PG} -c "set search_path= refineries, public, afri, cmz; create or replace view refineries.r_locations as select distinct clabel, '${ifClust}' loc_type, foo.geom  from ${ifClust}_${bw}_link join (select clabel, cl.geom from ${ifClust}s_${bw} cl, cmz.cmz_pnw cz where st_intersects(cz.geom, cl.geom)) as foo using (clabel) union select distinct clabel, 'urban_cluster' loc_type, foo.geom  from ${cClust}_${bw}_link join (select clabel, cl.geom from ${cClust}s_${bw} cl, cmz.cmz_pnw cz where st_intersects(cz.geom,cl.geom)) as foo using (clabel) where has_proxy='f'"
	touch $@

/tmp/locations.csv: db/r_locations
	${PG} -c "copy (select clabel, loc_type, st_x(geom) easting, st_y(geom) northing, st_askml(geom) from refineries.r_locations) to '$@' with csv header;"


/tmp/cmz${cmz}_odpairs.csv: db/r_locations
	${PG} -c "set search_path= afri, public, refineries,cmz; copy (select pid pxid, st_x(st_centroid(boundary)) src_lat ,st_y(st_centroid(boundary)) src_lon, st_askml(st_centroid(boundary)) src_kml, clabel ref_cluster, st_x(r.geom) dest_lat, st_y(r.geom) dest_lon, st_askml(r.geom) dest_kml, st_askml(st_makeline(st_centroid(boundary),r.geom)) link from pixels , cmz_pnw c cross join r_locations r where size=8192 and st_intersects(c.geom, boundary) and cmz='CMZ 34') to '$@' with csv header "

# this table contains the siting costs in this analysis: rail spur construction, air control technologies..
db/if_costs:
	${PG} -c "set search_path= refineries; drop table if exists ${ifCost}; create table ${ifCost} (cid serial primary key, gid int; type varchar(128), railcost real; )"
	 