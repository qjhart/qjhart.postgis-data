\set ON_ERROR_STOP 1
BEGIN;

set search_path=network,public;

-- This is an example query
-- select src,dest,sum(cost) from (select s.src,s.dest,(shortest_path('select * from edge'::text,s.src,s.dest,false,false)).cost from (select generate_series(138590,138595) as src,138696 as dest) as s) as paths group by src,dest;

-- Add in Roads (vertices,roads,cost)
-- Add in Railway (vertices,rail,cost)
-- Add in waterways (vertices,water,cost)
-- Add in IM facilities
-- Add in Feedstocks
--- Counties
--- MSW
-- Add in Proxy locations
--- Proxy cities

-- Sources are all feedstocks
--dests are potential locations

drop table if exists vertex cascade;
create table vertex (
       id serial primary key
);
SELECT AddGeometryColumn('network','vertex','point',102004,'POINT',2);
alter table vertex add  unique(point);
create index vertex_point_gist on network.vertex using gist(point gist_geometry_ops);

drop table if exists edge cascade;
create table edge (
       id serial primary key,
       type varchar(16),
       source integer references vertex(id),
       target integer references vertex(id),
       miles float,
       hours float,
       bale_cost float,
       liquid_cost float
);
SELECT AddGeometryColumn('network','edge','segment',102004,'LINESTRING',2);
create index edge_source on network.edge(source);
create index edge_target on network.edge(target);


-- Roads
insert into vertex (point) 
 select distinct startpoint(centerline) 
       from roads 
 union select distinct endpoint(centerline) 
       from roads;

drop table if exists road_edge;
create temp table road_edge as 
select s.id as source,d.id as target,
       n.link_type,
       makeline(startpoint(centerline),endpoint(centerline)) as segment,
       length(centerline)/1609.344 as miles,
       ( length(centerline) / 1609.344 ) / (case when (i.speed02 > 0) then i.speed02 else 25 end ) as hours02,
       length(centerline)/1609.344/ (case when (i.speed35 > 0 ) then i.speed35 else 25 end ) as hours35
  from roads n left join roads_info i using (id)
  join vertex s on (startpoint(centerline)=s.point) 
  join vertex d on (endpoint(centerline)=d.point);

insert into edge (type,source,target,segment,miles,hours,bale_cost,liquid_cost)
select 'road'::varchar(16) as type,source,target,segment,
       miles,
       hours02 as hours,
       inl.travel_cost('bale',c.fips,2010,miles,hours02) as bale_cost,
       inl.travel_cost('liquid',c.fips,2010,miles,hours02) as liquid_cost
from road_edge e join network.vertex v on (e.source=v.id) 
join network.county c on (ST_within(v.point,c.boundary));

-- Railway
insert into vertex (point) 
select centroid
from railwaynode;

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'rail' as type,
       s.id as source,d.id as target,
       makeline(startpoint(centerline),endpoint(centerline)) as segment,
       length(centerline)/1609.344 as miles,
       (inl.rail_cost('bale','00000',2010,length(centerline)/1609.344)).travel as bale_cost,
       (inl.rail_cost('liquid','00000',2010,length(centerline)/1609.344)).travel as liquid_cost       
  from railway r 
  join vertex s on (startpoint(centerline)=s.point) 
  join vertex d on (endpoint(centerline)=d.point);


-- Waterway
insert into vertex (point) 
 select distinct startpoint(centerline) 
       from waterway 
 union select distinct endpoint(centerline) 
       from waterway;

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'water' as type,
       s.id as source,d.id as target,
       makeline(startpoint(centerline),endpoint(centerline)) as segment,
       length(centerline)/1609.344 as miles,
       (inl.waterway_cost('bale','00000',2010,length(centerline)/1609.344)).travel as bale_cost,   
       (inl.waterway_cost('liquid','00000',2010,length(centerline)/1609.344)).travel as liquid_cost       
  from waterway r 
  join vertex s on (startpoint(centerline)=s.point) 
  join vertex d on (endpoint(centerline)=d.point);

-- -- Now Add in intermodal facilities

