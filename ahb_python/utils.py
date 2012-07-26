import os, zipfile as zp, urllib, csv


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
        
