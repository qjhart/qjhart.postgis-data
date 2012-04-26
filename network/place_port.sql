--- We don't move ports to cities anymore, so instead we look for
--- waterway connected cities that are close to a port that is okay
--- for fuel.
\set ON_ERROR_STOP 1
\set fp_distance 5000

-- Create a table of distances
create temp table connect as 
select p.gid as p_gid,port.gid as port_gid,distance(p.centroid,port.centroid) 
from network.place p,network.ports port
where st_dwithin(p.centroid,port.centroid,:fp_distance);

drop table if exists network.place_port cascade;
create table network.place_port as
select c.p_gid,min(port_gid) as port_gid 
from connect c join 
(select p_gid,min(distance) as min from connect group by p_gid) as min 
on (c.p_gid=min.p_gid and c.distance=min.min) 
group by c.p_gid;

create index place_port_p_gid on network.place_port(p_gid);
create index place_port_port_gid on network.place_port(port_gid);

create or replace view network.place_fuel_port as
select distinct p_gid,port_gid
from network.place_port c join network.ports p 
    on (c.port_gid=p.gid) 
where (comm_cd1 in ('20','21','22','23','29')        
    or comm_cd2 in ('20','21','22','23','29') 
    or comm_cd3 in ('20','21','22','23','29') 
    or comm_cd4 in ('20','21','22','23','29'));


