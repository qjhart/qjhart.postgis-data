import sys,tempfile, shutil, sqlite
sys.path.append('../ahb_python')
import db, gdal_utilities as gd, utils

tempfile.tempdir='.'
    
zones=db.query('select distinct cmz from cmz_pnw', 'cmz')
#url='%s'%sys.argv[1]
url='ftp://fargo.nserl.purdue.edu/pub/RUSLE2/Crop_Management_Templates/%s.zip'


###################################
#create table in afri postgresql
###################################
tdir=tempfile.mkdtemp()
gdb=utils.extractZip(url%zones[0],tdir)[0]

sq=db.sqliteQ("select sql from sqlite_master where type='table' and name='managements'", gdb)[0][0].replace("'managements'", "managements").replace("varvchar", "varchar").replace('text(8)','text')
mkTable='drop table if exists cmz.managements; '+sq
db.queryCommit(mkTable,'cmz')
shutil.rmtree(tdir)


