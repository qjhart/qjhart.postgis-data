#! /usr/bin/make -n

ifndef configure.mk
include ../configure.mk
endif

#http://www.fsl.orst.edu/~waring/3-PG_Workshops/WorkshopContents.htm
#http://www.fsl.orst.edu/~waring/3-PG_Workshops/3PGpjs(RHW)2004CLASS.xls
url:=www.fsl.orst.edu/~waring/3-PG_Workshops
docs:=3PGdescription.pdf

.PHONY:db
db:db/m3pg

db/m3pg:
	[[ -d db ]] || mkdir db
	${PG} -f m3pg.sql
	touch $@

.PHONY:docs
docs:$(patsubst %,${url}/%,${docs})

$(patsubst %,${url}/%,${docs}):
	wget -m http://$@

