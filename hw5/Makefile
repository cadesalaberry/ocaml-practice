exec:
	ocamlbuild exec.native

toplevel:
	ocamlbuild -use-menhir top.top;
	./top.top -I _build/

runtop:
	./top.top -I _build/

clean:
	rm -rf _build exec.native top.top

menhir:
	ocamlbuild -use-menhir exec.native

menhirtop:
	ocamlbuild -use-menhir top.top;
	./top.top -I _build/

parse:
	menhir -v parser.mly



