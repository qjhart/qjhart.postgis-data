drop schema prism cascade;
create schema prism;
set search_path=prism,public;

CREATE TABLE us (
       rid serial PRIMARY KEY,
       year integer,
       month integer,
       unique(year,month)
);

SELECT AddRasterColumn('prism','us','tmax',4322, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

SELECT AddRasterColumn('prism','us','tmin',4322, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

SELECT AddRasterColumn('prism','us','ppt',4322, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

SELECT AddRasterColumn('prism','us','tdmean',4322, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], 0.041666666670000, -0.041666666670000, 
       null, null, null);

-- Make static data, but need a default raster.
CREATE TABLE static (
 rid serial PRIMARY KEY,
 layer text unique
);

select AddRasterColumn('prism','static','rast',srid, ARRAY['32BSI'], 
       false, false, ARRAY[-9999.0], scalex,scaley, null, null, null)
from (select (st_metadata(default_rast())).*) as r;


create table climate (
       rid serial PRIMARY KEY,
       year integer,
       month integer,
       tmin raster,
       tmax raster,
       ppt  raster,
       tdmean raster,
       unique(year,month)
);

INSERT INTO climate (year,month,tmin,tmax,ppt,tdmean) 
values(0,0,
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI'),
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI'),
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI'),
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI')
);

update climate set 
tmin=st_setbandnodatavalue(tmin,-9999),
tmax=st_setbandnodatavalue(tmax,-9999),
tdmean=st_setbandnodatavalue(tdmean,-9999),
ppt=st_setbandnodatavalue(ppt,-9999);

select addrasterconstraints('climate',p) from 
(select unnest(ARRAY['tmin','tmax','ppt','tdmean']) as p) as a;

create table avg (
       rid serial PRIMARY KEY,
       startyr integer,
       stopyr integer,
       month integer,
       tmin raster,
       tmax raster,
       ppt  raster,
       tdmean raster,
       unique(startyr,stopyr,month)
);

INSERT INTO avg (startyr,stopyr,month,tmin,tmax,ppt,tdmean) 
values(0,0,0,
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI'),
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI'),
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI'),
ST_AddBand(ST_MakeEmptyRaster(default_rast()),'32BSI')
);

update avg set 
tmin=st_setbandnodatavalue(tmin,-9999),
tmax=st_setbandnodatavalue(tmax,-9999),
tdmean=st_setbandnodatavalue(tdmean,-9999),
ppt=st_setbandnodatavalue(ppt,-9999);

select addrasterconstraints('avg',p) from 
(select unnest(ARRAY['tmin','tmax','ppt','tdmean']) as p) as a;


create or replace function us_to_template(us raster,template raster,sample_type text='Cubic',OUT new raster) 
AS $$
BEGIN
select into new ST_MapAlgebraExpr(ST_Resample(us,template,sample_type),
template,'[rast1]');
END;
$$ LANGUAGE PLPGSQL;


create function create_avg(OUT boolean) 
as $$
select * from compute_2avg();
select * from compute_4avg(4);
select * from compute_4avg(8);
select * from compute_4avg(16);
select true;
$$ LANGUAGE SQL;


create function compute_2avg(OUT count integer)
as $$
BEGIN
insert into avg (startyr,stopyr,month,tmin,tmax,ppt,tdmean) 
select r1.year as startyr,r2.year as stopyr,r1.month,
ST_MapAlgebraExpr(r1.tmin,r2.tmin,'(([rast1]+[rast2])/2.0)::integer') as tmin,
ST_MapAlgebraExpr(r1.tmax,r2.tmax,'(([rast1]+[rast2])/2.0)::integer') as tmax,
ST_MapAlgebraExpr(r1.ppt,r2.ppt,'(([rast1]+[rast2])/2.0)::integer') as ppt,
ST_MapAlgebraExpr(r1.tdmean,r2.tdmean,'(([rast1]+[rast2])/2.0)::integer') 
  as tdmean
from climate r1 join climate r2 on (r1.year=r2.year-1 and r1.month=r2.month);
select into count count(*) from avg;
END;
$$ LANGUAGE plpgsql;

create or replace function compute_4avg(diff integer,OUT count integer)
as $$
BEGIN
--delete from avg where (1+stopyr-startyr)=diff;
insert into avg (startyr,stopyr,month,tmin,tmax,ppt,tdmean) 
select r1.startyr as startyr,r2.stopyr as stopyr,r1.month,
ST_MapAlgebraExpr(r1.tmin,r2.tmin,'(([rast1]+[rast2])/2.0)::integer') as tmin,
ST_MapAlgebraExpr(r1.tmax,r2.tmax,'(([rast1]+[rast2])/2.0)::integer') as tmax,
ST_MapAlgebraExpr(r1.ppt,r2.ppt,'(([rast1]+[rast2])/2.0)::integer') as ppt,
ST_MapAlgebraExpr(r1.tdmean,r2.tdmean,'(([rast1]+[rast2])/2.0)::integer') 
   as tdmean
from avg r1 join avg r2 on (r1.stopyr=r2.startyr-1 and r1.month=r2.month
and 1+r2.stopyr-r1.startyr=diff);
select into count count(*) from avg where 1+stopyr-startyr=diff;
END;
$$ LANGUAGE plpgsql;