SET search_path = statsgo, pg_catalog;
drop table if exists chorizon CASCADE;

--hzname,desgndisc,desgnmaster,desgnmasterprime,desgnvert,hzdept_l,hzdept_r,hzdept_h,hzdepb_l,hzdepb_r,hzdepb_h,hzthk_l,hzthk_r,hzthk_h,fraggt10_l,fraggt10_r,fraggt10_h,frag3to10_l,frag3to10_r,frag3to10_h,sieveno4_l,sieveno4_r,sieveno4_h,sieveno10_l,sieveno10_r,sieveno10_h,sieveno40_l,sieveno40_r,sieveno40_h,sieveno200_l,sieveno200_r,sieveno200_h,sandtotal_l,sandtotal_r,sandtotal_h,sandvc_l,sandvc_r,sandvc_h,sandco_l,sandco_r,sandco_h,sandmed_l,sandmed_r,sandmed_h,sandfine_l,sandfine_r,sandfine_h,sandvf_l,sandvf_r,sandvf_h,silttotal_l,silttotal_r,silttotal_h,siltco_l,siltco_r,siltco_h,siltfine_l,siltfine_r,siltfine_h,claytotal_l,claytotal_r,claytotal_h,claysizedcarb_l,claysizedcarb_r,claysizedcarb_h,om_l,om_r,om_h,dbtenthbar_l,dbtenthbar_r,dbtenthbar_h,dbthirdbar_l,dbthirdbar_r,dbthirdbar_h,dbfifteenbar_l,dbfifteenbar_r,dbfifteenbar_h,dbovendry_l,dbovendry_r,dbovendry_h,partdensity,ksat_l,ksat_r,ksat_h,awc_l,awc_r,awc_h,wtenthbar_l,wtenthbar_r,wtenthbar_h,wthirdbar_l,wthirdbar_r,wthirdbar_h,wfifteenbar_l,wfifteenbar_r,wfifteenbar_h,wsatiated_l,wsatiated_r,wsatiated_h,lep_l,lep_r,lep_h,ll_l,ll_r,ll_h,pi_l,pi_r,pi_h,aashind_l,aashind_r,aashind_h,kwfact,kffact,caco3_l,caco3_r,caco3_h,gypsum_l,gypsum_r,gypsum_h,sar_l,sar_r,sar_h,ec_l,ec_r,ec_h,cec7_l,cec7_r,cec7_h,ecec_l,ecec_r,ecec_h,sumbases_l,sumbases_r,sumbases_h,ph1to1h2o_l,ph1to1h2o_r,ph1to1h2o_h,ph01mcacl2_l,ph01mcacl2_r,ph01mcacl2_h,freeiron_l,freeiron_r,freeiron_h,feoxalate_l,feoxalate_r,feoxalate_h,extracid_l,extracid_r,extracid_h,extral_l,extral_r,extral_h,aloxalate_l,aloxalate_r,aloxalate_h,pbray1_l,pbray1_r,pbray1_h,poxalate_l,poxalate_r,poxalate_h,ph2osoluble_l,ph2osoluble_r,ph2osoluble_h,ptotal_l,ptotal_r,ptotal_h,excavdifcl,excavdifms,cokey,chkey

