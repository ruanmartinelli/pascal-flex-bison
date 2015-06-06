%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct Hash Hash;
typedef struct Variavel Variavel;
typedef struct Funcao Funcao;
typedef struct Lista Lista;
typedef struct Pilha Pilha;
typedef struct Dados Dados;

extern char* 	yytext;
extern int 		Nlinha;
Hash* 			variaveis[977];
Hash*			funcoes[977];
Lista* 			lista;
Pilha* 			pilha;
Dados*			dados;

int aridade = 0;

struct Pilha{
	char* nome;
	struct Pilha* prox;
};

struct Lista{
	char* 			nome;
	struct Lista* 	prox;
};

struct Hash{
	Variavel* 		variavel;
	Funcao* 		funcao;
	struct Hash* 	prox;
};

struct Funcao{
	char* 	nome;
	char* 	escopo;
	int 	aridade;
	int		forward;
};

struct Variavel{
	char* nome;
	char* tipo;
	char* escopo;
	//valor
};

struct Dados{
	char* nome;
	//int aridade;
	char* escopo;
	int forward;
};

void initLista(){
	lista 	= NULL;
}

void initPilha(){
	pilha 	= NULL;
}

void initDados(){
	dados 			= (Dados*)malloc(sizeof(Dados));
	dados->nome 	= (char*)malloc(sizeof(char) *  50);
	dados->escopo 	= (char*)malloc(sizeof(char) *  50);
	//dados->aridade  = 0;
}
void liberaDados(){
	free(dados->escopo);
	free(dados->nome);
	free(dados);
}

void pushEscopo(char* nome){
	Pilha* novo = (Pilha*) malloc (sizeof(Pilha));
	novo->nome  = (char*) malloc (sizeof(char)*50);
	strcpy		(novo->nome,nome);
	novo->prox  = pilha;
	pilha 		= novo;

}

void popEscopo(){
	Pilha* aux 	= (Pilha*) malloc (sizeof(Pilha)); 
	aux 		= pilha;
	pilha 		= pilha->prox;
	free 		(aux);
}

char* getEscopo(){
	if(pilha != NULL){
		return pilha->nome;
	}
}

int h(char* nome){
	int i,
		soma = 0;
	for(i = 0; i < strlen(nome) ; i++){
		soma = soma + nome[i];
	}
	return soma;
}

void insereFuncoes(char* nome, int aridade, char* escopo, int forward){
	int tamanhoNome 		= strlen(nome);
	int tamanhoEscopo		= strlen(escopo);
	Hash* novo 				= (Hash*) 	malloc(sizeof(Hash));
	novo->funcao 			= (Funcao*)	malloc(sizeof(Funcao));
	novo->funcao->nome 		= (char*) 	malloc(sizeof(char)*tamanhoNome);
	novo->funcao->escopo	= (char*) 	malloc(sizeof(char)*tamanhoEscopo);
	novo->funcao->forward	= forward;
	novo->prox 				= NULL;
	strcpy					(novo->funcao->nome, nome);
	strcpy					(novo->funcao->escopo, escopo);
	novo->funcao->aridade 	= aridade;

	int indice 				= h(novo->funcao->nome);
	if(funcoes[indice] == NULL){
		funcoes[indice] = novo;
	}else{
		if(funcoes[indice] != NULL){
			Hash* p;
			Hash* anterior;

			p = funcoes[indice];
			while(p != NULL){
				if(strcmp(p->funcao->nome, novo->funcao->nome) == 0 
					&& strcmp(p->funcao->escopo, novo->funcao->escopo) == 0
						&& p->funcao->forward == novo->funcao->forward){
							printf("Erro semantico na linha %d. Funcao redeclarada.\n", Nlinha);
							exit(0);
				}
				anterior = p;
				p = p->prox;
			}
			anterior->prox = novo;
		}
	}
}


