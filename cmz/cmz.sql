drop schema cmz cascade;
create schema cmz;
set search_path=cmz,national_atlas,public;

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

create table cmz.cmz_cnty as select 
       	     b.state_fips,
	     b.fips, 
       	     c.gid,
       	     st_intersection(b.boundary, c.geom) as geom
       from county b, cmz_pnw c 
       where st_intersects(c.geom, b.boundary) 
;
alter table cmz.cmz_cnty
      add ccid serial primary key
;

comment on table cmz.cmz_cnty is
	'spatial intersection between county and cmz polygons'
;

create table cmz.cmz_cty_pxfrac as select
       	     pid,
	     ccid,	      
	     st_area(st_intersection(boundary,geom))/st_area(boundary) as px_frac
	from  
	     	   cmz_cnty,
		   pixels  
	where st_intersects(boundary,geom) and size=8192
;
comment on table cmz.cmz_cty_pxfrac is
	'fraction of pixel contained in each intersected county/cmz geometry (cmz_cnty)'
;
