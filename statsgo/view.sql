create or replace view  statsgo.county_fitness_v as
select cm.county_gid,
         sum(comppct_r*area(boundary))::float as arable,
         0::decimal(6,2) as pct_arable,
         sum(comppct_r*irrcapcl::integer/100.0*area(boundary))/
             sum(comppct_r/100.0*area(boundary)) as irrcapcl,
         sum(comppct_r*nirrcapcl::integer/100.0*area(boundary))/
             sum(comppct_r/100.0*area(boundary)) as nirrcapcl
from statsgo.county_map_unit_poly cm 
join statsgo.component c using (mukey) 
group by cm.county_gid;


create table statsgo.county_fitness as 
select * from statsgo.county_fitness_v;

update statsgo.county_fitness f 
set pct_arable=f.arable/area(c.boundary)
from network.county c 
where f.county_gid=c.county_gid;
