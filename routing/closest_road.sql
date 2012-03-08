--http://gis.stackexchange.com/questions/2061/postgis-nearest-point-on-a-linestring-to-a-given-point
--SELECT AsText(ST_Line_Interpolate_Point(myLineGeom,ST_Line_Locate_Point(myLineGeom,ST_Transform(GeomFromText('POINT(LON LAT)',4326),3395))))
--FROM myLines
--WHERE myGeom && expand(ST_Transform(GeomFromText('POINT(LON LAT)',4326),3395), 100)
SELECT AsText(ST_Line_Interpolate_Point(poly,ST_Line_Locate_Point(poly,)))
FROM t64urdsp
WHERE myGeom && expand(ST_Transform(GeomFromText('POINT(LON LAT)',4326),26910), 100)

select st_closestpoint(poly,st_transform(st_geomfromtext('POINT (40.3 -123.1)', 4326), 26910)) from t64urdsp; 