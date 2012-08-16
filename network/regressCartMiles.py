# -*- coding: utf-8 -*-

"""
Created on Sat Jul 28 11:16:49 2012
https://www.googleapis.com/fusiontables/v1/query?sql=SELECT  <column_spec> {, <column_spec>}*

FROM <table_id>

{ WHERE <filter_condition> | <spatial_condition> { AND <filter_condition> }* }

{ GROUP BY <column_name> {, <column_name>}* }

{ ORDER BY <column_spec> { ASC | DESC } | <spatial_relationship> }

{ OFFSET <number> }

{ LIMIT <number> }

@author: peter
"""
import numpy as np, sys 
sys.path.append('../ahb_python')
import utils

# import urllib, json, numpy as np, pandas as pd

# baseUrl='https://www.googleapis.com/fusiontables/v1/%s'
# tUrl=baseUrl%'query?sql=%s'
# tab='1-3DE0kCMOD7faWRxCIPwOyPLZRvZFgsIa2oyyHg'
# sel='select src_qid, dest_qid, cost, road_mi, cart_miles from %s limit 10&key=%s'%(tab,apiKey)

# #get table schema

# #get JSON data
# m=urllib.urlopen(tUrl%sel)
# js=json.load(m)
