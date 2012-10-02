"""
The objective here is to implement the site selection heuristc. the steps are as follows:

1. cluster places with > 100 popn to 2.5 km
2. custer FRS locations meeting NAICS criteria to 2.5km
3. ID FRS locations within 5km of clustered places
4. Score locations

"""
import numpy as np, sys 
sys.path.append('../ahb_python')
import db
from sklearn.cluster import MeanShift, estimate_bandwidth
import pandas as pd

##Set mean shift clustering bandwidth
#bw_m=2500 #2.5 km
#ms=MeanShift(bw_m)


def clTable(ft, schema, name, srid=97260):
    '''
    ft = is a MeanShift.fit object
    '''
    drop='drop table if exists %s.%s cascade'%(schema,name)
    db.queryCommit(drop,search_path='public,%s'%schema)
    create='create table %s.%s (clabel int primary key, geom geometry)'%(schema,name)
    db.queryCommit(create)
    insert='insert into %s values(%s, st_setsrid(st_makepoint(%s,%s),%s))'
    for c in range(len(ft.cluster_centers_)):
        db.queryCommit(insert%(name,c,ft.cluster_centers_[c][0],ft.cluster_centers_[c][1],srid), search_path='public,%s'%schema)

def linkClst(ft, orig, schema, name, id_pos=0):
    '''
    orig is the original points subjected to clustering
    ft is the MS fit object
    schema: target schema
    name: table name
    id_pos: is the row identity to link source table primary id to cluster label, default is 0
    '''
    drop='drop table if exists %s.%s cascade'%(schema,name)
    create='create table %s.%s (gid varchar(128), clabel int)'%(schema,name)
    [db.queryCommit(q, search_path='public, %s'%schema) for q in [drop,create]]
    insert='insert into %s values(\'%s\', %s)'
    for r in range(len(ft.labels_)):
        db.queryCommit(insert%(name, orig[id_pos][r], ft.labels_[r]), search_path=schema)


def clusterPoints(df, bw, table_name, schema='refineries',pos=[1,2]):
    """
    Parameters
    ---------
    df : pandas DataFrame with formated |id|st_x|st_y|
    bw : mean shift bandwidth in SRID map units
    table_name : base table name for clustered points
    schema: target schema for the tables
    pos : data frame index position of lat and long coords, default is [1,2]

    Returns
    -------
    table summaries
    """
    ms=MeanShift(bw)
    ft=ms.fit(np.asarray(df[pos]))
    cTabNam=['%ss_%s'%(table_name,bw),'%s_%s_link'%(table_name,bw)]
    clTable(ft,'refineries',cTabNam[0])
    cRows=db.query('select count(*) from %s'%(cTabNam[0]),search_path=schema)
    print '%s cluster centers table created with %s rows'%(cTabNam[0], cRows[0])
    linkClst(ft,df,'refineries',cTabNam[1])
    lRows=db.query('select count(*) from %s'%(cTabNam[1]),search_path=schema)
    print '%s table created with %s rows'%(cTabNam[1],lRows[0])

    


# ##cluster places > 100 pop
# popMin=100
# cp=db.query('select qid, st_x(centroid), st_y(centroid) from place, afri_pbound  where pop_2000>%s and geom ~ centroid;'%popMin, search_path='afri,bts, public')
# placsDf=pd.DataFrame(cp)
# clusterPoints(placsDf,bw_m,'city_cluster')

# ##cluster EPA FRS
# frs=db.query('select gid,st_x(geom), st_y(geom) from pnw_target_frs', search_path='envirofacts, public')
# frsDf=pd.DataFrame(frs)
# clusterPoints(frsDf, bw_m, 'frs_cluster')

# #set FRS proxies for cities
# db.queryCommit



