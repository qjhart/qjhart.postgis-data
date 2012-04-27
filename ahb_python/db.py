import psycopg2

con = psycopg2.connect("dbname=afri")

def query(string, search_path='afri, solar, public'):
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
