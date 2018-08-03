(** abstract syntax for Rockstat *)

(** basic types *)
type dec64=float

(** boolean expression *)
type boolean=
  | True
  | False

(** var types *)
type value=
  | Undefined (** Mysterious *)
  | Null (** Null *)
  | Boolean of boolean (** Boolean *)
  | Number of float (** Number *)
  | String of string (** String *)
  | Object of (string*value) list (** Object *)

(** expression *)
type expression=
  | Variable of string
  | Value of value
  | Plus of expression * expression
  | Minus of expression * expression
  | Times of expression * expression
  | Divide of expression * expression
  | Call of string*(expression list)

(** statement *)
type statement=
  | Nop
  | Expression of expression
  | Definition of string*value
  | Assign of string*expression
  | Scan of string
  | Print of expression
  | Break
  | Continue
  | Return of expression
  | Inc of string
  | Dec of string

type condition=
  | Eq of expression*expression
  | Ne of expression*expression
  | Gt of expression*expression
  | Ge of expression*expression
  | Lt of expression*expression
  | Le of expression*expression

type block=
  | If of condition*(block list)*(block list)
  | While of condition*(block list)
  | Until of condition*(block list)
  | Stm of (statement list)

type segment=
  | Func of string*(string list)*(block list)
  | Block of (block list)

let print seg_list=
  let rec print_args=function
    | [] -> ()
    | hd::tl -> print_string (hd^" "); print_args tl
  in let string_of_val=function
    | Undefined -> "Undefined"
    | Null -> "Null"
    | Boolean bool -> if bool=True then "True" else "False"
    | Number f -> string_of_float f
    | String x -> "\""^x^"\""
    | _ -> "<object>"
  in let rec print_param=function
    | [] -> ()
    | hd::tl -> print_exp hd; print_string ","; print_param tl
  and print_exp=function
    | Variable x -> print_string ("(Var: "^x^")")
    | Value x -> print_string ("(Val: "^(string_of_val x)^")")
    | Plus (e1,e2) -> print_string "("; print_exp e1; print_string "+"; print_exp e2; print_string ")"
    | Minus (e1,e2) -> print_string "("; print_exp e1; print_string "-"; print_exp e2; print_string ")"
    | Times (e1,e2) -> print_string "("; print_exp e1; print_string "*"; print_exp e2; print_string ")"
    | Divide (e1,e2) -> print_string "("; print_exp e1; print_string "/"; print_exp e2; print_string ")"
    | Call (f,param) -> print_string ("(Call "^f^":[");print_param param; print_string "])"
  in let print_cond=function
    | Eq (e1,e2) -> print_string "(";print_exp e1; print_string "="; print_exp e2; print_string ")"
    | Ne (e1,e2) -> print_string "(";print_exp e1; print_string "!="; print_exp e2; print_string ")"
    | Gt (e1,e2) -> print_string "(";print_exp e1; print_string ">"; print_exp e2; print_string ")"
    | Lt (e1,e2) -> print_string "(";print_exp e1; print_string "<"; print_exp e2; print_string ")"
    | Ge (e1,e2) -> print_string "(";print_exp e1; print_string ">="; print_exp e2; print_string ")"
    | Le (e1,e2) -> print_string "(";print_exp e1; print_string "<="; print_exp e2; print_string ")"
  in let count=ref 0
  in let rec indent n=
    if n>0 then (print_char ' '; indent (n-1)) else ()
  in let print_stm=function
    | Nop -> print_string "Nop"
    | Expression e -> print_exp e
    | Definition (s,v) -> print_string ("Define: ("^s^","^(string_of_val v)^")")
    | Assign (s,e) -> print_string (s^"="); print_exp e
    | Scan s -> print_string ("Scan to: "^s)
    | Print e -> print_string "Print: "; print_exp e
    | Break -> print_string "Break"
    | Continue -> print_string "Continue"
    | Return e -> print_string "Return: "; print_exp e
    | Inc s -> print_string ("Inc: "^s)
    | Dec s -> print_string ("Dec: "^s)
  in let print_stms lst=
    let rec aux_stm=function
    | [] -> ()
    | hd::tl -> indent !count; print_stm hd; print_newline ();aux_stm tl
    in aux_stm lst
  in let rec print_block=function
    | If (cond,b1,b2) -> indent !count; print_string "IF("; print_cond cond; print_endline ")"; print_blocks b1; print_blocks b2
    | While (cond,b) -> indent !count; print_string "WHILE("; print_cond cond; print_endline ")"; print_blocks b
    | Until (cond,b) -> indent !count; print_string "UNTIL("; print_cond cond; print_endline ")"; print_blocks b
    | Stm lst -> print_stms lst
  and print_blocks b=
    let aux=function
    | [] -> ()
    | hd::tl -> print_block hd; print_blocks tl
    in print_endline "{"; count:=!count+2; aux b; count:=!count-2; print_endline "}"
  in let print_seg=function
    | Func (f,args,b) -> print_string (f^"("); print_args args; print_endline ")"; print_blocks b 
    | Block b -> print_blocks b
  in let rec aux_seg=function
    | [] -> ()
    | hd::tl -> print_seg hd; aux_seg tl
  in aux_seg seg_list