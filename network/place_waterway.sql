\set pw_dis 5000
-- Create a table of distances
create temp table connect as 
select p.gid as p_gid,w.gid as w_gid,distance(p.centroid,w.centerline) 
from network.place p,network.waterway w
where st_dwithin(p.centroid,w.centerline,:pw_dis);

create temp table pw as
select f.p_gid,min(w_gid) as w_gid 
from connect f 
join (select p_gid,min(distance) as min 
        from connect group by p_gid) as min 
on (f.p_gid=min.p_gid and min.min=distance) 
group by f.p_gid order by p_gid;

-- Select the minimum version
drop table if exists network.place_waterway cascade;
create table network.place_waterway as

select p.gid as p_gid,w.gid as w_gid,
       case when (distance(startpoint(w.centerline),p.centroid)<
                  distance(endpoint(w.centerline),p.centroid)) 
            then startpoint(w.centerline) 
            else endpoint(w.centerline) 
       end as centroid
from network.place p join 
pw on (p.gid=p_gid) join 
network.waterway w on (w_gid=w.gid);

create index place_waterway_p_gid on network.place_waterway(p_gid);
create index place_waterway_w_gid on network.place_waterway(w_gid);

