\set ON_ERROR_STOP 1
BEGIN;
set search_path=refineries,public;

drop table if exists ethanol_facility;
create table ethanol_facility (
 gid serial primary key,
 qid varchar(8),
 start_year integer,
 status varchar(32),
 capacity float,
 feedstock text
 );

create table foo (
gid serial primary key,
lon float,
lat float,
company varchar(255),
address text,
city varchar(255),
state_abbrev char(2),
zipcode varchar(12),
website text,
feedstock text,
status varchar(32),
capacity float,
start varchar(32)
);

COPY foo (lon,lat,company,address,city,state_abbrev,zipcode,website,feedstock,status,capacity,start) FROM 'ethanolfacility.csv' WITH DELIMITER AS ',' QUOTE AS '"'
 CSV HEADER;

alter table foo add qid varchar(8);
update foo set qid=p.qid 
from network.place p 
where (p.name=city and p.state=state_abbrev);

alter table foo add centroid geometry;
update foo set centroid=transform(setsrid(makepoint(lon,lat),4269),102004);

update foo set qid=e.qid 
from 
(select gid,qid from 
  (select f.gid,p.qid,distance(f.centroid,p.centroid),
         min(distance(f.centroid,p.centroid)) OVER (PARTITION BY f.gid) as min 
   from foo f,network.place p 
   where ST_DWithin(f.centroid,p.centroid,15000) and f.qid is Null
  ) as m where distance=min
) as e where e.gid=foo.gid;

insert into ethanol_facility (qid,start_year,status,capacity,feedstock) 
select qid,substring(start from '[12]\\d\\d\\d')::integer as start_year,
status,capacity,feedstock
from foo;

\echo The following states are not good
--select f.state from foo f left join network.state s using(state) where s is null;

END;
