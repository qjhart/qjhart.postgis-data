# -*- coding: utf-8 -*-
"""
Created on Tue May  8 15:24:53 2012
The objective here is to determine the fraction of total above ground biomass that remains
given a coppiced harvest system using a header leaving a stump height of h_s and 
given a total tree height
units for height are in meters
units for diameter are in cm
@author: peter tittmann
"""

from numpy import pi, exp, log10, average, power as pwr, linspace, column_stack
import csv
from sympy import solve, latex, pi as sy_pi, log as slog, power
from sympy.mpmath import isnan

density={'alder':[0.38,'$g \\cdot cc^{-1}$']}

def secPairs(H,count=20):
    ls= linspace(0,H,count)
    return column_stack((ls[0:-1],ls[1:]))

def params(cVar='Beaupre'):
    vr=["Beaupre", "Luisa Avanzo"]
    a={vr[0]:[1.197,0.28],vr[1]:[1.332,0.061]}
    b={vr[0]:[2.253,0.77],vr[1]:[1.777,0.056]}
    c={vr[0]:[1.799,0.26],vr[1]:[1.471,0.02]}
    return [a[cVar][0],b[cVar][0],c[cVar][0]]
    
def secVol(d1, d2, slen=5):
    '''
    from Benbrahim, M. and Galvand, A
    d1=diameter at bottom of segment
    d2=diameter at top of segment
    '''
    vol=(slen*pi/12)*(d1**2+d2**2+d1*d2)
    tex=r"V=\left(\frac{l\pi}{12}\right)(d_1^2+d_a^2+d_1d_2)"
    return {'volume':vol, 'tex':tex, 'params': [slen, d1,d2]}


#def secVol(d1, d2, slen=5):
#    '''
#    from Benbrahim, M. and Galvand, A
#    d1=diameter at bottom of segment
#    d2=diameter at top of segment
#    units are in centimeters
#    '''
#    from sympy.abc import l,b,t,#    eqn=(l*sy_pi/12)*(b**2+t**2+b*t)-V
#    vol=float(solve(eqn,V)[0].subs(b,d1).subs(t,d2).subs(l,slen))
#    tex=latex(solve(eqn,V))
#    return {'volume':vol, 'tex':tex, 'params': [slen, d1,d2]}

def tap(p=params(),solve_for='d'):
    '''doesnt work'''
    a,b,c=p
    from sympy.abc import d,D,h,H
    eqn=(D-D*power.Pow(slog(1-(h/(H*a)),10)/-b, 1/c))-d
    return solve(eqn,solve_for)
    


def htFromDiam(a,b,c,d_b,d,H):
    '''
    a,b,c are regression coefficients, see params
    d_b = diameter at trunk base in cm
    d = top diameter at which to determine height in cm
    H = total tree height in m
    '''
    sub1=float(d_b-d)/d_b
    sub2=-b*pwr(sub1,c)
    sub3=H*a*(1-exp(sub2))
    return [sub1, sub2, sub3]

def diamFromHt(a,b,c,d_b,h,H):
    '''
    a,b,c are regression coefficients, see params
    d_b = diameter at trunk base
    d = top diameter at which to determine height
    H = total tree height
    '''
    sub1=pow(log10(float(1-(h/(H*a))))/-b,1/c)
    sub2=d_b-d_b*sub1
    return sub2

def getDBH(stem_mass, coeffs='dbh_coeffs.csv', spp=['Acer saccharum', 'Populus tremuloides']):
    '''
    3-PG predicts stem volume, we predict DBH from stem volume here.
    The allometric equation describing the relationship for the mass of a given biomass
    component (stem, leaves) to the total biomass is:
        $W_i=a_iW^{n_i}$
    '''
    f= open(coeffs,'rt')
    try:
        reader = csv.DictReader(f)
        co=[[float(i['as']),float(i['ns'])] for i in reader if i['species'] in spp]
        a=average([i[0] for i in co])
        n=average([i[1] for i in co])
    finally:
        f.close()
    return [pow(stem_mass/a, float(1/n)), a,n]

def getHeight(mass,dbh):
    '''
    inputs should be floats
    from Brahim2000
    '''
    from sympy import solve
    from sympy.abc import W,H,D
    a,b,c,d=3.85, 68E-06, 2.34, -0.017
    m=solve((a+b*H*D**c+d*D**c)-W,H)
    return m[0].subs(W,mass).subs(D,dbh)
    
    #return (dbh**(-c)*(-a + mass)/b)**(1/d)
    #return dbh**-2.34*(-250.0*dbh**2.34 + 14705.8823529412*mass - 56617.6470588235)
    #return 3.85+68E-6*mass*pow(dbh,2.34)-0.017*pow(dbh,2.34)

def brahimEqn(solve_for='H'):
    '''
    solve allometric equation from Brahim2000 for
    H= height
    D= diameter at breast height
    p= stand average diameter at breast height
    W= dry weight
    
    As 3pg only produces a biomass estimation we have ti use the same value for 
    stand average DBH (d) and DBH (D)
    '''
    from sympy import solve, latex
    from sympy.abc import M,H,D,d
    a,b,c,e=3.85, 68E-06, 2.34, -0.017
    eqn=-M+(a+b*H*pow(D,c)+e*pow(d,c))
    res=solve(eqn,solve_for,rational=False)
    return [res, latex(res)]

def estBd(dbh,height,coeffs):
    '''
    coeffs should be a list of parameters from benbrahim
    '''
    a,b,c=coeffs
    from sympy import log, solve
    from sympy.abc import B     
    h=1.4
    H=height/100
    d=dbh
    eq=solve((B-B*(log(1-h/(H*a),10)/-b)**1/c)-d,B,rational=False)[0]
    m=eq.evalf()
    return [m.evalf(), latex(eq)]

def integVol(dbh, height, coeffs, wood_density):
    '''
    height in cm
    dbh in cm
    wood density in kg/cm^3
    '''
    from sympy.mpmath import isnan
    a,b,c=coeffs
    Hcm=height
    Hm=height/100
    bD=estBd(dbh,Hcm, [a,b,c])
    seg_vols=[]
    for se in secPairs(Hm):
        if se[0]==0:
            d1=bD
        else:
            d1=diamFromHt(a,b,c,bD, se[0], Hm)
        d2=diamFromHt(a,b,c,bD, se[1], Hm)
    #        print 'diam1=%s\n\
    #        diam2=%s\n\
    #        segment length=%s\n\
    #        tree height=%s\n\
    #        a=%s\n\
    #        b=%s\n\
    #        c=%s\n\
    #        dbh=%s\n\
    #        basal diameter=%s\n\
    #        segment base height=%s\n\
    #        segment top height=%s\n'%(d1,d2, (se[1]-se[0])*100, Hcm,a,b,c,dbh,bD, se[0],se[1])
        if isnan(secVol(d1,d2, (se[1]-se[0])*100)['volume'])==False:
            seg_vols.append(secVol(d1,d2, (se[1]-se[0])*100)['volume'])  
        else:
            print 'found nan' 
        print 'd1=%s d2=%s'%(d1,d2)

    return {'volume':sum(seg_vols), 'mass': sum(seg_vols)*wood_density}



#def findBdiam()
###integrate volumes
