\set ON_ERROR_STOP 1
\set pw_dis 50000
-- Create a table of distances
create temp table connect as 
select p.county_gid as county_gid,r.gid as r_gid,distance(p.centroid,r.centerline) 
from network.county p,network.roads r
where st_dwithin(p.centroid,r.centerline,:pw_dis);

create temp table pw as
select f.county_gid,min(r_gid) as r_gid 
from connect f 
join (select county_gid,min(distance) as min 
        from connect group by county_gid) as min 
on (f.county_gid=min.county_gid and min.min=distance) 
group by f.county_gid order by county_gid;

-- Select the minimum version
drop table if exists network.county_roads cascade;
create table network.county_roads as
select p.county_gid as county_gid,r.gid as r_gid,
       case when (distance(startpoint(r.centerline),p.centroid)<
                  distance(endpoint(r.centerline),p.centroid)) 
            then startpoint(r.centerline) 
            else endpoint(r.centerline) 
       end as centroid
from network.county p join 
pw using(county_gid) join 
network.roads r on (r_gid=r.gid);

create index county_road_county_gid on network.county_roads(county_gid);
create index county_road_r_gid on network.county_roads(r_gid);

