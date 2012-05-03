import psycopg2, sqlite



def query(string, search_path='afri, solar, public'):
    con = psycopg2.connect("dbname=afri")
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

def queryCommit(string, search_path='afri, solar, public'):
    con = psycopg2.connect("dbname=afri")
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
    con=sqlite.connect(filename)
    c= con.cursor()
    c.execute(string)
    con.commit
    c.close()
