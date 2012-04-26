#! /usr/bin/python 
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 14 10:43:43 2011
takes multi-line output with file name and hex encoded binary from psql copy statement and creates individual files binary encoded
pseudo:
    For each line:
        1. split line on '\'
        2. open destination file '.tif'
        3. write ascii.unhexlify(<hex string>)
        4. close file
 
@author: Peter Tittmann (pwtittmann@ucdavis.edu)
"""
import binascii, sys, argparse
 
parser = argparse.ArgumentParser(description='create tif files from psql copy')
parser.add_argument('infile', nargs='?', type=argparse.FileType('r'), default=sys.stdin, help="file to read. defaults to stdin")
parser.add_argument('-o', default='',help='directory location of output', dest='o')
args=parser.parse_args()
 
 
def parsefile(name, data):
    '''name is a string, data is a hex string'''
    outDir=args.o
    f=open(outDir+name+'.tif', 'w+')
    f.write(binascii.unhexlify(data))
    f.close()
 
 
for line in args.infile.readlines():
    n,d=line.split()
    parsefile(n,d)
