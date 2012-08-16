#! /usr/bin/make -f 

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
refineries.mk:=1

# table names
cClust:=city_cluster
fClust:=frs_cluster

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


db/${cClust}:
	python -c "import sys,pandas as pd, potential_locations as pl;\
		sys.path.append('../ahb_python');\
		import db;\
		cp=db.query('select qid, st_x(centroid), st_y(centroid) from place, afri_pbound  where pop_2000>${mPop} and geom ~ centroid;', search_path='afri,bts, public');\
		placsDf=pd.DataFrame(cp);\
		pl.clusterPoints(placsDf,${bw},'${cClust}');"
	${PG} -c 'alter table refineries.${cClust}_${bw}_link add column has_proxy boolean default false;'
	touch $@

db/${fClust}:
	python -c "import sys, pandas as pd, potential_locations as pl;\
		sys.path.append('../ahb_python');\
		import db;\
		frs=db.query('select gid,st_x(geom), st_y(geom) from pnw_target_frs', search_path='envirofacts, public');\
		frsDf=pd.DataFrame(frs);\
		pl.clusterPoints(frsDf,${bw},'${fClust}');"
	touch $@

db/hasProxy: db/${fClust} db/${fClust}
	${PG} -c "set search_path= refineries, public;\
		update city_cluster_${bw}_link set has_proxy='t' from (select i.id dest from city_clusters_${bw} c, frs_clusters_${bw} f join city_cluster_${bw}_link i using(clabel ) where st_dwithin(c.geom, f.geom,${th})) as foo where id=foo.dest;"
	touch $@

db/r_locations: db/hasProxy db/${fClust} db/${fClust}
	${PG} -c "set search_path= refineries, public, afri, cmz; create or replace view refineries.r_locations as select distinct clabel, 'frs_cluster' loc_type, foo.geom  from frs_cluster_${bw}_link join (select clabel, cl.geom from frs_clusters_${bw} cl, cmz.cmz_pnw cz where st_intersects(cz.geom, cl.geom) and cmz='CMZ ${cmz}') as foo using (clabel) union select distinct clabel, 'urban cluster' loc_type, st_askml(foo.geom)  from city_cluster_${bw}_link join (select clabel, cl.geom from city_clusters_${bw} cl, cmz.cmz_pnw cz where st_intersects(cz.geom,cl.geom) and cmz='CMZ ${cmz}') as foo using (clabel) where has_proxy='f'"
	touch $@

/tmp/locations.csv: db/r_locations
	${PG} -c "copy (select clabel, loc_type, st_askml(geom) from refineries.r_locations) to '$@' with csv header;"