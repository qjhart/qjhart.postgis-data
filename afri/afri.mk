#! /usr/bin/make -f 
ifndef configure.mk
include ../configure.mk
endif

.PHONY:db
db:db/afri

db/afri:
	[[ -d db ]] || mkdir db
	${PG} -f afri.sql
	touch $@

pixels.tsv:
	${PG-TSV} -c "set search_path=afri,public; select * from pixel_bounds where name='afri' and size in (65536)" > $@
