drop schema solar cascade;
create schema solar;
set search_path=solar,public;

create table solar.metadata(
       	     mid serial primary key,
	     t_name varchar(150),
	     meta xml
);
-- early attemps at creating the raster version
-- select st_setValue(rast) from (select st_band()