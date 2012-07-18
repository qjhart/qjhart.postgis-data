
--set search_path =  solar, public, afri;

select st_union(rast,1) from (SELECT ST_AsRaster(boundary, st_xmax(boundary)-st_xmin(boundary),st_ymax(boundary)-st_ymin(boundary),'64BF', wavg) rast 
       from (select pid, 
       sum(st_area(st_intersection(boundary, geom))*%s)/st_area(boundary) wavg, 
       boundary 
       from ghi_1deg_pnw, pixels 
       where st_intersects(boundary, geom) and size=%s 
       group by pid) foo) bar

