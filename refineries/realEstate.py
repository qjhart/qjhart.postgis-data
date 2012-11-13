# -*- coding: utf-8 -*-
"""
This script uses LoopNet data acquired in Novemner of 2012 on industrial properties in the AHB-NW region to create a basis fromwihc to estimate land costs taking into account spatial variation in market value.

The script uses the Google Geocoding API (https://developers.google.com/maps/documentation/geocoding/) to locate nased upon city and state names. The limits on the geocoding api ar 2500 per 24 hour period so if its not working, wait a day...

"""

import sys
sys.path.append('../ahb_python')
from bs4 import BeautifulSoup as bs
import json, shutil,time, db, tempfile, tarfile
import urllib as urll
from numpy import linspace

### File management ###
pages=range(1,26)
tDir=tempfile.mkdtemp()
tFile=tarfile.open('loopnet.tar.gz')
tFile.extractall(path=tDir)
tFile.close()
loc=tDir+"/loopNet/%s.html"


geocodeUrl="http://maps.googleapis.com/maps/api/geocode/json?address=%s+%s&sensor=false"

### needs to be a table to recieve the data ###
insertData="insert into real_estate (city,state,year,salemin,salemax,acremin,acremax,json,geom)\
            values ('%s','%s',%s,%s,%s,%s,%s,$$%s$$,\
            st_transform(st_setsrid(st_makepoint(%s,%s),4326),97260))"


def checkQueryOverload(geocodeUrl, waitTime):
    """
    the query api seems to return a limit exceeded periodically if the request come too rapidly. this function waits if the query returns a limit exceeded error. If you have exceeded the daily limit and run this script it will just keep going...i dont know how long
    """
    jsn=json.loads(urll.urlopen(geocodeUrl).read())
    for i in linspace(0,waitTime):
        if jsn['status']=='OVER_QUERY_LIMIT':
            count=0
            while (count < 10):
                while (jsn['status']=='OVER_QUERY_LIMIT'):
                    print 'google query overload, waiting %s seconds...'%i
                    time.sleep(i)
                    jsn=json.loads(urll.urlopen(geocodeUrl).read())
                count = count + 1
    return jsn


for p in pages:
    soup=bs(open(loc%p).read())
    searchResults=soup.find_all("div",attrs={'class':'searchResultDesc'})
    for r in searchResults:
        if r.a!=None: 
            addString=r.a['href'].split('/')[5].split('-')
            street,city,state,zipcode=' '.join([i for i in addString[:4]]),addString[4], addString[5],addString[6]
            print street.replace(' ','+')+'+'.join([city,state,zipcode])
        else:
            city,state=r.em.string.split(', ')
            salePriceRange=()
            acrePriceRange=()
            priceRange=[i for i in r.h2.children][-1]
            salePriceRange=[int(i) for i in priceRange.string.replace('$','').replace(',','').split('-')]
            sibs=[i for i in r.em.next_siblings]
            if sibs[0].string != None:
                acreRange=[float(i) for i in sibs[0].string.replace('$','').replace('/Acre','').replace(',','').split('-')]
            date=int(r.h2.children.next().split(' ')[2])
            js=checkQueryOverload(geocodeUrl%(city,state),15)
            graticule=['lat','lng']
            lat,lng=[js['results'][0]['geometry']['location'][i] for i in graticule]
            db.queryCommit(insertData%(city,state,date,salePriceRange[0],\
            salePriceRange[1], acreRange[0],acreRange[1],js,lng,lat), search_path='public, refineries')
    print 'completed scraping data from page '+str(p) +' of 25'

###Removes the unzipped temporary directory
shutil.rmtree(tDir)    
