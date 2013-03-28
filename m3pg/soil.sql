set search_path=m3pg,statsgo,public;

create table m3pg.pixel_mukey as 
select pid,mukey,
sum(st_area(st_intersection(p.boundary,s.boundary)))/st_area(p.boundary) as fraction
from afri.pixels p 
join statsgo.map_unit_poly s 
on (st_intersects(p.boundary,s.boundary)) 
where p.size=8192 group by pid,mukey;

create or replace view m3pg.pixel_maxAWS as 
select pid,fs/tot as maxAWS from 
(
 select pid,sum(aws0100wta*fraction) as fs,
 sum(fraction) as tot
 from m3pg.pixel_mukey join statsgo.muaggatt 
 using (mukey) where aws0100wta is not null group by pid 
) as a;

create or replace view chorizon_class as 
select cokey,chkey,
 CASE WHEN ( hzdepb_r < 100 )
       THEN hzdepb_r - hzdept_r
       ELSE 100 - hzdept_r END as depth_cm,
   m3pg.soil_class((sandtotal_r,silttotal_r,claytotal_r)::m3pg.SaSiCl)
   as class
 from statsgo.chorizon
 where sandtotal_r+silttotal_r+claytotal_r=100
 and hzdept_r < 100 ;

create table chorizon_class_m as 
select c.* from chorizon_class c
join (
 select distinct cokey from pixel_mukey join comp using (mukey) 
) as p 
using (cokey);

create index chorizon_class_m_cokey on chorizon_class_m (cokey);

create or replace view chorizon_class_m_split as 
select cokey,chkey,class,
 depth_cm*1.0/count(*) OVER (partition by chkey) as depth_cm 
from (
 select cokey,chkey,depth_cm,
 regexp_split_to_table(class,E'\\s*,\\s*') as 
 class from chorizon_class_m) as f;


create or replace view comp_class as 
select cokey,class,class_depth::float/total_depth as fraction from 
(
 select cokey,class,sum(depth_cm) as class_depth from
 chorizon_class_m_split group by cokey,class 
) as cd
join 
(select cokey,sum(depth_cm) as total_depth from
chorizon_class_m_split group by cokey) as t
using (cokey);

create or replace view mapunit_class as 
select mukey,class,classpct/totpct as fraction
from 
(select mukey,class,sum(comppct_r*0.01*fraction) as classpct
from
comp c 
join comp_class cl 
using (cokey) 
group by mukey,class) as c
join 
(select mukey,sum(comppct_r*0.01) as totpct 
from (
 select distinct c.* from
 comp c 
 join comp_class cl 
 using (cokey)) as f 
group by mukey ) as tot
using (mukey);

create view mapunit_sw as 
select mukey,
 sum(fraction*swconst)::decimal(6,2) as swconst,
 sum(fraction*swpower)::decimal(6,2) as swpower 
from mapunit_class 
join m3pg.soil_class 
using (class) group by mukey;

create view pixel_sw as 
select pid,sum(swconst*fraction/tot)::decimal(6,2) as swconst,
 sum(swpower*fraction/tot)::decimal(6,2) as swpower 
from 
pixel_mukey 
join mapunit_sw using (mukey) 
join 
( 
 select pid,sum(fraction) as tot 
 from pixel_mukey 
 group by pid
) as f 
using (pid) 
group by pid;