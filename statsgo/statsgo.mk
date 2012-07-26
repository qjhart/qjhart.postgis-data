#! /usr/bin/make -f


ifndef configure.mk
include ../configure.mk
endif

statsgo.mk:=1

INFO::
	@echo STATSGO Data
	@echo   from Soil Data Mart 

#http://soildatamart.nrcs.usda.gov/SDM%20Web%20Application/documents/SSURGO%20Metadata%20-%20Tables%20and%20Columns%20Report.pdf
########################################################################
# STATSGO data is downloaded manually from soildata mart
# http://soildatamart.nrcs.usda.gov/USDGSM.aspx
########################################################################
zip:=gsmsoil_us.zip
tab:=gsmsoil_us/tabular

db:: db/statsgo db/statsgo.map_unit_poly db/statsgo.map_unit db/statsgo.mapunit db/statsgo.comp db/statsgo.muaggatt db/statsgo.chorizon 

db/statsgo:
	${PG} -f statsgo.sql
	touch $@

db/statsgo.map_unit_poly: shp:=gsmsoil_us/spatial/gsmsoilmu_a_us.shp
db/statsgo.map_unit_poly: db/statsgo
	[[ -f ${shp} ]] || unzip -j ${zip};
	${shp2pgsql} -d -r 4269 -g boundary -s ${srid} -I -S ${shp} statsgo.map_unit_poly | sed -e 's/, ${srid}));$$/::geometry, ${srid}));/' | ${PG} > /dev/null;
	touch $@

db/statsgo.map_unit: db/statsgo.map_unit_poly
	${PG} -f map_unit.sql
	touch db/statsgo.map_unit

mapunit.cols:=musym,muname,mukind,mustatus,muacres,mapunitlfw_l,mapunitlfw_r,mapunitlfw_h,mapunitpfa_l,mapunitpfa_r,mapunitpfa_h,farmlndcl,muhelcl,muwathelcl,muwndhelcl,interpfocus,invesintens,iacornsr,nhiforsoigrp,nhspiagr,vtsepticsyscl,mucertstat,lkey,mukey
comp.cols:=comppct_l,comppct_r,comppct_h,compname,compkind,majcompflag,otherph,localphase,slope_l,slope_r,slope_h,slopelenusle_l,slopelenusle_r,slopelenusle_h,runoff,tfact,wei,weg,erocl,earthcovkind1,earthcovkind2,hydricon,hydricrating,drainagecl,elev_l,elev_r,elev_h,aspectccwise,aspectrep,aspectcwise,geomdesc,albedodry_l,albedodry_r,albedodry_h,airtempa_l,airtempa_r,airtempa_h,map_l,map_r,map_h,reannualprecip_l,reannualprecip_r,reannualprecip_h,ffd_l,ffd_r,ffd_h,nirrcapcl,nirrcapscl,nirrcapunit,irrcapcl,irrcapscl,irrcapunit,cropprodindex,constreeshrubgrp,wndbrksuitgrp,rsprod_l,rsprod_r,rsprod_h,foragesuitgrpid,wlgrain,wlgrass,wlherbaceous,wlshrub,wlconiferous,wlhardwood,wlwetplant,wlshallowwat,wlrangeland,wlopenland,wlwoodland,wlwetland,soilslippot,frostact,initsub_l,initsub_r,initsub_h,totalsub_l,totalsub_r,totalsub_h,hydgrp,corcon,corsteel,taxclname,taxorder,taxsuborder,taxgrtgroup,taxsubgrp,taxpartsize,taxpartsizemod,taxceactcl,taxreaction,taxtempcl,taxmoistscl,taxtempregime,soiltaxedition,castorieindex,flecolcomnum,flhe,flphe,flsoilleachpot,flsoirunoffpot,fltemik2use,fltriumph2use,indraingrp,innitrateleachi,misoimgmtgrp,vasoimgtgrp,mukey,cokey