drop table if exists connect;
create temp table connect as 
select p.gid as p_gid,r_gid,p.centroid as im_loc,pr.centroid as ww_loc
from (select * from network.road_rail_im union select * from network.road_waterway_im) as p join network.facility_roads pr
on (p.gid=pr.p_gid);

insert into vertex (point) select distinct im_loc from connect;

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'road_im' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.loading_cost('bale',c.fips,2010)).unloading as bale_cost,
       (inl.loading_cost('liquid',c.fips,2010)).unloading as liquid_cost
  from 
  connect
  join vertex s on (im_loc=s.point) 
  join vertex d on (ww_loc=d.point)
  join network.county c on (ST_within(s.point,c.boundary));


-- Railways
drop table if exists connect;
create temp table connect as 
select p.gid as p_gid,r_gid,p.centroid as im_loc,pr.centroid as ww_loc
from network.road_rail_im p join network.facility_railwaynode pr
on (p.gid=pr.p_gid);

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'rail_im' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.rail_cost('bale','00000',2010,0)).loading as bale_cost,
       (inl.rail_cost('liquid','00000',2010,0)).loading as liquid_cost
  from connect c
  join vertex s on (im_loc=s.point) 
  join vertex d on (ww_loc=d.point);


-- Waterways
drop table if exists connect;
create temp table connect as 
select p.gid as p_gid,w_gid,p.centroid as im_loc,pr.centroid as ww_loc
from network.road_waterway_im p join network.facility_waterway pr
on (p.gid=pr.p_gid);

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'water_im' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.waterway_cost('bale','00000',2010,0)).loading as bale_cost,
       (inl.waterway_cost('liquid','00000',2010,0)).loading as liquid_cost
  from connect
  join vertex s on (im_loc=s.point) 
  join vertex d on (ww_loc=d.point);


-- Now we need to add the feedstock to the mix.
-- These are the counties,soy locations and the MSW locations

insert into vertex (point) select centroid from network.county;

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'county_feed' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.loading_cost('bale',c.fips,2010)).unloading as bale_cost,
       (inl.loading_cost('liquid',c.fips,2010)).unloading as liquid_cost
  from
  network.county c join network.county_roads cr using (county_gid)
  join vertex s on (c.centroid=s.point) 
  join vertex d on (cr.centroid=d.point);


-- epa seed oil facilities
insert into vertex (point) select distinct centroid from refineries.epa_facility where sic_code in (2075,2076);

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'seedoil_feed' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.loading_cost('bale',c.fips,2010)).loading as bale_cost,
       (inl.loading_cost('liquid',c.fips,2010)).loading as liquid_cost
  from
  refineries.epa_facility f
  join network.epa_facility_roads cr on (f.gid=cr.p_gid)
  join vertex s on (f.centroid=s.point) 
  join vertex d on (cr.centroid=d.point)
  join network.county c on (ST_within(s.point,c.boundary))
  where f.sic_code in (2075,2076);

insert into vertex (point) select centroid from msw.msw_by_city join network.place using (gid);

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'muni_feed' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.loading_cost('bale',c.fips,2010)).loading as bale_cost,
       (inl.loading_cost('liquid',c.fips,2010)).loading as liquid_cost
  from
  msw.msw_by_city m join network.place c using (gid)
  join network.place_roads cr on (c.gid=cr.p_gid)
  join vertex s on (c.centroid=s.point) 
  join vertex d on (cr.centroid=d.point);

-- Finnally, add in the proxy_locations;

