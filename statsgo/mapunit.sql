SET search_path = statsgo, pg_catalog;
drop table if exists mapunit CASCADE;
create table mapunit (
musym  varchar(6) not null,
muname varchar(175),
mukind varchar(254),-- references mapunit_kind(mukind),
mustatus  varchar(254),-- mapunit_status
muacres integer,
mapunitlfw_l integer,
mapunitlfw_r integer,
mapunitlfw_h integer,
mapunitpfa_l float,
mapunitpfa_r float,
mapunitpfa_h float,
farmlndcl  varchar(254), --farmland_classification
muhelcl  varchar(254),-- mapunit_hel_class
muwathelcl  varchar(254),-- mapunit_hel_class
muwndhelcl  varchar(254),-- mapunit_hel_class
interpfocus varchar(30),
invesintens varchar(254),-- investigation_intensity
iacornsr integer,
nhiforsoigrp varchar(254),-- nh_important_forest_soil_group
nhspiagr float,
vtsepticsyscl  varchar(254),-- vt_septic_system_class
mucertstat varchar(254),-- mapunit_certification_status
lkey varchar(30) not null,
mukey varchar(30) primary key
);

--musym,muname,mukind,mustatus,muacres,mapunitlfw_l,mapunitlfw_r,mapunitlfw_h,mapunitpfa_l,mapunitpfa_r,mapunitpfa_h,farmlndcl,muhelcl,muwathelcl,muwndhelcl,interpfocus,invesintens,iacornsr,nhiforsoigrp,nhspiagr,vtsepticsyscl,mucertstat,lkey,mukey,


