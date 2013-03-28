drop schema from_bcam cascade;
create schema from_bcam;
set search_path=from_bcam,public;

\i tables.sql
\i rows.sql

create view economies as 
with i as (
select distinct economy,ccid from crop_loss
) 
select economy,
st_union(geom) as boundary
from i 
join cmz.cmz_cnty 
using (ccid) group by economy;
--\COPY (select economy,st_asKML(boundary) from economies) to ~/economies.csv with CSV HEADER

create table commodityXwalk (
 shorthand varchar primary key,
 commodity varchar
);

COPY commodityXwalk (shorthand,commodity) from STDIN WITH DELIMITER '|';
AlfalfaHay|HAY, ALFALFA
AlfalfaHaylage|HAYLAGE, ALFALFA
Barley|BARLEY
BeansDryEdible|BEANS, DRY EDIBLE, (EXCL LIMA)
BeansDryLima|BEANS, DRY EDIBLE, LIMA
Canola|CANOLA
CornGrain|CORN, GRAIN
CornSilage|CORN, SILAGE
GrassHay|HAY, TAME, (EXCL ALFALFA & SMALL GRAIN)
GrassHaylage|HAYLAGE, (EXCL ALFALFA)
Lentils|LENTILS
Oats|OATS
Potatoes|POTATOES
SpringWheat|WHEAT, SPRING, (EXCL DURUM)
Sugarbeets|SUGARBEETS
WinterWheat|WHEAT, WINTER
\.

create table crop_loss (
 economy varchar(32),
 ccid integer,
 poplar_price float,
 commodity varchar,
 acres float
);

create table poplar_gain (
 economy varchar(32),
 poplar_price float,
 commodity varchar,
 acres float
);
 
create or replace function add_crop_loss
(economy varchar,crop varchar,OUT ret boolean)
AS
$$ 
DECLARE 
ccid varchar;
sh varchar;
com varchar;
BEGIN
com:='UNK';
sh:=(regexp_matches(crop,'^([A-Za-z]+)(\d+)$'))[1];
select into com commodity from commodityXwalk where shorthand=sh;
ccid:=(regexp_matches(crop,'^([A-Za-z]+)(\d+)$'))[2]::integer;
EXECUTE 'insert into crop_loss (poplar_price,economy,ccid,commodity,acres) 
select POPPRICE::decimal(6,1),'''|| economy || ''',
''' || ccid || ''',''' || com || ''','|| crop ||'::decimal(10,1)
from ' || economy || ' order by popprice' ;
ret=true;
END
$$ LANGUAGE 'PLPGSQL';

create or replace function add_poplar_gain
(economy varchar) returns void
AS
$$ 
BEGIN
EXECUTE 'insert into poplar_gain (poplar_price,economy,commodity,acres) 
select POPPRICE::decimal(6,1),'''|| economy || ''',
''POPLAR'',poplar0::decimal(10,1)
from ' || economy || ' order by popprice' ;
END
$$ LANGUAGE 'PLPGSQL';


-- These three economies never have poplar come into play
select add_crop_loss(economy,row) 
from rows 
where economy not in ('CMZ71OR','CMZ47ID','CMZ52ORWA');

select add_poplar_gain(economy) from 
(
 select distinct economy from rows 
 where economy not in ('CMZ71OR','CMZ47ID','CMZ52ORWA')
) as f;
