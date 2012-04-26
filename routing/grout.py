# -*- coding: utf-8 -*-E
#ach query sent to the Distance Matrix API is limited by the number of allowed elements, where the number of origins times the number of destinations defines the number of elements.
#The Distance Matrix API has the following limits in place:
#100 elements per query.
#100 elements per 10 seconds.
#2 500 elements per 24 hour period.

#output from postgis DB like this select st_y(st_transform(centroid, 4326))||','||st_x(st_transform(centroid, 4326))||'|' from ethanol

import urllib, json, itertools
import numpy as np

originBox=[(41,-120), (40.746536,-123.918986)]
destBox= [(39.325064,-121.048808), (37.325733,-122.47703)]

def coordStr(urc,llc, elements=45):
    '''urc: upper right corner WGS84 (lat, long)
    llc: lower left corner WGS84 (lat, long)'''
    lspc=np.floor(np.sqrt(elements))
    minLat=min(urc[0],llc[0])
    maxLat=max(urc[0],llc[0])
    minLong=min(urc[1],llc[1])
    maxLong=max(urc[1],llc[1])
    coords = itertools.product(np.linspace(minLat,maxLat,lspc), np.linspace(minLong,maxLong,lspc))
    return {'coString':''.join(['%s,%s|'%(i[0],i[1]) for i in coords]).rstrip('|'), 'breaks': lspc}

def jsonRoutes(os, ds, output='json'):
    baseURL='http://maps.googleapis.com/maps/api/distancematrix/%s?origins=%s&destinations=%s&sensor=false'%(output,os,ds)
    print 'URL is %s characters'%len(baseURL)
    raw=urllib.urlopen(baseURL)
    return json.load(raw)
           
ori = coordStr(originBox[0], originBox[1])['coString']
des = coordStr(destBox[0], destBox[1])['coString']
jOb = jsonRoutes(ori, des)

#TODO grab route for the  5 least cost pathways using the Directions API http://code.google.com/apis/maps/documentation/directions/