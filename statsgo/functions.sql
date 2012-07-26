-- for field capacity depth in cm, but values are in %, so the
-- conversion to mm is *10/100
create or replace function comp_awc_via_horizon (depth float)
RETURNS TABLE (cokey varchar(30),awc_mm float,field_capacity_mm float)
as
$$
select cokey,
 sum(
 (CASE WHEN (hzdepb_r<$1)
       THEN hzdepb_r
       ELSE $1 END
   -hzdept_r)*10*awc_r) as awc_mm,
 sum(
 (CASE WHEN (hzdepb_r<$1)
       THEN hzdepb_r
       ELSE $1 END
   -hzdept_r)*10*
 (COALESCE((wtenthbar_r+wthirdbar_r)/2,
           wthirdbar_r,
	   wtenthbar_r)))/100 as field_capacity_mm
 from statsgo.chorizon
 where hzdept_r < $1 
 group by cokey;
$$ LANGUAGE SQL;


create or replace function mapunit_awc_via_horizon(depth float)
RETURNS TABLE (mukey varchar(30),awc_mm float,field_capacity_mm float)
as 
$$
select mukey,
sum(awc_mm*comppct_r)/sum(comppct_r) as awc_mm,
sum(field_capacity_mm*comppct_r)/sum(comppct_r) as field_capacity_mm
from comp join comp_awc($1) a using (cokey)
group by mukey;
$$ LANGUAGE SQL;

create or replace function chorizon_class (depth float)
RETURNS TABLE (chkey varchar(30), cokey varchar(30),depth float,class varchar(8))
as
$$
select cokey,chkey,
 CASE WHEN ( hzdepb_r < $1 )
       THEN hzdepb_r - hzdept_r
       ELSE $1 - hzdept_r END as depth_cm,
   statsgo.soil_class((sandtotal_r,silttotal_r,claytotal_r)::m3pg.SaSiCl) as class
 from statsgo.chorizon
 where sandtotal_r+silttotal_r+claytotal_r=100 and hzdept_r < $1 
$$ LANGUAGE SQL;
