CREATE OR REPLACE FUNCTION network.add_road_connector(pt_connector varchar(30), pt_gid varchar(30), pt_distance double precision, pt_link_type integer)
RETURNS integer AS 
$BODY$
  DECLARE
      count integer;
  BEGIN
 RAISE INFO 'creating connect table';

 EXECUTE 'create temp table connect as 
 select c.' || pt_gid ||' as gid,
        r.gid as r_gid,
        distance(c.centroid,r.centerline) as distance 
 from ' || pt_connector || ' as c, network.roads r 
 where  st_dwithin(c.centroid,r.centerline,' || pt_distance ||') and r.link_type < 90;'; 

create index connect_gid on connect(gid); 

drop table if exists min_connect;

 RAISE INFO 'creating min_connect table';
 EXECUTE 'create temp table min_connect as 
 select m.gid,r_gid,distance,(line_locate_point(r.centerline,c.centroid)*1000)::integer/1000.0 as locate_point
 from 
 (select con.gid as gid,distance,min(r_gid) as r_gid from 
  connect con
  join (select gid,min(distance) as distance from connect group by gid)  
        as min
  using(gid,distance) group by con.gid,distance) as m
 join ' || pt_connector ||' c on (m.gid=c.' || pt_gid || ')
 join network.roads r on (r.gid=r_gid);';

--RAISE INFO 'Saving';
gdrop table if exists tmp.connect;
drop table if exists tmp.min_connect;
create table tmp.connect as select * from connect;
create table tmp.min_connect as select * from min_connect;

--drop table if exists connect;

-- Now split the connectors, since these are connected by id, we don't
-- need to add anything to the road_2data file to get speeds, etc.
 RAISE INFO 'adding splits';

-- splitting at connectors
insert into network.roads 
  (id,dir,recid,state,sign1,sign2,sign3,lname,rucode,fclass,status,nhs,link_type,stfips,ctfips,btsversion,centerline) 
 select id,dir,recid,state,sign1,sign2,sign3,lname,rucode,fclass,status,nhs,link_type,stfips,ctfips,btsversion,
   st_line_substring(centerline,0,m.locate_point)
   from network.roads n join min_connect m 
 on (n.gid=m.r_gid) where (m.locate_point != 0 and m.locate_point != 1)
union
 select id,dir,recid,state,sign1,sign2,sign3,lname,rucode,fclass,status,nhs,link_type,stfips,ctfips,btsversion,
   st_line_substring(centerline,m.locate_point,1)
 from network.roads n join min_connect m 
 on (n.gid=m.r_gid) where (m.locate_point != 0 and m.locate_point != 1);

 RAISE INFO 'adding connectors';
-- and adding connectors, some names are too long.
EXECUTE 'insert into network.roads 
 (lname,link_type,centerline) 
select substr(c.name||''(' || pt_connector || ')'',0,30),' || pt_link_type ||',
  MakeLine(c.centroid,line_interpolate_point(centerline,m.locate_point))
from min_connect m 
join '||pt_connector||' c on (c.' || pt_gid ||'=m.gid)
join network.roads n on (n.gid=m.r_gid) where distance != 0';

--drop table if exists min_connect;

 RETURN 1;
   END
$BODY$
  LANGUAGE 'plpgsql';

-- For Railways, we just connect to the closest (few?) Spurs for a
-- city.  No changes are made to the railway line, since it's very
-- nice.

CREATE OR REPLACE FUNCTION network.add_railway_connector(pt_connector text, pt_distance double precision, net char(1))
RETURNS integer AS 
$BODY$
  DECLARE
      count integer;
  BEGIN

 RAISE INFO 'creating connect table';
 drop table if exists connect;

 EXECUTE 'create temp table connect as 
 select c.gid as gid,
        r.gid as r_gid,
        distance(c.centroid,r.centroid) as distance 
 from ' || pt_connector || ' as c join rrterminals r 
 on(st_dwithin(c.centroid,r.centroid,' || pt_distance ||'))';

create index connect_gid on connect(gid); 

drop table if exists min_connect;

 RAISE INFO 'creating min_connect table';
 EXECUTE '
 create temp table min_connect as 
 select gid,r_gid,distance
 from connect con
 join (select gid,min(distance) as distance from connect group by gid) 
      as min
 using(gid,distance) where distance<'||pt_distance||';';

drop table if exists connect;

 RAISE INFO 'add railway nodes';
 EXECUTE 'insert into network.railwaynode
  (onmainnet,centroid) 
 select -1,c.centroid
 from min_connect m 
 join '||pt_connector||' c using (gid);';

 RAISE INFO 'add connectors';
 EXECUTE 'insert into network.railway 
  (rrowner1,net,centerline) 
 select ''ZZZZ'','''||net||''',
   MakeLine(c.centroid,r.centroid)
 from min_connect m 
 join '||pt_connector||' c using (gid)
 join rrterminals r on (r.gid=m.r_gid) where distance != 0';

drop table if exists min_connect;

 RETURN 1;
   END
$BODY$
  LANGUAGE 'plpgsql';


-- For Marine, we just connect to the closest (few?) link for a
-- city.  No changes are made to the waterway line

CREATE OR REPLACE FUNCTION network.add_waterway_connector(pt_connector varchar(30), pt_distance double precision, net char(1))
RETURNS integer AS
$BODY$
  DECLARE
      count integer;
  BEGIN

 RAISE INFO 'creating connect table';
 drop table if exists connect;

EXECUTE 'create temp table connect as 
select c.gid as gid,
       w.centroid as to_centroid,
       distance(c.centroid,w.centroid) as distance 
from ' || pt_connector || ' c join waterwaynode w 
on(st_dwithin(c.centroid,w.centroid,' || pt_distance ||'))'; 

create index connect_gid on connect(gid); 
create index connect_to_centroid on connect(to_centroid); 

drop table if exists min_connect;

 RAISE INFO 'creating min_connect table';
 EXECUTE '
 create temp table min_connect as 
 select distinct gid,to_centroid,distance
 from connect con
 join (select gid,min(distance) as distance from connect group by gid) as min
 using(gid,distance)
 where distance<'||pt_distance||';';

drop table if exists tmp.connect;
drop table if exists tmp.min_connect;
create table tmp.connect as select * from connect;
create table tmp.min_connect as select * from min_connect;

drop table if exists connect;

 RAISE INFO 'add connectors';
 EXECUTE 'insert into network.waterway 
  (featurid,linkname,linktype,centerline) 
 select ''-1'',m.gid,'''||net||''',
   MakeLine(c.centroid,to_centroid)
 from min_connect m 
 join '||pt_connector||' c using (gid);';

drop table if exists min_connect;

 RETURN 1;
   END
$BODY$
  LANGUAGE 'plpgsql';




