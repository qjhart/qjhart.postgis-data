-- TMP Region is used to collect the polygons into multi-polygons.
set search_path=statsgo,public;

drop table if exists map_unit;

create table map_unit as 
select areasymbol,spatialver,musym,mukey
from map_unit_poly 
group by areasymbol,spatialver,musym,mukey 
limit 0;

SELECT AddGeometryColumn('statsgo','map_unit','boundary',:srid,'MULTIPOLYGON',2);

insert into map_unit (areasymbol,spatialver,musym,mukey,boundary )
select areasymbol,spatialver,musym,mukey,
st_multi(st_union(boundary)) as boundary 
from map_unit_poly 
group by areasymbol,spatialver,musym,mukey;

CREATE INDEX "map_unit_boundary_gist" ON "statsgo"."map_unit" using gist ("boundary");