insert into vertex (point) select p.centroid from refineries.m_proxy_location join network.place p using (gid) left join vertex v on (p.centroid=v.point) where v is null;

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'ref_road' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.loading_cost('bale',c.fips,2010)).unloading as bale_cost,
       (inl.loading_cost('liquid',c.fips,2010)).unloading as liquid_cost
  from
  refineries.m_proxy_location pr join network.place p using (gid)
  join network.place_roads cr on (pr.gid=cr.p_gid)
  join vertex s on (pr.centroid=s.point) 
  join vertex d on (cr.centroid=d.point)
  join network.county c on (ST_within(s.point,c.boundary));

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'ref_rail' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.rail_cost('bale','00000',2010,0)).unloading as bale_cost,
       (inl.rail_cost('liquid','00000',2010,0)).unloading as liquid_cost
  from
  refineries.m_proxy_location c join network.place using (gid)
  join network.place_railwaynode cr on (c.gid=cr.p_gid)
  join vertex s on (c.centroid=s.point) 
  join vertex d on (cr.centroid=d.point);

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'ref_water' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.waterway_cost('bale','00000',2010,0)).unloading as bale_cost,
       (inl.waterway_cost('liquid','00000',2010,0)).unloading as liquid_cost
  from
  refineries.m_proxy_location c join network.place using (gid)
  join network.place_waterway cr on (c.gid=cr.p_gid)
  join vertex s on (c.centroid=s.point) 
  join vertex d on (cr.centroid=d.point);

-- Add in connectors to the terminals.  These are not used for the
-- feedstocks, but are used for connecting product.
-- Add in cities not in already
insert into vertex (point) 
select distinct p.centroid
from refineries.terminals join network.place p using (qid) 
left join network.vertex v on (p.centroid=v.point) where v is null;

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'terminal_rail' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.rail_cost('bale','00000',2010,0)).unloading as bale_cost,
       (inl.rail_cost('liquid','00000',2010,0)).unloading as liquid_cost
  from
  refineries.terminals c join network.place p using (qid)
  join refineries.terminal_railwaynode cr on (p.gid=cr.p_gid)
  join vertex s on (p.centroid=s.point) 
  join vertex d on (cr.centroid=d.point);

insert into edge (type,source,target,segment,miles,bale_cost,liquid_cost)
select 'terminal_water' as type,
       s.id as source,d.id as target,
       makeline(s.point,d.point) as segment,
       length(makeline(s.point,d.point))/1609.344 as miles,
       (inl.waterway_cost('bale','00000',2010,0)).unloading as bale_cost,
       (inl.waterway_cost('liquid','00000',2010,0)).unloading as liquid_cost
  from
  refineries.terminals c join network.place p using (qid)
  join refineries.terminal_waterway cr on (p.gid=cr.p_gid)
  join vertex s on (p.centroid=s.point) 
  join vertex d on (cr.centroid=d.point);

-- Okay, and finally, the sources are all the feedstocks and the
-- destinations are the proxy_locations, but their road, rail, and
-- marine connections.
drop table if exists vertex_source;
create table vertex_source as 
select c.qid,'county'::varchar(12) as type,c.centroid as point from 
network.county c 
union
select p.qid,'msw',p.centroid from 
msw.msw_by_city join network.place p using (gid);

-- For liquid, sources are seedoil,msw feedstocks
drop table if exists liquid_vertex_source;
create table liquid_vertex_source as 
select p.qid,'msw' as type,p.centroid as point from 
msw.msw_by_city join network.place p using (gid)
union
select o.qid,o.type,e.centroid 
from feedstock.oils o join refineries.epa_facility e on (o.qid='SB'||e.gid);

-- Destinations
drop table if exists vertex_dest;
create table vertex_dest as
select p.qid,p.centroid as point from 
refineries.m_proxy_location p;

-- -- This way has several destinations for each based on arrival type.  Can be used with postgis routing.
-- create table vertex_per_dest as
-- select v.id,p.gid,p.qid,'road'::varchar(32) as type from 
-- refineries.m_proxy_location p
-- join vertex v on (centroid=v.point)
-- union
-- select v.id,p.gid,p.qid,'rail'::varchar(32) from 
-- refineries.m_proxy_location p 
-- join network.place_railwaynode x on (p.gid=x.p_gid)
-- join vertex v on (x.centroid=v.point)
-- union
-- select v.id,p.gid,p.qid,'water'::varchar(32) from 
-- refineries.m_proxy_location p 
-- join network.place_waterway x on (p.gid=x.p_gid)
-- join vertex v on (x.centroid=v.point);

-- create index vertex_per_dest_id on network.vertex_per_dest (id);
-- create index vertex_per_dest_type on network.vertex_per_dest (type);
END;