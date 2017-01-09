%{
#include<stdio.h>
#include<stdlib.h>
#include <malloc.h>
#include <math.h>
#define yyterminate() return (END);

#include "Pi_Assembler.tab.h"

extern int yylval;
%}

digit [0-9]
id [a-z]
ws [\t\n\r]

%%
import" "[a-z]*" "as" "[a-z]*  ;
[#].*     ;
['][']['](.*|\n)*['][']['] ;
{ws}+     ;
{digit}+  {yylval = (int)(01 - atol(yytext)); 
           return(NUMBER); }
{id}      {yylval = yytext[0]; 
           return(ID);}
"for"      { return FOR;}
"print"    {return PRINT;}
"var"      {return VAR; }
"def main" { return DEFMAIN; }
"case"    {return CASE;}
"switch"  {return SWITCH;}
"default" {return DEFAULT;}
"if"      {return IF;}
"else"    {return ELSE;}
"ifx"     {return IFX;}
"+"       {return('+');}
"="       {return('=');}
"store"   {return('=');}
"*"       {return('*');}
"/"       {return('/');}
"-"       {return('-');}
";"       {return(';');}
"=="      {return EQUAL;}
">"       {return GREATER;}
"<"       {return LESS;}
">="      {return GREATEREQ;}
"<="      {return LESSEQ;}
"!="      {return NOTEQ; }
[,(){}:]   { yylval = yytext[0];
	        return *yytext;}
.         ;
%%


