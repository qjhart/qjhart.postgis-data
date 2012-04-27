drop schema cmz cascade;
create schema cmz;
set search_path=cmz,public;

create table cmz.metadata(
       	     mid serial primary key,
	     t_name varchar(150),
	     meta xml
);

create table cmz.path(
       pid serial primary key,
       p_code varchar(8),
       p_desc varchar(24)
);

-- early attemps at creating the raster version
-- select st_setValue(rast) from (select st_band()