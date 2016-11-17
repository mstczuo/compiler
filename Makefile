all:
	happy -gca ParMCalc.y
	alex -g LexMCalc.x
	ghc --make TestMCalc.hs -o TestMCalc

clean:
	-rm -f *.log *.aux *.hi *.o *.dvi

distclean: clean
	-rm -f DocMCalc.* LexMCalc.* ParMCalc.* LayoutMCalc.* SkelMCalc.* PrintMCalc.* TestMCalc.* AbsMCalc.* TestMCalc ErrM.* SharedString.* ComposOp.* MCalc.dtd XMLMCalc.* Makefile*
	

