BEGIN;
\set t epa_facility
\set s refineries
\set st refineries.epa_facility

set search_path=:s,public;

drop table if exists :st;

create table :st (
       gid serial primary key,
       program_system_acronym varchar(32),
       facility_name varchar(255),
       registry_id int8,
       sic_code int,
       city_name varchar(48),
       county_name varchar(32),
       state_code varchar(2),
       default_map_flag char(1),
       latitude float,
       longitude float,
       accuracy_value int,
       state_fips varchar(2),
       fips55 varchar(5)
);

COPY :st (program_system_acronym,facility_name,registry_id,sic_code,city_name,county_name,state_code,default_map_flag,latitude,longitude,accuracy_value) FROM 'epa_facility.csv' WITH DELIMITER AS ',' QUOTE AS '"' CSV HEADER;

select add_nad83('refineries','epa_facility','longitude','latitude');
select add_centroid('refineries','epa_facility');
select add_qid('refineries','epa_facility','state_code','city_name');

--select addGeometryColumn('refineries','epa_facility','nad83',4269,'POINT',2);
--select addGeometryColumn('refineries','epa_facility','centroid',102004,'POINT',2);
--CREATE INDEX "epa_facility_centroid_gist" ON :t using gist ("centroid" gist_geometry_ops);

--update :t set nad83=setsrid(MakePoint(longitude,latitude),4269);
--update :t set centroid=transform(nad83,102004);


END;
