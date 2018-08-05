open Lexing
open Syntax
open Eval
open Printf

exception SyntaxError of string

let from_stdin=ref false
let show_ast=ref false
let file_list=ref []

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

let append_file filename=
  file_list:=filename::(!file_list)

let process_file filename=
  if !from_stdin then () else begin
    let in_c=open_in filename
    in let lexbuf_=(Lexing.from_channel in_c) 
    in let lexbuf=(Lexing.from_string (Preprocessor.preprocess lexbuf_ (Buffer.create 1024)))
    in let ()=close_in in_c
    in let ()=lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename }
    in if !show_ast then print (parse_with_error lexbuf) else 
      eval_with_error (parse_with_error lexbuf)
  end

let rec loop_file=function
  | [] -> ()
  | hd::tl -> process_file hd; loop_file tl

let main =
  begin
    let speclist = [("-stdin", Arg.Set from_stdin, "Read script from standard input");
                    ("-ast", Arg.Set show_ast, "Print the ast rather than eval the script");
                   ]
    in let usage_msg = "rockstar-ml is a Rockstar interpreter implemented in OCaml"
    in Arg.parse speclist append_file usage_msg;
    if !from_stdin then 
    begin 
    let lexbuf_=(Lexing.from_channel stdin)
    in let lexbuf=(Lexing.from_string (Preprocessor.preprocess lexbuf_ (Buffer.create 1024)))
    in let ()=lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = "stdin" }
    in if !show_ast then print (parse_with_error lexbuf) else eval_with_error (parse_with_error lexbuf) 
    end
    else 
    begin if !file_list=[] then Arg.usage speclist usage_msg else loop_file (List.rev !file_list) end
  end

let () = main