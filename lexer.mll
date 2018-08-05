{
  open Lexing

  exception SyntaxError of string

  let incr_linenum lexbuf=
    let pos=lexbuf.lex_curr_p in
    lexbuf.lex_curr_p<-{ pos with
      pos_lnum=pos.pos_lnum + 1;
      pos_bol=pos.pos_cnum;
    }
  (* assume all variables live with global scope *)
  let env=ref []
  type state=
    | CODE
    | NEWLINE
    | COMMENT
    | STR
    | PSTRING
    | PNUMBER
    | IS
  let state=ref CODE
  let is_cond=ref false
}

let int = '-'? ['0'-'9'] ['0'-'9']*
let digit = ['0'-'9']
let frac = '.' digit*
let exp = ['e' 'E'] ['-' '+']? digit+
let float = digit+ frac? exp?

let whitespace=[' ' '\t']+
let newline="\r\n"|'\r'|'\n'
let blankline="\r\n\r\n"|"\r\r"|"\n\n"

let pronoun="it"|"he"|"she"|"him"|"her"
  |"they"|"them"|"ze"|"hir"|"zie"|"zir"
  |"xe"|"xem"|"ve"|"ver"
let article="a"|"an"|"the"|"my"|"your"|"A"|"An"|"The"|"My"|"Your"
let captical_article="A"|"An"|"The"|"My"|"Your"
let captical=['A'-'Z'] ['A'-'Z' 'a'-'z']*
let id=(article whitespace ['a'-'z']+)

let bool_true="true"|"right"|"yes"|"ok"
let bool_false="false"|"wrong"|"no"|"lies"
let null="nothing"|"nowhere"|"nobody"|"empty"|"gone"
let is="is"|"was"|"were"
let gt=is whitespace ("higher"|"greater"|"bigger"|"stronger") whitespace "than"
let lt=is whitespace ("lower"|"less"|"smaller"|"weaker") whitespace "than"
let ge=is whitespace "as" whitespace ("high"|"great"|"big"|"strong") whitespace "as"
let le=is whitespace "as" whitespace ("low"|"little"|"small"|"weak") whitespace "as"
rule read=
  parse
  | whitespace { read lexbuf }
  | newline { is_cond:=false; incr_linenum lexbuf; state:=NEWLINE; read_newline lexbuf }
  | '"' { state:=STR; read_string (Buffer.create 16) lexbuf }
  | "mysterious" { Parser.UNDEFINED }
  | "says " { state:=PSTRING; Parser.IS }
  | "Put" { Parser.PUT }
  | "into" { Parser.INTO }
  | "Build" { Parser.BUILD }
  | "up" { Parser.UP }
  | "Knock" { Parser.KNOCK }
  | "down" { Parser.DOWN }
  | "plus"|"with" { Parser.PLUS }
  | "minus"|"without" { Parser.MINUS }
  | "times"|"of" { Parser.TIMES }
  | "over" { Parser.DIVIDE }
  | "Listen" { Parser.LISTEN }
  | "to" { Parser.TO }
  | "Say"|"Shout"|"Whisper"|"Scream" { Parser.PRINT }
  | "If" { is_cond:=true; Parser.IF }
  | "Else" { is_cond:=true; Parser.ELSE }
  | "While" { is_cond:=true; Parser.WHILE }
  | "Until" { is_cond:=true; Parser.UNTIL }
  | "Break"|"Break" whitespace "it" whitespace "down" { Parser.BREAK }
  | "Continue"|"Take" whitespace "it" whitespace "to" whitespace "the" whitespace "top" { Parser.CONTINUE }
  | "takes" { Parser.TAKE }
  | "Give" whitespace "back" { Parser.RETURN }
  | "and" { Parser.AND }
  | "or" { Parser.OR }
  | "taking" { Parser.TAKING }
  | ',' { Parser.COMMA }
  | null { Parser.NULL }
  | int { Parser.NUM (float_of_string (lexeme lexbuf)) }
  | float { Parser.NUM (float_of_string (lexeme lexbuf)) }
  | bool_true { Parser.TRUE }
  | bool_false { Parser.FALSE }
  | gt { Parser.GT }
  | lt { Parser.LT }
  | ge { Parser.GE }
  | le { Parser.LE }
  | ((is whitespace "not")|"aint") whitespace { (if not !is_cond then state:=IS); Parser.ISNOT }
  | is whitespace { (if not !is_cond then state:=IS); Parser.IS }
  | pronoun {  try Parser.VARIABLE(List.hd !env) with (Failure hd) -> raise (SyntaxError ((lexeme lexbuf)^" refers to nothing")) }
  | id { env:=(lexeme lexbuf)::!env; (Parser.VARIABLE (String.lowercase (lexeme lexbuf))) }
  | captical { let buf=Buffer.create 32 in let ()=Buffer.add_string buf (lexeme lexbuf) in read_var buf lexbuf }
  | _ { raise (SyntaxError ("Unexpected character:"^(lexeme lexbuf))) }
  | eof { state:=CODE; Parser.EOF }
