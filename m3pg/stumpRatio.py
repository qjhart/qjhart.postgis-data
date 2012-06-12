# -*- coding: utf-8 -*-
"""
Created on Wed May  9 14:53:53 2012

@author: peter
"""

import numpy as np
from sympy.mpmath import isnan
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt


from allometry import *
kgDens=density['alder'][0]/1000

def fitEqn(x,a,b):
    return a*pow(x,b)


### get height secion pairs (h_n,h_n+1)


def tWH(minV=8.0, maxV=50.0, count=10):
    '''
    function produces an array of
    volume, height, and dbh at linspace intervals 
    between a min (minV=8) and max (maxV=50)
    '''
    v=np.linspace(minV,maxV, count)
    h=[getHeight(i,getDBH(i)) for i in v]
    d=[getDBH(i) for i in v]
    return np.column_stack((v,h,d))
    
## Set taper regression coefficients
tParams=np.array((params('Beaupre'),params('Luisa Avanzo')))
a,b,c=[np.average(tParams[:,i]) for i in range(len(tParams[0]))]

inputs=tWH(count=30)

##set tolerance for volume matching in kg
t1=1.5
stump_height=10
oAr=np.empty([len(inputs),5])
oCt=0
f=open('plots/stumpvol.csv','w')

for i in inputs:
    #print i
    ht=i[1]
    dbh=i[2]
    while (np.abs(i[0]-integVol(dbh, i[1], [a,b,c], kgDens)['mass'])>=t1):
        diff=i[0]-integVol(dbh, i[1], [a,b,c], kgDens)['mass']
        #print np.abs(diff)
        if diff > 0:
            #print 'increasing dbh'
            dbh=dbh + 0.1
            #print dbh
        elif diff < 0:
            #print 'decreasing dbh'
            dbh=dbh - 0.1
        print diff
    treeMass=integVol(dbh, i[1], [a,b,c], kgDens)['mass']
    BD=estBd(dbh, ht,params())   
    #print BD,diamFromHt(a,b,c,BD,stump_height,ht),stump_height
    stumpMass=secVol(BD,diamFromHt(a,b,c,BD,stump_height,ht),stump_height)['volume']*kgDens
    oAr[oCt]= [dbh,ht,treeMass,stumpMass,stumpMass/treeMass]   
    oCt = oCt+1
    f.write('%s,%s,%s\n'%(dbh,ht,stumpMass/treeMass))
f.close()

##determine coefficeints for fit
af,bf=curve_fit(fitEqn, oAr[0:,2],oAr[0:,4])[0] 
    

plt.xlabel(r'Stem mass (kg)')
plt.ylabel(r'$M_{stump}/M_{stem}$')
plt.title('10 cm stump mass ratio estimated by\n$M_{stump}:M_{stem}=%s M_{stem}^{%s}$'%(af,bf))            
plt.plot(fitEqn(np.linspace(5,80,100), af,bf),'k')
plt.savefig('plots/curve.png')

   # print 'original dbh= %s\nfinal dbh=%s\n'%(delta,i[2],dbh)
    #print integVol(i[2], i[1], params(), kgDens).values()
    
### determine volume

