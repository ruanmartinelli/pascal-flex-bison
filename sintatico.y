%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct Hash Hash;
typedef struct Variavel Variavel;
typedef struct Dimensao Dimensao;
typedef struct Funcao Funcao;
typedef struct Lista Lista;
typedef struct Pilha Pilha;
typedef struct Dados Dados;
typedef struct Programa Programa;
typedef struct No No;
typedef struct PilhaNo PilhaNo;

extern char* 	yytext;
extern char*	id;
extern int 		Nlinha;
Hash* 			variaveis[977];
Hash*			funcoes[977];
Lista* 			lista;
Pilha* 			pilha;
Dados*			dados;
Dimensao*		dimensoes;
PilhaNo*		pilhaNo;
No*				arvoreExp;
Programa* 		programa;
No*				currentStatement;
No* 			prog;
No* 			listaProg;
char* 			nomeVar;

int aridade 		= 0;
int qtdParametros 	= 0;
int dim 			= 0;
int ini 			= 0, 
	fim 			= 0;
bool verificar 			= false;
bool encontrouRetorno 	= false;
bool emCorpo 			= false;
bool ehVetor			= false;
char* tipoCorrente;
char* tipoCompara;
char* escopoGlobal;
bool onMainCorpo = false;

struct PilhaNo{
	struct No* no;
	struct PilhaNo* prox;
};

/* Arvore de execucao */
struct No{
	
	char* tipo;
	char* valor;
	
	struct No* prox;	
	
	struct No* um;
	struct No* dois;
	struct No* tres;
	struct No* quatro;
};

/*struct Statement{
	struct No* lista;
};

struct Declaracao{
	struct No* lista;
};*/

struct Programa{
	//struct Declaracao* dec;
	//struct Statement* stmt;
	struct No* statements;
	struct No* declaracoes;

	struct Programa* prox;
};

/* Semantico */
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
	char*   tipo;
};

struct Variavel{
	char* nome;
	char* tipo;
	char* escopo;
	int forward;
	bool utilizada;
	Dimensao* dimensoes;
	int dimensao;
	int val;
};

struct Dimensao{
	int inicio;
	int fim;
	struct Dimensao* prox;
};

struct Dados{
	char* nome;
	char* escopo;
	int forward;
	char* tipo;
};

void initLista(){
	lista 	= NULL;
}

void initPilhaNo(){
	pilhaNo 	= NULL;
	currentStatement = NULL;
}

void initPilha(){
	pilha 	= NULL;
}

void initDimensao(){
	dimensoes = NULL;
}

void liberaDimensao(){
	free(dimensoes);
}

void initDados(){
	dados 			= (Dados*)malloc(sizeof(Dados));
	dados->nome 	= (char*)malloc(sizeof(char) *  255);
	dados->escopo 	= (char*)malloc(sizeof(char) *  255);
	dados->tipo 	= (char*)malloc(sizeof(char) *  255);
}

void imprimePilha();



void liberaDados(){
	free(dados->escopo);
	free(dados->nome);
	free(dados);
}

void liberaArvore(No* arv){
	if(arv == NULL){
		return;
	}
	liberaArvore(arv->um);
	liberaArvore(arv->dois);
	
	return free(arv);
}

int ehOperador(char* s){
	if(strcmp(s,"+") == 0 
		|| strcmp(s,"-")  == 0
		|| strcmp(s,"*")  == 0
		|| strcmp(s,"/")  == 0 
		|| strcmp(s,">")  == 0
		|| strcmp(s,"=")  == 0
		|| strcmp(s,"<>") == 0
		|| strcmp(s,"<")  == 0){
			return 1;
	}
	return 0;
}

void popPilhaExp();

No* desempilha(/*Pilha*/){
	if(ehOperador(pilhaNo->no->valor) == 0){
		No* node = pilhaNo->no;
		popPilhaExp();
		return node;
	}
	else{
			No* op = pilhaNo->no;
			popPilhaExp();
			op->dois = desempilha();
			op->um = desempilha();
			return op;
	}
}

