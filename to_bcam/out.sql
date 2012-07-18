drop schema to_bcam cascade;
create schema to_bcam;
set search_path=afri, cmz, cdl, national_atlas,public;

create or replace view to_bcam.ahb_county as select 
       * 
       from county, 
       	    afri_pbound 
	    where st_intersects(boundary,geom)
	    and state <> 'NV' and state <> 'UT' 
	    and st_area(st_intersection(boundary, geom))/st_area(boundary) > 0.5
;

comment on table to_bcam.ahb_county is
	'counties with greater than 50% of the land area the ahb study area (afri_pbound) and not in NV or UT'
;


create table to_bcam.crops_by_cmzxcty as select 
       	     ccid,
	     sum(pixel_fraction*8192^2*px_frac)* 0.000247105381 acres,
	     category						 
	     from cdl 
	     join cmz_cty_pxfrac using(pid) 
	     join cmz_cnty using(ccid) 
	     join cat using(cat_id)
	     group by ccid, category
	     order by ccid, category
;
comment on table to_bcam.crops_by_cmzxcty is
	'landcover/crop acres in each cmz X county intersected geometry'
;
 

--make the output table for mark
--copy (select state, name county, ccid,cmz, category,acres from to_bcam.crops_by_cmzxcty join cmz_cnty g using(ccid) join ahb_county using(fips) join cmz_pnw using(gid) where state <> 'NV' and state <> 'UT') to '/tmp/crops_ccid.csv' with csv header;

--- and the map
--copy (select ccid, state, name county, cmz, st_askml(c.geom) from cmz_cnty c join ahb_county using(fips) join cmz_pnw using(gid)) to '/tmp/ccid_map.csv' with csv header;

--Quinns fix:
-- select fips,
--        sum,
--        st_area(boundary)*0.000247105381 as area 
--        from (select fips,
--        	    	    sum(acres) as sum
-- 		    from (select category,
-- 		    	 	 fips,
-- 				 sum(pixel_fraction*8000^2*px_frac)*0.000247105381 as acres 
-- 				 from cdl 
-- 				 join cat using (cat_id) 
-- 				 join cmz_cty_pxfrac using (pid) 
--  				 join cmz_cnty using (ccid) 
-- 				 group by fips,
-- 				       	  category 
-- 				order by fips,
-- 				      	 category) as f 
