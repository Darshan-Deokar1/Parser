%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
int yylex();
void yyerror(const char *s);

int yydebug;
%}

%token NUMBER IDENTIFIER DECIMAL STRING __DOT
%token LCURLY RCURLY LPARA RPARA LSQBRAC RSQBRAC SEPERATOR SEMICOLON
%token COND_START COND_OPTS 
%token DTYPE
%token PREPOS_HASH PREPOS_INCD PREPOS_DEFI HEADER_TYPE COMMENTS
%token OP_ADD OP_SUB OP_MUL OP_DIV OP_MOD OP_XOR OP_NOT OP_OR OP_EQL OP_EQLS OP_LST OP_GRT OP_LOG_OR OP_AND OP_LEQ OP_GEQ OP_NEQ UMINUS UPLUS OP_INC OP_DEC

%start program

%%
program: program program_unit | %empty

program_unit: function | statement | prepos | COMMENTS

prepos: prepos_include | prepos_definition

prepos_include: PREPOS_HASH PREPOS_INCD STRING | PREPOS_HASH PREPOS_INCD OP_LST include_dll_internal OP_GRT

include_dll_internal: IDENTIFIER __DOT HEADER_TYPE

prepos_definition: PREPOS_HASH PREPOS_DEFI IDENTIFIER expression | PREPOS_HASH PREPOS_DEFI NUMBER | PREPOS_HASH PREPOS_DEFI IDENTIFIER

function: DTYPE IDENTIFIER LPARA args RPARA statement_block

statements: statements statement | %empty

statement_block: LCURLY statements RCURLY

args: vargs | arg | %empty

vargs: vargs SEPERATOR arg | arg

arg: DTYPE IDENTIFIER

statement: cond_stat | init_stat | decl_stat | assign_stat | function_call | expr_unary SEMICOLON

decl_stat: DTYPE IDENTIFIER SEMICOLON | DTYPE IDENTIFIER LSQBRAC NUMBER RSQBRAC SEMICOLON

init_stat: DTYPE IDENTIFIER OP_EQL expression SEMICOLON | DTYPE IDENTIFIER LSQBRAC NUMBER RSQBRAC OP_EQL arrays_assign SEMICOLON

assign_stat: IDENTIFIER OP_EQL expression SEMICOLON

arrays_assign: LCURLY array_vals RCURLY

array_vals: array_single_val | array_multiple_val

array_single_val: NUMBER | DECIMAL

array_multiple_val: array_multiple_val SEPERATOR array_single_val | array_single_val

cond_stat: COND_START LPARA condition RPARA statement_block opts_cond

opts_cond: COND_OPTS cond_stat | COND_OPTS statement_block | %empty

condition: logical_or_expr

logical_or_expr: logical_and_expr | logical_or_expr OP_LOG_OR logical_and_expr

logical_and_expr: equality_expr | logical_and_expr OP_AND equality_expr

equality_expr: relational_expr | equality_expr OP_EQLS relational_expr | equality_expr OP_NEQ  relational_expr

relational_expr: additive_expr | relational_expr OP_LST additive_expr | relational_expr OP_GRT additive_expr 
| relational_expr OP_LEQ additive_expr | relational_expr OP_GEQ additive_expr

additive_expr: multiplicative_expr | additive_expr OP_ADD multiplicative_expr | additive_expr OP_SUB multiplicative_expr

multiplicative_expr: unary_expr | multiplicative_expr OP_MUL unary_expr | multiplicative_expr OP_DIV unary_expr | multiplicative_expr OP_MOD unary_expr

unary_expr: primary_expr | OP_NOT unary_expr | OP_SUB unary_expr %prec UMINUS | OP_ADD unary_expr %prec UPLUS

primary_expr: IDENTIFIER | IDENTIFIER LSQBRAC expression RSQBRAC | NUMBER | DECIMAL | LPARA condition RPARA

expression: expr_cond

expr_cond:  expr_logical_or | expr_logical_or '?' expression ':' expr_cond

expr_logical_or: expr_logical_and | expr_logical_or OP_LOG_OR expr_logical_and

expr_logical_and: expr_bitwise_or | expr_logical_and OP_AND expr_bitwise_or

expr_bitwise_or: expr_bitwise_xor | expr_bitwise_or OP_OR expr_bitwise_xor

expr_bitwise_xor: expr_equality | expr_bitwise_xor OP_XOR expr_equality

expr_equality: expr_relational | expr_equality OP_EQLS expr_relational | expr_equality OP_NEQ expr_relational

expr_relational: expr_additive | expr_relational OP_LST expr_additive | expr_relational OP_GRT expr_additive 
| expr_relational OP_LEQ expr_additive | expr_relational OP_GEQ expr_additive

expr_additive: expr_multiplicative | expr_additive OP_ADD expr_multiplicative | expr_additive OP_SUB expr_multiplicative

expr_multiplicative: expr_unary | expr_multiplicative OP_MUL expr_unary | expr_multiplicative OP_DIV expr_unary 
| expr_multiplicative OP_MOD expr_unary

expr_unary: OP_INC expr_unary | OP_DEC expr_unary | UPLUS expr_unary | UMINUS expr_unary 
| expr_primary OP_INC | expr_primary OP_DEC | expr_primary

expr_primary: IDENTIFIER | IDENTIFIER LSQBRAC expression RSQBRAC | NUMBER | DECIMAL | LPARA expression RPARA

function_call: IDENTIFIER LPARA function_args RPARA SEMICOLON

function_args: expression | function_args SEPERATOR expression | %empty

%% 

void yyerror(const char *s) {
    extern char *yytext;
    fprintf(stderr, "SyntaxError: %s\n", s);

    if (strcmp(yytext, ";") == 0) {
        fprintf(stderr, "Unexpected token '%s' encountered. A semicolon may be misplaced or unexpected here.\n", yytext);
    } else if (strcmp(yytext, "{") == 0) {
        fprintf(stderr, "Unmatched '{' encountered. A corresponding '}' is required to properly close the block.\n");
    } else if (strcmp(yytext, "(") == 0) {
        fprintf(stderr, "Unmatched '(' encountered. A corresponding ')' is required to complete the expression.\n");
    } else if (strcmp(yytext, "}") == 0) {
        fprintf(stderr, "Unexpected '}' encountered. No matching '{' exists for this token.\n");
    } else if (strcmp(yytext, ")") == 0) {
        fprintf(stderr, "Unexpected ')' encountered. No matching '(' exists for this token.\n");
    } else if (strcmp(yytext, "#") == 0) {
        fprintf(stderr, "Invalid preprocessor directive syntax. Verify the format for directives such as #include or #define.\n");
    } else {
        fprintf(stderr, "Unexpected token '%s' encountered. Review the surrounding syntax for potential errors.\n", yytext);
    }
}




int main(void) {
    yyin = stdin;
    yyparse();
    fclose(yyin);
    return 0;
}
