import sys
#from xml.etree import cElementTree as ET
#from psycopg2.extensions import adapt, register_adapter
#,subprocess


fname=sys.argv[1]
tname=sys.argv[2]

#class ElementAdapter:
#    def __init__(self, elem):
#        self.elem = elem
#    def getquoted(self):
#        return "%s::xml" \
#            % adapt(ET.tostring(elem))
#
#register_adapter(type(ET.Element('')),
#                 ElementAdapter)
#
#print adapt(elem).getquoted()
# '<doc>Hello, ''xml''!</doc>'::xml
#cur.execute("""
#    INSERT INTO xmltest (xmldata)
#VALUES (%s);""", (elem,))

txt=open(fname,'r').read().replace('(','\(').replace(')','\)')

#subprocess.check_call(['psql service=afri -c "insert into solar.metadata (t_name, meta) values (\'%s\', \'%s\')"'%(tname,txt)], shell=True)
print 'psql service=afri -c "insert into solar.metadata (t_name, meta) values (\'%s\', \'%s\')"'%(tname,txt)