and read_var buf=
  parse
  | newline { is_cond:=false; incr_linenum lexbuf; state:=NEWLINE; Parser.VARIABLE (Buffer.contents buf) }
  | "Put" { Parser.PUT }
  | "Build" { Parser.BUILD }
  | "Knock" { Parser.KNOCK }
  | "Listen" { Parser.LISTEN }
  | "Say"|"Shout"|"Whisper"|"Scream" { Parser.PRINT }
  | "If" { is_cond:=true; Parser.IF }
  | "Else" { is_cond:=true; Parser.ELSE }
  | "While" { is_cond:=true; Parser.WHILE }
  | "Until" { is_cond:=true; Parser.UNTIL }
  | "Break"|"Break" whitespace "it" whitespace "down" { Parser.BREAK }
  | "Continue"|"Take" whitespace "it" whitespace "to" whitespace "the" whitespace "top" { Parser.CONTINUE }
  | "Give" whitespace "back" { Parser.RETURN }
  | whitespace { read_var buf lexbuf }
  | captical { Buffer.add_char buf ' ';Buffer.add_string buf (lexeme lexbuf) ; read_var buf lexbuf }
  | "" { Parser.VARIABLE (Buffer.contents buf) }
and read_is=
  parse
  | "true" { state:=CODE; Parser.TRUE }
  | "false" { state:=CODE; Parser.FALSE }
  | "nothing"|"nowhere"|"nobody" { state:=CODE; Parser.NULL }
  | float { state:=CODE; Parser.NUM (float_of_string (lexeme lexbuf)) }
  | int { state:=CODE; Parser.NUM (float_of_string (lexeme lexbuf)) }
  | "" { state:=PNUMBER; read_number 0 false (Buffer.create 16) lexbuf }
  | eof { state:=CODE; raise (SyntaxError ("Is literal is not terminated")) }
and read_number count period buf=
  parse
  | newline { if count>0 then Buffer.add_string buf (string_of_int (count mod 10)); incr_linenum lexbuf; state:=NEWLINE; Parser.NUM (float_of_string (Buffer.contents buf)) }
  | whitespace { if count>0 then Buffer.add_string buf (string_of_int (count mod 10)); read_number 0 period buf lexbuf }
  | '.' { if period then read_number count period buf lexbuf else (Buffer.add_string buf (string_of_int (count mod 10)); Buffer.add_char buf '.'; read_number 0 true buf lexbuf) }
  | ['A'-'Z' 'a'-'z'] { read_number (count+1) period buf lexbuf }
  | _ { read_number count period buf lexbuf }
  | eof { state:=CODE; Parser.EOF }
and read_newline=
  parse
  | newline { incr_linenum lexbuf; Parser.BLANKLINE }
  | "" { state:=CODE; read lexbuf }
  | eof { Parser.EOF }
and read_comment=
  parse
  | ')' { state:=CODE; read lexbuf }
  | newline { incr_linenum lexbuf; read_comment lexbuf }
  | [^')'] { read_comment lexbuf }
  | eof { raise (SyntaxError ("Comment not terminated")) }
and read_pstring buf=
  parse
  | '\n'|"\r\n" { state:=CODE; Parser.STRING (Buffer.contents buf) }
  | [^ '\n' '\r']+ { Buffer.add_string buf (lexeme lexbuf); read_pstring buf lexbuf }
  | eof { raise (SyntaxError ("Poetic String is not terminated")) }
and read_string buf=
  parse
  | '"' { state:=CODE; Parser.STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+ { Buffer.add_string buf (Lexing.lexeme lexbuf); read_string buf lexbuf }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("String is not terminated")) }

{
  let lex lexbuf=
    match !state with
    | CODE -> read lexbuf
    | IS -> read_is lexbuf
    | NEWLINE -> read_newline lexbuf
    (* will not hit? *)
    | COMMENT -> read_comment lexbuf
    | PNUMBER -> read_number 0 false (Buffer.create 16) lexbuf
    | PSTRING -> read_pstring (Buffer.create 16) lexbuf
    | STR -> read_string (Buffer.create 16) lexbuf
}