No* criaNo(char* tipo, char* valor, No* um, No* dois, No* tres, No* quatro){
	No* novo 	= (No*) malloc (sizeof(No));
	novo->tipo 	= (char*)malloc(sizeof(char) *  255);
	novo->valor = (char*)malloc(sizeof(char) *  255);
	
	strcpy(novo->tipo,tipo);
	strcpy(novo->valor,valor);
	
	/*novo->um 		= (No*) malloc (sizeof(No));
	novo->dois 		= (No*) malloc (sizeof(No));
	novo->tres 		= (No*) malloc (sizeof(No));
	novo->quatro 	= (No*) malloc (sizeof(No));*/
	novo->prox 		= NULL;

	novo->um 		= um;
	novo->dois 		= dois;
	novo->tres 		= tres;
	novo->quatro 	= quatro;
	
	return novo;
}

Programa* initPrograma(){
	Programa* novo 	= (Programa*) malloc (sizeof(Programa));
	novo->statements = NULL;
	novo->prox 		= NULL;
	return novo;
};
void imprimeArvoreDoisFilhos(No* no, int profundidade);

void appendStmt(No* arv, No* lista){
	if(listaProg == NULL){
		listaProg = arv;
	}else{
		No* p = listaProg;
		while(p->prox != NULL) p = p->prox;
		p->prox = arv;
	}
}

/*--- Pilha de Expressoes ----*/
void pushPilhaExp(char* valor){
	PilhaNo* novo 	= (PilhaNo*)malloc(sizeof(PilhaNo));
	novo->no 		= criaNo("", valor, NULL, NULL, NULL, NULL);
	novo->prox 		= pilhaNo;
	pilhaNo 		= novo;
}

void popPilhaExp(){
	PilhaNo* aux 	= (PilhaNo*) malloc (sizeof(PilhaNo)); 
	aux 		= pilhaNo;
	pilhaNo		= pilhaNo->prox;
	free 		(aux);
}
/*--- Pilha de Expressoes ----*/

void pushEscopo(char* nome){
	Pilha* novo = (Pilha*) malloc (sizeof(Pilha));
	novo->nome  = (char*) malloc (sizeof(char)*255);
	strcpy		(novo->nome,nome);
	novo->prox  = pilha;
	pilha 		= novo;

}

void popEscopo(){
		
	if(pilha->prox != NULL){
	printf("Popando Escopo\n");

	Pilha* aux 	= (Pilha*) malloc (sizeof(Pilha)); 
	aux 		= pilha;
	pilha 		= pilha->prox;
	imprimePilha();
	printf("Popando FIM\n");
	}
	//free 		(aux);
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
	if(soma > 977){
		return soma % 9;
	}
	
	return soma;
}

/*From: http://www.programmingsimplified.com/c/source-code/c-program-convert-string-to-integer-without-using-atoi-function*/
int toInt(char a[]) {
  int c, sign, offset, n;
 
  if (a[0] == '-') {  
    sign = -1;
  }
  if (sign == -1) {
    offset = 1;
  }
  else {
    offset = 0;
  }
  n = 0;
  for (c = offset; a[c] != '\0'; c++) {
    n = n * 10 + a[c] - '0';
  }
  if (sign == -1) {
    n = -n;
  }
  return n;
}

void insereDimensoes(int ini, int fim){
		Dimensao* novo = (Dimensao*)malloc(sizeof(Dimensao));
		novo->inicio = ini;
		novo->fim = fim;
		novo->prox = dimensoes;
		dimensoes = novo;
}

