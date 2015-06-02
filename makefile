all:
	clear
	flex -i lexico.l
	bison sintatico.y -v
	gcc -otrab sintatico.tab.c -lfl

run1:
	clear
	./trab < Entradas/in.pas
run2:
	clear
	./trab < Entradas/in2.pas
run3:
	clear
	./trab < Entradas/in3.pas
run4:
	clear
	./trab < Entradas/in4.pas
run5:
	clear
	./trab < Entradas/in5.pas

teste:
	clear
	flex -i lexico.l
	bison sintatico.y -v
	gcc -otrab sintatico.tab.c -lfl
	./trab < Entradas/in.pas