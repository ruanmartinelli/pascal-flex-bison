%{
#include <stdio.h>
%}
%token tk_absolute 
%token tk_and 
%token tk_array 
%token tk_begin
%token tk_case 
%token tk_char 
%token tk_const 
%token tk_div 
%token tk_do 
%token tk_downto 
%token tk_else 
%token tk_end 
%token tk_external 
%token tk_file 
%token tk_for 
%token tk_forward 
%token tk_func 
%token tk_function 
%token tk_goto 
%token tk_if 
%token tk_implementation 
%token tk_in 
%token tk_integer 
%token tk_interface 
%token tk_interrupt 
%token tk_label 
%token tk_main
%token tk_mod
%token tk_nil
%token tk_nit
%token tk_not
%token tk_of
%token tk_or
%token tk_packed
%token tk_proc
%token tk_procedure
%token tk_progr
%token tk_program
%token tk_record
%token tk_repeat
%token tk_set
%token tk_shl
%token tk_shr
%token tk_string
%token tk_then
%token tk_to
%token tk_type
%token tk_unit
%token tk_until
%token tk_uses
%token tk_var
%token tk_while
%token tk_with
%token tk_xor

%token tk_real
%token tk_boolean

%token tk_constString

%token tk_vezes
%token tk_mais
%token tk_menos
%token tk_divisao
%token tk_restoDivisaoInteira
%token tk_elevado
%token tk_numeroInteiro
%token tk_numeroReal
%token tk_identificador
%token tk_caractere
%token tk_igual
%token tk_abreParenteses
%token tk_fechaParenteses
%token tk_abreColchete
%token tk_fechaColchete
%token tk_abreChaves
%token tk_fechaChaves
%token tk_virgula
%token tk_doisPontos
%token tk_pontoEVirgula
%token tk_maiorQue
%token tk_menorQue
%token tk_maiorIgual
%token tk_menorIgual
%token tk_diferenteDe
%token tk_atribuicao
%token tk_pontoPonto
%token tk_ponto

%start PROG

%%

/* Inicio do programa. */
PROG: 					CABECALHO BLOCO tk_ponto
;

CABECALHO: 				tk_program tk_identificador tk_pontoEVirgula
;

/* Bloco agrega todos os demais componentes do programa */
BLOCO: 					VARIAVEIS BLOCO 
						| DECLARACAO_PROCEDURE BLOCO 
						| DECLARACAO_PROCEDURE 
						| VARIAVEIS 	
						| CORPO 
						| CORPO BLOCO 
						| DECLARACAO_FUNCTION 
						| DECLARACAO_FUNCTION BLOCO 
;
/* Declaracao inicial das variaveis. */
VARIAVEIS: 				tk_var DECLARACAO_VARIAVEIS
;
DECLARACAO_VARIAVEIS: 	LISTA_VARIAVEIS tk_doisPontos TIPO tk_pontoEVirgula
						| DECLARACAO_VARIAVEIS LISTA_VARIAVEIS tk_doisPontos TIPO tk_pontoEVirgula
;
LISTA_VARIAVEIS: 		tk_identificador  
						| LISTA_VARIAVEIS tk_virgula tk_identificador
;
/* Vetores ou tipo */
TIPO: 					TIPO_PADRAO
						| tk_array tk_abreColchete DIMENSAO_LISTA tk_fechaColchete tk_of TIPO_PADRAO
;
/*DIMENSAO: 				tk_abreColchete tk_numeroInteiro tk_pontoPonto tk_numeroInteiro tk_fechaColchete 
						| tk_abreColchete tk_numeroInteiro tk_pontoPonto tk_numeroInteiro tk_fechaColchete DIMENSAO
;*/
DIMENSAO_LISTA:			DIMENSAO 	| DIMENSAO_LISTA tk_virgula DIMENSAO
;
DIMENSAO: 				tk_numeroInteiro tk_pontoPonto tk_numeroInteiro ;
TIPO_PADRAO: 			tk_integer
						| tk_char
						| tk_boolean
						| tk_real
;
/* Declaracao dos Procedures */
DECLARACAO_PROCEDURE: 	CABECALHO_PROCEDURE BLOCO tk_pontoEVirgula
						| CABECALHO_PROCEDURE tk_forward tk_pontoEVirgula
;
CABECALHO_PROCEDURE: 	tk_procedure tk_identificador ARGUMENTOS tk_pontoEVirgula
;
ARGUMENTOS: 			tk_abreParenteses LISTA_ARGUMENTOS tk_fechaParenteses
						| tk_abreParenteses tk_fechaParenteses
;
LISTA_ARGUMENTOS: 		LISTA_VARIAVEIS tk_doisPontos TIPO
						| tk_var LISTA_VARIAVEIS tk_doisPontos TIPO
						| tk_var LISTA_VARIAVEIS tk_doisPontos TIPO tk_pontoEVirgula LISTA_ARGUMENTOS
						| LISTA_VARIAVEIS tk_doisPontos TIPO tk_pontoEVirgula LISTA_ARGUMENTOS
;

/* Declaracao de Funcoes */
DECLARACAO_FUNCTION: 	CABECALHO_FUNCTION BLOCO tk_pontoEVirgula
						| CABECALHO_FUNCTION tk_forward tk_pontoEVirgula
