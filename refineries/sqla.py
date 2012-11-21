from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy import *
from geoalchemy import *
from sqlalchemy.ext.declarative import declarative_base

metadata=MetaData(schema='refineries')

Base=declarative_base(metadata)

class woodUsers (Base):
    __tablename__='gquery_wood'
    id=Column('id', Integer, primary_key=True)
    name=Column('name', String)
    addr=Column('address', String)
    types=Column('type', ARRAY(String))
    jsn=Column('json', String)
    geom=GeometryColumn('geom', Point(2))
