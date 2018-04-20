##########################################################################
#                                                                        #
#  This file is part of Calendar.                                        #
#                                                                        #
#  Copyright (C) 2003-2011 Julien Signoles                               #
#                                                                        #
#  you can redistribute it and/or modify it under the terms of the GNU   #
#  Lesser General Public License version 2.1 as published by the         #
#  Free Software Foundation, with a special linking exception (usual     #
#  for Objective Caml libraries).                                        #
#                                                                        #
#  It is distributed in the hope that it will be useful,                 #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR                           #
#                                                                        #
#  See the GNU Lesser General Public Licence version 2.1 for more        #
#  details (enclosed in the file LGPL).                                  #
#                                                                        #
#  The special linking exception is detailled in the enclosed file       #
#  LICENSE.                                                              #
##########################################################################

# Used programs
###############

CAMLC	= ocamlc.opt
CAMLOPT	= ocamlopt.opt
CAMLDEP	= ocamldep
CAMLDOC	= ocamldoc
CAMLWEB	= ocamlweb
CAMLWC	= ocamlwc
CAMLDOT	= ocamldot
CAMLLIB	= /home/jerome/.opam/4.04.2/lib/ocaml
CAMLFIND= ocamlfind
CAMLMAJORVERSION= 4

# Object/Library File Extensions
OBJ_EXT = .o
LIB_EXT = .a

HAS_NATDYNLINK=yes

# Project
#########

NAME	= calendar
NAMELIB = calendarLib
VERSION	= 2.04

LIBDIR	= target

LIBS	= $(LIBDIR)/$(NAMELIB).cmo $(LIBDIR)/$(NAMELIB).cma
CLIBS   =
ifneq ($(CAMLOPT),no)
LIBS   := $(LIBS) $(LIBDIR)/$(NAMELIB).cmx $(LIBDIR)/$(NAMELIB).cmxa
ifeq ($(HAS_NATDYNLINK),yes)
LIBS	:= $(LIBS) $(LIBDIR)/$(NAMELIB).cmxs
endif
CLIBS   := $(CLIBS) $(LIBDIR)/$(NAMELIB)$(OBJ_EXT) \
	$(LIBDIR)/$(NAMELIB)$(LIB_EXT)
endif

DIRS	= src target tests

SRC	= utils.mli utils.ml time_Zone.mli time_Zone.ml period.mli \
	time_sig.mli time.mli time.ml ftime.mli ftime.ml \
	date_sig.mli date.mli date.ml \
	calendar_sig.mli calendar_builder.mli calendar_builder.ml \
	calendar.mli calendar.ml fcalendar.mli fcalendar.ml \
	printer.mli printer.ml \
	version.mli version.ml
SRC	:= $(addprefix src/, $(SRC))

ML	= $(filter %.ml, $(SRC))
MLI	= $(filter %.mli, $(SRC))

CMO	= $(ML:.ml=.cmo)
CMX	= $(CMO:.cmo=.cmx)
CMI	= $(MLI:.mli=.cmi)
CMI_ONLY= src/period.cmi src/date_sig.cmi src/time_sig.cmi src/calendar_sig.cmi

GENERATED= src/version.ml

# Libs and flags
################

CAMLIBS	= $(addprefix -I , $(DIRS)) -package re.str

CAMLFLAGS= $(CAMLIBS)
BYTEFLAGS= $(CAMLFLAGS)
LINK_OPTFLAGS = $(CAMLFLAGS) -noassert
OPTFLAGS = $(LINK_OPTFLAGS) -for-pack CalendarLib

# Main rules
############

all: $(LIBS) META

$(LIBDIR)/$(NAMELIB).cmo: $(CMI_ONLY) $(CMO)
	mkdir -p $(LIBDIR)
	$(CAMLFIND) ocamlc $(BYTEFLAGS) -pack -o $@ \
		$(filter-out $(LIBDIR), $^)

$(LIBDIR)/$(NAMELIB).cma: $(LIBDIR)/$(NAMELIB).cmo
	$(CAMLFIND) ocamlc $(BYTEFLAGS) -a -o $@ $<

$(LIBDIR)/$(NAMELIB).cmx: $(CMI_ONLY) $(CMX)
	mkdir -p $(LIBDIR)
	$(CAMLFIND) ocamlopt $(LINK_OPTFLAGS) -pack -o $@ \
		$(filter-out $(LIBDIR), $^)

$(LIBDIR)/$(NAMELIB).a $(LIBDIR)/$(NAMELIB).cmxa: $(LIBDIR)/$(NAMELIB).cmx
	$(CAMLFIND) ocamlopt $(LINK_OPTFLAGS) -a -o $@ $<

$(LIBDIR)/$(NAMELIB).cmxs: $(LIBDIR)/$(NAMELIB).cmxa
	$(CAMLFIND) ocamlopt -I $(LIBDIR) -shared -linkall -o $@ $<

src/version.ml: Makefile
	echo "let version = \"$(VERSION)\"" > $@
	echo "let date = \"`date`\"" >> $@

META: Makefile
	echo "name = \"$(NAME)\"" > $@
	echo "description = \"$(NAME) library\"" >> $@
	echo "version = \"$(VERSION)\"" >> $@
	echo "archive(byte) = \"$(NAMELIB).cma\"" >> $@
	echo "archive(native) = \"$(NAMELIB).cmxa\"" >> $@
	echo "requires = \"unix re.str\"" >> $@

# Generic rules
###############

%.gz: %
	gzip -f --best $<

.SUFFIXES: .ml .mli .cmo .cmi .cmx $(OBJ_EXT)

.mli.cmi:
	$(CAMLFIND) ocamlc $(BYTEFLAGS) -c $<

