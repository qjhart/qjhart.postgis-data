set search_path=envirofacts, public;

create or replace view envirofacts.pnw_target_frs as select 
       	  	       		      	 f.gid,
					 fac_name,
					 reg_id, 
					 loc_state,
					 loc_city,
					 naics_code, 
					 sic_code,
					 st_transform(f.the_geom, :srid) 0geom
					 from us_frs f 
					 join (select distinct reg_id,
					      	      	       naics_code 
						from epa_naics) as foo  using(reg_id) 
					join ic_xwalk e on (naics_code=naics::real) 
					where naics_code in (:codes);






