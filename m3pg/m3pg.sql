drop schema m3pg cascade;
create schema m3pg;
set search_path=m3pg,public;

create table soil_class (
       soil_class_id integer,
       class varchar(6) primary key,
       description text,
       SWconst float,
       SWpower float
);

copy soil_class from stdin delimiter '|';
-1|?|unknown|0.7|9
0|NA|No soil water effects|999|9
1|Sa|sandy|0.7|9
2|SaLo|sandy loam|0.6|7
3|CaLo|clay loam|0.5|5
4|Cl|clay|0.4|3
\.

-- For classes 1-4....
-- update soil_class set SWconst=0.8-0.1*class,SWpower=11.0-2*class
-- where SWconst is Null;

create or replace function fSW (ASW float,MaxASW float,SWconst float,SWpower float, OUT fSW float)
as $$
BEGIN
   select into fSW 1.0 / (1.0 +((1 - (ASW/MaxASW)) / SWconst ) ^ SWpower);
END;
$$ LANGUAGE 'plpgsql';

comment on function fSW (ASW float,MaxASW float,SWconst float,SWpower float, OUT fSW float) 
is 'soil water modifier';

create or replace function fSW (ASW float,MaxASW float,sc varchar(6), 
  OUT fSW float)
as $$
DECLARE 
const float;
power float;
BEGIN
  select SWconst,SWpower into const,power from soil_class 
    where class=sc;
   select fSW(ASW,MaxASW,const,power) into fSW;
END;
$$ LANGUAGE 'plpgsql';

create or replace function m3pg.soil_class(sand float,silt float,clay float,
OUT class varchar(8)) AS $$
BEGIN
  select into class CASE when (clay>.5) THEN 'Cl' ELSE 'UNKN' END;
END;
$$ LANGUAGE 'plpgsql';

