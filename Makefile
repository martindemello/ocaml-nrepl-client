
OLIB = /usr/lib/ocaml

WIN_LIBS = /usr/lib/i486-mingw32-ocaml/unix,bigarray,str,nums,$(OLIB)/camlp5/camlp5,$(OLIB)/pcre/pcre,$(OLIB)/camomile/camomile,$(OLIB)/camlp5/gramlib,$(OLIB)/ledit/ledit

LIBS = unix,bigarray,str,nums,camlp5/camlp5,pcre/pcre,camomile/camomile,camlp5/gramlib,ledit/ledit

OCAMLBUILD = ocamlbuild -j 2 -I src -lflags -I,/usr/lib/ocaml/pcre  -lflags -I,/usr/lib/ocaml/ledit \
           -lflags -I,/usr/lib/ocaml/camlp5 -cflags  -I,/usr/lib/ocaml/ledit \
           -cflags -I,/usr/lib/ocaml/pcre -cflags -I,/usr/lib/ocaml/camlp5 

all:: native


native :
	$(OCAMLBUILD) -libs $(LIBS) main.native
	cp _build/src/main.native jark.native


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
	$(OCAMLBUILD) -libs $(WIN_LIBS) -I,/usr/lib/ocaml/ledit -ocamlc i486-mingw32-ocamlc -ocamlopt i486-mingw32-ocamlopt  main.native
	cp _build/src/main.native jark.exe

clean::
	rm -f *.cm[iox] *~ .*~ src/*~ #*#
	rm -rf html
	rm -f jark.{exe,native,byte}
	rm -f gmon.out
	rm -f jark*.tar.{gz,bz2}
	rm -rf jark
	ocamlbuild -clean
