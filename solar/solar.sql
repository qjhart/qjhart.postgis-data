drop schema solar cascade;
create schema solar;
set search_path=solar,public;

create table solar.metadata(
       	     mid serial primary key,
	     t_name varchar(150),
	     meta xml
);

create table solar.pnw_solar(
       	     sid serial primary key,
	     pid integer references afri.pixels(pid),
	     ghi_name varchar(128),
	     ghi_wavg float,
	     rast raster
);