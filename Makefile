RESULT = nrepl-client

SOURCES = \
					ledit/cursor.ml \
					ledit/ledit.mli ledit/ledit.ml \
					src/util.ml src/datatypes.ml src/nrepl_client.ml src/nrepl_frontend.ml src/repl.ml

GODI = /home/martin/opt/godi/lib/ocaml
PKG = $(GODI)/pkg-lib
PACKS = unix bigarray str pcre batteries
INCDIRS = $(PKG)/batteries $(GODI)/std-lib/camlp5 $(PKG)/pcre
CREATE_LIB = yes
PRE_TARGETS = ledit/pa_local.cmo ledit/pa_def.cmo
USE_CAMLP4 = yes
PP = ./camlp4find $(PACKS)
export PP

all: native-code

OCAMLMAKEFILE = OCamlMakefile
include $(OCAMLMAKEFILE)
