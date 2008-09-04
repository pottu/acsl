
DEPS=intro.tex speclang.tex libraries.tex compjml.tex \
	div_lemma.pp assigns.pp invariants.pp example-lt.pp \
	isqrt.pp sizeof.pp incrstar.pp parsing_annot.pp integer-cast.pp \
	max.pp max_index.pp cond_assigns.pp bsearch.pp bsearch2.pp \
	assigns_array.pp assigns_list.pp sum.pp \
	listdecl.pp listdef.pp listlengthdef.pp import.pp listmodule.pp \
	strcpyspec.pp dowhile.pp num_of_pos.pp nb_occ.pp permut.pp \
	acsl_allocator.pp gen_spec_with_model.pp gen_code.pp out_char.pp \
	ghostpointer.pp ghostcfg.pp flag.pp lexico.pp footprint.pp \
	fwrite-malloc.pp loopvariantnegative.pp \
	fact.pp mutualrec.pp abrupt_termination.pp \
        advancedloopinvariants.pp inductiveloopinvariants.pp \
	term.bnf binders.bnf fn_behavior.bnf oldandresult.bnf at.bnf loc.bnf \
	assertions.bnf loops.bnf generalinvariants.bnf \
	st_contracts.bnf moreterm.bnf ghost.bnf model.bnf \
	logic.bnf logictypedecl.bnf higherorder.bnf logicreads.bnf \
	data_invariants.bnf  \
	cfg.mps volatile.pp volatile-gram.bnf euclide.pp \
	initialized.pp specified.pp exitbehavior.bnf dependencies.bnf \
	sum2.pp modifier.pp gen_spec_with_ghost.pp terminates_list.pp

all: main.pdf

main.ps: main.dvi
	dvips $^ -o $@

main.dvi: main.tex $(DEPS)
	latex main
	makeindex main
	bibtex main
	latex main
	latex main

main.pdf: main.tex $(DEPS)
	pdflatex main
	makeindex main
	bibtex main
	pdflatex main
	pdflatex main

%.1: %.mp
	mpost -interaction batchmode $<

%.mps: %.1
	mv $< $@

%.pp: %.tex pp
	./pp -utf8 $< > $@

%.pp: %.c pp
	./pp -utf8 -c $< > $@

%.tex: %.ctex pp
	./pp $< > $@

%.bnf: %.tex transf
	./transf < $< > $@

%.ml: %.mll
	ocamllex $<

%.pdf: %.tex
	pdflatex $<
	bibtex $(<:.tex=)
	pdflatex $<
	pdflatex $<

pp: pp.ml
	ocamlopt -o $@ str.cmxa $^

transf: transf.cmo transfmain.cmo
	ocamlc -o $@ $^

%.cmo: %.ml
	ocamlc -c $<

transfmain.cmo: transf.cmo

.PHONY: clean rubber

check:
	gcc -c *.c
	for f in *.c ; do ../../bin/toplevel.byte $$f ; done

tutorial-check: acsl-mini-tutorial.tex
	@for f in *-tut.c; do \
            echo "***Starting analysis of $$f"; \
            gcc -c -std=c99 $$f; \
            ../../bin/toplevel.byte -pp-annot $$f; \
        done

acsl-mini-tutorial.html: acsl-mini-tutorial.tex
	hevea -fix $<

#acsl_tutorial_index.html: acsl-mini-tutorial.html
#	hacha -o $@ $<

clean:
	rm -rf *~ *.aux *.log *.nav *.out *.snm *.toc *.pp *.bnf \
               transf trans.ml *.cm? *.idx

#.PHONY: implementation rubber
acsl-implementation.pdf: $(DEPS)
	mv main.tex main_old.tex
	sed -e 's/%--//' main_old.tex > main.tex
	@if $(MAKE) rubber; then \
	   mv main_old.tex main.tex; \
           mv main.pdf acsl-implementation.pdf; \
           echo "implementation manual generated"; \
         else \
           mv main_old.tex main.tex; \
           echo "Error while processing document See main.log for details"; \
           exit 2; \
        fi

# see http://www.pps.jussieu.fr/~beffara/soft/rubber/ for details on rubber.
rubber: $(DEPS)
	rubber -d main.tex
