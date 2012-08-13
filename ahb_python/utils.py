import os, zipfile as zp, urllib, csv, numpy.average as avg, numpy.std as std


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
         