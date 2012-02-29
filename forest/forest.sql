-- Data from Ken Skog (need reference)

drop SCHEMA IF EXISTS forest CASCADE;
CREATE SCHEMA forest;

SET search_path = forest,public;

create table feedstock (
qid varchar(8),
scenario varchar(32),
type varchar(32),
price float,
marginal_addition float,
primary key(qid,scenario,type,price)
);
create index feedstock_qid on feedstock(qid);

create view feedstock_all as 
select p.qid,p.scenario,p.price,l as log,m as mill,t as thinning,o as other,coalesce(l,0)+coalesce(t,0)+coalesce(o,0)+coalesce(m,0) as total
from 
(select distinct qid,scenario,price from feedstock ) as p
full outer join
(select qid,scenario,price,marginal_addition as l from feedstock where type='forest.log') as h 
on (p.qid=h.qid and p.price=h.price and p.scenario=h.scenario)
full outer join 
(select qid,scenario,price,marginal_addition as t from feedstock where type='forest.thin') as t
on (p.qid=t.qid and p.price=t.price and p.scenario=h.scenario)
full outer join 
(select qid,scenario,price,marginal_addition as o from feedstock where type='forest.other') as so
on (p.qid=so.qid and p.price=so.price and p.scenario=h.scenario) 
full outer join 
(select qid,scenario,price,marginal_addition as m from feedstock where type='forest.mill') as m
on (p.qid=m.qid and p.price=m.price and p.scenario=h.scenario);

