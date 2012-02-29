-- I believe this terminal database is from the data that Peter bought
-- that includes only the city so is okay for redistribution.  Need to
-- verify again and get a citation.

set search_path=refineries,public;

BEGIN;

drop table if exists terminals cascade;

create table terminals (
       company integer,
       city varchar(50),
       state char(2),
       qid char(8)
);


\COPY terminals (company,city,state) FROM 'terminals.csv' WITH DELIMITER AS ',' QUOTE AS '"' CSV HEADER


-- Quickly try and match to bts places
update terminals f set qid=cx.qid 
from bts.place cx 
where f.state=cx.state 
and lower(f.city)=lower(cx.name);

END;
