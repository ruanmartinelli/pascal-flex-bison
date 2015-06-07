%{
#include <string.h>
int Nlinha = 1;
void contaEnter(char* comentario);
char* id ;
%}

%%

absolute							{return tk_absolute ;}	
and									{return tk_and ;}
array								{return tk_array ;}
begin								{return tk_begin;}
case								{return tk_case ;}
char								{return tk_char ;}
const								{return tk_const ;}
div									{return tk_div ;}
do									{return tk_do ;}
downto								{return tk_downto ;}
else								{return tk_else ;}
end									{return tk_end ;}
external							{return tk_external ;}
file								{return tk_file ;}
for									{return tk_for ;}
forward								{return tk_forward ;}
func								{return tk_func ;}
function							{return tk_function ;}
goto								{return tk_goto ;}
if									{return tk_if ;}
implementation						{return tk_implementation ;}
in									{return tk_in ;}
integer								{return tk_integer ;}
interface							{return tk_interface ;}
interrupt							{return tk_interrupt ;}
label								{return tk_label ;}
main								{return tk_main ;}
mod									{return tk_mod ;}
nil									{return tk_nil ;}
nit									{return tk_nit ;}
not									{return tk_not;}
of									{return tk_of ;}
or									{return tk_or ;}
packed								{return tk_packed ;}
proc								{return tk_proc ;}
procedure							{return tk_procedure ;}
progr								{return tk_progr ;}
program								{return tk_program ;}
record								{return tk_record ;}
repeat								{return tk_repeat ;}
set									{return tk_set ;}
shl									{return tk_shl ;}
shr									{return tk_shr ;}
string								{return tk_string ;}
then								{return tk_then ;}
to									{return tk_to ;}
type								{return tk_type ;}
unit								{return tk_unit ;}
until								{return tk_until ;}
uses								{return tk_uses ;}
var									{return tk_var ;}
while								{return tk_while ;}
with								{return tk_with ;}
xor									{return tk_xor ;}

boolean								{return tk_boolean;}
real 								{return tk_real;}

[\n]								{Nlinha++;}
"(*"("*"^")"|[^*])*"*)"						{contaEnter(yytext);}	
"{"[^}]*"}"							{contaEnter(yytext);}	
"//".*\n							{Nlinha++;}

[a-zA-Z][a-zA-Z0-9]*				{id = (char*)malloc(sizeof(char)*255); strcpy(id,yytext); return tk_identificador;}
L?\"(\\.|[^\\"])*\"					{return tk_constString;}

"*"									{return tk_vezes;}
"+"									{return tk_mais;}
"-"									{return tk_menos;}
"/"									{return tk_divisao;}
"%"									{return tk_restoDivisaoInteira;}
"^"									{return tk_elevado;}
[0-9]+      						{return tk_numeroInteiro;}
"'"[a-zA-Z]"'"						{return tk_caractere;} 
[0-9]+\.[0-9]+("E"[0-9]+)?			{return tk_numeroReal;}

"="									{return tk_igual;} 
"("									{return tk_abreParenteses;}
")"									{return tk_fechaParenteses;}
"["									{return tk_abreColchete;}
"]"									{return tk_fechaColchete;}
"{"									{return tk_abreChaves;}
"}"									{return tk_fechaChaves;}
","									{return tk_virgula;}
":"									{return tk_doisPontos;}
";"									{return tk_pontoEVirgula;}
">"									{return tk_maiorQue;}
"<"									{return tk_menorQue;}
">="								{return tk_maiorIgual;}
"<="								{return tk_menorIgual;}
"<>"								{return tk_diferenteDe;}
":="								{return tk_atribuicao;}
"."									{return tk_ponto;}
".."								{return tk_pontoPonto;}
[ \t]								;


%%
void contaEnter(char* comentario){
	int i = 0;
	while( comentario[i] != 0){
		if(comentario[i] == 10){
			Nlinha++;
		}
		i++;
	}
}

