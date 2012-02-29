\set ON_ERROR_STOP 1
BEGIN;
set search_path=refineries,public;

-- drop table if exists ethanol;
-- create table ethanol (
--  gid serial primary key,
--  qid varchar(8),
--  start_year integer,
--  status varchar(32),
--  capacity float,
--  feedstock text
--  );

create table ethanol (
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
start varchar(32),
start_year integer
);

\COPY ethanol (lon,lat,company,address,city,state_abbrev,zipcode,website,feedstock,status,capacity,start) FROM 'refineries.ethanol.csv' WITH DELIMITER AS ',' QUOTE AS '"' CSV HEADER

select bts.add_centroid_from_ll('refineries','ethanol','lon','lat',:srid,:snap); 
select bts.add_and_find_qid('refineries.ethanol','state_abbrev','city');

update ethanol set start_year=substring(start from '[12]\\d\\d\\d')::integer;

--\echo The following states are not good
--select f.state_abbrev from ethanol f left join network.state s using(state) where s is null;

END;
