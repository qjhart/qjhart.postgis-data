#! /usr/bin/make -f 

ifndef configure.mk
include ../configure.mk
endif

pwd:=$(shell pwd)

# Doesn't seem complete
#include out.mk

#refineries.ethanol.csv:gcsv:=http://spreadsheets.google.com/pub?key=t9MFzewsuMk6Rlv5bz7AOjQ&single=true&gid=0&output=csv
cdl_nass.csv:gcsv:=https://docs.google.com/spreadsheet/ccc?key=0AmgH34NLQLU-dHRZZnQxd05HNHNxWlY5U3I4YlpIM3c&single=true&gid=0&output=csv
cdl_nass.csv:
	wget -O $@ '${gcsv}'

db/to_bcam: cdl_nass.csv
	${PG} --variable=cdl_nass_csv="'${pwd}/cdl_nass.csv'" -f to_bcam.sql