void insereFuncoes(char* nome, int aridade, char* escopo, int forward, char* tipo){
	int tamanhoNome 		= strlen(nome);
	int tamanhoEscopo		= strlen(escopo);
	int tamanhoTipo			= strlen(tipo);
	Hash* novo 				= (Hash*) 	malloc(sizeof(Hash));
	novo->funcao 			= (Funcao*)	malloc(sizeof(Funcao));
	novo->funcao->nome 		= (char*) 	malloc(sizeof(char)*tamanhoNome);
	novo->funcao->escopo	= (char*) 	malloc(sizeof(char)*tamanhoEscopo);
	novo->funcao->tipo 		= (char*) 	malloc(sizeof(char)*tamanhoTipo);
	novo->funcao->forward	= forward;
	novo->prox 				= NULL;
	strcpy					(novo->funcao->nome, nome);
	strcpy					(novo->funcao->escopo, escopo);
	strcpy					(novo->funcao->tipo, tipo);
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
						&& p->funcao->forward == novo->funcao->forward 
							&& strcmp(p->funcao->tipo, novo->funcao->tipo) == 0){
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

void insereVariaveis(char* nome, char* tipo, char* escopo, Dimensao* dim){
	int tamanhoNome 		= 				strlen(nome);
	int tamanhoTipo 		= 				strlen(tipo);
	int tamanhoEscopo		= 				strlen(escopo);
	Hash* novo 				= (Hash*)		malloc(sizeof(Hash));
	novo->variavel 			= (Variavel*)	malloc(sizeof(Variavel));
	novo->variavel->nome 	= (char*)		malloc(sizeof(char)*tamanhoNome);
	novo->variavel->tipo 	= (char*)		malloc(sizeof(char)*tamanhoTipo);
	novo->variavel->escopo 	= (char*)		malloc(sizeof(char)*tamanhoEscopo);
	novo->variavel->val 	= 0;

	novo->variavel->dimensoes = (Dimensao*)malloc(sizeof(Dimensao));
	novo->variavel->dimensoes = dim;

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

					/*	Caso encontre uma variavel igual, 
						vê se ela foi declarada
						em uma funcao do tipo forward 
						antes de acusar como redeclarada
					*/
					Hash* f;
					int j = 0;
					for(j = 0 ; j < 977 ; j++){
						for(f = funcoes[j] ; f != NULL ; f = f->prox){
							if(strcmp(p->variavel->escopo, f->funcao->nome) == 0
								&& f->funcao->forward == 1){
								return;
							}
						}
						
					}

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

void adicionaListaTabela(char* tipo, char* escopo, Dimensao* dim){
	Lista* id;
	for(id = lista; id != NULL ; id = id->prox){
		if(id->nome != NULL){
			insereVariaveis(id->nome, tipo, escopo, dim);
		}
		Lista* aux 	= (Lista*)malloc(sizeof(Lista));
		aux 		= lista->prox;
		free 		(lista);
		lista 		= aux;
	}
}

void insereFuncoesPrimitivas(){
	insereFuncoes("read", 1, escopoGlobal, 0, "string");
	insereFuncoes("readln", 1, escopoGlobal, 0, "string");
	insereFuncoes("write", 1, escopoGlobal, 0, "N/A");
	insereFuncoes("+", 2, escopoGlobal, 0, "integer");
	insereFuncoes("-", 2, escopoGlobal, 0, "integer");
	insereFuncoes("*", 2, escopoGlobal, 0, "integer");
	insereFuncoes("pow", 2, escopoGlobal, 0, "integer");
	insereFuncoes("div", 2, escopoGlobal, 0, "integer");
	insereFuncoes("mod", 2, escopoGlobal, 0, "integer");
	insereFuncoes("max", 2, escopoGlobal, 0, "integer");
	insereFuncoes("min", 2, escopoGlobal, 0, "integer");
	insereFuncoes("+", 2, escopoGlobal, 0, "real");
	insereFuncoes("-", 2, escopoGlobal, 0, "real");
	insereFuncoes("*", 2, escopoGlobal, 0, "real");
	insereFuncoes("pow", 2, escopoGlobal, 0, "real");
	insereFuncoes("div", 2, escopoGlobal, 0, "real");
	insereFuncoes("mod", 2, escopoGlobal, 0, "real");
	insereFuncoes("max", 2, escopoGlobal, 0, "real");
	insereFuncoes("min", 2, escopoGlobal, 0, "real");
}

void verificaVariavel(char* nome){
	int i = 0;
	char* escopo = getEscopo();
	for(i = 0 ; i < 977 ; i++){
		if(variaveis[i] != NULL){
			Hash* aux;
			for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
				if(strcmp(aux->variavel->nome, nome) == 0
					&& (strcmp(aux->variavel->escopo, escopo) == 0 || strcmp(aux->variavel->escopo, escopoGlobal) == 0)){
					return;
				}
			}
		}
	}
			printf("Variavel nao encontrada na linha %d \n", Nlinha);
			exit(0);
}

/*
COMPARA : P
CORRENTE: R
*/
void setTipo(char* nome, char t, char* valorConstante){
	int i = 0;
	char* escopo = getEscopo();
	if(valorConstante == NULL){
		for(i = 0 ; i < 977 ; i++){
			if(variaveis[i] != NULL){
				Hash* aux;
				for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
					if(nome != NULL){
						if(strcmp(aux->variavel->nome, nome) == 0 && ( strcmp(aux->variavel->escopo, escopo) == 0 
							|| strcmp(aux->variavel->escopo,escopoGlobal) == 0)){
							if(t == 'p'){
								tipoCompara = (char*)malloc(sizeof(char)*strlen(aux->variavel->tipo));
								strcpy(tipoCompara,aux->variavel->tipo);
							}else{
								if(t == 'r'){
									tipoCorrente = (char*)malloc(sizeof(char)*strlen(aux->variavel->tipo));
									strcpy(tipoCorrente,aux->variavel->tipo);
								}					
							}
						}
					}
				}
			}
		}
		return;
	}if(valorConstante != NULL){
		tipoCompara = (char*)malloc(sizeof(char)*strlen(valorConstante));
		strcpy(tipoCompara,valorConstante);
	}
}

