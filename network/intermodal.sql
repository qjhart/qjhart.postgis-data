-- Some views that are required for intermodal facilities
-- Doces network.facility and network.Commodi need to be in place?


create or replace view network.road_rail_im as 
select distinct f.gid,f.name,f.mode_type,f.centroid 
from network.facility f 
join network.commodi c on (f.id=c.facility_i) 
where c.code in ('03','04','06','25','26','27') 
and f.mode_type like '%RAIL%' and f.mode_type like '%TRUCK%';

create or replace view network.road_waterway_im as 
select distinct f.gid,f.name,f.mode_type,f.centroid 
from network.facility f join network.commodi c on (f.id=c.facility_i) 
where c.code in ('03','04','06','25','26','27') 
and f.mode_type like '%PORT%' and f.mode_type like '%TRUCK%';

create or replace view network.fuel_ports as
select gid,centroid from network.ports where comm_cd1 in ('41','60','61') union select gid,centroid from network.ports where comm_cd2 in ('41','60','61') union select gid,centroid from network.ports where comm_cd3 in ('41','60','61') union select gid,centroid from network.ports where comm_cd4 in ('41','60','61');

