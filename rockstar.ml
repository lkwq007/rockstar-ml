open Lexing
open Syntax
open Eval
open Printf

exception SyntaxError of string

let from_stdin=ref false
let show_ast=ref false
let anno_arg=ref false

let print_position outx lexbuf=
  let pos=lexbuf.lex_curr_p in
  fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parse_with_error lexbuf =
  try Parser.prog Lexer.lex lexbuf with
  | SyntaxError msg ->
    fprintf stderr "%a: %s\n" print_position lexbuf msg;
    exit (-1)
  | Parser.Error ->
    fprintf stderr "%a: syntax error\n" print_position lexbuf;
    exit (-1)
let eval_with_error prog=
  try eval prog with
  | SemanticError msg-> 
    fprintf stderr "semantic error: %s\n" msg;
    exit (-1)

let process_file filename=
  let ()=anno_arg:=true in
  if !from_stdin then () else begin
    let in_c=open_in filename
    in let lexbuf_=(Lexing.from_channel in_c) 
    in let lexbuf=(Lexing.from_string (Preprocessor.preprocess lexbuf_ (Buffer.create 1024)))
    in let ()=close_in in_c
    in let ()=lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename }
    in if !show_ast then print (parse_with_error lexbuf) else 
      eval_with_error (parse_with_error lexbuf)
  end
let main =
  begin
    let speclist = [("-stdin", Arg.Set from_stdin, "Read script from standard input");
                    ("-ast", Arg.Set show_ast, "Print the ast rather than eval the script");
                   ]
    in let usage_msg = "rockstar-ml is a Rockstar interrupter implemented in OCaml"
    in Arg.parse speclist process_file usage_msg;
    let lexbuf_=(Lexing.from_channel stdin)
    in let lexbuf=(Lexing.from_string (Preprocessor.preprocess lexbuf_ (Buffer.create 1024)))
    in let ()=lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = "stdin" }
    in if !from_stdin then begin if !show_ast then print (parse_with_error lexbuf) else eval_with_error (parse_with_error lexbuf) end
    else if not !anno_arg then Arg.usage speclist usage_msg
  end

let () = main