void setTipoFuncao(char* nome){
	int i = 0;
	char* escopo = getEscopo();
	for(i = 0 ; i < 977 ; i++){
		if(funcoes[i] != NULL){
			Hash* aux;
			for(aux = funcoes[i] ; aux != NULL; aux = aux->prox){
				if(strcmp(aux->funcao->nome, nome) == 0
					&& strcmp(aux->funcao->escopo, escopo) == 0
						&& aux->funcao->forward == 0){
					tipoCompara = (char*) malloc(sizeof(char)*255);
					strcpy(tipoCompara,aux->funcao->tipo);
				}
			}
		}
	}
}

void setVarUtilizada(char* nome){
	int i = 0;
	char* escopo = getEscopo();
	for(i = 0 ; i < 977 ; i++){
		if(variaveis[i] != NULL){
			Hash* aux;
			for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
				if(strcmp(aux->variavel->nome, nome) == 0
					&& (strcmp(aux->variavel->escopo, escopo) == 0 || (strcmp(aux->variavel->escopo, escopoGlobal) == 0) )){
						//if(emCorpo){
							aux->variavel->utilizada = true;
						//}
						//if(!emCorpo){
						//	aux->variavel->utilizada =false;
						//}
				}
			}
		}
	}
}

void lancaErroNaoUtilizadas(){
	int i = 0;
	char* escopo = getEscopo();
	for(i = 0 ; i < 977 ; i++){
		if(variaveis[i] != NULL){
			Hash* aux;
			for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
				if(!aux->variavel->utilizada){
					printf("Erro semantico em %s. Variavel %s nao utilizada.\n", aux->variavel->escopo, aux->variavel->nome);
					exit(0);
				}
			}
		}
	}
}

void verificaTipos(){
	if(tipoCompara != NULL && tipoCorrente !=NULL){
		if(strcmp(tipoCompara,tipoCorrente) != 0 || strcmp(tipoCompara, "N/A") == 0){
			printf("Erro semantico na linha %d. Tipo incorreto atribuido a variavel.\n", Nlinha);
			exit(0);
		
		}
	}
}

