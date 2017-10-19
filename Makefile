SETUP=LDFLAGS=-L/usr/local/lib LIBRARY_PATH=/opt/local/lib ocaml setup.ml
libdai_caml=oasis

libdai:
	git clone https://bitbucket.org/kennethadammiller/libdai

osxconf:
	cp libdai/Makefile.MACOSX64 libdai/Makefile.conf

linuxconf:
	cp libdai/Makefile.LINUX libdai/Makefile.conf

libdai/lib/libdai.a: libdai
	sed -i -e  "s/typedef int64_t int64;//g" libdai/swig/dai.i 
	make -C libdai -j4
	make -C libdai/swig dai_stub.c

libdai_osx: libdai osxconf libdai/lib/libdai.a
	cp libdai/swig/*.ml $(libdai_caml)/src/
	cp libdai/swig/*.mli $(libdai_caml)/src/
	cp libdai/swig/*.c $(libdai_caml)/src/
	make -C oasis

#TODO should clean out setup.data setup.ml and edit the .i file to
#remove the declaration for int64, also regenerate the interface 
#files with swig
libdai_linux: libdai linuxconf libdai/lib/libdai.a
	cp libdai/swig/*.ml $(libdai_caml)/src/
	cp libdai/swig/*.mli $(libdai_caml)/src/
	cp libdai/swig/*.c $(libdai_caml)/src/
	make -C libdai
	cd oasis ; rm setup.* ; ocaml setup.ml -configure ; oasis setup -setup-update dynamic ; make


test:
	./$(libdai_caml)/test.native

install:
	cd $(libdai_caml) ; $(SETUP) -configure --bindir $(shell opam config var bin)
	cd $(libdai_caml) ; $(SETUP) -install

clean:
	rm -rf libdai
	make -C $(libdai_caml) clean
