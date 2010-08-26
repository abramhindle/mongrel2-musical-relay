FILE = presentation
NFILE = notes
NAME = ahindle-lda-presentation
HEIGHT=22cm
HEIGHT=225mm
WIDTH=30cm
default: $(NAME).pdf

$(NAME).pdf: $(FILE).out.pdf
	cp $(FILE).out.pdf $(NAME).pdf

notes: $(NFILE).pdf 
notesview: $(NFILE).pdf 
	xpdf $(NFILE).pdf

$(NFILE).pdf: $(NFILE).out.pdf
	cp $(NFILE).out.pdf $(NFILE).pdf

edit: ${FILE}.tex
	gvim $<

view: ${FILE}.out.pdf 
	xpdf -z page ${FILE}.out.pdf

psview: ${FILE}.out.ps
	gv ${FILE}.out.ps

present: ${FILE}.out.pdf
	xpdf -fullscreen -bg black ${FILE}.out.pdf

#		acroread ${FILE}.out.pdf	

acro: ${FILE}.out.pdf
	acroread $<

edit:
	gvim ${FILE}.tex

${FILE}.out.tex: parser.pl ${FILE}.tex header.tex
	perl parser.pl < ${FILE}.tex > ${FILE}.out.tex

${NFILE}.out.tex: 	notes1.out.tex notes.tex
	cp notes.tex $(NFILE).out.tex

notes1.out.tex: parser.pl notes1.tex 
	perl parser.pl < notes1.tex > notes1.out.tex



transitions: ${TRANSITIONSEPS}



${FILE}.out.pdf:	${FILE}.out.ps
	ps2pdf -dEmbedAllFonts=true $<

${NFILE}.out.pdf:	${NFILE}.out.ps
	ps2pdf -dEmbedAllFonts=true $<


#${FILE}.out.pdf:	${FILE}.out.tex 
#	pdflatex ${FILE}.out.tex
#	bibtex ${FILE}.out
#	pdflatex ${FILE}.out.tex
#	pdflatex ${FILE}.out.tex
${FILE}.out.ps:	${FILE}.out.dvi 
	dvips -T ${WIDTH},${HEIGHT} $< -o $@
#${FILE}.out.ps:	${FILE}.out.dvi 
#	dvips -T ${WIDTH},${HEIGHT} $< -o $@

${NFILE}.out.ps:	${NFILE}.out.dvi 
	dvips -T ${WIDTH},${HEIGHT} $< -o $@


#

$(FILE).out.dvi: $(FILE).out.tex ${TRANSITIONSEPS}
	latex $(FILE).out
#	bibtex $(FILE).out
	latex $(FILE).out
	latex $(FILE).out

$(NFILE).out.dvi: $(NFILE).out.tex ${TRANSITIONSEPS}
	latex $(NFILE).out
#	bibtex $(NFILE).out
	latex $(NFILE).out
	latex $(NFILE).out





$(FILE).s: $(FILE).dvi
	dvips -T ${WIDTH},${HEIGHT} -o $@ $<

$(NFILE).ps: $(NFILE).dvi
	dvips -T ${WIDTH},${HEIGHT} -o $@ $<


#$(FILE).ps: $(FILE).dvi
#	dvips -T ${WIDTH},${HEIGHT} -o $@ $<



$(FILE).pdf: $(FILE).ps
	ps2pdf $< $@



.SUFFIXES: .ps .pdf .eps .dia

.ps.pdf:
	ps2pdf $<

.dia.eps:
	dia -n -t eps $<

.png.eps:
	convert $< $@
.jpg.eps:
	convert $< $@

clean:
	rm -f *.bbl *.aux
	rm -f ${FILE}.out.*
	rm -f ${FILE}.out.pdf 
