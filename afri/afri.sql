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
$$ select st_setsrid(st_makebox2d(st_makepoint(west,south),
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
--(select unnest(ARRAY[2^11,2^12,2^13,2^14,2^15,2^16]) as s) as s ,

create table raster_templates as 
select bound_id, sc.sc as scale_id, name,2^sc.sc as size,
st_asRaster(b.bb,-1.0*2^sc.sc,1.0*2^sc.sc,'1BB') as rast 
from bounds b,
(select * from generate_series(11,16) as sc) as sc
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
create table pixels as 
select name,size,x,y,
st_x(st_centroid(boundary)) as east,st_y(st_centroid(boundary)) as north
from pixel_bounds
limit 0;
alter table pixels add pid serial primary key;
select addGeometryColumn('afri','pixels','boundary',:srid,'POLYGON',2);

insert into pixels (name,size,x,y,east,north,boundary)
select name,size,x,y,
st_x(st_centroid(boundary)) as east,st_y(st_centroid(boundary)) as north,
boundary
from pixel_bounds;

create index pixels_boundary_gist on pixels using gist(boundary);

create view pixels_8km as 
select * from pixels where size=8192;

create or replace view afri.afri_pbound as 
       select st_setsrid(st_extent(boundary),97260) as geom 
       from pixels;
