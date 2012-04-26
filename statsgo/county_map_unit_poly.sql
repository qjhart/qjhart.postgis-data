\set ON_ERROR_STOP 1
BEGIN;
set search_path=statsgo,public;
create table county_map_unit_poly (
       county_gid integer references network.county(county_gid),
       map_unit_poly_gid integer references statsgo.map_unit_poly(map_unit_poly_gid),
       mukey varchar(30)
);
select addgeometrycolumn('statsgo','county_map_unit_poly','boundary',102004,'MULTIPOLYGON',2);

insert into county_map_unit_poly (county_gid,map_unit_poly_gid,mukey,boundary)
select c.county_gid,m.map_unit_poly_gid,m.mukey,
       multi(intersection(c.boundary,m.boundary)) as boundary 
from network.county c, statsgo.map_unit_poly m 
where (c.boundary && m.boundary) 
and st_overlaps(c.boundary,m.boundary);

create index county_map_unit_poly_mukey on county_map_unit_poly(mukey);
create index county_map_unit_poly_county_gid on county_map_unit_poly(county_gid);

END;
