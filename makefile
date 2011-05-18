RESULT = jark

SOURCES = \
					ledit/cursor.ml \
					ledit/ledit.mli ledit/ledit.ml \
					src/nrepl_client.ml

GODI = /home/icylisper/share/ocaml/godi/lib/ocaml
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
