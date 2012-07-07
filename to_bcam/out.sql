drop schema to_bcam cascade;
create schema to_bcam;
set search_path=cmz, cdl, national_atlas,public;

create table to_bcam.crops_by_cmzxcty as select 
       	     ccid,
	     (pixel_fraction*px_frac)*st_area(geom)*0.000247105381 as acres,
	     category						 
	     from cdl 
	     join cmz_cty_pxfrac using(pid) 
	     join cmz_cnty using(ccid) 
	     join cat using(cat_id)
;
comment on table to_bcam.crops_by_cmzxcty is
	'landcover/crop acres in each cmz X county intersected geometry'
;

--make the output table for mark
--select state, name county, cmz, category,acres, st_askml(g.geom) from to_bcam.crops_by_cmzxcty join cmz_cnty g using(ccid) join county using(fips) join cmz_pnw using(gid) limit 10;

--- and the map
--select ccid, state, name county, cmz, st_askml(c.geom) from cmz_cnty c join county using(fips) join cmz_pnw using(gid)