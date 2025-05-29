%{
#include "parser.tab.h"
#include <stdio.h>

extern FILE *yyin; 
%}

%%

"+"                     { return OP_ADD; }
"-"                     { return OP_SUB; }
"*"                     { return OP_MUL; }
"/"                     { return OP_DIV; }
"%"                     { return OP_MOD; }
"^"                     { return OP_XOR; }
"!"                     { return OP_NOT; }
"|"                     { return OP_OR; }
"="                     { return OP_EQL; }
"=="                    { return OP_EQLS; }
"<"                     { return OP_LST; }
">"                     { return OP_GRT; }
"||"                    { return OP_LOG_OR; }
"&&"                    { return OP_AND; }
"<="                    { return OP_LEQ; }
">="                    { return OP_GEQ; }
"!="                    { return OP_NEQ; }
"+"                    { return UPLUS; }
"-"                    { return UMINUS; }
"++"                    { return OP_INC; }
"--"                    {return OP_DEC; } 

"#"                     { return PREPOS_HASH; }
"include"               { return PREPOS_INCD; }
"define"                { return PREPOS_DEFI; }
"h"                     { return HEADER_TYPE; }

"int"                   { return DTYPE; }
"float"                 { return DTYPE; }
"char"                  { return DTYPE; }
"void"                  { return DTYPE; }

"if"                    { return COND_START; }
"else"                  { return COND_OPTS; }

"{"                     { return LCURLY; }
"}"                     { return RCURLY; }
"("                     { return LPARA; }
")"                     { return RPARA; }
"["                     { return LSQBRAC; }
"]"                     { return RSQBRAC; }
","                     { return SEPERATOR; }
";"                     { return SEMICOLON; }
"."                     { return __DOT; }

^\/\/.*                   { return COMMENTS; }
^\/\*(.|\n)*\*\/      { return COMMENTS; }


[0-9]+                  { return NUMBER; }
[0-9]+\.[0-9]+          { return DECIMAL; }
[a-zA-Z_][a-zA-Z0-9_]*    { return IDENTIFIER; }
[ \t\n]+                { /* Ignore whitespace */ }
.                       { return yytext[0]; }
\"([^\"\\]|\\.)*\"      { return STRING;}


%%

int yywrap(void) {
    return 1;
}


