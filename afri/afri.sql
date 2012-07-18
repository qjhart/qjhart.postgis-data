drop schema afri cascade;
create schema afri;
set search_path=afri,public, national_altas;

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

--TODO raster_templates has 
create table raster_templates as 
select bound_id, sc.sc as scale_id, name,s.s as size,
st_asRaster(b.bb,-1.0*s.s,1.0*s.s,'1BB') as rast 
from bounds b,
(select unnest(ARRAY[2^11,2^12,2^13,2^14,2^15,2^16]) as s) as s ,
(select * from generate_series(0,5) as sc) as sc
where bound_id=1;

create view pixel_bounds as 
select name,size,x,y,st_pixelAsPolygon(rast,x,y) as boundary, 
            st_asKML(st_pixelAsPolygon(rast,x,y)) as kml
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

-- materialize one set of pixels
create table pixels_8km as 
select name,size,x,y
from pixel_bounds
where size=8192 limit 0;
select addGeometryColumn('afri','pixels_8km','boundary',:srid,'POLYGON',2);

insert into pixels_8km (name,size,x,y,boundary)
select name,size,x,y,boundary
from pixel_bounds
where size=8192;

create index pixels_8km_boundary_gist on pixels_8km using gist(boundary);

--create a simple project boundary

create or replace view afri.afri_pbound as 
       select st_setsrid(st_extent(boundary),97260) as geom 
       from pixels;
