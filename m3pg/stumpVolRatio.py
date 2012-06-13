# -*- coding: utf-8 -*-
"""
Created on Mon Jun 11 18:56:57 2012

@author: peter

3PG outputs biomass/tree we need to determine the biomass of the stump
to determine this we will use the taper equation from benbrahim and galvand for which 
the followimg in necessary:

basal diameter
total tree heigh

to estimate the basal dimaeter we need  to:
1. use DBH and parameters from benbrahim

"""

from allometry import *
from sympy import *
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

def fitEqn(x,a,b):
    return a*pow(x,b)

#Height eqn
H_eq, H_tex=brahimEqn('H')

## Set taper regression coefficients
tParams=np.array((params('Beaupre'),params('Luisa Avanzo')))
a,b,c=[np.average(tParams[:,i]) for i in range(len(tParams[0]))]

#Set stump height
sH=10.0 #cm

#Wood density
dens=density['alder'][0]

def pltLine(xlab,ylab,title,data,fname):
    plt.xlabel(xlab)
    plt.ylabel(ylab)
    plt.title(title)            
    plt.plot(data,'k')
    plt.savefig('plots/%s.png'%fname)
    


def tWH(minV=5.0, maxV=20.0, count=10):
    '''
    function produces an array of
    volume, height, and dbh at linspace intervals 
    between a min (minV=8) and max (maxV=50)
    '''
    
    D,W,p= symbols('D W p')
    v=np.linspace(minV,maxV, count)
    h=[float(H_eq[0].subs(D,getDBH(i)).subs(W,i).subs(p,getDBH(i))) for i in v]
    d=[float(getDBH(i)) for i in v]
    db=[float(estBd(d[i],h[i],[a,b,c])) for i in range(len(v))]
    sD=[float(diamFromHt(a,b,c,db[i],sH,h[i])) for i in range(len(v))]
    sV=[float(secVol(db[i],sD[i],slen=sH)['volume']) for i in range(len(v))]
    sW=[float((sV[i]*dens)/1000) for i in range(len(v))]
    s_ratio=[float(sW[i]/v[i]) for i in range(len(v))]
    return np.column_stack((v,h,d,db, sD, sV, sW, s_ratio))

data=tWH(count=50)

af,bf=curve_fit(fitEqn, data[0:,0],data[0:,7])[0] 
    
xlb=r'Stem mass (kg)'
ylb=r'$M_{stump}/M_{stem}$'
tit='10 cm stump mass ratio estimated by\n$M_{stump}:M_{stem}=%s M_{stem}^{%s}$'%(af,bf)            
dt=fitEqn(np.linspace(5,80,100), af,bf)
nm='curve2'

pltLine(xlb,ylb,tit,dt,nm)
