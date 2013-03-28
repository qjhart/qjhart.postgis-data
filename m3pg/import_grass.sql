set search_path=m3pg,public;

create table grass_daylight (
 month integer,
 pid integer,
 daylight float
);

-- In grass
-- for d in XXXX-*; do m=${d#XXXX-*}; r.stats -1 input=8km_pids@quinn,daylight@$d fs=',' nv='' | sed -e "s/^/$m,/" ; done | psql -d afri -c 'copy m3pg.grass_daylight (month,pid,daylight) from stdin with csv';

create table grass_3pg_output (
date varchar(8),
parm varchar(8),
irrigated boolean,
pid integer,
value float);

-- In grass
-- for d in 201*; do for p in ASW Irrig Transp CumIrrig LAI WS WF WR; do r.stats -1 input=8km_pids@quinn,$p@$d fs=',' nv='' | sed -e "s/^/$d,$p,F,/" ; done; done | psql -d afri -c 'copy m3pg.grass_3pg_output (date,parm,irrigated,pid,value) from stdin with csv;

create table grass_3pg_parms as
select 
pid,irrigated,parm,
array_agg(date) as dates,
array_agg(value) as values from 
(
 select * from grass_3pg_output 
 order by pid,irrigated,parm,date
) as f 
group by pid,irrigated,parm;

create table grass_3pg_dates as select dates from grass_3pg_parms group by dates;
alter TABLE grass_3pg_parms drop column dates;

create table public_view.grass_3pg_output as 
with foo as (
select * from crosstab (
'select pid::varchar||irrigated as id,pid,irrigated,parm,values from grass_3pg_parms order by 1',
'select distinct parm from grass_3pg_parms order by 1')
as (
foo varchar,pid integer,irrigated boolean,
ASW float[],CumIrrig float[],Irrig float[],
LAI float[],Trans float[],WF float[],WR float[],
WS float[])
)
select pid,irrigated,Irrig,CumIrrig,ASW,Trans,LAI,WS,WF,WR
from foo;

