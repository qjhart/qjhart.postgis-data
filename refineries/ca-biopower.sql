set search_path=refineries,public;

drop table if exists caBiopower;

create table caBiopower (
gid serial primary key,
status text,
"name" text,
city text,
county text,
state varchar(2),
longitude float,
latitude float,
ptype text,
MWgross float,
cogen text
);

truncate caBiower;

\COPY caBiopower (status,"name",city,county,longitude,latitude,ptype,MWgross,cogen) FROM STDIN WITH DELIMITER AS ',' QUOTE AS '"' CSV HEADER

update caBiopower set state='CA';
select bts.add_centroid_from_ll('refineries','cabiopower','longitude','latitude',:srid,:snap); 
select bts.add_and_find_qid('refineries.cabiopower','state','city');
