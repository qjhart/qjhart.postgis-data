import os, zipfile as zp, urllib, csv, json, pandas as pd
from numpy import average as avg
from numpy import std as std


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
        
def stanardScore(ind,raw,ar):
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

    
    
