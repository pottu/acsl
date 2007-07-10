
DEPS=annot1.pp annot2.pp assigns.pp invariants.pp \
	isqrt.pp incrstar.pp \
	max.pp max_index.pp cond_assigns.pp bsearch.pp bsearch2.pp \
	assigns_array.pp assigns_list.pp \
	listdecl.pp listdef.pp listlengthdef.pp import.pp \
	term.bnf fn_behavior.bnf oldandresult.bnf loc.bnf \
	assertions.bnf loops.bnf st_contracts.bnf moreterm.bnf ghost.bnf \
	logic.bnf logictypedecl.bnf 

all: main.dvi

main.ps: main.dvi
	dvips $^ -o $@

main.dvi: main.tex $(DEPS)
	pdflatex main
	makeindex main
	bibtex main
	pdflatex main
	pdflatex main

%.pp: %.tex pp.ml
	ocaml pp.ml -color $< > $@

%.pp: %.c pp.ml
	ocaml pp.ml -color -c $< > $@

%.bnf: %.tex transf
	./transf < $< > $@

pp.ml: pp.mll
	ocamllex pp.mll

transf: transf.cmo transfmain.cmo
	ocamlc -o $@ $^

%.cmo: %.ml
	ocamlc -c $<

transfmain.cmo: transf.cmo

transf.ml: transf.mll
	ocamllex transf.mll

.PHONY: clean rubber

clean:
	rm -rf *~ *.aux *.log *.nav *.out *.snm *.toc *.pp *.bnf \
               transf trans.ml *.cm?

# see http://www.pps.jussieu.fr/~beffara/soft/rubber/ for details on rubber.
rubber: $(DEPS)
	rubber -d main.tex