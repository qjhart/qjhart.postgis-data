drop schema zipcode cascade;
create schema zipcode;
set search_path=zipcode,public;

SET CLIENT_ENCODING TO UTF8;
SET STANDARD_CONFORMING_STRINGS TO ON;

CREATE TABLE zip5 (
gid serial primary key,
year integer not null,
zipcode varchar(5),
geoid varchar(10),
unique(year,zipcode),
unique(year,geoid)
);
SELECT AddGeometryColumn('zipcode','zip5','boundary',:srid,'MULTIPOLYGON',2);
CREATE INDEX "zip5_boundary_gist" ON zip5 USING GIST ("boundary");

