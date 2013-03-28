set search_path=public_view,public;

create view economy_predictions as 
select 
economy,
poplar_price,
commodity,
sum(acres) as acres
from from_bcam.crop_loss 
group by economy,poplar_price,commodity 
union
select
economy,
poplar_price,
commodity,
acres
from from_bcam.poplar_gain
order by economy,poplar_price,commodity;
create table economy_predictions_m as select * from economy_predictions ;
grant select on economy_predictions_m to public;

create or replace function public_view.bcam_predictions(economy varchar) 
RETURNS table (economy varchar,poplar_price float,commodity varchar,acres float)
AS $$
select economy,poplar_price,commodity,acres
from public_view.economy_predictions_m
where economy=$1
order by economy,poplar_price,commodity
$$ LANGUAGE 'SQL';
grant EXECUTE on FUNCTION public_view.bcam_predictions(economy varchar) TO PUBLIC;

create or replace function public_view.bcam_commodity_predictions(economy varchar) 
RETURNS table (
--economy varchar,
poplar_price float,
"BARLEY" float,
"BEANS, DRY EDIBLE, (EXCL LIMA)" float,
"BEANS, DRY EDIBLE, LIMA" float,
"CANOLA" float,
"CORN, GRAIN" float,
"CORN, SILAGE" float,
"HAY, ALFALFA" float,
"HAYLAGE, ALFALFA" float,
"HAYLAGE, (EXCL ALFALFA)" float,
"HAY, TAME, (EXCL ALFALFA & SMALL GRAIN)" float,
"LENTILS" float,
"OATS" float,
"POPLAR" float,
"POTATOES" float,
"SUGARBEETS" float,
"WHEAT, SPRING, (EXCL DURUM)" float,
"WHEAT, WINTER" float
)
AS $$
with c as 
(
select * from crosstab (                                              
'select poplar_price,commodity,acres
 from public_view.economy_predictions_m
 where economy='''||$1||
 ''' order by poplar_price,commodity',
'select distinct commodity from public_view.economy_predictions_m order by 1'
) AS 
(
poplar_price float,
"BARLEY" float,
"BEANS, DRY EDIBLE, (EXCL LIMA)" float,
"BEANS, DRY EDIBLE, LIMA" float,
"CANOLA" float,
"CORN, GRAIN" float,
"CORN, SILAGE" float,
"HAY, ALFALFA" float,
"HAYLAGE, ALFALFA" float,
"HAYLAGE, (EXCL ALFALFA)" float,
"HAY, TAME, (EXCL ALFALFA & SMALL GRAIN)" float,
"LENTILS" float,
"OATS" float,
"POPLAR" float,
"POTATOES" float,
"SUGARBEETS" float,
"WHEAT, SPRING, (EXCL DURUM)" float,
"WHEAT, WINTER" float
)
)
select 
-- $1 as economy,
poplar_price,
COALESCE("BARLEY",0),
COALESCE("BEANS, DRY EDIBLE, (EXCL LIMA)",0),
COALESCE("BEANS, DRY EDIBLE, LIMA",0),
COALESCE("CANOLA",0),
COALESCE("CORN, GRAIN",0),
COALESCE("CORN, SILAGE",0),
COALESCE("HAY, ALFALFA",0),
COALESCE("HAYLAGE, ALFALFA",0),
COALESCE("HAYLAGE, (EXCL ALFALFA)",0),
COALESCE("HAY, TAME, (EXCL ALFALFA & SMALL GRAIN)",0),
COALESCE("LENTILS",0),
COALESCE("OATS",0),
COALESCE("POPLAR",0),
COALESCE("POTATOES",0),
COALESCE("SUGARBEETS",0),
COALESCE("WHEAT, SPRING, (EXCL DURUM)",0),
COALESCE("WHEAT, WINTER",0)
from c;
$$ LANGUAGE SQL;
grant EXECUTE on FUNCTION public_view.bcam_commodity_predictions(economy varchar) TO PUBLIC;
