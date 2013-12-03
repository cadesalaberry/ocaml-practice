type action  = Minml.exp      -> unit
type actions = Minml.exp list -> unit

open Lexing

  (* A few actions *)

let print s = (print_string s; flush stdout)

let ast e = List.iter print [Print.astToString e; ";\n"]

let show e =  List.iter print [Print.expToString e; ";\n"]

let freevars e = 
  let fv = Eval.freeVariables e in 
  let s = match fv with 
    | [] -> "No free variables found"
    |  _ -> "Found " ^ (List.fold_right (fun x b -> x ^ " " ^ b) fv " " )
  in 
  List.iter print [s ; ";\n"]

let unusedvars e = 
  let fv = Eval.unusedVariables e in 
  let s = match fv with 
    | [] -> "No unused variables found"
    |  _ -> "Found " ^ (List.fold_right (fun x b -> x ^ " " ^ b) fv " " )
  in 
  List.iter print [s ; ";\n"]

let check action e = action
    (try
      let t = Typecheck.infer Typecheck.empty e in
      let _ = print_endline ("type: " ^ Type.toString t ^ "\n") in e
    with Typecheck.TypeError message ->
      (print_endline ("Type error: " ^ message ^ "*\n"); e))

let eval action e = action (Eval.eval e)

let smallstep action e = action (Eval.smallstep e)

let usual action e = action
    (try
      let t = (Typecheck.infer Typecheck.empty e) in
      let _ = print_endline ("type: " ^ Type.toString t ^ "\n") in
      Eval.eval e
    with Typecheck.TypeError message ->
      (print_endline ("Type error: " ^ message ^ "\n"); e))

let wait action e =
  let _ = action e in
  let _ = print_endline "Press return:" in
  let _ = input_line stdin in
  ()

  (* Running the actions on an interactive loop or a file *)

let loop info action =
  let n = ref 0 in
  let f = fun () -> if !n = 0 then Lexer.lex n else Lexer.comment n in
  let lbuf = Lexing.from_string (Input.promptkeybd ("MinML " ^ info ^ "> ")) in
  try
    action (Parser.parse (f ()) lbuf)
  with
  | Lexer.Error msg ->
    Printf.eprintf "%s%!" msg
  | Parser.Error -> 
    let pos = Lexing.lexeme_start_p lbuf in
    Printf.eprintf "At line %d and column %d: syntax error === %s.\n%!"
      pos.pos_lnum (pos.pos_cnum - pos.pos_bol) (Lexing.lexeme lbuf)

let loopFile file action =
let n = ref 0 in
  let f = fun () -> if !n = 0 then Lexer.lex n else Lexer.comment n in
  let inBuffer = open_in file in
  let lbuf = Lexing.from_channel inBuffer in
  try
    action (Parser.parse (f ()) lbuf)
  with
  | Lexer.Error msg ->
    Printf.eprintf "%s%!" msg
  | Parser.Error -> 
    let pos = Lexing.lexeme_start_p lbuf in
    Printf.eprintf "At line %d and column %d: syntax error === %s.\n%!"
      pos.pos_lnum (pos.pos_cnum - pos.pos_bol) (Lexing.lexeme lbuf)
