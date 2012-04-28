# -*- coding: utf-8 -*-
from osgeo import gdal, ogr, osr

#Reproject source 4326 to 26910
drv=ogr.GetDriverByName("ESRI Shapefile")
shpf=drv.Open("../solar/dniHigh/dniHigh_pnw.shp")
lyr0=shpf.GetLayerByIndex(0)
srsIn=osr.SpatialReference()
srsOut=osr.SpatialReference()
srsIn.CopyGeogCSFrom(lyr0.GetSpatialRef())
srsOut.ImportFromEPSG(26910)
trans=osr.CoordinateTransformation(srsIn,srsOut)


for ft in range(lyr0.GetFeatureCount()):
    feat=lyr0.GetFeature(ft)
    geom=feat.GetGeometryRef()
    geom.Transform(trans)
