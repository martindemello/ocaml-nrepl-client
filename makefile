RESULT = nrepl-client

SOURCES = \
					ledit/cursor.ml \
					ledit/ledit.mli ledit/ledit.ml \
					nrepl_client.ml

GODI = /home/martin/opt/godi/lib/ocaml
PKG = $(GODI)/pkg-lib
PACKS = unix bigarray str mikmatch_pcre pcre batteries
INCDIRS = $(PKG)/batteries $(GODI)/std-lib/camlp5 $(PKG)/pcre $(PKG)/mikmatch_pcre
CREATE_LIB = yes
PRE_TARGETS = ledit/pa_local.cmo ledit/pa_def.cmo
USE_CAMLP4 = yes
PP = ./camlp4find $(PACKS)
export PP

all: native-code

OCAMLMAKEFILE = OCamlMakefile
include $(OCAMLMAKEFILE)
