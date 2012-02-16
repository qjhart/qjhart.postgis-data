\set ON_ERROR_STOP 1
BEGIN;

SET search_path = forest,public;

-- Urban Wood

create temp table u (
county_name varchar(32),
fips char(5),
total float
);

copy u from 'forest.urban.csv' WITH CSV HEADER;

insert into feedstock (qid,scenario,type,price,marginal_addition)
select 'S'||fips,'forest','msw.wood' as type,10,total from u;

\echo The following qids do not match
select * from feedstock left join network.county c using (qid) where type='msw.wood' and c is null;

END;