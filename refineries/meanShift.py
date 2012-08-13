# -*- coding: utf-8 -*-
"""
Created on Tue Jul 24 11:25:00 2012
This implements a mean shift clustering approach to
@author: peter
"""
import numpy as np, sys 
sys.path.append('../ahb_python')
import db
from sklearn.cluster import MeanShift, estimate_bandwidth

caFRS=np.array(db.query("select ogc_fid,\
                        st_x(st_transform(wkb_geometry,26910)), \
                        st_y(st_transform(wkb_geometry,26910)) \
                        from env_geodata_shp \
                        where loc_state='CA'",\
                        'enviro','public'),\
                        dtype=[('pid', '<i4'), ('x', '<f8'), ('y', '<f8')])

coords=np.column_stack((caFRS['x'],caFRS['y']))
#bw=estimate_bandwidth(coords)
bw_m=2500 #2.5 km
ms=MeanShift(bw_m)
ft=ms.fit(coords)

db.queryCommit("drop table if exists centers; \
                create table centers (label real,\
                cid serial primary key);\
                select addgeometrycolumn('centers',\
                'geom',4269,'POINT',2)"\
                ,'enviro','public')

db.queryCommit("alter table env_geodata_shp drop column center;\
                alter table env_geodata_shp add column center int;"\
                ,'enviro','public')

inst='insert into centers (label,geom) values(%s,st_transform(ST_SetSRID(ST_Point(%s,%s),26910),4269))'
insP='update env_geodata_shp set center=%s where ogc_fid=%s'

for i in xrange(len(ft.cluster_centers_)):
    #print inst%(bw,i,ft.cluster_centers_[i][0],ft.cluster_centers_[i][1])
    db.queryCommit(inst%(i,ft.cluster_centers_[i][0],ft.cluster_centers_[i][1]),'enviro','public')

for t in range(len(caFRS)):
    db.queryCommit(insP%(ft.labels_[t], caFRS[t][0]),'enviro','public')

print bw_m
