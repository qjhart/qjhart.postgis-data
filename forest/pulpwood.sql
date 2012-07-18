\set ON_ERROR_STOP 1
BEGIN;
SET search_path = forest,public;

create temp table be (
qid varchar(8),
scenario varchar(32),
type varchar(12),
be005 float,
be012 float,
be017 float,
be022 float,
be027 float,
be032 float,
be037 float,
be042 float,
be047 float,
be052 float,
be057 float,
be062 float,
be067 float,
be072 float,
be077 float,
be082 float,
be087 float,
be092 float,
be097 float,
be102 float,
be107 float,
be112 float,
be117 float,
be122 float,
be127 float,
be132 float,
be137 float,
be142 float,
be147 float,
be152 float,
be157 float,
be162 float,
be167 float,
be172 float,
be177 float,
be182 float,
be187 float,
be192 float,
be197 float,
be200 float
);

copy be from 'forest.pulpwood.csv' WITH CSV HEADER;

--\echo The following fips codes do not match in the file as they should
--select lfips,ofips,tfips,mfips from f where lfips != ofips or lfips != tfips or lfips != mfips;

insert into feedstock (qid,scenario,type,price,marginal_addition)
select qid,scenario,type,5.0,be005 from be
union
select qid,scenario,type,12.0,be012-be005 from be
union
select qid,scenario,type,17.0,be017-be012 from be
union
select qid,scenario,type,22.0,be022-be017 from be
union
select qid,scenario,type,27.0,be027-be022 from be
union
select qid,scenario,type,32.0,be032-be027 from be
union
select qid,scenario,type,37.0,be037-be032 from be
union
select qid,scenario,type,42.0,be042-be037 from be
union
select qid,scenario,type,47.0,be047-be042 from be
union
select qid,scenario,type,52.0,be052-be047 from be
union
select qid,scenario,type,57.0,be057-be052 from be
union
select qid,scenario,type,62.0,be062-be057 from be
union
select qid,scenario,type,67.0,be067-be062 from be
union
select qid,scenario,type,72.0,be072-be067 from be
union
select qid,scenario,type,77.0,be077-be072 from be
union
select qid,scenario,type,82.0,be082-be077 from be
union
select qid,scenario,type,87.0,be087-be082 from be
union
select qid,scenario,type,92.0,be092-be087 from be
union
select qid,scenario,type,97.0,be097-be092 from be
union
select qid,scenario,type,102.0,be102-be097 from be
union
select qid,scenario,type,107.0,be107-be102 from be
union
select qid,scenario,type,112.0,be112-be107 from be
union
select qid,scenario,type,117.0,be117-be112 from be
union
select qid,scenario,type,122.0,be122-be117 from be
union
select qid,scenario,type,127.0,be127-be122 from be
union
select qid,scenario,type,132.0,be132-be127 from be
union
select qid,scenario,type,137.0,be137-be132 from be
union
select qid,scenario,type,142.0,be142-be137 from be
union
select qid,scenario,type,147.0,be147-be142 from be
union
select qid,scenario,type,152.0,be152-be147 from be
union
select qid,scenario,type,157.0,be157-be152 from be
union
select qid,scenario,type,162.0,be162-be167 from be
union
select qid,scenario,type,167.0,be167-be162 from be
union
select qid,scenario,type,172.0,be172-be167 from be
union
select qid,scenario,type,177.0,be177-be172 from be
union
select qid,scenario,type,182.0,be182-be177 from be
union
select qid,scenario,type,187.0,be187-be182 from be
union
select qid,scenario,type,192.0,be192-be187 from be
union
select qid,scenario,type,197.0,be197-be192 from be
union
select qid,scenario,type,200.0,be200-be197 from be;

delete from feedstock where marginal_addition = 0;

\echo The following qids do not match
select distinct qid from be left join network.county c using (qid) where c is null;

END;
