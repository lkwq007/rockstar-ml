open Syntax

exception SemanticError of string
exception BreakLoop
exception ContinueLoop
exception ReturnFunc of value

let eval prog=
  let is_equal v1 v2=
    match (v1,v2) with
    | (Number x,Null) -> if x=0. then true else false
    | (Null,Number x) -> if x=0. then true else false
    | (Boolean False,Null) -> true
    | (Null,Boolean False) -> true
    | (x,y) -> x=y
  in
  let is_gt v1 v2=
    match (v1,v2) with
    | (Number x,Null) -> x>0.
    | (Null,Number x) -> x<0.
    | (Number x,Number y) -> x>y
    | (_,_) -> raise (SemanticError "Arthimetic op with other types")
  in
  let is_lt v1 v2=is_gt v2 v1 in
  let is_ge v1 v2=(is_gt v1 v2)&&(is_equal v1 v2) in
  let is_le v1 v2=(is_lt v1 v2)&&(is_equal v1 v2) in
  let print=function
    | Undefined -> print_string "Undefined"
    | Null -> print_string "Null"
    | Boolean x -> if x=True then print_string "True" else print_string "False"
    | Number x -> print_float x
    | String s -> print_string s
    | _ -> print_string "<object>"
  in
  let num_part value=
    match value with
    | Number x -> x
    | Null -> 0.0
    | Boolean x -> if x=True then 1.0 else 0.0
    | _ -> raise (SemanticError "Arthimetic op with other types")
  in
  let func_lst=Hashtbl.create 64 in
  let rec eval_exp env=function
    | Variable x -> begin try Hashtbl.find env x with Not_found -> (Hashtbl.add env x Undefined); Undefined end
    | Value x -> x
    | Plus (e1, e2) -> Number ((eval_exp env e1 |> num_part)+.(eval_exp env e2 |> num_part))
    | Minus (e1, e2) -> Number ((eval_exp env e1 |> num_part)-.(eval_exp env e2 |> num_part))
    | Times (e1, e2) -> Number ((eval_exp env e1 |> num_part)*.(eval_exp env e2 |> num_part))
    | Divide (e1, e2) -> Number ((eval_exp env e1 |> num_part)/.(eval_exp env e2 |> num_part))
    | Call (f,lst) -> begin let (arg,b)=try Hashtbl.find func_lst f with Not_found -> raise (SemanticError ("Function "^f^" is not defined"))
        in let rec extract_lst env=function
            | [] -> []
            | hd::tl -> (eval_exp env hd)::(extract_lst env tl)
        in let rec add_arg env arg_ lst_=match (arg_,lst_) with
            | (hd1::tl1,hd2::tl2) -> Hashtbl.add env hd1 hd2; add_arg env tl1 tl2
            | ([],[]) -> ()
            | (_,_) -> raise (SemanticError "will not hit")
        in let rec remove_arg env arg_=match arg_ with 
            | hd::tl -> Hashtbl.remove env hd; remove_arg env tl 
            | [] -> ()
        in let ()=if (List.length arg)=(List.length lst) then add_arg env arg (extract_lst env lst) else (raise (SemanticError ("Function "^f^" is called with more or less arguments")))
        in let value=try eval_block env false true b;Null with ReturnFunc x -> x
        in let ()=remove_arg env arg
        in value end  
  and eval_cond env=function
    | Eq (e1,e2) -> is_equal (eval_exp env e1) (eval_exp env e2)
    | Ne (e1,e2) -> not (is_equal (eval_exp env e1) (eval_exp env e2))
    | Gt (e1,e2) -> is_gt (eval_exp env e1) (eval_exp env e2)
    | Lt (e1,e2) -> is_lt (eval_exp env e1) (eval_exp env e2)
    | Ge (e1,e2) -> is_ge (eval_exp env e1) (eval_exp env e2)
    | Le (e1,e2) -> is_le (eval_exp env e1) (eval_exp env e2)

  and eval_stm env in_block in_func=function
    | Scan var -> begin let data=read_line () in 
        let result=try Number(float_of_string data) with (Failure float_of_string) -> String data
        in Hashtbl.replace env var result end
    | Print e -> print (eval_exp env e)
    | Return x -> if in_func then raise (ReturnFunc (eval_exp env x))
    | Nop -> ()
    | Expression e -> let _=eval_exp env e in ()
    | Definition (var,value) -> Hashtbl.replace env var value
    | Assign (var,e) -> Hashtbl.replace env var (eval_exp env e)
    | Break -> if in_block then raise BreakLoop else ()
    | Continue -> if in_block then raise ContinueLoop else ()
    | Inc x -> begin let temp=try Hashtbl.find env x with Not_found -> (Hashtbl.add env x (Undefined);Undefined)
        in Hashtbl.replace env x (Number ((num_part temp)+.1.)) end
    | Dec x->  begin let temp=try Hashtbl.find env x with Not_found -> (Hashtbl.add env x (Undefined);Undefined)
        in Hashtbl.replace env x (Number ((num_part temp)-.1.)) end

  and eval_block env in_block in_func block=
    let eval_block_ env in_block in_func=function
      | If (cond,then_b,else_b) -> if eval_cond env cond then eval_block env in_block in_func then_b else eval_block env in_block in_func else_b
      | While (cond,b) -> begin let loop=ref true in 
          while !loop&&(eval_cond env cond) do 
            try eval_block env true in_func b with 
            | BreakLoop -> loop:=false
            | ContinueLoop -> ()
          done end
      | Until (cond,b) -> begin let loop=ref true in 
          while !loop&&(not (eval_cond env cond)) do 
            try eval_block env true in_func b with 
            | BreakLoop -> loop:=false
            | ContinueLoop -> ()
          done end
      | Stm lst -> begin let rec read_stm env in_block in_func=function
          | [] -> ()
          | hd::tl -> eval_stm env in_block in_func hd; read_stm env in_block in_func tl
          in read_stm env in_block in_func lst end
    in let rec eval_blocks env in_block in_func=function
        | [] -> ()
        | hd::tl -> eval_block_ env in_block in_func hd; eval_blocks env in_block in_func tl
    in eval_blocks env in_block in_func block

  and eval_seg env=function
    | Func (f,args,b) -> Hashtbl.add func_lst f (args,b)
    | Block b -> eval_block env false false b

  in let rec aux env=function
      | [] -> ()
      | hd::tl -> eval_seg env hd; aux env tl
  in aux (Hashtbl.create 64) prog