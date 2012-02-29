drop schema greenbk cascade;
create schema greenbk;
set search_path=greenbk,public;

SET CLIENT_ENCODING TO UTF8;
SET STANDARD_CONFORMING_STRINGS TO ON;

BEGIN;
CREATE TABLE "ozone_8hr_1997std_naa" (gid serial,
"area_name" varchar(45),
"composid" varchar(50));
ALTER TABLE "ozone_8hr_1997std_naa" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','ozone_8hr_1997std_naa','geom','4269','MULTIPOLYGON',2);
CREATE INDEX "ozone_8hr_1997std_naa_geom_gist" ON "ozone_8hr_1997std_naa" USING GIST ("geom");
COMMIT;

