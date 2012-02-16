SET search_path = forest, public;
\set srid 102004
\set ON_ERROR_STOP 1
BEGIN;
SELECT AddGeometryColumn('forest','pulpmills','centroid',:srid,'POINT',2);
update pulpmills set centroid=transform(the_geom,:srid);
CREATE INDEX "pulpmills_centroid_gist" ON "forest"."pulpmills" using gist ("centroid" gist_geometry_ops);

alter table pulpmills add column qid varchar(8);
update pulpmills p set qid=q.qid from 
(
select gid,qid,distance 
from (select m.gid,p.qid,ST_Distance(m.centroid,p.centroid) as distance,
             min(ST_Distance(m.centroid,p.centroid)) OVER w as min 
      from forest.pulpmills m,network.place p 
      where ST_DWithin(m.centroid,p.centroid,15000)
window w as (partition by m.gid)) as f 
where distance=min
) as q 
where p.gid=q.gid;

END;