create table chorizon (
       hzname varchar(12),
       desgndisc Integer,
       desgnmaster varchar(254), -- horz_desgn_master
       desgnmasterprime varchar(254), --horz_desgn_master_prime
       desgnvert Integer,
       hzdept_l integer,
       hzdept_r integer,
       hzdept_h Integer,
       hzdepb_l Integer,
       hzdepb_r Integer,
       hzdepb_h Integer,
       hzthk_l Integer,
       hzthk_r Integer,
       hzthk_h Integer,
       fraggt10_l Integer,
       fraggt10_r Integer,
       fraggt10_h Integer,
       frag3to10_l Integer,
       frag3to10_r Integer,
       frag3to10_h Integer,
       sieveno4_l Float,
       sieveno4_r Float,
       sieveno4_h Float,
       sieveno10_l Float,
       sieveno10_r Float,
       sieveno10_h Float,
       sieveno40_l Float,
       sieveno40_r Float,
       sieveno40_h Float,
       sieveno200_l Float,
       sieveno200_r Float,
       sieveno200_h Float,
       sandtotal_l Float,
       sandtotal_r Float,
       sandtotal_h Float,
       sandvc_l Float,
       sandvc_r Float,
       sandvc_h Float,
       sandco_l Float,
       sandco_r Float,
       sandco_h Float,
       sandmed_l Float,
       sandmed_r Float,
       sandmed_h Float,
       sandfine_l Float,
       sandfine_r Float,
       sandfine_h Float,
       sandvf_l Float,
       sandvf_r Float,
       sandvf_h Float,
       silttotal_l Float,
       silttotal_r Float,
       silttotal_h Float,
       siltco_l Float,
       siltco_r Float,
       siltco_h Float,
       siltfine_l Float,
       siltfine_r Float,
       siltfine_h Float,
       claytotal_l Float,
       claytotal_r Float,
       claytotal_h Float,
       claysizedcarb_l Float,
       claysizedcarb_r Float,
       claysizedcarb_h Float,
       om_l Float,
       om_r Float,
       om_h Float,
       dbtenthbar_l Float,
       dbtenthbar_r Float,
       dbtenthbar_h Float,
       dbthirdbar_l Float,
       dbthirdbar_r Float,
       dbthirdbar_h Float,
       dbfifteenbar_l Float,
       dbfifteenbar_r Float,
       dbfifteenbar_h Float,
       dbovendry_l Float,
       dbovendry_r Float,
       dbovendry_h Float,
       partdensity Float,
       ksat_l Float,
       ksat_r Float,
       ksat_h Float,
       awc_l Float,
       awc_r Float,
       awc_h Float,
       wtenthbar_l Float,
       wtenthbar_r Float,
       wtenthbar_h Float,
       wthirdbar_l Float,
       wthirdbar_r Float,
       wthirdbar_h Float,
       wfifteenbar_l Float,
       wfifteenbar_r Float,
       wfifteenbar_h Float,
       wsatiated_l Integer,
       wsatiated_r Integer,
       wsatiated_h Integer,
       lep_l Float,
       lep_r Float,
       lep_h Float,
       ll_l Float,
       ll_r Float,
       ll_h Float,
       pi_l Float,
       pi_r Float,
       pi_h Float,
       aashind_l Integer,
       aashind_r Integer,
       aashind_h Integer,
       kwfact varchar(254),-- soil_erodibility_factor
       kffact varchar(254), --soil_erodibility_factor
       caco3_l Integer,
       caco3_r Integer,
       caco3_h Integer,
       gypsum_l Integer,
       gypsum_r Integer,
       gypsum_h Integer,
       sar_l Float,
       sar_r Float,
       sar_h Float,
       ec_l Float,
       ec_r Float,
       ec_h Float,
       cec7_l Float,
       cec7_r Float,
       cec7_h Float,
       ecec_l Float,
       ecec_r Float,
       ecec_h Float,
       sumbases_l Float,
       sumbases_r Float,
       sumbases_h Float,
       ph1to1h2o_l Float,
       ph1to1h2o_r Float,
       ph1to1h2o_h Float,
       ph01mcacl2_l Float,
       ph01mcacl2_r Float,
       ph01mcacl2_h Float,
       freeiron_l Float,
       freeiron_r Float,
       freeiron_h Float,
       feoxalate_l Float,
       feoxalate_r Float,
       feoxalate_h Float,
       extracid_l Float,
       extracid_r Float,
       extracid_h Float,
       extral_l Float,
       extral_r Float,
       extral_h Float,
       aloxalate_l Float,
       aloxalate_r Float,
       aloxalate_h Float,
       pbray1_l Float,
       pbray1_r Float,
       pbray1_h Float,
       poxalate_l Float,
       poxalate_r Float,
       poxalate_h Float,
       ph2osoluble_l Float,
       ph2osoluble_r Float,
       ph2osoluble_h Float,
       ptotal_l Float,
       ptotal_r Float,
       ptotal_h Float,
       excavdifcl varchar(254), -- excavation_difficulty_class
       excavdifms varchar(254), -- observed_soil_moisture_status
       cokey varchar(30) not null references comp,
       chkey varchar(30) primary key
);
create index chorizon_cokey on chorizon (cokey);
