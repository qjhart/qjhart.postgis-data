Drop schema if exists cdl cascade;
create schema cdl;
set search_path=cdl,public;

create table cat (
cat_id integer primary key,
category text,
crop boolean
);

\COPY cat (cat_id,category,crop) from category.csv CSV HEADER

create table cdl(
pid integer,
east float,
north float,
pixel_fraction float,
cat_id integer);

create or replace view crops_by_pixel as 
 select pid,category,crop_pixel_fraction,
 crop_pixel_fraction*(8192^2)/10000 as crop_pixel_hectares
 from cdl 
 join cat using (cat_id) 
 where crop is true;

create or replace view crops_by_pixel as 
 select pid,category,crop_pixel_fraction,
 crop_pixel_fraction*(8192^2)/10000 as crop_pixel_hectares,
 sum(pixel_fraction) OVER (partition by pid) as total_crop_pixel_fraction 
 sum(pixel_fraction)*(8192^2)/10000  OVER (partition by pid) as total_crop_pixel_hectares
 from cdl 
 join cat using (cat_id) 
 where crop is true;

create or replace view cmz_total_hectares as
select cmz,sum(area(z.geom)/10000)::integer as cmz_hectares,
 sum(grid_count) as grids,sum(grid_area) as model_area,
 sum(foo.crop_hectares) as model_crop_area,
from
(select gid,sum(crop_hectares) as crop_hectares,
count(*) as grid_count,(count(*)*8192^2/10000)::integer as grid_area 
from (
 select pid,sum(amt*(8192^2)/10000)::decimal(6,2) as crop_hectares 
 from cdl 
 join cat using (cat_id) 
 where crop is true
 group by pid
 ) as c 
 join quinn.cmz_pixel_best p 
 using (pid)
 group by gid
) as foo 
join 
cmz.cmz_pnw z 
using (gid)
group by cmz
order by cmz;

create or replace view cmz_total_hectares as

select cmz,(area(z.geom)/10000)::integer as cmz_hectares,
 foo.crop_hectares,
from
(select gid,sum(hectares) as crop_hectares,
count(*) as grid_count,count(*)*8192^2/10000 as grid_area 
from (
 select pid,category,(amt*(8192^2)/10000)::decimal(6,2) as hectares 
 from cdl 
 join cat using (cat_id) 
 where crop is true
 group by pid
 ) as c 
 join quinn.cmz_pixel_best p 
 using (pid)
 group by gid
) as foo 
join 
cmz.cmz_pnw z 
using (gid)
order by gid;


