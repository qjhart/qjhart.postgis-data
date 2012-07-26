\set ON_ERROR_STOP 1
\set pw_dis 5000
-- Create a table of distances
create temp table connect as 
select p.gid as p_gid,r.gid as r_gid,distance(p.centroid,r.centerline) 
from network.place p,network.roads r
where st_dwithin(p.centroid,r.centerline,:pw_dis);

create temp table pw as
select f.p_gid,min(r_gid) as r_gid 
from connect f 
join (select p_gid,min(distance) as min 
        from connect group by p_gid) as min 
on (f.p_gid=min.p_gid and min.min=distance) 
group by f.p_gid order by p_gid;

-- Select the minimum version
drop table if exists network.place_roads cascade;
create table network.place_roads as
select p.gid as p_gid,r.gid as r_gid,
       case when (distance(startpoint(r.centerline),p.centroid)<
                  distance(endpoint(r.centerline),p.centroid)) 
            then startpoint(r.centerline) 
            else endpoint(r.centerline) 
       end as centroid
from network.place p join 
pw on (p.gid=p_gid) join 
network.roads r on (r_gid=r.gid);

create index place_road_p_gid on network.place_roads(p_gid);
create index place_road_r_gid on network.place_roads(r_gid);