void insereVariaveis(char* nome, char* tipo, char* escopo){
	int tamanhoNome 		= 				strlen(nome);
	int tamanhoTipo 		= 				strlen(tipo);
	int tamanhoEscopo		= 				strlen(escopo);
	Hash* novo 				= (Hash*)		malloc(sizeof(Hash));
	novo->variavel 			= (Variavel*)	malloc(sizeof(Variavel));
	novo->variavel->nome 	= (char*)		malloc(sizeof(char)*tamanhoNome);
	novo->variavel->tipo 	= (char*)		malloc(sizeof(char)*tamanhoTipo);
	novo->variavel->escopo 	= (char*)		malloc(sizeof(char)*tamanhoEscopo);
	novo->prox  			= NULL;
	strcpy					(novo->variavel->nome, nome);
	strcpy					(novo->variavel->tipo, tipo);
	strcpy					(novo->variavel->escopo, escopo);
	
	int indice 				= h(nome);
	if(variaveis[indice] == NULL){
		variaveis[indice] = novo;
	}else{
		if(variaveis[indice] != NULL){
			Hash* p;
			Hash* anterior;
			p = variaveis[indice];
			while(p != NULL){
				if(strcmp(p->variavel->nome, novo->variavel->nome) == 0 
					&& strcmp(p->variavel->escopo, novo->variavel->escopo) == 0){
						printf("Erro semantico na linha %d. Variavel redeclarada.\n", Nlinha);
						exit(0);
				}
				anterior = p;
				p = p->prox;
			}
			anterior->prox = novo;
		}
	}
}

void insereIdentificadores(char* nome){
	int tamanho 			= strlen(nome);
	Lista* novo 			= (Lista *)malloc(sizeof(Lista));
	novo->nome 				= (char *)malloc((tamanho+1)*sizeof(char));
	strcpy					(novo->nome, nome);
	h 						(nome);
	novo->prox 				= lista;
	lista					= novo;
}

void adicionaListaTabela(char* tipo, char* escopo){
	Lista* id;
	for(id = lista; id != NULL ; id = id->prox){
		if(id->nome != NULL){
			insereVariaveis(id->nome, tipo, escopo);
		}
		Lista* aux 	= (Lista*)malloc(sizeof(Lista));
		aux 		= lista->prox;
		free 		(lista);
		lista 		= aux;
	}
}

void imprimeVariaveis(){
	int i;
	printf("Tabela de Variaveis:\n");
	for(i = 0 ; i < 977 ; i++){
		if(variaveis[i] != NULL){
			Hash* aux;
			for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
				printf("	[%d] : %s		- %s		- %s\n", i, aux->variavel->nome, aux->variavel->escopo, aux->variavel->tipo);
			}
		}
	}
}

void imprimeFuncoes(){
	int i;
	printf("Tabela de Funcoes:\n");
	for(i = 0 ; i < 977 ; i++){
		if(funcoes[i] != NULL){
			Hash* aux;
			for(aux = funcoes[i] ; aux != NULL; aux = aux->prox){
				printf("	[%d] : %s		- %s		-	 %d 	-	%d\n", i, aux->funcao->nome, aux->funcao->escopo, aux->funcao->aridade, aux->funcao->forward);
			}
		}
	}
}

void imprimePilha(){
	int 	i;
	Pilha* 	p;
	printf("Pilha de Escopo: \n");
	for(p = pilha ; p!= NULL ; p = p->prox){
		printf("	%s\n", p->nome);
	}
}

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

CABECALHO: 				tk_program tk_identificador {pushEscopo(yytext);} tk_pontoEVirgula 
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
						| DECLARACAO_TYPE
						| DECLARACAO_TYPE BLOCO
;
/* Declaracao inicial das variaveis. */
VARIAVEIS: 				tk_var DECLARACAO_VARIAVEIS {}
;						//a, b
DECLARACAO_VARIAVEIS: 	LISTA_VARIAVEIS tk_doisPontos TIPO {} tk_pontoEVirgula
						| DECLARACAO_VARIAVEIS LISTA_VARIAVEIS tk_doisPontos TIPO tk_pontoEVirgula
