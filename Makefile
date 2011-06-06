
OLIB = /usr/lib/ocaml
WLIB = /usr/lib/i486-mingw32-ocaml

WIN_LIBS = $(WLIB)/unix,$(WLIB)/bigarray,$(WLIB)/str,$(WLIB)/nums,$(OLIB)/camlp5/camlp5,$(OLIB)/camlp5/gramlib,$(OLIB)/ledit/ledit,$(OLIB)/extlib/extLib

LIBS = unix,bigarray,str,nums,$(OLIB)/camlp5/camlp5,$(OLIB)/camlp5/gramlib,$(OLIB)/ledit/ledit,$(OLIB)/extlib/extLib

OCAMLBUILD = ocamlbuild -j 2 -quiet -I src -lflags -I,/usr/lib/ocaml/pcre  \
           -lflags -I,/usr/lib/ocaml/camlp5 -cflags  -I,/usr/lib/ocaml/ledit -lflags -I,/usr/lib/ocaml/extlib  \
	   -cflags -I,/usr/lib/ocaml/extlib 



all:: native


native :
	$(OCAMLBUILD) -libs $(LIBS) main.native
	cp _build/src/main.native bin/jark


byte :
	$(OCAMLBUILD) -libs $(LIBS) main.byte
	cp _build/src/main.byte jark.byte


native32 :
	$(OCAMLBUILD) -libs $(LIBS) -ocamlopt "ocamlopt.32" main.native
	cp _build/src/main.native jark.native

gprof :
	$(OCAMLBUILD) -libs $(LIBS) -ocamlopt "ocamlopt -p" main.native
	cp _build/src/main.native jark.native

ocamldebug :
	$(OCAMLBUILD) -libs $(LIBS) -lflag -g -cflag -g main.byte
	cp _build/src/main.byte jark.byte

exe :
	$(OCAMLBUILD) -libs $(WIN_LIBS) -ocamlc i486-mingw32-ocamlc -ocamlopt i486-mingw32-ocamlopt  main.native
	cp _build/src/main.native bin/jark.exe

clean::
	rm -f *.cm[iox] *~ .*~ src/*~ #*#
	rm -rf html
	rm -f jark.{exe,native,byte}
	rm -f gmon.out
	rm -f jark*.tar.{gz,bz2}
	rm -rf jark
	ocamlbuild -clean
