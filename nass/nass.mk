#! /usr/bin/make -f

ifndef configure.mk
include ../configure.mk
endif

# If included somewhere else
nass.mk:=1


quickstats.csv:=$(patsubst %,db/%,$(shell echo quickstats/*.csv))

quickstats:${quickstats.csv}


INFO::
	@echo NASS - Quickstats
	@echo ${quickstats.csv}


db/nass:
	[[ -d db ]] || mkdir db
	${PG} -f nass.sql
	touch $@

${quickstats.csv}:db/%:db/nass
	${PG} -c '\COPY nass.quickstats FROM $* CSV HEADER'
	touch $@
