drop schema to_bcam cascade;
create schema to_bcam;
set search_path=to_bcam,public;

create foreign table cdl_nass (
category text,
commodity text,
crop boolean ) 
SERVER file_fdw_server 
OPTIONS (format 'csv', header 'true', 
filename :cdl_nass_csv,
delimiter ',', null '');

create foreign table category_parms (
category text,
water float
)
SERVER file_fdw_server 
OPTIONS (format 'csv', header 'true', 
filename :category_parms_csv,
delimiter ',',quote '"',null '');

create temp table nass_of_interest as 
select c.cat_id,c.category,
s.commodity,s.parameter,s.year,
s.unit,replace(s.value,',','')::integer as value,
s.statefips||s.countycode as fips 
from cdl_nass cn
join cdl.cat c using (category) 
join nass.stats s using (commodity) 
where s.domain='TOTAL' 
and (s.parameter='PRODUCTION' or s.parameter like 'ACRES%') 
and s.value not in ('(D)','(Z)') 
and cn.crop is True
order by c.cat_id,fips,s.commodity,s.parameter,s.unit,s.year;

create temp table nass_row (
nass_id serial,
cat_id integer,
commodity text,
fips varchar(5),
year integer);

insert into nass_row (cat_id,commodity,fips,year) 
Select distinct cat_id,commodity,fips,year from nass_of_interest;

create temp table nass_production as 
select f.*,u.cat_id,u.unit from 
(select * from crosstab (
'select nass_id,fips,commodity,year,parameter,value 
 from nass_of_interest n join 
 nass_row using (commodity,fips,year) 
 order by 1,5',
'select distinct parameter 
 from nass_of_interest order by 1'
) AS (
nass_id integer,
fips varchar(5),
commodity text,
year integer,
acres integer,
acres_bearing integer,
acres_harvested integer,
acres_in_production integer,
acres_non_bearing integer,
acres_not_harvested integer,
production integer)) as f
left join 
(select nass_id,cat_id,
 string_agg(CASE WHEN (unit='') THEN 'NA' ELSE unit END,':') as unit
 from 
(select distinct nass_id,cat_id,unit 
 from nass_of_interest n 
 join nass_row 
 using (commodity,cat_id,fips,year) ) as r
 group by nass_id,cat_id
) as u
using (nass_id);

create temp view nass_county_cat_hectares as 
select fips,cat_id,year,
sum(coalesce(acres,acres_harvested,acres_bearing)*0.404686) as hectares
from nass_production 
group by fips,cat_id,year;

create temp view county_cat_commodity_fraction as 
select fips,cat_id,commodity,year,
(hectares/cat_hectares)::decimal(6,2) as fraction 
from (
select fips,cat_id,commodity,year,unit,
coalesce(acres,acres_harvested,acres_bearing)*0.404686 as hectares,
sum(coalesce(acres,acres_harvested,acres_bearing)*0.404686) OVER (partition by fips,cat_id,year) as cat_hectares,
production 
from nass_production 
order by year,cat_id,fips) as f;

create temp view cdl_county_cat_hectares as 
select fips,cat_id,sum(pixel_fraction*cp.fraction)*(8192^2)/10000 as hectares 
from cdl.cdl 
join m3pg.county_pixel_fraction_m cp 
Using (pid) 
group by fips,cat_id;

create temp view cdl_nass_county_cat_hectares as 
select cat_id,fips,year,n.hectares as nass,c.hectares as cdl 
from nass_county_cat_hectares n 
full outer join
cdl_county_cat_hectares c 
using (cat_id,fips) 
order by year,fips,cat_id;

create table to_bcam.pixel_county_cdl_fraction as 
select pid,fips,cat_id,cp.fraction*pixel_fraction/
sum(cp.fraction*pixel_fraction) OVER (Partition by fips,cat_id) as fraction
from m3pg.county_pixel_fraction_m cp
join cdl.cdl using (pid);

create table to_bcam.pixel_nass_production as 
select pid,na.state,fips,z.cmz,cc.ccid,commodity,year,
acres*fraction as acres,
acres_bearing*fraction as acres_bearing,
acres_harvested*fraction as acres_harvested,
acres_in_production*fraction as acre_in_production,
acres_non_bearing*fraction as acres_non_bearing,
acres_not_harvested*fraction as acres_not_harvested,
production*fraction as production,
unit from nass_production 
join pixel_county_cdl_fraction using (fips,cat_id)
join national_atlas.county na using (fips)
join m3pg.cmz_pixel_best_8km using (pid)
join cmz.cmz_cnty cc using (fips,gid)
join cmz.cmz_pnw z using (gid);

create table to_bcam.ccid_nass_production as 
select cc.ccid,fips,z.cmz,na.state,commodity,year,
acres,acres_bearing,acres_harvested,acres_in_production,
acres_non_bearing,acres_not_harvested,production
from 
(select ccid,commodity,year,unit,
sum(acres*fraction) as acres,
sum(acres_bearing*fraction) as acres_bearing,
sum(acres_harvested*fraction) as acres_harvested,
sum(acres_in_production*fraction) as acres_in_production,
sum(acres_non_bearing*fraction) as acres_non_bearing,
sum(acres_not_harvested*fraction) as acres_not_harvested,
sum(production*fraction) as production
from nass_production 
join pixel_county_cdl_fraction using (fips,cat_id)
join m3pg.cmz_pixel_best_8km using (pid)
join cmz.cmz_cnty using (fips,gid) -- Added GID 
group by ccid,commodity,year,unit) as cc
join cmz.cmz_cnty using (ccid)
join national_atlas.county na using (fips)
join cmz.cmz_pnw z using (gid);
