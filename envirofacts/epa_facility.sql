BEGIN;

set search_path=envirofacts,public;

drop table if exists epa_facility;

create table epa_facility (
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

\COPY epa_facility (program_system_acronym,facility_name,registry_id,sic_code,city_name,county_name,state_code,default_map_flag,latitude,longitude,accuracy_value) FROM 'epa_facility.csv' WITH DELIMITER AS ',' QUOTE AS '"' CSV HEADER

select * from bts.add_centroid_from_ll('envirofacts','epa_facility','longitude','latitude',:srid,:snap);

-- This uses BTS places to locate EPA facilities.
select bts.add_and_find_qid('envirofacts.epa_facility','state_code','city_name');

END;
