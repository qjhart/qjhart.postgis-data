-- This creates the connectors to the EPA facilities if they exist
\set ON_ERROR_STOP 1
\set pw_dis 5000
-- Create a table of distances
drop table if exists connect;
create temp table connect as 
select p.gid as p_gid,r.gid as r_gid,distance(p.centroid,r.centerline) 
from refineries.epa_facility p,network.roads r
where st_dwithin(p.centroid,r.centerline,:pw_dis);

drop table if exists pw;
create temp table pw as
select f.p_gid,min(r_gid) as r_gid 
from connect f 
join (select p_gid,min(distance) as min 
        from connect group by p_gid) as min 
on (f.p_gid=min.p_gid and min.min=distance) 
group by f.p_gid order by p_gid;

-- Select the minimum version
drop table if exists network.epa_facility_roads cascade;
create table network.epa_facility_roads as
select p.gid as p_gid,r.gid as r_gid,
       case when (distance(startpoint(r.centerline),p.centroid)<
                  distance(endpoint(r.centerline),p.centroid)) 
            then startpoint(r.centerline) 
            else endpoint(r.centerline) 
       end as centroid
from refineries.epa_facility p join 
pw on (p.gid=p_gid) join 
network.roads r on (r_gid=r.gid);

create index epa_facility_road_p_gid on network.epa_facility_roads(p_gid);
create index epa_facility_road_r_gid on network.epa_facility_roads(r_gid);

\set pr_dis 5000
-- Create a table of distances
drop table if exists connect;
create temp table connect as 
select p.gid as p_gid,r.gid as r_gid,distance(p.centroid,r.centroid) 
from refineries.epa_facility p,network.railwaynode r 
where st_dwithin(p.centroid,r.centroid,:pr_dis) 
and r.onmainnet != 1;

-- Select the minimum version
drop table if exists network.epa_facility_railwaynode cascade;
create table network.epa_facility_railwaynode as
select p_gid,r_gid,r.centroid from 
(
 select f.p_gid,min(r_gid) as r_gid 
 from connect f 
 join (select p_gid,min(distance) as min 
        from connect group by p_gid) as min 
 on (f.p_gid=min.p_gid and min.min=distance) 
 group by f.p_gid order by p_gid ) as p join network.railwaynode r on (p.r_gid=r.gid);

create index epa_facility_railwaynode_p_gid on network.epa_facility_railwaynode(p_gid);
create index epa_facility_railwaynode_r_gid on network.epa_facility_railwaynode(r_gid);

\set pw_dis 5000
-- Create a table of distances
drop table if exists connect;
create temp table connect as 
select p.gid as p_gid,w.gid as w_gid,distance(p.centroid,w.centerline) 
from refineries.epa_facility p,network.waterway w
where st_dwithin(p.centroid,w.centerline,:pw_dis);

drop table if exists pw;
create temp table pw as
select f.p_gid,min(w_gid) as w_gid 
from connect f 
join (select p_gid,min(distance) as min 
        from connect group by p_gid) as min 
on (f.p_gid=min.p_gid and min.min=distance) 
group by f.p_gid order by p_gid;

-- Select the minimum version
drop table if exists network.epa_facility_waterway cascade;
create table network.epa_facility_waterway as

select p.gid as p_gid,w.gid as w_gid,
       case when (distance(startpoint(w.centerline),p.centroid)<
                  distance(endpoint(w.centerline),p.centroid)) 
            then startpoint(w.centerline) 
            else endpoint(w.centerline) 
       end as centroid
from refineries.epa_facility p join 
pw on (p.gid=p_gid) join 
network.waterway w on (w_gid=w.gid);

create index epa_facility_waterway_p_gid on network.epa_facility_waterway(p_gid);
create index epa_facility_waterway_w_gid on network.epa_facility_waterway(w_gid);



