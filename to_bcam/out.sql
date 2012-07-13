drop schema to_bcam cascade;
create schema to_bcam;
set search_path=cmz, cdl, national_atlas,public;

create table to_bcam.crops_by_cmzxcty as select 
       	     ccid,
	     sum(pixel_fraction*px_frac)*st_area(geom)*0.000247105381) acres,
	     category						 
	     from cdl 
	     join cmz_cty_pxfrac using(pid) 
	     join cmz_cnty using(ccid) 
	     join cat using(cat_id)
	     group by ccid, category
;
comment on table to_bcam.crops_by_cmzxcty is
	'landcover/crop acres in each cmz X county intersected geometry'
;

--make the output table for mark
--select state, name county, cmz, category,acres, s from to_bcam.crops_by_cmzxcty join cmz_cnty g using(ccid) join county using(fips) join cmz_pnw using(gid) limit 10;

--- and the map
--select ccid, state, name county, cmz, st_askml(c.geom) from cmz_cnty c join county using(fips) join cmz_pnw using(gid)

--Quinns fix:
---select fips,
--       sum,
--       st_area(boundary)*0.000247105381 as area 
--       from (select fips,
--       	    	    sum(acres) as sum-
--		    from (select category,
--		    	 	 fips,
--				 sum(pixel_fraction*8000^2*px_frac)*0.000247105381 as acres 
--				 from cdl join cat using (cat_id) join cmz_cty_pxfrac using (pid) join cmz_cnty using (ccid) group by fips,category order by fips,category) as f 