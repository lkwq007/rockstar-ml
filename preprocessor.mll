{
  (** deal with the single quotes *)
  open Lexing
  type processor=
  | EOF of int
  | CODE of string
  let blocks=ref 0
}

let whitespace=[' ' '\t']+

rule process=
  parse
  | "'s" whitespace { CODE " is " }
  | "'" { process lexbuf }
  | "If"|"Else"|"While"|"Until"|"takes" { blocks:=!blocks+1; CODE (lexeme lexbuf)}
  | _ { CODE (lexeme lexbuf) }
  | eof { print_int !blocks; EOF !blocks }

{
  let rec preprocess lexbuf buffer=
      match process lexbuf with
    | CODE x -> Buffer.add_string buffer x; preprocess lexbuf buffer
    | EOF n -> for i=0 to n do Buffer.add_string buffer '\n' done; Buffer.contents buffer
}