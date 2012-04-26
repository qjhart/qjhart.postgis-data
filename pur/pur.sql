-- srid needs to be defined variable
drop schema pur cascade;
create schema pur;
set search_path=pur,public;
set datestyle=MDY;
SET CLIENT_ENCODING TO UTF8;
SET STANDARD_CONFORMING_STRINGS TO ON;

create function pur_date(char(8))
RETURNS date AS 
$$
select (substring($1,1,2)||'-'||substring($1,3,2)||'-'||substring($1,5,4))::date;
$$ LANGUAGE SQL;

create domain application_unit as char
CHECK(
   VALUE in ('?','A','C','S','U','T','K','P')
);

comment on domain application_unit is 'This is the unit designation
for the application of the pesticide.  Used for acre_planted and
acres_applied fields in the UDC codes.  Codes are: A=acres, S=square
feet, C=cubic feet, K=thousand cubic feet, U= Misc. Examples of
misc. units include: bins, tree holes, bunches, pallets, etc.';

create table chemical (
CHEM_CODE decimal(5,0) primary key,
CHEMALPHA_CD decimal(8),
CHEMNAME varchar(171)
);
\copy chemical from chemical.txt CSV HEADER

create table CAS_Number (
CHEM_CODE decimal(5,0) references chemical,
CAS_NUMBER char(12)
);
\copy cas_number from chem_cas.txt CSV HEADER

create table site (
SITE_CODE decimal(6,0) primary key,
SITE_NAME varchar(50)
);
\copy site from site.txt CSV HEADER

create table Formula (
FORMULA_CD char(2) primary key,
FORMULA_DSC varchar(50)
);
\copy formula from formula.txt CSV HEADER

create table Qualify (
QUALIFY_CD decimal(3,0) primary key,
QUALIFY_DSC varchar(50)
);
\copy qualify from qualify.txt CSV HEADER

create table County (
COUNTY_CD char(2) primary key,
COUNTY_NAME varchar(15)
);
\copy county from county.txt CSV HEADER

create table product(
prodno decimal(6,0) primary key,
mfg_firmno decimal(7,0),
reg_firmno decimal(7,0),
LABEL_SEQ_NO  decimal(5,0),	
REVISION_NO   char(2),	
FUT_FIRMNO    decimal(7,0),
PRODSTAT_IND  char(1),	
PRODUCT_NAME  varchar(100),	
SHOW_REGNO    varchar(24),	
AER_GRND_IND  char(1),	
AGRICCOM_SW   char(1),	
CONFID_SW     char(1),	
DENSITY	      decimal(7,3),
FORMULA_CD    char(2) references formula,	
FULL_EXP_DT   char(8),
FULL_ISS_DT   char(8),
FUMIGANT_SW   char(1),	
GEN_PEST_IND  char(1),	
LASTUP_DT     char(8),
MFG_REF_SW    char(1),	
PROD_INAC_DT  char(8),
REG_DT	      char(8),
REG_TYPE_IND  char(1),	
RODENT_SW     char(1),	
SIGNLWRD_IND  decimal(9,0),
SOILAPPL_SW   char(1),	
SPECGRAV_SW   char(1),	
SPEC_GRAVITY  decimal(7,4),
CONDREG_SW    char(1)
);
\copy product from product.txt CSV HEADER
--FULL_EXP_DT   date,
--FULL_ISS_DT   date,
--LASTUP_DT     date,
--PROD_INAC_DT  date,
--REG_DTdate,

create table udc_old (
use_no decimal(8,0),
prodno decimal(8,0) references product,
chem_code decimal(5,0) references chemical,
prodchem_pct decimal(10,5),
lbs_chm_used float,
lbs_prd_used decimal(15,4),
amt_prd_used decimal(13,4),
unit_of_meas char(2),
acre_planted decimal(8,2),
unit_planted application_unit,
acre_treated decimal(8,2),
unit_treated application_unit,
applic_cnt decimal(6,0),
applic_dt date,
applic_time char(4), -- time HHMM,
county_cd char(2) references county,
base_ln_mer char(1),
township char(2),
tship_dir char(1),
range char(2),
range_dir char(1),
section char(2),
site_loc_id char(8),
grower_id char(11),
license_no char(13),
planting_seq decimal(1,0),
aer_gnd_ind char(1),
site_code decimal(6,0) references site,
qualify_cd decimal(2,0) references qualify,
batch_no decimal(4,0),
document_no char(8),
summary_cd decimal(4,0),
record_id char(1),
comtrs varchar(12),
error_flag char(2)
-- chem_code is NULL
--primary key(use_no,chem_code)
);

create table udc (
use_no integer,
prodno integer references product,
chem_code integer references chemical,
prodchem_pct float,
lbs_chm_used float,
lbs_prd_used float,
amt_prd_used float,
unit_of_meas char(2),
acre_planted float,
unit_planted application_unit,
acre_treated float,
unit_treated application_unit,
applic_cnt integer,
applic_dt date,
applic_time char(4), -- time HHMM,
county_cd char(2) references county,
base_ln_mer char(1),
township char(2),
tship_dir char(1),
range char(2),
range_dir char(1),
section char(2),
site_loc_id char(8),
grower_id char(11),
license_no char(13),
planting_seq integer,
aer_gnd_ind char(1),
site_code integer references site,
qualify_cd integer references qualify,
batch_no integer,
document_no char(8),
summary_cd integer,
record_id char(1),
comtrs varchar(12),
error_flag char(2)
);


create function co_mtrs(udc) 
returns varchar(7)
AS $$ 
select $1.county_cd||$1.base_ln_mer||$1.township||$1.range||$1.section
$$ LANGUAGE SQL;


-- pls gis data
-- started from shp2pgsql -p plsnet_nad

create domain pls_source as integer
CHECK(VALUE in (0,1,2,3));

CREATE TABLE "pls" (
gid serial primary key,
"source" pls_source,
"county_cd" varchar(2) references county,
"base_ln_mer" varchar(1),
"township" varchar(3),
"range" varchar(3),
"section" varchar(2),
"co_mtrs" varchar(11) unique
);
SELECT AddGeometryColumn('pur','pls','boundary',:srid,'MULTIPOLYGON',2);

-- Helper Functions for extended names.
create function mtr(pls) 
returns varchar(7)
AS $$ 
select $1.base_ln_mer||$1.township||$1.range
$$ LANGUAGE SQL;

create function mtrs(pls) 
returns varchar(7)
AS $$ 
select $1.base_ln_mer||$1.township||$1.range||$1.section
$$ LANGUAGE SQL;



-- -- Not included as buildable from above.
-- CREATE TABLE "township" (
-- gid serial primary key,
-- "county_cd" varchar(2) references county,
-- "mtown" varchar(4),
-- "range" varchar(3),
-- "base_ln_me" varchar(1),
-- "township" varchar(3),
-- "mtr" varchar(7),
-- "co_mtr" varchar(9));
-- SELECT AddGeometryColumn('pur','mtr','boundary',':srid','MULTIPOLYGON',2);