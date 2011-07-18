#!/bin/bash

CUR=`pwd`

wget -O - http://pauillac.inria.fr/~ddr/camlp5/distrib/src/camlp5-6.02.3.tgz 2> /dev/null | tar xzvf - && cd camlp5-6.02.3
./configure && make world.opt
rm -rf /usr/lib/ocaml/camlp5
cp -r lib/  /usr/lib/ocaml/camlp5
cp main/*.cmxa /usr/lib/ocaml/camlp5/

cd $CUR

wget -O - http://cristal.inria.fr/~ddr/ledit/distrib/src/ledit-2.02.1.tgz 2> /dev/null | tar xzvf - && cd ledit-2.02.1
make && make install && make ledit.cmxa
rm -rf /usr/lib/ocaml/ledit
cp -r ../ledit-2.02.1/ /usr/lib/ocaml/ledit

cd $CUR

wget http://ocaml-extlib.googlecode.com/files/extlib-1.5.1.tar.gz 2> /dev/null | tar xzvf - && cd extlib-1.5.1
make && make opt && make install

cd $CUR

