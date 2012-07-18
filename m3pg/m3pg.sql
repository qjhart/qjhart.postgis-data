drop schema m3pg cascade;
create schema m3pg;
set search_path=m3pg,public;

%
% Solar Interception
%
create or replace function m3pg.gross_canopy_production(Qo float, k float, L float, out Qint) AS 
$$

$$ LANGUAGE 'plpgsql';


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
3|ClLo|clay loam|0.5|5
4|Cl|clay|0.4|3
\N|LoSa|loamy sand|0.8|8
\N|SaClLo|sandy clay loam|0.5|6
\N|SaCl|sandy clay|0.4|5
\N|Lo|loam|.55|6
\N|SiCl|silty clay|.45|4
\N|SiClLo|silty clay loam|.5|5
\N|SiLo|silty loam|.5|5
\N|Si|silt|.5|5
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

create TYPE SaSiCl as (
       "SAND" float,
       "SILT" float,
       "CLAY" float
);

create or replace function m3pg.soil_class(indata SaSiCl)
RETURNS varchar(8) AS $$
  return(TT.points.in.classes(tri.data=indata,PiC.type="t"))
$$ LANGUAGE 'plr' STRICT;

-- create or replace function m3pg.soil_class_tridata(indata SaSiCl)
-- RETURNS tridata AS $$
--    outdata <- data.frame(SAND=1,SOIL=5,CLAY=80,class='')
--    outdata$class<-TT.points.in.classes(tri.data=indata,PiC.type="t")
--    return(outdata)
-- $$ LANGUAGE 'plr' STRICT;


create or replace function m3pg.initialize_R(OUT good boolean) AS $$
  library(soiltexture)
  TT.set("class.sys"="USDA.TT")
  return(TRUE)
$$ LANGUAGE 'plr' STRICT;

