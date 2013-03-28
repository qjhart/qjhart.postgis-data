set search_path=solar,public;

create table nrel (
       rid serial primary key,
       layer text,
       rast raster
);

create table ghi (
       pid integer references afri.pixels,
       month integer,
       ghi float
);

create temp table ghi_fraction as 
select pid,gid,st_area(st_intersection(boundary, geom))/st_area(boundary) as fraction 
from solar.ghi_1deg_pnw join afri.pixels on (st_intersects(boundary, geom))
where size=8192;

with sum as (select pid,sum(fraction) from ghi_fraction group by pid order by sum asc) 
delete from ghi_fraction f using sum where f.pid=sum.pid and sum.sum < 1;

insert into ghi
select pid,01,sum(fraction*ghi01) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,02,sum(fraction*ghi02) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,03,sum(fraction*ghi03) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,04,sum(fraction*ghi04) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,05,sum(fraction*ghi05) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,06,sum(fraction*ghi06) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,07,sum(fraction*ghi07) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,08,sum(fraction*ghi08) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,09,sum(fraction*ghi09) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,10,sum(fraction*ghi10) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,11,sum(fraction*ghi11) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid
union
select pid,12,sum(fraction*ghi12) from
solar.ghi_1deg_pnw join ghi_fraction using(gid) group by pid;



--SELECT AddRasterConstraints('solar','nrel','rast',4269, ARRAY['32BSI'],      false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

insert into nrel (layer,rast) 
select month, 
st_addBand(st_makeEmptyRaster(cx,cy,nx,xy,0.1,0.1,0,0,4269),'32BSI') 
from (
 select *,((xx-nx)/0.1)::integer as cx,
 ((xy-ny)/0.1)::integer as cy 
 from ( 
  select max(lon) as xx,min(lon) as nx,max(lat) as xy,min(lat) as ny 
  from solar.us9805_dni
 ) as bounds
) as vals,
(select unnest(ARRAY['Jan','Feb','Mar','Apr',
 'May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Ann']) as month) 
as m;


select month,
st_addBand(st_makeEmptyRaster(),ARRAY['32BSI'])
from
(select (st_metadata(default_rast())).*) as r
cross join
(select unnest(ARRAY['Jan','Feb','Mar','Apr',
 'May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Ann']) as month) as m;
