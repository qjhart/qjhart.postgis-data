from osgeo import ogr
import sys

def getSR(shapeFID, dr_type='ESRI Shapefile'):
    drv=ogr.GetDriverByName(dr_type)
    ds=drv.Open(shapeFID)
    if ds is None:
        print "Open failed.\n"
        sys.exit(1)
    lyr=ds.GetLayer(0)
    sr=lyr.GetSpatialRef()
    out={'projcs': [sr.GetAuthorityName('PROJCS'), sr.GetAuthorityCode('PROJCS')], 'geogcs': [sr.GetAuthorityName('GEOGCS'), sr.GetAuthorityCode('GEOGCS')], 'proj4': sr.ExportToProj4()}
    return out
