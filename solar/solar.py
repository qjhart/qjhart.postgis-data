import sys
sys.path.append('../ahb_python')
import db

tname=sys.argv[1]

sql=open('pnw_solar_v.sql','r').read()
size=db.query('select distinct size from pixels')
metric=db.query("select column_name from information_schema.columns where table_name='ghi_1deg_pnw' and data_type='smallint'")

for s in size:
    for m in metric:
        rSize=int(s[0])
        rMetric=m[0]
        sqlR=sql%(rMetric,rMetric,rSize,)
        print 'building weighted average Global Horizontal Irradiance for time period: %s and scale: %s'%(rMetric,rSize)
        db.queryCommit("insert into %s (pid, ghi_name, ghi_wavg ) %s "%(tname, sqlR))
