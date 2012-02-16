\set ON_ERROR_STOP 1
BEGIN;
set search_path=refineries,public;

-- Refinery network is a subset of feedstock network.
create or replace view refineries.edge as 
select id,type,source,target,miles,0 as hours,
       0 as bale_cost,liquid_cost,segment
from network.edge where type in ('rail','water','ref_water','ref_rail','terminal_rail','terminal_water'); 

create or replace view refineries.vertex as 
select distinct v.* 
from network.vertex v join refineries.edge on(v.id=source or v.id=target);

-- Sources are now the proxy locations.
drop table if exists vertex_source;
create table vertex_source as
select p.qid,p.centroid from 
refineries.m_proxy_location p ;

drop table if exists vertex_dest;
create table vertex_dest as 
select p.qid,p.centroid from
refineries.terminals t join network.place p using (qid);

END;