;
CABECALHO_FUNCTION: 	tk_function tk_identificador ARGUMENTOS tk_doisPontos TIPO_PADRAO tk_pontoEVirgula
;

/* Corpo representa tudo que pode ser incluido dentro do escopo de um begin-end */
CORPO: 					tk_begin CORPO_LISTA tk_end 
						| tk_begin tk_end
;
CORPO_LISTA: 			DECLARACAO tk_pontoEVirgula
						| DECLARACAO tk_pontoEVirgula CORPO_LISTA
;

/* Loops, atribuicoes, chamadas de procedimento */
DECLARACAO: 			VARIAVEL_DECLARACAO
						| IF_DECLARACAO
						| WHILE_DECLARACAO
						| FOR_DECLARACAO
						| REPEAT_DECLARACAO
						| CASE_DECLARACAO
						| PROCEDURES_CHAMADA
;
VARIAVEL_DECLARACAO: 	VARIAVEL tk_atribuicao EXPRESSAO
;

/* If */
IF_DECLARACAO: 			tk_if EXPRESSAO tk_then CORPO 
						| tk_if EXPRESSAO tk_then CORPO tk_else CORPO tk_pontoEVirgula
						| tk_if EXPRESSAO tk_then DECLARACAO 
;

/* While */
WHILE_DECLARACAO: 		tk_while EXPRESSAO tk_do DECLARACAO
						| tk_while EXPRESSAO tk_do CORPO
;

/* Repeat-until */
REPEAT_DECLARACAO: 		tk_repeat CORPO_LISTA tk_until EXPRESSAO
;
/* For */
FOR_DECLARACAO: 		tk_for tk_identificador tk_atribuicao EXPRESSAO tk_to EXPRESSAO tk_do DECLARACAO
						| tk_for tk_identificador tk_atribuicao EXPRESSAO tk_downto EXPRESSAO tk_do DECLARACAO
						| tk_for tk_identificador tk_atribuicao EXPRESSAO tk_downto EXPRESSAO tk_do CORPO 
						| tk_for tk_identificador tk_atribuicao EXPRESSAO tk_to EXPRESSAO tk_do CORPO
;

/* Case */
CASE_DECLARACAO: 		tk_case EXPRESSAO tk_of CASE_LISTA tk_end
;
CASE_LISTA: 			CASE tk_pontoEVirgula 	
						| CASE tk_pontoEVirgula CASE_LISTA
;
CASE: 					LISTA_CONSTANTES tk_doisPontos DECLARACAO
;
LISTA_CONSTANTES: 		CONSTANTE
						| CONSTANTE tk_virgula LISTA_CONSTANTES
;
CONSTANTE:				tk_numeroReal
						| tk_numeroInteiro
						| tk_caractere
;

/* Chamadas de Funcao e Procedures */
PROCEDURES_CHAMADA: 	tk_identificador tk_abreParenteses EXPRESSAO_LISTA tk_fechaParenteses
						| tk_identificador tk_abreParenteses tk_fechaParenteses
;
FUNCAO_CHAMADA: 		tk_identificador tk_abreParenteses EXPRESSAO_LISTA tk_fechaParenteses
						| tk_identificador tk_abreParenteses tk_fechaParenteses
;
EXPRESSAO_LISTA : 		EXPRESSAO
						| EXPRESSAO_LISTA tk_virgula EXPRESSAO
;

/* Continuacao das Variaveis*/
VARIAVEL: 				tk_identificador
	| 					tk_identificador tk_abreColchete EXPRESSAO_LISTA tk_fechaColchete
;
EXPRESSAO: 				EXPRESSAO_SIMPLES
						| EXPRESSAO_SIMPLES tk_igual EXPRESSAO_SIMPLES
						| EXPRESSAO_SIMPLES tk_diferenteDe EXPRESSAO_SIMPLES
						| EXPRESSAO_SIMPLES tk_maiorQue EXPRESSAO_SIMPLES
						| EXPRESSAO_SIMPLES tk_menorQue EXPRESSAO_SIMPLES
						| EXPRESSAO_SIMPLES tk_menorIgual EXPRESSAO_SIMPLES
;
EXPRESSAO_SIMPLES: 		TERMO
						| EXPRESSAO_SIMPLES tk_mais TERMO
						| EXPRESSAO_SIMPLES tk_menos TERMO
						| EXPRESSAO_SIMPLES tk_or TERMO
;
TERMO: 					FATOR
						| TERMO MULOP FATOR
;
FATOR: 					VARIAVEL
						| CONSTANTE
						| tk_abreParenteses EXPRESSAO tk_fechaParenteses 
						| ADDOP FATOR
						| FUNCAO_CHAMADA
						| tk_constString
;
MULOP:
						tk_vezes
						| tk_divisao
						| tk_restoDivisaoInteira
						| tk_div
						| tk_and
;
ADDOP: 					tk_mais 
						| tk_menos 
						| tk_not 
;


%%

#include "lex.yy.c"

main(){
	yyparse();
}

/* Rotina chamada por yyparse quando encontra erro */
yyerror (void){
	printf("Erro na Linha: %d\n", Nlinha);
}

