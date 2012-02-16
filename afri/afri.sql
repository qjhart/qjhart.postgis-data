drop schema afri cascade;
create schema afri;
set search_path=afri,public;

create table bounds (
bound_id serial primary key,
name varchar(32),
srid integer references public.spatial_ref_sys,
exp integer,
west integer,
south integer,
east integer,
north integer
);

create function bb (bounds)
returns geometry AS
$$ select setsrid(st_makebox2d(st_makepoint(west,south),
                  st_makepoint(east,north)),srid) from bounds;
$$ LANGUAGE SQL;

COPY bounds (bound_id,name,srid,exp,west,south,east,north)
FROM stdin WITH CSV HEADER;
bound_id,name,exp,east,south,west,north
1,afri,97260,1,-393216,-720896,524288,589824
\.


--select AddRasterColumn('prism','bounds','boundary',b.srid,'{1BB}',
--false,true,'{0}',4096,-4096, integer (b.east-b.west)/, 
--integer blocksize_y, bounds.bb);

create table raster_templates as 
select bound_id,name,s.s as size,
st_asRaster(b.bb,-1.0*s.s,1.0*s.s,'1BB') as rast 
from bounds b,
(select unnest(ARRAY[2^11,2^12,2^13,2^14,2^15,2^16]) as s) as s 
where bound_id=1;

create view pixel_bounds as 
select name,size,x,y,st_asKML(st_pixelAsPolygon(rast,x,y)) as pixel
from 
(select name,size,generate_series(1,st_width(r.rast)) as x
 from raster_templates r ) as x
join 
(select 
 name,size,generate_series(1,st_height(r.rast)) as y 
 from raster_templates r ) as y
using (name,size)
join raster_templates r 
using (name,size);

