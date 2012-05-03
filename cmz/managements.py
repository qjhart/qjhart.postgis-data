import sys, tempfile, shutil, sqlite
sys.path.append('../ahb_python')
import db, gdal_utilities as gd, utils

tempfile.tempdir='.'
    
zones=db.query('select distinct cmz from cmz_pnw', 'cmz')

url='%s'%sys.argv[1]
#ftp://fargo.nserl.purdue.edu/pub/RUSLE2/Crop_Management_Templates/%s.zip'

tmdir=tempfile.mkdtemp()

filelist=[]

for l in range(len(zones)):
    filelist.append(utils.extractZip(url%zones[l],tmdir)[0])
    print 'downloaded and extracted zone %s'%zones[l]

#print ' '.join([i for i in filelist])


