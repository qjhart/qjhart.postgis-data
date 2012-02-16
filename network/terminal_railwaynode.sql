\set pr_dis 5000
-- Create a table of distances
create temp table connect as 
select p.gid as p_gid,r.gid as r_gid,distance(p.centroid,r.centroid) 
from network.place p join refineries.terminals using (qid),network.railwaynode r 
where st_dwithin(p.centroid,r.centroid,:pr_dis) 
and r.onmainnet != 1;

-- Select the minimum version
drop table if exists refineries.terminal_railwaynode cascade;
create table refineries.terminal_railwaynode as
select p_gid,r_gid,r.centroid from 
(
 select f.p_gid,min(r_gid) as r_gid 
 from connect f 
 join (select p_gid,min(distance) as min 
        from connect group by p_gid) as min 
 on (f.p_gid=min.p_gid and min.min=distance) 
 group by f.p_gid order by p_gid ) as p join network.railwaynode r on (p.r_gid=r.gid);

create index terminal_railwaynode_p_gid on refineries.terminal_railwaynode(p_gid);
create index terminal_railwaynode_r_gid on refineries.terminal_railwaynode(r_gid);

