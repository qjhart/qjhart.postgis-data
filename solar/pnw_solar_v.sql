

select pid, '%s', sum(st_area(st_intersection(boundary, geom))*%s)/st_area(boundary) wavg from ghi_1deg_pnw, pixels where st_intersects(boundary, geom) and size=%s group by pid




