import os, zipfile as zp, urllib


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
    
