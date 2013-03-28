set search_path=public_view,public;

create table soil as 
select pid,maxaws,swconst,swpower from 
m3pg.pixel_maxaws join m3pg.pixel_sw using (pid);
create index soil_pid on soil(pid);
grant select on soil to public;


create or replace function public_view.pointToSoil(long float,lat float,size integer)
RETURNS table (maxaws float,swpower numeric(6,2),swconst numeric(6,2))
AS $$
BEGIN
RETURN QUERY
select 
s.maxaws,s.swpower,s.swconst from public_view.pointToPID(long,lat,size) p 
join public_view.soil s using (pid);
END;
$$ LANGUAGE PLPGSQL;
grant EXECUTE on FUNCTION public_view.pointToSoil(float,float,integer) TO PUBLIC;
