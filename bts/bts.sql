drop schema if exists bts cascade;
create schema bts;
set search_path=bts,public;

-- This might go somewhere else like network?
create or replace function add_qid(tableName varchar,OUT ret boolean)
AS
$$ 
BEGIN
EXECUTE 'alter table '||tableName||' add column qid varchar(8)';
ret=true;
END
$$ LANGUAGE 'PLPGSQL';

CREATE OR REPLACE FUNCTION 
add_and_find_qid(tab text,
state_fips char(2), name varchar(255), OUT okay boolean)
AS $$
DECLARE
t varchar;
BEGIN
EXECUTE 'alter table ' || tab || ' add qid char(8)';
EXECUTE 'update '|| tab || ' f set qid=cx.qid from bts.place cx where f.'||
        state_fips||'=cx.state and lower(f.'||name||')=lower(cx.name)';
EXECUTE 'update '|| tab || ' f set qid=ul.qid from 
  ( select l.gid,l.centroid,c.qid,
    st_distance(l.centroid,c.centroid) as dis,
    min(st_distance(l.centroid,c.centroid)) 
    OVER (PARTITION BY l.centroid) as min 
    from (select gid,'||state_fips||',centroid from '|| tab ||
  ' where qid is null ) as l,
          bts.place c where c.state=l.'||state_fips||
') as ul where ul.dis=ul.min and f.gid=ul.gid';
select into okay true;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION add_centroid_from_ll(schemaname varchar(32), 
       tablename varchar(32), longitude varchar(32), latitude varchar(32),
       srid integer,snap integer, OUT cnt boolean)
AS $$
DECLARE
t varchar;
BEGIN
t=quote_ident(schemaname) || '.' || quote_ident(tablename);
perform addGeometryColumn(schemaname,tablename,'centroid',srid,'POINT',2);
EXECUTE 
'UPDATE ' || t || 
' set centroid=st_snaptogrid(st_transform(st_setsrid(st_MakePoint( ' 
|| quote_ident(longitude) ||',' || quote_ident(latitude) || 
'),4269),'||srid||'),'||snap||')';
EXECUTE 
'CREATE INDEX "'||quote_ident(tablename)||'_centroid_gist" ON '
|| t ||' using gist ("centroid")';
SELECT into cnt true;
END;
$$ LANGUAGE 'plpgsql';
