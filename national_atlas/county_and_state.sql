set search_path=national_atlas,public;

drop table if exists county cascade;
create table county as 
select state_fips,fips,state,county as name 
from countyp020 limit 0;
alter table county add column county_gid serial primary key;

select AddGeometryColumn('national_atlas','county','boundary',
                         :srid,'MULTIPOLYGON',2);

insert into county (state_fips,fips,state,name,boundary) 
select state_fips,fips,state,county,collect(boundary) as boundary 
from countyp020 group by state_fips,fips,state,county;

select AddGeometryColumn('national_atlas','county','centroid',
                         :srid,'POINT',2); 
update county set centroid=st_centroid(boundary);

-- Rethinking qids
--alter table county add column qid varchar(32) unique;
--update county set centroid='S'||fips;

create index county_centroid on county(centroid);
create index county_centroid_gist on county using gist(centroid);
create index county_boundary_gist on county using gist(boundary);

-- Make a prettier States Layer
-- National Atlas States layer has multiple polys per state, and also
-- no abbreviations.

drop table if exists state cascade;
create table state as select state_fips,state,
 ''::varchar(2) as state_abbrev 
from statesp020 limit 0;

alter table state add column state_gid serial primary key;
select AddGeometryColumn('national_atlas','state','boundary',
                         :srid,'MULTIPOLYGON',2);

insert into state (state_fips,state,boundary) 
select state_fips,state,collect(boundary) as boundary 
from statesp020
group by state_fips,state;

-- Get Abbreviations from the county layer !!
update state n set state_abbrev=s.state 
from (select distinct state_fips,state from county) as s 
where s.state_fips=n.state_fips;
