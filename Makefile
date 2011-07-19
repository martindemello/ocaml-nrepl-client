
VERSION = 0.4

BIN_NAME = jark-$(VERSION)-`uname -m`

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
	cp _build/src/main.native build/$(BIN_NAME)

upx :
	$(OCAMLBUILD) -libs $(LIBS) main.native
	cp _build/src/main.native build/$(BIN_NAME)-un
	rm build/$(BIN_NAME)
	upx -9 -o build/$(BIN_NAME) build/$(BIN_NAME)-un
	rm -f build/$(BIN_NAME)-un

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
	cp _build/src/main.native build/jark.exe

clean::
	rm -f *.cm[iox] *~ .*~ src/*~ #*#
	rm -rf html
	rm -f jark.{exe,native,byte}
	rm -f gmon.out
	rm -f jark*.tar.{gz,bz2}
	rm -rf jark
	ocamlbuild -clean

upload:
	cd build && upload.rb jark-$(VERSION)-x86_64 icylisper/jark-client
	cd build && upload.rb jark-$(VERSION).exe icylisper/jark-client	
	cd build && upload.rb jark-$(VERSION)-i686 icylisper/jark-client		
	cd build && upload.rb jark-$(VERSION)-x86_64-macosx  icylisper/jark-client		

gh-x86:
	cd build && upload.rb jark-$(VERSION)-x86_64 icylisper/jark-client

deps:
	wget -O - http://pauillac.inria.fr/~ddr/camlp5/distrib/src/camlp5-6.02.3.tgz 2> /dev/null | tar xzvf - 
	cd camlp5-6.02.3 && ./configure && make world.opt
	rm -rf /usr/lib/ocaml/camlp5
	cp -r lib/  /usr/lib/ocaml/camlp5
	rm -rf camlp5-6.02.3
	wget -O - http://cristal.inria.fr/~ddr/ledit/distrib/src/ledit-2.02.1.tgz 2> /dev/null | tar xzvf - 
	cd ledit-2.02.1 && make && make install && make ledit.cmxa
	rm -rf /usr/lib/ocaml/ledit
	cp -r ledit-2.02.1/ /usr/lib/ocaml/ledit
	rm -rf ledit-2.02.1
	wget -O - http://ocaml-extlib.googlecode.com/files/extlib-1.5.1.tar.gz 2> /dev/null | tar xzvf - 
	cd extlib-1.5.1 && make && make opt && make install
	rm -rf extlib-1.5.1
