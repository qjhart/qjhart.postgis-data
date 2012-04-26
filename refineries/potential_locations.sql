set search_path=refineries,public;

-- No national sewage data yet.
-- create or replace view sewage_location as 
-- select qid, True as sewage 
-- from city_parameters p  where p.parameter='sewage';

create or replace view refineries.has_populated as 
select distinct qid, True as populated
from bts.place cx where cx.pop_2000>10000 and cx.pop_2000 < 100000;

create or replace view refineries.urban as 
select distinct qid, True as urban
from bts.place cx where cx.pop_2000 > 100000;

create or replace VIEW refineries.has_railway as 
select distinct qid, True as railway 
from bts.place c join bts.rail_nodes r  
using (qid);

-- Fuel port is currently removed from consideration
--create or replace VIEW refineries.has_fuel_port as
--select gid,qid,True as fuel_port 
--from bts.place p join bts.place_fuel_port fp on (p.gid=fp.p_gid);

--create or replace VIEW refineries.has_connected as
--select qid,fuel_port as connected
--from has_fuel_port
--union 
--select qid,railway as connected 
--from has_railway;

create or replace view refineries.has_epa as 
select distinct qid, True as epa
from envirofacts.epa_facility;

create or replace view refineries.has_mill as 
select distinct qid, True as mill
from forest.mills;

create or replace view refineries.has_biopower as 
select distinct qid, True as biopower
from refineries.biopower where state!='CA'
union
select distinct qid, True as biopower
from refineries.caBiopower;

create or replace view refineries.has_terminal as 
select distinct qid, True as terminal
from refineries.terminals;

create or replace view refineries.has_ethanol as 
select distinct qid, True as ethanol
from refineries.ethanol;

create or replace VIEW refineries.has_similar as
select qid,epa as similar
from refineries.has_epa
union
select qid,mill as similar
from refineries.has_mill
union 
select qid,biopower as similar
from refineries.has_biopower
union
select qid,ethanol as similar
from refineries.has_ethanol
union
select qid,terminal as similar
from refineries.has_terminal;

create or replace VIEW refineries.in_ozone as 
select distinct qid,TRUE as in_ozone
from bts.place p 
join greenbk.ozone o 
on st_intersects(p.centroid,o.boundary) where o is not null;

create or replace VIEW refineries.in_pm25 as 
select distinct qid,TRUE as in_pm25 
from bts.place p 
join greenbk.pm25 o 
on st_intersects(p.centroid,o.boundary) where o is not null;


-- Potential locations is pretty simple.  It's just any location has
-- is connected and is either populated enough, or has an existing
-- epa_facility, ethanol plant, or biopower facility.  Since none of
-- the facilities are cellulosic, we are probably okay to ignore
-- competition?

create or replace view refineries.candidate_location as 
select f.qid,
coalesce(f.populated,false) as populated,
coalesce(f.terminal,false) as terminal,
coalesce(f.epa,false) as epa,
coalesce(f.biopower,false) as biopower,
coalesce(f.ethanol,false) as ethanol,
coalesce(r.railway,false) as railway,
coalesce(o.in_ozone,false) as o3,
coalesce(p.in_pm25,false) as pm25,
-- Calculate Score
(case when (f.populated is true) then 10 else 0 end +
case when (f.terminal is true)  then 10 else 0 end +
case when (f.epa is true)  then 20 else 0 end +
case when (f.biopower is true)  then 30 else 0 end +
case when (f.ethanol is true)  then 30 else 0 end +
case when (r.railway is true)  then 20 else 0 end +
case when (o.in_ozone is true)  then -100 else 0 end +
case when (p.in_pm25 is true)  then -100 else 0 end )::int as score
from
( select qid,populated,terminal,epa,biopower,ethanol 
from  has_populated 
full outer join has_terminal using (qid)
full outer join has_epa using (qid)
full outer join has_biopower using (qid)
full outer join has_ethanol using (qid) ) as f 
left join urban u using (qid) 
left join has_railway r using (qid)
left join in_ozone o using(qid)
left join in_pm25 p using(qid)
where urban is not true;

-- This is very AFRI project dependant.

drop table if exists potential_location;
create table potential_location
as select p.*,false as is_proxy,
p.qid as proxy,
0::int as proxy_score, 
0::int as proxy_distance,
c.centroid
from bts.place c join candidate_location p using (qid)
join
( select st_setsrid(st_makebox2d(st_makepoint(west,south),
                                 st_makepoint(east,north)),srid) as boundary
 from afri.bounds) as b
on ( st_within(c.centroid,b.boundary) ) ;

alter table potential_location
add constraint potential_location_pk primary key(gid);

create index potential_location_centroid_gist
  on potential_location using gist(centroid);
create index potential_location_centroid on potential_location(centroid);
create index potential_location_qid on potential_location(qid);

update potential_location m 
set proxy=x.p2,proxy_score=x.score,proxy_distance=x.distance 
from 
( select p1,p2,min(p2) OVER (partition by p1) as min,score,distance::int
  from 
  ( select p1.qid as p1,p2.qid as p2,p2.score,
      max(p2.score) OVER (partition by p1.qid) as max,
      st_distance(p1.centroid,p2.centroid) as distance 
    from potential_location p1 
    join potential_location p2 
    on ( (p1=p2) or st_dwithin(p1.centroid,p2.centroid,20000) ) 
    where p1.score <= p2.score 
  ) as w 
  where score=max 
) as x where x.p2=x.min and m.qid=x.p1;

update potential_location m set is_proxy=true 
from (select distinct proxy from potential_location ) as p 
where m.qid=p.proxy;
