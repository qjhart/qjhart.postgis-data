\set ON_ERROR_STOP 1
BEGIN;
SET search_path = forest,public;

create temp table f (
name varchar(100),
lfips varchar(8),
l_0 float,
l_10 float,
l_20 float,
l_30 float,
l_40 float,
l_50 float,
l_60 float,
l_70 float,
l_80 float,
l_90 float,
l_100 float,
ofips varchar(8),
o_0 float,
o_10 float,
o_20 float,
o_30 float,
o_40 float,
o_50 float,
o_60 float,
o_70 float,
o_80 float,
o_90 float,
o_100 float,
tfips varchar(8),
t_0 float,
t_10 float,
t_20 float,
t_30 float,
t_40 float,
t_50 float,
t_60 float,
t_70 float,
t_80 float,
t_90 float,
t_100 float,
mfips varchar(8),
m float);

copy f from 'forest.csv' WITH CSV HEADER;

--\echo The following fips codes do not match in the file as they should
--select lfips,ofips,tfips,mfips from f where lfips != ofips or lfips != tfips or lfips != mfips;

insert into feedstock (qid,scenario,type,price,marginal_addition)
select 'S'||lfips,'unknown_scenario','forest.log' as type,10,0.5*(l_10) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,20,0.5*(l_20-l_10) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,30,0.5*(l_30-l_20) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,40,0.5*(l_40-l_30) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,50,0.5*(l_50-l_40) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,60,0.5*(l_60-l_50) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,70,0.5*(l_70-l_60) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,80,0.5*(l_80-l_70) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,90,0.5*(l_90-l_80) from f
union
select 'S'||lfips,'unknown_scenario','forest.log' as type,100,0.5*(l_100-l_90) from f;

insert into feedstock (qid,scenario,type,price,marginal_addition)
select 'S'||ofips,'unknown_scenario','forest.other' as type,10,0.5*(o_10) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,20,0.5*(o_20-o_10) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,30,0.5*(o_30-o_20) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,40,0.5*(o_40-o_30) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,50,0.5*(o_50-o_40) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,60,0.5*(o_60-o_50) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,70,0.5*(o_70-o_60) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,80,0.5*(o_80-o_70) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,90,0.5*(o_90-o_80) from f
union
select 'S'||ofips,'unknown_scenario','forest.other' as type,100,0.5*(o_100-o_90) from f;

insert into feedstock (qid,scenario,type,price,marginal_addition)
select 'S'||tfips,'unknown_scenario','forest.thin' as type,10,0.5*(t_10) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,20,0.5*(t_20-t_10) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,30,0.5*(t_30-t_20) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,40,0.5*(t_40-t_30) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,50,0.5*(t_50-t_40) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,60,0.5*(t_60-t_50) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,70,0.5*(t_70-t_60) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,80,0.5*(t_80-t_70) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,90,0.5*(t_90-t_80) from f
union
select 'S'||tfips,'unknown_scenario','forest.thin' as type,100,0.5*(t_100-t_90) from f;

insert into feedstock (qid,scenario,type,price,marginal_addition)
select 'S'||mfips,'unknown_scenario','forest.mill' as type,10,m from f;

delete from feedstock where marginal_addition = 0;

\echo The following qids do not match
select distinct qid from feedstock left join network.county c using (qid) where c is null;

END;