.ml.cmo:
	$(CAMLFIND) ocamlc $(BYTEFLAGS) -c $<

.ml$(OBJ_EXT):
	$(CAMLFIND) ocamlopt $(OPTFLAGS) -c $<

.ml.cmx:
	$(CAMLFIND) ocamlopt $(OPTFLAGS) -c $<

# Tests
#######

TESTS_SRC= gen_test.mli gen_test.ml test_timezone.ml test_time.ml \
	test_ftime.ml test_date.ml test_calendar.ml test_fcalendar.ml \
	test_pcalendar.ml test_fpcalendar.ml test_printer.ml test.ml
TESTS_SRC:= $(addprefix tests/, $(TESTS_SRC))

TESTS_ML= $(filter %.ml, $(TESTS_SRC))
TESTS_CMO= $(TESTS_ML:.ml=.cmo)

$(TESTS_CMO) $(TESTS_CMI): $(LIBDIR)/$(NAMELIB).cmo $(LIBDIR)/$(NAMELIB).cmi

tests/test: $(LIBDIR)/$(NAMELIB).cmo $(TESTS_CMO)
	$(CAMLC) -o $@ $(BYTEFLAGS) unix.cma str.cma $(LIBDIR)/$(NAMELIB).cmo \
		$(TESTS_CMO)

.PHONY: tests
tests: tests/test
	./$<

# Documentation
###############

wc: $(SRC)
	$(CAMLWC) -p $^

$(NAMELIB).ps: $(SRC)
	$(CAMLWEB) --ps -o $@ $^

ifeq ($(CAMLMAJORVERSION),3)
utils/example.ml: utils/example.ml.3 Makefile
	cp $< $@
else
utils/example.ml: utils/example.ml.4 Makefile
	cp $< $@
endif

utils/example.cmo: utils/example.ml
	$(CAMLC) -I +ocamldoc -I utils -c $<

.PHONY: doc
doc: $(CMO) utils/example.cmo
	mkdir -p doc
	rm -f doc/*
	$(CAMLDOC) -g utils/example.cmo -colorize-code -I src -d doc \
		$(MLI) $(ML)

# Headers
#########

.PHONY: headers
headers:
	headache -c headache_config.txt -h HEADER $(SRC) $(TESTS_SRC) \
	  Makefile.in utils/example.ml
	headache -c headache_config.txt -h CONFIGURE_HEADER configure.in

# Install
#########

install: $(LIBS) $(CLIBS) META
	@if [ "`sed -n -e 's/version = "\([0-9.+dev]*\)"/\1/p' META`" = "$(VERSION)" ]; then \
	  (if test -d `ocamlfind install -help | grep destdir | sed -e "s/.*default: \(.*\))/\1/"`/$(NAME); then $(MAKE) uninstall; fi;\
	  $(CAMLFIND) install $(NAME) target/*.cm* $(MLI) $(CLIBS) META); \
	else \
	  (echo; echo "Not the good version. Please, do :"; \
	   echo "  make clean && make"; \
	   echo "next reinstall"; echo) \
	fi

uninstall:
	$(CAMLFIND) remove $(NAME)

# Exporting
###########

EXPORT_DIR= $$HOME/EXPORT/$(NAME)
TMP_DIR	= $$HOME/tmp

ROOT= $$HOME/DEV/calendar

export: doc
	(cd $(TMP_DIR); \
	  svn co svn+ssh://signoles@svn.forge.ocamlcore.org/svnroot/calendar/trunk)
	svn copy $(TMP_DIR)/trunk $(ROOT)/tags/v$(VERSION)
	rm -rf $(TMP_DIR)/trunk
	(cd $(ROOT)/tags; svn commit -m "v $(VERSION)")
	rm -rf $(EXPORT_DIR)/doc
	mkdir -p $(EXPORT_DIR)
	cp -rf CHANGES doc $(EXPORT_DIR)
	cp -rf $(ROOT)/tags/v$(VERSION) $(TMP_DIR)/$(NAME)-$(VERSION)
	cp -rf .depend configure config.status doc $(TMP_DIR)/$(NAME)-$(VERSION)
	cd $(TMP_DIR); \
	  (rm -rf $(NAME)-$(VERSION)/.svn $(NAME)-$(VERSION)/*/.svn; \
	   tar cvf $(NAME)-$(VERSION).tar $(NAME)-$(VERSION); \
	   gzip -f --best $(NAME)-$(VERSION).tar; \
	   rm -rf $(NAME)-$(VERSION); \
	   mv $(NAME)-$(VERSION).tar.gz $(EXPORT_DIR))
	rm -rf $(TMP_DIR)/$(NAME)-$(VERSION)

# Rebuilding Makefile
#####################

Makefile: Makefile.in
	./config.status

config.status: configure
	./config.status --recheck

configure: configure.in
	autoconf

# Emacs tags
############

TAGS: $(SRC)
	otags -o $@ $^

# Cleaning
##########

clean:
	rm -f TAGS META $(TESTS) tests/test $(GENERATED)
	for i in . src tests utils; do \
	  rm -f $$i/*~ $$i/\#* $$i/*.cm[iox] $$i/*.*a $$i/*$(OBJ_EXT) $$i/a.out; \
	done
	rm -f utils/example.ml

dist-clean distclean: clean
	rm -rf $(NAME).ps.gz doc $(LIBDIR)

clean-configure cleanconfig: dist-clean
	rm -f Makefile configure config.*

# Depend
########

.depend depend: $(GENERATED)
	rm -f .depend
	$(CAMLDEP) -I src -I tests src/*.ml src/*.mli tests/*.ml tests/*.mli \
	  > .depend

view-depend:
	$(CAMLDOT) .depend | dot -Tps | gv -

include .depend