void verificaFuncao(char* nome, int qtdParametros){
	int i = 0;
	char* escopo = getEscopo();
	for(i = 0 ; i < 977 ; i++){
		if(funcoes[i] != NULL){
			Hash* aux;
			for(aux = funcoes[i] ; aux != NULL; aux = aux->prox){
				if(strcmp(aux->funcao->nome, nome) == 0
					&& strcmp(aux->funcao->escopo, escopo) == 0
						&& aux->funcao->forward == 0){
					if(aux->funcao->aridade != qtdParametros){
						printf("Erro semantico na linha %d. Quantidade de parametros incorreta para a funcao.\n", Nlinha);
						exit(0);
					}
					return;
				}
			}
		}
	}
			printf("Funcao nao encontrada na linha %d \n", Nlinha);
			exit(0);
}

void verificaRetorno(char* nome, char* escopo){
	if(verificar && strcmp(nome,escopo) == 0){
		encontrouRetorno = true;
	}
}

void lancaErroRetorno(char* nome){
	if(!encontrouRetorno){
		printf("Funcao %s nao possui retorno.\n", nome);
		exit(0);
	}
}


int findVariavel(char* nomeVariavel){
	int i;
	char* escopo = getEscopo();
	for(i = 0 ; i < 977 ; i++){
		if(variaveis[i] != NULL){
			Hash* aux;
			for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
				if(strcmp(aux->variavel->nome, nomeVariavel) == 0){
					return aux->variavel->val;
				}
			}
		}
	}
}

bool ehNumero(char* nome){
	int i;
	printf("Avaliando %s. Primeira letra = %d\n",nome, nome[0]);
	for(i = 0 ; i < strlen(nome) ; i++){
		if(nome[i] < 48 || nome[i] > 57){
			return false;
		}
	}
	return true;
}

int avaliaExp(No* arv){
	if(arv->um == NULL && arv->dois == NULL){
		if(ehNumero(arv->valor) == false){
			return findVariavel(arv->valor);

		}
		return atoi(arv->valor);
	}
	else{
		if(strcmp(arv->valor,"+") == 0){
			return(avaliaExp(arv->um) + avaliaExp(arv->dois));
		}
		if(strcmp(arv->valor,"-") == 0){
			return(avaliaExp(arv->um) - avaliaExp(arv->dois));
		}
		if(strcmp(arv->valor,"/") == 0){
			return(avaliaExp(arv->um) / avaliaExp(arv->dois));
		}
		if(strcmp(arv->valor,"*") == 0){
			return(avaliaExp(arv->um) * avaliaExp(arv->dois));
		}
		if(strcmp(arv->valor,"div") == 0){
			return(avaliaExp(arv->um) / avaliaExp(arv->dois));
		}
		if(strcmp(arv->valor,"%") == 0){
			return(avaliaExp(arv->um) % avaliaExp(arv->dois));
		}
		
	}
}

void setValorVariavel(char* nomeVariavel, int resultado){
	int i;
	char* escopo = getEscopo();
	for(i = 0 ; i < 977 ; i++){
		if(variaveis[i] != NULL){
			Hash* aux;
			for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
				if(strcmp(aux->variavel->nome, nomeVariavel) == 0 && (strcmp(aux->variavel->escopo, escopo) == 0)){
					aux->variavel->val = resultado;
				}
			}
		}
	}
}


void executaAtribuicoes(No* programa){
	No* p;
	for(p = programa ; p != NULL ; p = p->prox){
		setValorVariavel(p->um->valor, avaliaExp(p->dois));
	}
}

/*Funcoes de imprimir*/
void imprimePilhaExp(){
	PilhaNo* p = pilhaNo;
	printf("Pilha de Nos:\n");
	while(p!= NULL){
		printf("@ %s",p->no->valor);
		printf("\n");
		p = p->prox;
	}

}

void imprimeArvoreDoisFilhos(No* arv, int profundidade){
	if(arv != NULL){
		imprimeArvoreDoisFilhos(arv->um,profundidade+2);
		int i;
		for(i = 0 ; i < profundidade ; i++){
			printf("  ");
		}
		printf("%s\n", arv->valor);
		imprimeArvoreDoisFilhos(arv->dois,profundidade+2);
	}
}

