set search_path=bcam,public;

create foreign table cmz34 (
ccid integer,
poplar_price float,
profit float,
alfalfa float,
barley float,
dry_beans float,
corn float,
cotton float,
grass_hay float,
melons float,
oats_and_corn float,
oats float,
rice float,
rye float,
safflower float,
tomato float,
triticale float,
wheat float,
wheat_and_corn float,
poplar float
)
SERVER file_fdw_server 
OPTIONS (format 'csv', header 'true', 
filename :cmz34_csv,
delimiter ',',null '');



create temp table cmz34_initial as 
select ccid,
alfalfa,
barley,
dry_beans,
corn,
cotton,
grass_hay,
melons,
oats_and_corn,
oats,
rice,
rye,
safflower,
tomato,
triticale,
wheat,
wheat_and_corn,
poplar
from cmz34 
where profit=0;

create temp view cmz34_fractional as 
select ccid,poplar_price,profit,
1-(coalesce(c.alfalfa,0)/i.alfalfa) as alfalfa,
1-(coalesce(c.barley,0)/i.barley) as barley,
1-(coalesce(c.dry_beans,0)/i.dry_beans) as dry_beans,
1-(coalesce(c.corn,0)/i.corn) as corn,
1-(coalesce(c.cotton,0)/i.cotton) as cotton,
1-(coalesce(c.grass_hay,0)/i.grass_hay) as grass_hay,
1-(coalesce(c.melons,0)/i.melons) as melons,
1-(coalesce(c.oats_and_corn,0)/i.oats_and_corn) as oats_and_corn,
1-(coalesce(c.oats,0)/i.oats) as oats,
1-(coalesce(c.rice,0)/i.rice) as rice,
1-(coalesce(c.rye,0)/i.rye) as rye,
1-(coalesce(c.safflower,0)/i.safflower) as safflower,
1-(coalesce(c.tomato,0)/i.tomato) as tomato,
1-(coalesce(c.triticale,0)/i.triticale) as triticale,
1-(coalesce(c.wheat,0)/i.wheat) as wheat,
1-(coalesce(c.wheat_and_corn,0)/i.wheat_and_corn) as wheat_and_corn,
c.poplar
from cmz34 c 
join cmz34_initial i using (ccid);

create or replace temp view cmz34_agg as 
select ccid,poplar_price::decimal(6,2),profit::decimal(6,2),
coalesce(c.alfalfa*i.alfalfa,0)+
coalesce(c.barley*i.barley,0)+
coalesce(c.dry_beans*i.dry_beans,0)+
coalesce(c.corn*i.corn,0)+
coalesce(c.cotton*i.cotton,0)+
coalesce(c.grass_hay*i.grass_hay,0)+
coalesce(c.melons*i.melons,0)+
coalesce(c.oats_and_corn*i.oats_and_corn,0)+
coalesce(c.oats*i.oats,0)+
coalesce(c.rice*i.rice,0)+
coalesce(c.rye*i.rye,0)+
coalesce(c.safflower*i.safflower,0)+
coalesce(c.tomato*i.tomato,0)+
coalesce(c.triticale*i.triticale,0)+
coalesce(c.wheat*i.wheat,0)+
coalesce(c.wheat_and_corn*i.wheat_and_corn,0) as farm_acres_lost,
c.poplar
from cmz34_fractional c 
join cmz34_initial i using (ccid);

create temp table cmz34_marginal as 
select c.ccid,c.poplar_price,c.profit::decimal(6,3),
((cp.alfalfa-coalesce(c.alfalfa,0))/i.alfalfa)::decimal(6,3) as alfalfa,
((cp.barley-coalesce(c.barley,0))/i.barley)::decimal(6,3) as barley,
((cp.dry_beans-coalesce(c.dry_beans,0))/i.dry_beans)::decimal(6,3) as dry_beans,
((cp.corn-coalesce(c.corn,0))/i.corn)::decimal(6,3) as corn,
((cp.cotton-coalesce(c.cotton,0))/i.cotton)::decimal(6,3) as cotton,
((cp.grass_hay-coalesce(c.grass_hay,0))/i.grass_hay)::decimal(6,3) as grass_hay,
((cp.melons-coalesce(c.melons,0))/i.melons)::decimal(6,3) as melons,
((cp.oats_and_corn-coalesce(c.oats_and_corn,0))/i.oats_and_corn)::decimal(6,3) as oats_and_corn,
((cp.oats-coalesce(c.oats,0))/i.oats)::decimal(6,3) as oats,
((cp.rice-coalesce(c.rice,0))/i.rice)::decimal(6,3) as rice,
((cp.rye-coalesce(c.rye,0))/i.rye)::decimal(6,3) as rye,
((cp.safflower-coalesce(c.safflower,0))/i.safflower)::decimal(6,3) as safflower,
((cp.tomato-coalesce(c.tomato,0))/i.tomato)::decimal(6,3) as tomato,
((cp.triticale-coalesce(c.triticale,0))/i.triticale)::decimal(6,3) as triticale,
((cp.wheat-coalesce(c.wheat,0))/i.wheat)::decimal(6,3) as wheat,
((cp.wheat_and_corn-coalesce(c.wheat_and_corn,0))/i.wheat_and_corn)::decimal(6,3) as wheat_and_corn,
c.poplar
from cmz34 c
join cmz34 cp on (c.ccid=cp.ccid 
 and (cp.poplar_price*10)::integer=(c.poplar_price*10)::integer-1)
