#
# Makefile.inc
#

inc_opt	= -I../.. \
	  -I../Resource

def_opt = \
 -D PROJECT_URL=https://github.com/steel-wheels/TrustedSearch

m4_opt  = -P $(inc_opt) $(def_opt)

%.md : %.md4
	m4 $(m4_opt) $< > $@

