module M = Minml

type name = M.name

type env = Env of (name * obj') list
and obj' = Exp' of M.exp
         | Closure' of M.exp * (env option ref)

type obj =
| Exp of M.exp
| Closure of M.exp * env

let empty = Env []

let lift f env = f (Lib.valOf (!env))

let rec str trail e =
  let Env list = e in
  let f = fun (x, obj) -> 
    "\"" ^ x ^ "\" |-> " ^
      (match obj with
      | Exp' exp -> Print.expToString exp
      | Closure' (exp, env) ->
        (if List.exists (fun r -> r = env) trail then 
            "*"
         else 
            "(" ^ Print.expToString exp ^ " | " ^ lift (str (env::trail)) env ^ ")"))
  in
  Lib.separate ", " f list

let toString env = str [] env

exception NotFound

let rec assoc orig x l = match l with
  | [] -> print_endline ("Env.assoc: \"" ^ x ^ "\" not found in " ^ toString (Env orig)); 
           raise NotFound
  | ((y, r)::rest) -> if x = y then r else assoc orig x rest

let lookup e x = 
  let Env list = e in
  let obj = assoc list x list in
  match obj with
  | Exp' exp -> Exp exp
  | Closure' (exp, envref) -> Closure (exp, Lib.valOf (!envref))

let extend e s = 
  let Env list = e in
  let (x, obj) = s in
  let obj' = match obj with
    | Exp exp -> Exp' exp
    | Closure (exp, env) -> Closure' (exp, ref (Some env))
  in
  Env ((x, obj')::list)

let extend_rec e s =
  let Env list = e in
  let (x, Closure(exp, env)) = s in
  let hole = ref None in
  let env = Env((x, Closure'(exp, hole)) :: list) in
  let _ = hole := Some env in
  env

let rec extend_list env l = match l with
  | [] -> env
  | ((x, v) :: rest) -> extend_list (extend env (x, v)) rest