chorizon.cols:=hzname,desgndisc,desgnmaster,desgnmasterprime,desgnvert,hzdept_l,hzdept_r,hzdept_h,hzdepb_l,hzdepb_r,hzdepb_h,hzthk_l,hzthk_r,hzthk_h,fraggt10_l,fraggt10_r,fraggt10_h,frag3to10_l,frag3to10_r,frag3to10_h,sieveno4_l,sieveno4_r,sieveno4_h,sieveno10_l,sieveno10_r,sieveno10_h,sieveno40_l,sieveno40_r,sieveno40_h,sieveno200_l,sieveno200_r,sieveno200_h,sandtotal_l,sandtotal_r,sandtotal_h,sandvc_l,sandvc_r,sandvc_h,sandco_l,sandco_r,sandco_h,sandmed_l,sandmed_r,sandmed_h,sandfine_l,sandfine_r,sandfine_h,sandvf_l,sandvf_r,sandvf_h,silttotal_l,silttotal_r,silttotal_h,siltco_l,siltco_r,siltco_h,siltfine_l,siltfine_r,siltfine_h,claytotal_l,claytotal_r,claytotal_h,claysizedcarb_l,claysizedcarb_r,claysizedcarb_h,om_l,om_r,om_h,dbtenthbar_l,dbtenthbar_r,dbtenthbar_h,dbthirdbar_l,dbthirdbar_r,dbthirdbar_h,dbfifteenbar_l,dbfifteenbar_r,dbfifteenbar_h,dbovendry_l,dbovendry_r,dbovendry_h,partdensity,ksat_l,ksat_r,ksat_h,awc_l,awc_r,awc_h,wtenthbar_l,wtenthbar_r,wtenthbar_h,wthirdbar_l,wthirdbar_r,wthirdbar_h,wfifteenbar_l,wfifteenbar_r,wfifteenbar_h,wsatiated_l,wsatiated_r,wsatiated_h,lep_l,lep_r,lep_h,ll_l,ll_r,ll_h,pi_l,pi_r,pi_h,aashind_l,aashind_r,aashind_h,kwfact,kffact,caco3_l,caco3_r,caco3_h,gypsum_l,gypsum_r,gypsum_h,sar_l,sar_r,sar_h,ec_l,ec_r,ec_h,cec7_l,cec7_r,cec7_h,ecec_l,ecec_r,ecec_h,sumbases_l,sumbases_r,sumbases_h,ph1to1h2o_l,ph1to1h2o_r,ph1to1h2o_h,ph01mcacl2_l,ph01mcacl2_r,ph01mcacl2_h,freeiron_l,freeiron_r,freeiron_h,feoxalate_l,feoxalate_r,feoxalate_h,extracid_l,extracid_r,extracid_h,extral_l,extral_r,extral_h,aloxalate_l,aloxalate_r,aloxalate_h,pbray1_l,pbray1_r,pbray1_h,poxalate_l,poxalate_r,poxalate_h,ph2osoluble_l,ph2osoluble_r,ph2osoluble_h,ptotal_l,ptotal_r,ptotal_h,excavdifcl,excavdifms,cokey,chkey

muaggatt.cols:=musym,munamed,mustatus,slopegraddcp,slopegradwta,brockdepmin,wtdepannmin,wtdepaprjunmin,flodfreqdcd,flodfreqmax,pondfreqprs,aws025wta,aws050wta,aws0100wta,aws0150wta,drclassdcd,drclasswettest,hydgrpdcd,iccdcd,iccdcdpct,niccdcd,niccdcdpct,engdwobdcd,engdwbdcd,engdwbll,engdwbml,engstafdcd,engstafll,engstafml,engsldcd,engsldcp,englrsdcd,engcmssdcd,engcmssmp,urbrecptdcd,urbrecptwta,forpehrtdcp,hydclprs,awmmfpwwta,mukey

db/statsgo.mapunit:db/statsgo.%:db/statsgo
	${PG} -f $*.sql
	unzip -p ${zip} ${tab}/$*.txt |\
	${PG} -c "COPY statsgo.$* (${$*.cols}) FROM STDIN DELIMITER AS '|' CSV QUOTE AS '\"'";
	touch $@

db/statsgo.muaggatt db/statsgo.comp:db/statsgo.%:db/statsgo.mapunit
	${PG} -f $*.sql
	unzip -p ${zip} ${tab}/$*.txt |\
	${PG} -c "COPY statsgo.$* (${$*.cols}) FROM STDIN DELIMITER AS '|' CSV QUOTE AS '\"'";
	touch $@

db/statsgo.chorizon:db/statsgo.%:db/statsgo.comp
	${PG} -f $*.sql
	unzip -p ${zip} ${tab}/$*.txt |\
	${PG} -c "COPY statsgo.$* (${$*.cols}) FROM STDIN DELIMITER AS '|' CSV QUOTE AS '\"'";
	touch $@


# Goes blazing fast when you don't compose the polys.  Have to be
# careful when you run this, since it does depend on pfarm_county and
# ssurgo.map_unit_poly (The single one)
db/statsgo.county_map_unit_poly:db/%:db/network.county db/ssurgo.map_unit_poly
	${PG} -f '$(subst .,/,$*).sql'
	touch $@