;
LISTA_VARIAVEIS: 		tk_identificador 
							{insereIdentificadores(yytext); aridade++;}
						| LISTA_VARIAVEIS tk_virgula tk_identificador 
							{insereIdentificadores(yytext);aridade++;}
;
/* Vetores ou tipo */
TIPO: 					TIPO_PADRAO 
							{char* escopo = getEscopo(); adicionaListaTabela(yytext, escopo);}
						| tk_array tk_abreColchete DIMENSAO_LISTA tk_fechaColchete tk_of TIPO_PADRAO 
							{char* escopo = getEscopo(); adicionaListaTabela(yytext, escopo);}
;

DIMENSAO_LISTA:			DIMENSAO 	
						| DIMENSAO_LISTA tk_virgula DIMENSAO
;
DIMENSAO: 				tk_numeroInteiro tk_pontoPonto tk_numeroInteiro ;
TIPO_PADRAO: 			tk_integer {}
						| tk_char
						| tk_boolean
						| tk_real
						| tk_abreParenteses LISTA_IDS tk_fechaParenteses;
;
LISTA_IDS : tk_identificador | tk_identificador tk_virgula LISTA_IDS
;
DECLARACAO_TYPE: 		tk_type LISTA_TYPE
;
LISTA_TYPE:				DEF_TYPE
						| DEF_TYPE LISTA_TYPE
;
DEF_TYPE: 				tk_identificador tk_igual TIPO_PADRAO tk_pontoEVirgula
;

/* Declaracao dos Procedures */
DECLARACAO_PROCEDURE: 	CABECALHO_PROCEDURE {insereFuncoes(dados->nome, aridade, dados->escopo, 0); aridade = 0;} BLOCO tk_pontoEVirgula 
						| CABECALHO_PROCEDURE {insereFuncoes(dados->nome, aridade, dados->escopo, 1); aridade = 0;} tk_forward tk_pontoEVirgula {popEscopo();}
;
CABECALHO_PROCEDURE: 	tk_procedure 
							{initDados(); char* escopo = getEscopo(); strcpy(dados->escopo, escopo); aridade = 0;} 
						tk_identificador 
							{strcpy(dados->nome, yytext); pushEscopo(yytext);} 
						ARGUMENTOS tk_pontoEVirgula 
							
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
DECLARACAO_FUNCTION: 	CABECALHO_FUNCTION {insereFuncoes(dados->nome, aridade, dados->escopo, 0); aridade = 0;} BLOCO tk_pontoEVirgula 
						| CABECALHO_FUNCTION {insereFuncoes(dados->nome, aridade, dados->escopo, 1); aridade = 0;} tk_forward tk_pontoEVirgula {popEscopo();}
;
CABECALHO_FUNCTION: 	tk_function 
							{initDados(); char* escopo = getEscopo(); strcpy(dados->escopo, escopo); aridade = 0;} 
						tk_identificador 
							{strcpy(dados->nome, yytext); pushEscopo(yytext);} 
						ARGUMENTOS tk_doisPontos TIPO_PADRAO tk_pontoEVirgula 
							
;

/* Corpo representa tudo que pode ser incluido dentro do escopo de um begin-end */
CORPO: 					tk_begin CORPO_LISTA tk_end {popEscopo();}
						| tk_begin tk_end {popEscopo();}
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
#define HASHSIZE 97

main(){
	initLista(); /* Inicializa Lista. */
	initPilha();
	//initDados();
	yyparse();
	imprimeVariaveis();
	imprimePilha(); /* Deve sempre imprimir vazio. */
	imprimeFuncoes();
	/*liberaHash()
	liberaPilha()*/
}

yyerror (void){
	printf("Erro na Linha: %d\n", Nlinha);
}
















