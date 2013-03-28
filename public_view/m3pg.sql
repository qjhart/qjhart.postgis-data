#drop schema public_view cascade;
#create schema public_view;
#grant usage on schema public_view to public;
set search_path=public_view,public;


create or replace function public_view.pointTo3pg(long float,lat float,size integer,
getname varchar default 'Irrigated')
RETURNS table(month varchar,
ASW float,CumIrrig float,Irrig float,
LAI float,Trans float,WF float,WR float,WS float)
AS $$
BEGIN
RETURN QUERY
with p as (select * from public_view.pointToPID(long,lat,size))
select 
unnest(d.dates) as month,
unnest(o.ASW) as ASW,
unnest(o.CumIrrig) as CumIrrig,
unnest(o.Irrig) as Irrig,
unnest(o.LAI) as LAI,
unnest(o.Trans) as Trans,
unnest(o.WF) as WF,
unnest(o.WR) as WR,
unnest(o.WS) as WS
from public_view.grass_3pg_output o 
join p using (pid),
public_view.grass_3pg_dates d
where name=getname;
END;
$$ LANGUAGE PLPGSQL;
grant EXECUTE on FUNCTION public_view.pointTo3pg(float,float,integer,varchar) TO PUBLIC;