void imprimeVariaveis(){
	int i;
	printf("Tabela de Variaveis:\n");
	for(i = 0 ; i < 977 ; i++){
		if(variaveis[i] != NULL){
			Hash* aux;
			for(aux = variaveis[i] ; aux != NULL; aux = aux->prox){
				printf("	[%d] : %s	- %s	- %s 	- %d\n",
				 i, aux->variavel->nome, aux->variavel->escopo, aux->variavel->tipo, aux->variavel->utilizada);
				printf("		Valor: %d\n", aux->variavel->val);
				Dimensao* d;
				for(d = aux->variavel->dimensoes ; d != NULL ; d = d->prox){
					printf(" 		%d..%d\n", d->inicio, d->fim);
				}

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
				if(aux->funcao->tipo != NULL){
					printf("	[%d] : %s	- 	%s	- %s	-	 %d -	%d\n",
					 i, aux->funcao->nome, aux->funcao->escopo, aux->funcao->tipo ,aux->funcao->aridade, aux->funcao->forward);
				}
				else{
					printf("	[%d] : %s	- 	%s	-	 %d -	%d\n", i, 
						aux->funcao->nome, aux->funcao->escopo, aux->funcao->aridade, aux->funcao->forward);
				}
			}
		}
	}
}

void imprimePilha(){ //deve sempre estar vazia pois pilha eh desempilhada
	int 	i;
	Pilha* 	p;
	printf("Pilha de Escopo: \n");
	for(p = pilha ; p!= NULL ; p = p->prox){
		printf("	%s\n", p->nome);
	}
}

/*void imprimePrograma(Programa* prog){
	if(prog->statements != NULL){
		No* p;
		for(p = prog->statements ; p->prox!= NULL ; p = p->prox){
			printf("@ %s\n", p->tipo);
			imprimeArvoreDoisFilhos(p,0);
		}
	}
	else{
		printf("@ Programa NULL\n");
	}
}*/