join cmz34_initial i on (c.ccid=i.ccid);

create or replace temp view cmz34_i as 
select ccid,'Alfalfa' as category,
alfalfa as acres from cmz34_initial 
where alfalfa is not null 
union select ccid,'Barley',barley from cmz34_initial 
where barley is not null 
union select ccid,'Dry Beans',dry_beans from cmz34_initial 
where dry_beans is not null 
union select ccid,'Corn',corn from cmz34_initial 
where corn is not null 
union select ccid,'Cotton',cotton from cmz34_initial 
where cotton is not null 
union select ccid,'Other Hay/Non Alfalfa',grass_hay from cmz34_initial
where grass_hay is not null 
union select ccid,'Watermelons',melons from cmz34_initial
where melons is not null 
union select ccid,'Dbl Crop Oats/Corn',oats_and_corn from cmz34_initial
where oats_and_corn is not null 
union select ccid,'Oats',oats from cmz34_initial
where oats is not null 
union select ccid,'Rice',rice from cmz34_initial
where rice is not null 
union select ccid,'Rye',rye from cmz34_initial
where rye is not null 
union select ccid,'Safflower',safflower from cmz34_initial
where safflower is not null 
union select ccid,'Tomato',tomato from cmz34_initial
where tomato is not null 
union select ccid,'Triticale',triticale from cmz34_initial
where triticale is not null 
union select ccid,'Winter Wheat',wheat from cmz34_initial
where wheat is not null 
union select ccid,'Dbl Crop WinWht/Corn',wheat_and_corn from cmz34_initial
where wheat_and_corn is not null ;

create or replace temp view cmz34_f as 
select ccid,poplar_price::decimal(6,2),'Alfalfa' as category,
alfalfa as fraction from cmz34_fractional 
where alfalfa is not null 
union select ccid,poplar_price,'Barley',barley from cmz34_fractional 
where barley is not null 
union select ccid,poplar_price,'Dry Beans',dry_beans from cmz34_fractional 
where dry_beans is not null 
union select ccid,poplar_price,'Corn',corn from cmz34_fractional 
where corn is not null 
union select ccid,poplar_price,'Cotton',cotton from cmz34_fractional 
where cotton is not null 
union select ccid,poplar_price,'Other Hay/Non Alfalfa',grass_hay from cmz34_fractional
where grass_hay is not null 
union select ccid,poplar_price,'Watermelons',melons from cmz34_fractional
where melons is not null 
union select ccid,poplar_price,'Dbl Crop Oats/Corn',oats_and_corn 
from cmz34_fractional where oats_and_corn is not null 
union select ccid,poplar_price,'Oats',oats from cmz34_fractional
where oats is not null 
union select ccid,poplar_price,'Rice',rice from cmz34_fractional
where rice is not null 
union select ccid,poplar_price,'Rye',rye from cmz34_fractional
where rye is not null 
union select ccid,poplar_price,'Safflower',safflower from cmz34_fractional
where safflower is not null 
union select ccid,poplar_price,'Tomato',tomato from cmz34_fractional
where tomato is not null 
union select ccid,poplar_price,'Triticale',triticale from cmz34_fractional
where triticale is not null 
union select ccid,poplar_price,'Winter Wheat',wheat from cmz34_fractional
where wheat is not null 
union select ccid,poplar_price,'Dbl Crop WinWht/Corn',wheat_and_corn 
from cmz34_fractional where wheat_and_corn is not null ;

