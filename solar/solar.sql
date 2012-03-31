drop schema solar cascade;
create schema solar;
set search_path=solar,public;

CREATE TABLE us (
       rid serial PRIMARY KEY,
       month integer
);

SELECT AddRasterColumn('solar','us','',4322, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

SELECT AddRasterColumn('prism','us','tmin',4322, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

SELECT AddRasterColumn('prism','us','ppt',4322, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

create function new_from_template(sch text,rst text,template raster,OUT ok text)
AS $$
BEGIN
EXECUTE 'DROP TABLE IF EXISTS '||sch||'.'||rst||' CASCADE';
EXECUTE 'CREATE TABLE '||sch||'.'||rst||' (rid serial PRIMARY KEY,year integer,month integer,unique(year,month))';

PERFORM AddRasterColumn(sch,rst,p,srid, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], scalex,scaley, null, null, null) 
from
(select (st_metadata(template)).*) as r, 
(select unnest(ARRAY['tmin','tmax','ppt']) as p) as a;
select into ok sch||'.'||rst||' created';
END;
$$ LANGUAGE PLPGSQL;

create or replace function us_to_template(us raster,template raster,sample_type text='Cubic',OUT new raster) 
AS $$
BEGIN
select into new ST_MapAlgebraExpr(ST_Resample(us,template,sample_type),template,'rast1');
END;
$$ LANGUAGE PLPGSQL;


--select new_from_template('prism','avg',default_rast());
--alter table avg rename year to start;
--alter table avg add column stop integer;

create function compute_2avg(OUT count integer)
as $$
BEGIN;
insert into avg (start,stop,month,tmin,tmax,ppt) 
select r1.year as start,r2.year as stop,r1.month,
ST_MapAlgebraExpr(r1.tmin,r2.tmin,'((rast1 + rast2)/2.0)::integer') as tmin,
ST_MapAlgebraExpr(r1.tmax,r2.tmax,'((rast1 + rast2)/2.0)::integer') as tmax,
ST_MapAlgebraExpr(r1.ppt,r2.ppt,'((rast1 + rast2)/2.0)::integer') as ppt
from pnw r1 join pnw r2 on (r1.year=r2.year-1 and r1.month=r2.month);
select into count count(*) from avg;
END;
$$ LANGUAGE plpgsql;

create function compute_4avg(OUT count integer)
as $$
BEGIN;
insert into avg (start,stop,month,tmin,tmax,ppt) 
select r1.start as start,r2.stop as stop,r1.month,
ST_MapAlgebraExpr(r1.tmin,r2.tmin,'((rast1 + rast2)/2.0)::integer') as tmin,
ST_MapAlgebraExpr(r1.tmax,r2.tmax,'((rast1 + rast2)/2.0)::integer') as tmax,
ST_MapAlgebraExpr(r1.ppt,r2.ppt,'((rast1 + rast2)/2.0)::integer') as ppt
from avg r1 join avg r2 on (r1.stop=r2.start and r1.month=r2.month);
select into count count(*) from avg;
END;
$$ LANGUAGE plpgsql;