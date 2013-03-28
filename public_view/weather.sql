drop schema public_view cascade;
create schema public_view;
grant usage on schema public_view to public;
set search_path=public_view,public;

create or replace function public_view.pointToPID(geometry,size integer,
OUT east float,OUT north float,OUT x int,OUT y int,OUT pid int) 
as $$
BEGIN
with loc as 
(
select
st_x(p) as east,
st_y(p) as north,
((st_x(p) - b.west + t.size/2 ) / t.size)::integer as x,
((b.north + t.size/2 - st_y(p)) /  t.size)::integer as y,
t.size as size
from afri.raster_templates t 
join afri.bounds b using (bound_id),
st_transform(st_centroid($1),97260) as p
where t.size=$2
)
select into east,north,x,y,pid
loc.east,loc.north,loc.x,loc.y,p.pid
from loc join afri.pixels p using (x,y,size);
END;
$$ LANGUAGE PLPGSQL;
grant EXECUTE on FUNCTION public_view.pointToPID(geometry,integer) TO PUBLIC;

create or replace function public_view.pointToPID(long float,lat float,size integer,
OUT east float,OUT north float,OUT x int,OUT y int,OUT pid int) 
as $$
BEGIN
select into east,north,x,y,pid p.east,p.north,p.x,p.y,p.pid
from public_view.pointToPID(st_SetSRID(st_MakePoint($1,$2),4326),$3) p;
END;
$$ LANGUAGE PLPGSQL;
grant EXECUTE on FUNCTION public_view.pointToPID(float,float,integer) TO PUBLIC;

create or replace function public_view.pointToPrismAvgs(long float,lat float,size integer)
RETURNS table(month integer,tmin float,tmax float,tdmean float,ppt float)
AS $$
BEGIN
RETURN QUERY select a.month,
st_value(a.tmin,p.x,p.y)/100 as tmin,
st_value(a.tmax,p.x,p.y)/100 as tmax,
st_value(a.tdmean,p.x,p.y)/100 as tdmean,
st_value(a.ppt,p.x,p.y)/100 as ppt
from prism.avg a,
public_view.pointToPID(long,lat,size) p
where a.startyr=1994 and a.stopyr=2009;
END;
$$ LANGUAGE PLPGSQL;
grant EXECUTE on FUNCTION public_view.pointToPrismAvgs(float,float,integer) TO PUBLIC;

create table sun as 
select pid,month,(s.ghi*0.0036) as rad,daylight
from solar.ghi s
join m3pg.grass_daylight using (pid,month);
create index sun_pid_month on sun(pid,month);
grant select on public_view.sun to public;

create or replace function public_view.pointToWeather(long float,lat float,size integer)
RETURNS table(month integer,tmin float,tmax float,tdmean float,ppt float,rad float,daylight float)
AS $$
BEGIN
RETURN QUERY
with w as (select a.month,p.pid,
st_value(a.tmin,p.x,p.y)/100 as tmin,
st_value(a.tmax,p.x,p.y)/100 as tmax,
st_value(a.tdmean,p.x,p.y)/100 as tdmean,
st_value(a.ppt,p.x,p.y)/100 as ppt
from prism.avg a,
public_view.pointToPID(long,lat,size) p
where a.startyr=1994 and a.stopyr=2009)
select w.month,
w.tmin,w.tmax,w.tdmean,w.ppt,s.rad,s.daylight
from w left join public_view.sun s using (pid,month);
END;
$$ LANGUAGE PLPGSQL;
grant EXECUTE on FUNCTION public_view.pointToWeather(float,float,integer) TO PUBLIC;


