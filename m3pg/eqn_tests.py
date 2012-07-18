# -*- coding: utf-8 -*-
"""
Created on Thu May 24 19:01:05 2012

@author: peter
"""
import numpy as np
from allometry import *
import matplotlib.pyplot as plt

## Set taper regression coefficients
tParams=np.array((params('Beaupre'),params('Luisa Avanzo')))
a,b,c=[np.average(tParams[:,i]) for i in range(len(tParams[0]))]

v=30
dbh=getDBH(v)
H=getHeight(v,dbh)
DB=estBd(dbh,H,[a,b,c])
intHt=np.linspace(0,H)
intHtm=np.linspace(0,H/100)
#plt.plot([diamFromHt(a,b,c,DB,i,H) for i in intHt])
plt.plot([diamFromHt(a,b,c,DB,i,H) for i in intHtm])
plt.savefig('plots/test.png')
plt.close()