void imprimeProgramaNo(No* prg){
	if(prg != NULL){
		No* p;
		for(p = prg; p!= NULL ; p = p->prox){
			printf("@ %s\n", p->tipo);
			imprimeArvoreDoisFilhos(p,0);
		}
	}
	else{
		printf("@ Programa Null\n");
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
%token tk_false
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
%token tk_true
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
%token tk_identificador
%token tk_vezes
%token tk_mais
%token tk_menos
%token tk_divisao
%token tk_restoDivisaoInteira
%token tk_elevado
%token tk_numeroInteiro
%token tk_numeroReal

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
PROG: 					CABECALHO {} BLOCO {lancaErroNaoUtilizadas();} tk_ponto 
;

CABECALHO: 				tk_program tk_identificador 
						{pushEscopo(yytext); escopoGlobal = getEscopo();insereFuncoesPrimitivas();} 
						tk_pontoEVirgula 
;

/* Bloco agrega todos os demais componentes do programa */
BLOCO: 					VARIAVEIS BLOCO 
						| DECLARACAO_PROCEDURE BLOCO 
						| DECLARACAO_PROCEDURE 
						| VARIAVEIS 	
						| CORPO 
						| DECLARACAO_FUNCTION 
						| DECLARACAO_FUNCTION BLOCO 
						| DECLARACAO_TYPE
						| DECLARACAO_TYPE BLOCO
;
/* Declaracao inicial das variaveis. */
VARIAVEIS: 				tk_var DECLARACAO_VARIAVEIS
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
							{char* escopo = getEscopo(); adicionaListaTabela(yytext, escopo,NULL);}
						| tk_array tk_abreColchete {initDimensao(); dim = 0;} DIMENSAO_LISTA tk_fechaColchete tk_of TIPO_PADRAO 
							{char* escopo = getEscopo();adicionaListaTabela(yytext, escopo, dimensoes); ini = fim = 0;}
;

DIMENSAO_LISTA:			DIMENSAO {dim++;}
						| DIMENSAO_LISTA tk_virgula DIMENSAO {dim++;}
;
DIMENSAO: 				tk_numeroInteiro {ini = toInt(yytext);} tk_pontoPonto tk_numeroInteiro 
						{fim = toInt(yytext);insereDimensoes(ini,fim);}
;
TIPO_PADRAO: 			tk_integer
						| tk_char
						| tk_boolean
						| tk_real
						| tk_string
						| tk_abreParenteses LISTA_IDS tk_fechaParenteses
;
LISTA_IDS : 			tk_identificador 
						| tk_identificador tk_virgula LISTA_IDS
;
DECLARACAO_TYPE: 		tk_type LISTA_TYPE
;
LISTA_TYPE:				DEF_TYPE
						| DEF_TYPE LISTA_TYPE
;
DEF_TYPE: 				tk_identificador tk_igual TIPO_PADRAO tk_pontoEVirgula
;

/* Declaracao dos Procedures */
DECLARACAO_PROCEDURE: 	CABECALHO_PROCEDURE {insereFuncoes(dados->nome, aridade, dados->escopo, 0, "N/A"); aridade = 0;} 
						BLOCO tk_pontoEVirgula 
						| CABECALHO_PROCEDURE {insereFuncoes(dados->nome, aridade, dados->escopo, 1, "N/A"); aridade = 0;} 
						tk_forward tk_pontoEVirgula {popEscopo();}
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
DECLARACAO_FUNCTION: 	CABECALHO_FUNCTION 
												{	
													insereFuncoes(dados->nome, aridade, dados->escopo, 0, dados->tipo); 
													insereVariaveis(dados->nome, dados->tipo, dados->nome,NULL); 
													aridade = 0; 
													verificar = true; 
													encontrouRetorno = false;
												} 
						BLOCO 
												{
													verificar = false; lancaErroRetorno(dados->nome);
												} 
						tk_pontoEVirgula 
						| 
						CABECALHO_FUNCTION 
												{
													insereFuncoes(dados->nome, aridade, dados->escopo, 1, dados->tipo); 
													aridade = 0;
												} 
						tk_forward 
						tk_pontoEVirgula 
												{
													popEscopo();
												}
;
CABECALHO_FUNCTION: 	tk_function 
												{
													initDados();
													char* escopo = getEscopo();
													strcpy(dados->escopo, escopo); 
													aridade = 0;
												} 
						tk_identificador 
												{
													strcpy(dados->nome, yytext); 
													pushEscopo(yytext);
												} 
						ARGUMENTOS 
						tk_doisPontos 
						TIPO_PADRAO 
												{
													strcpy(dados->tipo,yytext);
												} 
						tk_pontoEVirgula 
;

/* Corpo representa tudo que pode ser incluido dentro do escopo de um begin-end */
CORPO: 					tk_begin {emCorpo = true;} CORPO_LISTA {emCorpo = false;} tk_end {popEscopo();}
						| tk_begin {} tk_end {popEscopo();}
;
CORPO_LISTA: 			 DECLARACAO tk_pontoEVirgula {}
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
VARIAVEL_DECLARACAO: 	VARIAVEL {char* escopo = getEscopo(); verificaRetorno(id,escopo); setTipo(id,'r',NULL); nomeVar = id;} 
						tk_atribuicao 
						EXPRESSAO 
						{
							appendStmt(criaNo("atribuicao","A",criaNo("variavel",nomeVar,NULL,NULL,NULL,NULL), desempilha(), NULL,NULL), listaProg); 
							verificaTipos();
						}
;

/* If */
IF_DECLARACAO: 			tk_if EXPRESSAO tk_then CORPO 
						| tk_if EXPRESSAO tk_then CORPO tk_else CORPO tk_pontoEVirgula
						| tk_if EXPRESSAO tk_then DECLARACAO
;

/* While */
WHILE_DECLARACAO: 		tk_while EXPRESSAO tk_do DECLARACAO {}
						| tk_while EXPRESSAO tk_do {} CORPO {}
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


CONSTANTE:				tk_numeroReal 		{setTipo(NULL, 'p', "real"); 	pushPilhaExp(yytext);}
						| tk_numeroInteiro 	{setTipo(NULL, 'p', "integer"); pushPilhaExp(yytext);}
						| tk_caractere 		{setTipo(NULL, 'p', "char"); 	pushPilhaExp(yytext);}
						| BOOL				{setTipo(NULL, 'p', "boolean");pushPilhaExp(yytext);}
						| tk_constString	{setTipo(NULL, 'p', "string"); 	pushPilhaExp(yytext);}
;

BOOL: tk_true | tk_false;
/* Chamadas de Funcao e Procedures */
PROCEDURES_CHAMADA: 	tk_identificador {initDados(); strcpy(dados->nome,id); qtdParametros = 0;} PARAMS
;
FUNCAO_CHAMADA: 		tk_identificador {initDados(); strcpy(dados->nome,id);qtdParametros = 0;} PARAMS;

PARAMS: 				tk_abreParenteses {qtdParametros = 0;} EXPRESSAO_LISTA 
{verificaFuncao(dados->nome,qtdParametros);} tk_fechaParenteses
						| tk_abreParenteses {verificaFuncao(dados->nome,qtdParametros);} tk_fechaParenteses
;
EXPRESSAO_LISTA : 		EXPRESSAO {qtdParametros++;}
						| EXPRESSAO_LISTA tk_virgula EXPRESSAO {qtdParametros++;}
;

/* Continuacao das Variaveis*/
VARIAVEL: 				 tk_identificador {verificaVariavel(id) ; setVarUtilizada(id);}
						| tk_identificador {verificaVariavel(id) ; setVarUtilizada(id);} tk_abreColchete EXPRESSAO_LISTA {} tk_fechaColchete

;
EXPRESSAO: 				EXPRESSAO_SIMPLES 
						| EXPRESSAO_SIMPLES tk_igual EXPRESSAO_SIMPLES {pushPilhaExp("==");}
						| EXPRESSAO_SIMPLES tk_diferenteDe EXPRESSAO_SIMPLES {pushPilhaExp("<>");}
						| EXPRESSAO_SIMPLES tk_maiorQue EXPRESSAO_SIMPLES {pushPilhaExp(">");}
						| EXPRESSAO_SIMPLES tk_menorQue EXPRESSAO_SIMPLES {pushPilhaExp("<");}
						| EXPRESSAO_SIMPLES tk_menorIgual EXPRESSAO_SIMPLES {pushPilhaExp("<=");}
;
EXPRESSAO_SIMPLES: 		TERMO 
						| EXPRESSAO_SIMPLES tk_mais TERMO {pushPilhaExp("+");}
						| EXPRESSAO_SIMPLES tk_menos TERMO {pushPilhaExp("-");} 
						| EXPRESSAO_SIMPLES tk_or TERMO {pushPilhaExp("or");} 
;
TERMO: 					FATOR 
						| TERMO tk_vezes FATOR {pushPilhaExp("*");}
						| TERMO tk_divisao FATOR {pushPilhaExp("/");}
						| TERMO tk_restoDivisaoInteira FATOR {pushPilhaExp("%");}
						| TERMO tk_div FATOR {pushPilhaExp("div");}
						| TERMO tk_and FATOR {pushPilhaExp("and");}
;
FATOR: 					VARIAVEL {setTipo(id, 'p', NULL); pushPilhaExp(id);}
						| CONSTANTE {}
						| tk_abreParenteses EXPRESSAO tk_fechaParenteses 
						| ADDOP FATOR
						| FUNCAO_CHAMADA {setTipoFuncao(id);}
;
ADDOP: 					tk_mais 
						| tk_menos 
						| tk_not 
;


%%

#include "lex.yy.c"

main(){
	initLista();
	initPilha();
	initPilhaNo();
	listaProg = NULL;
	arvoreExp = NULL;

	yyparse();

	//imprimePilha(); 
	//imprimePilhaExp();
	//imprimeFuncoes();


	//int a = avaliaExp(listaProg->dois);
	//printf("avalia: %d\n", a);

	executaAtribuicoes(listaProg);

	imprimeVariaveis();
	imprimeProgramaNo(listaProg);
	return 0;
}

yyerror (void){
	printf("Erro na Linha: %d\n", Nlinha);
}
