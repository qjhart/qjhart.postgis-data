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
import sys

def TxEqn(tex,label=''):
    eq=r'%s'%tex
    return '\\begin{equation}\n\
    \\label{eqn:%s}\n\
    %s\n\
    \\end{equation}'%(label,eq)

def TxFig(img,width='0.5\\textwidth',caption='',label=''):
    tx='\\begin{figure}[h]\n \
    \\centering\n\
    \\includegraphics[width=%s]{%s}\n\
    \\caption{%s}\n\
    \\label{fig:%s}\n\
    \\end{figure}\n'%(width,img,caption,label)
    return tx
    
def fitEqn(x,a,b):
    return a*pow(x,b)

#Height eqn
H_eq, H_tex=brahimEqn('H')

## Set taper regression coefficients
tParams=np.array((params('Beaupre'),params('Luisa Avanzo')))
a,b,c=[np.average(tParams[:,i]) for i in range(len(tParams[0]))]

#Set stump height
#sH=sys.argv[1]
sH=10.0 #cm

#Wood density
dens=density['alder'][0]

def pltLine(xlab,ylab,data,fname):
    plt.xlabel(xlab)
    plt.ylabel(ylab)
    #plt.title(title)            
    plt.plot(data,'k')
    plt.savefig('graph/%s.png'%fname)
    


def tWH(minV=5.0, maxV=20.0, count=10):
    '''
    function produces an array of
    volume, height, and dbh at linspace intervals 
    between a min (minV=8) and max (maxV=50)
    '''
    
    D,M,d= symbols('D M d')
    v=np.linspace(minV,maxV, count)
    h=[float(H_eq[0].subs(D,getDBH(i)[0]).subs(M,i).subs(d,getDBH(i)[0])) for i in v]
    d=[float(getDBH(i)[0]) for i in v]
    db=[float(estBd(d[i],h[i],[a,b,c])[0]) for i in range(len(v))]
    sD=[float(diamFromHt(a,b,c,db[i],sH,h[i])) for i in range(len(v))]
    sV=[float(secVol(db[i],sD[i],slen=sH)['volume']) for i in range(len(v))]
    sW=[float((sV[i]*dens)/1000) for i in range(len(v))]
    s_ratio=[float(sW[i]/v[i]) for i in range(len(v))]
    return np.column_stack((v,h,d,db, sD, sV, sW, s_ratio))

data=tWH(count=50)

af,bf=curve_fit(fitEqn, data[0:,0],data[0:,7])[0] 
    
xlb=r'Stem mass (kg)'
ylb=r'$M_{stump}/M_{stem}$'
#tit='10 cm stump mass ratio estimated by\n$M_{stump}:M_{stem}=%s M_{stem}^{%s}$'%(af,bf)            
dt=fitEqn(np.linspace(5,80,100), af,bf)
nm='nlm_stump'

pltLine(xlb,ylb,dt,nm)

doc=open('stumpVol.tex','w')
doc.write('\\subsubsection{Stump volume}\n\\label{sec:allo}\nFirst, $dbh$ is calculated from tree mass $M$\n')
doc.write(TxEqn('dbh=aM^b','dbh'))
doc.write('as in (\\ref{eqn:form}) where $a=%s$ and $b=%s$ from \\cite{Landsberg1997}.\n'%(getDBH(8)[1],getDBH(8)[2]))
doc.write('We the calculate total tree height ($H$) using coefficients provided by \\cite{Brahim2000}\n')
doc.write(TxEqn(H_tex,'height'))
doc.write('where $D$ is $dbh$ for the individual tree and $d$ is the stand average $dbh$. The use of stand average can improve the accuracy of the relationship, however as the 3-PG model does not predict variation in $dbh$ between stands we simply use the derived $dbh$ from \\ref{eqn:dbh} fro both values. \\citeauthor{Benbrahim2003} also provides (\\ref{eqn:taper}) to determine diameter at a given height or height at a given diameter:\n')
doc.write(TxEqn(r'0=-d+\left(b_d-b_d\left(\frac{\log{\frac{1-h}{Ha}}}{-b}\right)^{1/c}\right)','taper'))
doc.write('The taper equation provided by \\citeauthor{Benbrahim2003} also requires a basal diameter ($b_d$). We calculate $b_d$ modifying equation (\\ref{eqn:taper}) using coefficients provided and $H$, $dbh$ from above. Using a stump height of %s cm we calculate the top stump diameter with whihc we can calculate the stump volume.\n'%sH)
doc.write(TxEqn(secVol(12,14)['tex'],'sectionvolume'))
doc.write('We then calculate stump mass using a wood density of %s %s and compare with total tree mass $M$'%(density['alder'][0],density['alder'][1]))
doc.write('\n\\subsubsection{Stump volume regression}\n')
doc.write('To determine a simplified relationship between tree volume and stump volume we derive coefficients $a$ and $b$ in (\\ref{eqn:form}) using a the ratio of stump mas to total stem mass over a range of stem volumes based on the allometric relationships in section \\ref{sec:allo}.')
doc.write(TxFig(nm+'.png',caption='Stump to stem volume ratio as a function of stem volume', label='stump_vol'))
doc.write('Coefficients used in calculating stump volume as a function of total stem volume were found to be $a=%s$ and $b=%s$.'%(af,bf))  


doc.close()
print 'a= %s\nb= %s'%(af,bf)
