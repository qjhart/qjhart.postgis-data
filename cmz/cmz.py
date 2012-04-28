import sys, urllib2, zipfile
sys.path.append('../ahb_python')
import db, gdal_utilities as gd

tname=sys.argv[1]


zones=db.query('select distinct cmz from cmz_pnw', 'cmz')

url='ftp://fargo.nserl.purdue.edu/pub/RUSLE2/Crop_Management_Templates/%s.zip'
for z in zones:
    zUrl=url%(z)
    urllib2.urlopen(zUrl)
