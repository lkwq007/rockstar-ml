all:
	ocamlbuild -use-menhir rockstar.native

test:
	./rockstar.native -ast demo.rock
	./rockstar.native demo.rock
clean:
	rm -r _build
	rm rockstar.native