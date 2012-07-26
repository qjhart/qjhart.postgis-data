Drop schema if exists envirofacts cascade;
create schema envirofacts;
set search_path=envirofacts,public;


create table epa_naics(
       REG_ID varchar(64),
       PGM_SYS_ACRNM varchar(64),
       PGM_SYS_ID varchar(64),
       INTEREST_TYPE varchar(64),
       NAICS_CODE real,
       PRIMARY_INDICATOR varchar(64),
       CODE_DESCRIPTION varchar(128)
);

comment on table epa_naics is 'This table comes from the EPA state level combined Facility Reporting System (http://www.epa.gov/enviro/html/frs_demo/geospatial_data/geo_data_state_combined.html) and is intended to provide the NAICS codes for each FRS location'

