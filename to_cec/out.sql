drop schema to_cec cascade;
create schema to_cec;
set search_path=cmz, cdl, national_atlas,public;

-- first draft region boundary
-- copy(select 'CEC forest-based biofuel region boundary', st_askml(st_union(st_union(c.boundary, s.boundary))) from to_bcam.ahb_county c, state s where state_abbrev='CA' ) to '/tmp/cec_boundary.csv' with csv header;