%{
  open Syntax
%}

/* Lexemes */
%token BLANKLINE
%token <string> STRING
%token <float> NUM
%token <string> VARIABLE
%token TRUE
%token FALSE
%token UNDEFINED
%token NULL
%token TAKE
%token TAKING
%token RETURN
%token CONTINUE
%token BREAK
%token WHILE
%token UNTIL
%token IF
%token ELSE
%token IS
%token ISNOT
%token LISTEN
%token TO
%token PRINT
%token PUT
%token INTO
%token BUILD
%token UP
%token KNOCK
%token DOWN
%token GT
%token GE
%token LT
%token LE
%token PLUS
%token MINUS
%token TIMES
%token DIVIDE
%token COMMA
%token AND
%token OR
%token EOF

/* Precedence and associativity */
%left PLUS MINUS
%left TIMES DIVIDE

/* Top level rule */
%start prog
%type <(Syntax.segment list)> prog

%%

/* Grammar */

prog:
  | blankline s=seg blankline p=prog { s::p }
  | blankline s=seg blanklines EOF { [s] }
;

seg:
  | f=VARIABLE TAKE arg=arguments b=block BLANKLINE { Func (f,arg,b) }
  | b=block { Block (b) }
;

blankline:
  | { Stm([Nop]) }
  | blanklines { Stm([Nop]) }

blanklines:
  | BLANKLINE blanklines { Stm([Nop]) }
  | BLANKLINE { Stm([Nop]) }
;

condition:
  | e1=expression IS e2=expression { Eq (e1,e2) }
  | e1=expression ISNOT e2=expression { Ne (e1,e2) }
  | e1=expression GT e2=expression { Gt (e1,e2) }
  | e1=expression GE e2=expression { Ge (e1,e2) }
  | e1=expression LT e2=expression { Lt (e1,e2) }
  | e1=expression LE e2=expression { Le (e1,e2) }
  | c1=condition AND c2=condition { And (c1,c2) }
  | c1=condition OR c2=condition { Or (c1,c2) }
;

arguments:
  | x=VARIABLE AND arg=arguments { x::arg }
  | x=VARIABLE { [x] }
;

parameters:
  | e=expression COMMA param=parameters { e::param }
  | e=expression { [e] }
;

statements:
  | s1=statement s2=statements { s1::s2 } 
  | s=statement { [s] } 
;

statement:
  | x=VARIABLE IS v=value { Definition (x,v) }
  | e=expression { Expression e }
  | PUT e=expression INTO x=VARIABLE { Assign (x,e) } 
  | LISTEN TO x=VARIABLE { Scan x }
  | PRINT e=expression { Print e }
  | BREAK { Break }
  | CONTINUE { Continue }
  | RETURN e=expression { Return e }
  | KNOCK x=VARIABLE DOWN { Dec x }
  | BUILD x=VARIABLE UP { Inc x }
;

block:
  | b=block_content { [b] }
  | b1=block_content b2=block { b1::b2 } 
;

block_content:
  | IF cond=condition b=block BLANKLINE { If (cond,b,[Stm([Nop])]) }
  | IF cond=condition b1=block BLANKLINE ELSE b2=block BLANKLINE { If (cond,b1,b2) }
  | WHILE cond=condition b=block BLANKLINE { While (cond,b) }
  | UNTIL cond=condition b=block BLANKLINE { Until (cond,b) }
  | s=statements { Stm(s) }
;

value:
  | TRUE      { Boolean True }
  | FALSE     { Boolean False }
  | UNDEFINED { Undefined }
  | NULL { Null }
  | s = STRING { String s }
  | n = NUM   { Number n }
;

expression:
  | f=VARIABLE TAKING p=parameters { Call(f,p) }
  | x = VARIABLE   { Variable x }
  | v = value      { Value v }
  | e1 = expression TIMES  e2 = expression  { Times (e1, e2) }
  | e1 = expression PLUS   e2 = expression  { Plus (e1, e2) }
  | e1 = expression MINUS  e2 = expression  { Minus (e1, e2) }
  | e1 = expression DIVIDE e2 = expression  { Divide (e1, e2) }
;