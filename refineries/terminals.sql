-- I beleive this terminal database is from the data that Peter bought
-- that includes only the city so is okay for redistribution.  Need to
-- verify again and get a citation.

BEGIN;
\set t terminals
\set s refineries
\set st refineries.terminals

set search_path=:s,public;

drop table if exists :st cascade;

create table :st (
       company integer,
       city varchar(50),
       state char(2),
       qid char(8)
);


COPY :st (company,city,state) FROM 'terminals.csv' WITH DELIMITER AS ',' QUOTE AS '"' CSV HEADER;

-- Can't use add_qid() since no locations
update :st f set qid=cx.qid from network.place cx where f.state=cx.state and lower(f.city)=lower(cx.name);

END;
