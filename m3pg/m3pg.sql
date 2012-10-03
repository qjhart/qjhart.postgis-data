drop schema m3pg cascade;
create schema m3pg;
set search_path=m3pg,public;

create table m3pg.plant (
plant_id serial primary key,
name text unique,
parms hstore,
parms_desc hstore,
use boolean default False
);

create table m3pg.model (
       month integer,
       standAge float,
       wF float              
);

insert into m3pg.plant (name,parms) 
select 'definitions',
hstore('
alpha=>"Canopy quantum efficiency [mol C/mol photon]",
molPAR_MJ=>"conversion of MJ to PAR [mol photon / MJ]",
gDM_mol=>"conversion [gDM/mol]",
y=>"Assimilate use efficiency"
k=>"Radiation extinction coefficient"
SLA0 =>"specific leaf area at age 0 (m^2/kg)"
SLA1 =>"specific leaf area for mature trees (m^2/kg)"
tSLA =>"stand age (years) for SLA = (SLA0+SLA1)/2",
seedlingMass=>"Starting mass of tree [g]",
stemNoi=>Initial Stand Stocking [trees/ha]"
');

insert into m3pg.plant (name,parms) 
select 'BAS',
hstore(' 
 nAge=>4,
 alpha=>0.055,
 molPAR_MJ=>2.3,
 gDM_mol=>24,
 y=> 0.47,
 k => 0.5,
 SLA0 => 4,
 SLA1 => 4,
 tSLA => 2.5,
 fullCanAge => 0,
 days_per_month=>30.4,
 seedlingMass=>1,
 stemNoi=>12000
');

insert into m3pg.plant (name,parms) 
select 'landsberg97',
parms||hstore('alpha=>0.03') 
from m3pg.plant where name='BAS';

insert into m3pg.plant (name,parms) 
select 'ahb-pnw',
parms||hstore('fullCanCover=>2') 
from m3pg.plant where name='landsberg97';


create or replace function m3pg.CanCover 
       (m m3pg.model, p m3pg.plant, OUT CanCover float) as 
$$
DECLARE 
fullCanAge float;
BEGIN
	fullCanAge:=coalesce((p.parms->'fullCanAge')::float,0);
	CanCover=CASE WHEN (m.standAge < fullCanAge) 
	THEN m.StandAge / fullCanAge
	ELSE 1
	END;
END;
$$ LANGUAGE 'plpgsql';

--Specific LAI
create or replace function m3pg.LAI
       (m m3pg.model, p m3pg.plant, OUT LAI float) AS 
$$
DECLARE 
SLA float;
BEGIN
SLA = CASE WHEN (m.StandAge > 3*(p.parms->'tSLA')::float)
    THEN (p.parms->'SLA1')::float
    ELSE
     (p.parms->'SLA1')::float + 
    ((p.parms->'SLA0')::float - (p.parms->'SLA1')::float) * 
    exp(-ln(2) * (m.StandAge / (p.parms->'tSLA')::float) ^ 2)
    END;
LAI = m.wF * SLA * 0.1;
END;
$$ LANGUAGE 'plpgsql';

%
% Solar Interception
%
create or replace function m3pg.monthly_RADpa_kg_ha
       (RAD float, model m, p m3pg.plant, out RADpa) AS 
$$
BEGIN
	RADpa = RAD*(p.parms->'days_per_month')::float*
	        (1 - exp(-(p.parms->'k'):float * LAI(m,p)))*
	        (p.parms->'molPar_MJ'):float*(p.parms->'y')::float*
		(p.parms->'gDM_mol')::float/100;
END;
$$ LANGUAGE 'plpgsql';

create or replace function m3pg.monthly_RADpau_tDM_ha
       (RAD float, model m, p m3pg.plant, out RADpau) AS 
$$
DECLARE
RADpa float;
physMod float;
fNutr float;
fT float;
fFrost float;
BEGIN
	select into RADpa m3pg.RADpa(RAD,m,p);
	RADpau=RADpa*
END;
$$ LANGUAGE 'plpgsql';


create or replace function fAGE (StandAge float,MaxAge float,p m3pg.plant, 
       OUT fAGE float)
as $$
BEGIN
   select into fAGE 1.0 / 
     (1.0 + (StandAge/MaxAge/(p.parms->'rAge')) ^ (p.parms->'nAge'));
END;
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


-- CROP Management Zones

create or replace view m3pg.cmz_pixel_fraction as select pid,gid,
(st_area(st_intersection(p.boundary,c.geom))/size^2)::decimal(6,2) 
as fraction
from afri.pixels p
join cmz.cmz_pnw c on (st_intersects(p.boundary,c.geom));

create table m3pg.cmz_pixel_fraction_m as 
select * from m3pg.cmz_pixel_fraction;

create or replace view m3pg.county_pixel_fraction as 
select p.pid,c.county_gid,
(st_area(st_intersection(p.boundary,c.boundary))/size^2) as fraction 
from afri.pixels p 
join national_atlas.county c on (st_intersects(p.boundary,c.boundary));

create table m3pg.county_pixel_fraction_m as 
select * from m3pg.county_pixel_fraction;

create or replace view m3pg.model_county as
select state,county,fraction from (
select state,replace(name,' County','') as county,
hectares/(st_area(c.boundary)/10000) as fraction 
from m3pg.county_area ca 
join national_atlas.county c using (county_gid) 
where state not in ('NV','UT') order by state,name) as f
where fraction > 0.25;


create view m3pg.cmz_pixel_best as
select pid,gid from
( select pid,gid,fraction,max(fraction) OVER (partition by pid) as max
 from cmz_pixel_fraction_m) as m
where max=fraction;

create view cmz_crops_by_zone as 
select gid,category,
sum(crop_hectares_in_pixel) as crop_hectares_in_zone 
from m3pg.cmz_pixel_best_8km 
join crops_by_pixel using (pid) 
group by gid,category;

create or replace view m3pg.cmz_total_hectares as
select cmz,sum(st_area(z.geom)/10000)::integer as cmz_hectares,
 sum(grid_count) as grids,sum(grid_area) as model_area,
 sum(foo.crop_hectares) as model_crop_area
from
(select gid,sum(crop_hectares) as crop_hectares,
count(*) as grid_count,(count(*)*8192^2/10000)::integer as grid_area
from (
 select pid,sum(amt*(8192^2)/10000)::decimal(6,2) as crop_hectares
 from cdl.cdl
 join cdl.cat using (cat_id)
 where crop is true
 group by pid
 ) as c
 join m3pg.cmz_pixel_best p
 using (pid)
 group by gid
) as foo
join
cmz.cmz_pnw z
using (gid)
group by cmz
order by cmz;



