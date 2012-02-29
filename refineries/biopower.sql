set search_path=refineries,public;

drop table if exists biopower;

create table biopower (
gid serial primary key,
plant text,
company text,
capacity float,
year integer,
fuel_type varchar(32),
city text,
state char(2),
latitude float,
longitude float,
status text);

\COPY biopower (plant,company,capacity,year,fuel_type,city,state,latitude,longitude,status) FROM 'us-biopower-facilities.csv' WITH DELIMITER AS ',' QUOTE AS '"' CSV HEADER

select bts.add_centroid_from_ll('refineries','biopower','longitude','latitude',:srid,:snap); 
select bts.add_and_find_qid('refineries.biopower','state','city');