create or replace temp view cmz34_m as 
select ccid,poplar_price,profit,'Alfalfa' as category,
alfalfa as marginal_fraction from cmz34_marginal 
where alfalfa is not null 
union select ccid,poplar_price,profit,'Barley',barley from cmz34_marginal
where barley is not null
union select ccid,poplar_price,profit,'Dry Beans',dry_beans from cmz34_marginal
where dry_beans is not null
union select ccid,poplar_price,profit,'Corn',corn from cmz34_marginal
where corn is not null
union select ccid,poplar_price,profit,'Cotton',cotton from cmz34_marginal
where cotton is not null
union select ccid,poplar_price,profit,'Other Hay/Non Alfalfa',grass_hay from cmz34_marginal
where grass_hay is not null
union select ccid,poplar_price,profit,'Watermelons',melons 
from cmz34_marginal where melons is not null
union select ccid,poplar_price,profit,'Dbl Crop Oats/Corn',oats_and_corn 
from cmz34_marginal where oats_and_corn is not null
union select ccid,poplar_price,profit,'Oats',oats from cmz34_marginal
where oats is not null
union select ccid,poplar_price,profit,'Rice',rice from cmz34_marginal
where rice is not null
union select ccid,poplar_price,profit,'Rye',rye from cmz34_marginal
where rye is not null
union select ccid,poplar_price,profit,'Safflower',safflower from cmz34_marginal
where safflower is not null
union select ccid,poplar_price,profit,'Tomato',tomato from cmz34_marginal
where tomato is not null
union select ccid,poplar_price,profit,'Triticale',triticale from cmz34_marginal
where triticale is not null
union select ccid,poplar_price,profit,'Winter Wheat',wheat from cmz34_marginal
where wheat is not null
union select ccid,poplar_price,profit,'Dbl Crop WinWht/Corn',wheat_and_corn 
from cmz34_marginal where wheat_and_corn is not null;

create or replace temp view cmz34_marginal_acres_feet as select 
ccid,poplar_price::decimal(6,2),
sum(marginal_fraction*acres*water) as marginal_acre_feet 
from cmz34_i join cmz34_m using (ccid,category) 
join category_parms using (category) 
where marginal_fraction > 0 
group by ccid,poplar_price 
order by ccid,poplar_price;

create or replace temp view cmz34_acres_feet as
select c.ccid,c.poplar_price,c.marginal_acre_feet,
sum(p.marginal_acre_feet) as acre_feet 
from cmz34_marginal_acres_feet c 
join cmz34_marginal_acres_feet p 
on (c.ccid=p.ccid and c.poplar_price >= p.poplar_price) 
group by c.ccid,c.poplar_price,c.marginal_acre_feet 
order by c.ccid,c.poplar_price,c.marginal_acre_feet;

-- create temp view cmz34_aggregation as
-- select c.ccid,c.poplar_price,c.farm_acres_lost,c.poplar,
-- sum(p.farm_acres_lost) as total_farm_acres_lost,
-- sum(p.poplar) as total_poplar
-- from cmz34_agg c 
-- join cmz34_agg p 
-- on (c.ccid=p.ccid and c.poplar_price >= p.poplar_price) 
-- where c.farm_acres_lost > 0
-- group by c.ccid,c.poplar_price,c.farm_acres_lost,c.poplar
-- order by c.ccid,c.poplar_price,c.farm_acres_lost,c.poplar;

create temp view cmz34_water_fraction as 
select ccid,poplar_price,poplar/farm_acres_lost as fraction
from cmz34_agg
full outer join cmz34_acres_feet
using (ccid,poplar_price)
where poplar>0
order by ccid,poplar_price;

create temp view cmz34_to_poplar_fraction as 
select ccid,poplar_price,category,
f.fraction*w.fraction as poplar_fractional_acres 
from cmz34_f f join cmz34_water_fraction w 
using (ccid,poplar_price) 
where f.fraction >0.05 
order by ccid,poplar_price,category;

create temp table cmz34_poplar_pixels as
select pid,poplar_price,
sum(px_frac*pixel_fraction*poplar_fractional_acres)
*(8192^2)/10000 poplar_hectares 
from cmz.cmz_cty_pxfrac 
join cdl.cdl using (pid) 
join cdl.cat using (cat_id) 
join cmz34_to_poplar_fraction pf 
using (ccid,category) 
group by pid,poplar_price 
order by pid,poplar_price;

--\COPY (select p.pid,p.poplar_price,p.poplar_hectares,p.poplar_hectares-coalesce(v.poplar_hectares,0) as marginal_addition,st_asKML(x.boundary) as boundary from cmz34_poplar_pixels p left join cmz34_poplar_pixels v on (p.pid=v.pid and p.poplar_price=v.poplar_price + 0.1) join afri.pixels x on (p.pid=x.pid) where p.poplar_hectares > 1 order by pid,poplar_price) TO 'cmz34_poplar.csv' with CSV header

--\COPY (select p.pid,p.poplar_price,p.poplar_hectares,v.poplar_hectares,p.poplar_hectares-coalesce(v.poplar_hectares,0) as marginal_addition from cmz34_poplar_pixels p join (select p.pid,p.poplar_price,max(v.poplar_price) as previous from cmz34_poplar_pixels p join cmz34_poplar_pixels v on (p.pid=v.pid and p.poplar_price>v.poplar_price) group by p.pid,p.poplar_price order by p.poplar_price) as l using(pid,poplar_price) left join cmz34_poplar_pixels v on (l.pid=v.pid and v.poplar_price=l.previous) join afri.pixels x on (p.pid=x.pid) where p.pid=300183 where p.poplar_hectares > 1 order by pid,poplar_price) TO 'cmz34_poplar.csv' with CSV header
