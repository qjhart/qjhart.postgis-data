\set ON_ERROR_STOP 1
\set pw_dis 5000
-- Create a table of distances
create temp table connect as 
select p.gid as p_gid,w.gid as w_gid,distance(p.centroid,w.centerline) 
from network.place p join refineries.terminals using (qid),network.waterway w
where st_dwithin(p.centroid,w.centerline,:pw_dis);

create temp table pw as
select f.p_gid,min(w_gid) as w_gid 
from connect f 
join (select p_gid,min(distance) as min 
        from connect group by p_gid) as min 
on (f.p_gid=min.p_gid and min.min=distance) 
group by f.p_gid order by p_gid;

-- Select the minimum version
drop table if exists refineries.terminal_waterway cascade;
create table refineries.terminal_waterway as

select p.gid as p_gid,w.gid as w_gid,
       case when (distance(startpoint(w.centerline),p.centroid)<
                  distance(endpoint(w.centerline),p.centroid)) 
            then startpoint(w.centerline) 
            else endpoint(w.centerline) 
       end as centroid
from refineries.terminals t join network.place p using (qid)
join  pw on (p.gid=p_gid) join 
network.waterway w on (w_gid=w.gid);

create index terminals_waterway_p_gid on refineries.terminal_waterway(p_gid);
create index terminals_waterway_w_gid on refineries.terminal_waterway(w_gid);



