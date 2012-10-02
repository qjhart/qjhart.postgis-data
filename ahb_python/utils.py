import os, zipfile as zp, urllib, csv, json, pandas as pd
from numpy import average as avg
from numpy import std as std
from numpy import floor, ceil

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def extractZip (URL,DIR):
    '''
    URL is a reference locator pointing to a zip file
    DIR is a target directory

    returns a list of pathnames to extracted files
    '''
    name=DIR+'/'+os.path.basename(URL)
    urllib.urlretrieve(URL,name)
    zf=zp.ZipFile(name)
    return [zf.extract(zf.namelist()[i],DIR) for i in range(len(zf.namelist()))]
    
# For a future moment....
# pandas may be relevant to this, good data loading and column typing capabilities
# def csvtosql(dict, table_name, schema='public'):
#     '''
#     pass a csv.DictReader object so we dont need to deal with filenames
#     '''
#     create= 'create table %s.%s (%s);'
#     for f in dict.fieldnames:
        
def standardScore(ind,raw,ar):
    '''
    ind -- the index of the array of raw scores. 
    raw -- the index of arr for which the standard score in arr is desired
    arr -- is a numpy array
    ######
    returns the standard score $\frac{x-\mu}{\sigma}$
    '''
    return (raw[ind]-avg(ar))/std(ar)

def fusionQuery (table, query, apikey='AIzaSyDv-8N5AOJZgw6UcVZ7l0SMa1Ko7vdY6xo'):
    '''
    Parameters
    ----------
    apikey: the fusion table api key
    table: google table locator
    query: fusion table sql

    Returns
    -------
    list containing 2 items.
    [0]: is a pandas DataFrame contiaing the results of the query.
    [1]: is a list of column names.
    '''
    baseUrl='https://www.googleapis.com/fusiontables/v1/%s'
    QK='query?sql=%s from %s&key=%s'%(query,table,apikey)
    js=json.load(urllib.urlopen(baseUrl%QK))
    return [pd.DataFrame(js['rows']), js['columns']]

## this funtion is not complete
def fusionMod (table, query, apikey='AIzaSyDv-8N5AOJZgw6UcVZ7l0SMa1Ko7vdY6xo'):
    '''
    Parameters
    ----------
    apikey: the fusion table api key
    table: google table locator
    query: fusion table sql without from clause

    Returns
    -------
    list containing 2 items.
    [0]: is a pandas DataFrame contiaing the results of the query.
    [1]: is a list of column names.
    '''
    baseUrl='https://www.googleapis.com/fusiontables/v1/%s'
    QK='query?sql=%s from %s&key=%s'%(query,table,apikey)
    js=json.load(urllib.urlopen(baseUrl%QK))
    return [pd.DataFrame(js['rows']), js['columns']]


class railCost:
    """
    Class can be used to calculate the costs of constructing rail spurs. The inputs are derived from the State of Michigan SUBDIVISION DEVELOPMENT COSTS SECTION UIP 16 available at http://www.michigan.gov/documents/Vol2-40UIP16SubDevCosts-YardCosts-Demolition_121083_7.pdf.
    Costs calculation include scaling based upon rail weight and icludes costs fro interconnection, road crossings, bumpers, and wheel stops.  
    """
    costs={'weight':[40,60,80,100,115,130,'lbs/ft'],\
           'minlc':[49.5,62.5,73.75,84.25,91.5,98.25,'$/ft'],\
           'maxlc':[62.75,78.25,91.75,103.5,111.75,119.5,'$/ft'],\
           'mincross':[17250,21000,24250,27000,29500,31750,'$'],\
           'maxcross':[22000,26000,30500,34250,36750,39500,'$']}

    bumperCost=3550
    crossingSignals=1295
    #concrete roadbed cost is currently not used in this class but is referenced in the report.
    concreteRoadbed=[85,'$/ft'] 
    crossingTimbers=300
    wheelStopCost=835
    
    def linecost(self,length,railWeight):
        """
        length is the line length in feet
        railWeight must be one of the following 40,60,80,100,115,130 in lbs/ft
        """
        d=self.costs['weight'].index(railWeight)
        return (length*avg([self.costs[i][d] for i in ['minlc','maxlc']]))+ avg([self.costs[i][d] for i in ['mincross','maxcross']])

    def lengthFactoredCost(self,length,railWeight):
        """
        calcualtes the length dependent cost scaling for lengths <> 500 ft.
        length is the line length in feet
        railWeight must be one of the following 40,60,80,100,115,130 in lbs/ft
        """
        lc=self.linecost(length,railWeight)
        maxDed=0.25*lc
        if length <= 500:
            incPct=ceil(length/100)*0.02
            return lc+(lc*incPct)
        else:
            dedPct=floor((length-500)/100)*0.02
            return max([maxDed, lc-(lc*dedPct)])

    def railSpurCost(self,length, crossings=0, bumpers=0,railWeight=80, wheelStops=4):
        d=self.costs['weight'].index(railWeight)
        bc=bumpers*self.bumperCost
        cc=crossings*self.crossingSignals
        wsc=wheelStops*self.wheelStopCost
        lineCost=self.lengthFactoredCost(length,railWeight)
        additional=bc+cc+wsc
        return {'total':[additional+lineCost, 'total spur construction cost'], 'lnCon':[lineCost,'distance dependent cost plus mainline connection'], 'unitItems':{'bumpers':bc,'crossingSignals':cc,'wheelStops':wsc}}

    
