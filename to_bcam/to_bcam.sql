--drop schema to_bcam cascade;
--create schema to_bcam;
set search_path=to_bcam,public;

--\set cdl_nass_csv '''/home/quinn/qjhart.postgis-data/to_bcam/cdl_nass.csv''',

create foreign table cdl_nass (
category text,
commodity text,
crop boolean ) 
SERVER file_fdw_server 
OPTIONS (format 'csv', header 'true', 
filename :cdl_nass_csv,
delimiter ',',null '');

create temp table nass_of_interest as 
select c.cat_id,c.category,
s.commodity,s.parameter,s.year,
s.unit,replace(s.value,',','')::integer as value,
s.statefips||s.countycode as fips 
from cdl_nass 
join cdl.cat c using (category) 
join nass.stats s using (commodity) 
where s.domain='TOTAL' 
and (s.parameter='PRODUCTION' or s.parameter like 'ACRES%') 
and s.value not in ('(D)','(Z)') 
order by c.cat_id,fips,s.commodity,s.parameter,s.unit,s.year;

create temp table nass_row (
nass_id serial,
commodity text,
fips varchar(5),
year integer);

insert into nass_row (commodity,fips,year) 
select distinct commodity,fips,year from nass_of_interest;

select * from crosstab (
'select nass_id,fips,commodity,year,parameter,value 
 from nass_of_interest n join 
 nass_row using (commodity,fips,year) 
 order by 1,5',
'select distinct parameter 
 from nass_of_interest order by 1'
) AS (
nass_id integer,
fips varchar(5),
commodity text,
year integer,
acres integer,
acres_bearing integer,
acres_harvested integer,
acres_in_production integer,
acres_non_bearing integer,
acres_not_harvested integer,
production integer);
