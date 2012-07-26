set search_path=envirofacts;

create or replace view pnw_target_frs as select 
       	  	       		      	 f.gid,
					 fac_name,
					 reg_id, 
					 loc_state,
					 loc_city,
					 naics_code, 
					 sic_code,
					 f.the_geom
					 from us_frs f 
					 join (select distinct reg_id,
					      	      	       naics_code 
						from epa_naics) as foo  using(reg_id) 
					join ic_xwalk e on (naics_code=naics::real) 
					where sic_code in (:codes)

--(2011,2015,2041,2046,2062,2063,2074,2075,2076,2079,2421,2429,2431,2611,2631,2911,4221,5171,5159,8731)