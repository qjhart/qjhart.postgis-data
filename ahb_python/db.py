import psycopg2

def query(string, dbname='afri',search_path='afri, solar, public'):
    con = psycopg2.connect("dbname=%s"%dbname)
    sp='set search_path=%s;'%search_path
    stWpath= sp+string
    curs=con.cursor()
    sql=curs.mogrify(stWpath)
    try:
        curs.execute(sql)
    except Exception, e:
        print e.pgerror
        pass
    res = curs.fetchall()
    curs.close()
    return res

def queryCommit(string, dbname='afri',search_path='afri, solar, public'):
    con = psycopg2.connect("dbname=%s"%dbname)
    sp='set search_path=%s;'%search_path
    stWpath= sp+string
    curs=con.cursor()
    sql=curs.mogrify(stWpath)
    try:
        curs.execute(sql)
    except Exception, e:
        print e.pgerror
        pass
    #res = curs.fetchall()
    con.commit()
    curs.close()
    #return res

def sqliteQ(string,filename):
    '''
    string= query string
    filename= string file name
    '''
    import sqlite
    con=sqlite.connect(filename)
    c= con.cursor()
    #c.execute()
    c.execute(string)
    out=c.fetchall()
    c.close()
    return out


def sqliteQcommit(string,filename):
    '''
    string= query string
    filename= string file name
    '''
    import sqlite
    con=sqlite.connect(filename)
    c= con.cursor()
    c.execute(string)
    con.commit
    c.close()
