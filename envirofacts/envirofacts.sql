Drop schema if exists envirofacts cascade;
create schema envirofacts;
set search_path=envirofacts,public;


-- Maybe move this to bts as well....
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



