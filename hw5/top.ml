let loop_type () = Loop.loop "type" (Loop.check Loop.show)

let loop_eval () = Loop.loop "eval" (Loop.eval Loop.show)

let loop_eval_smallstep () = Loop.loop "smallstep" (Loop.smallstep Loop.show)

let loop_print () = Loop.loop "print" Loop.show

let loop_ast () = Loop.loop "ast" Loop.ast

let loop_freevars () = Loop.loop "freevars" Loop.freevars

let loop_unusedvars () = Loop.loop "unusedvars" Loop.unusedvars

let loop () = Loop.loop "" (Loop.usual Loop.show)

let file_print f = Loop.loopFile f Loop.show

let file_ast f = Loop.loopFile f Loop.ast

let file_freevars f = Loop.loopFile f Loop.freevars

let file_unusedvars f = Loop.loopFile f Loop.unusedvars

let file_type f = Loop.loopFile f (Loop.check Loop.show)

let file_eval f = Loop.loopFile f (Loop.eval Loop.show)

let file_eval_smallstep f = Loop.loopFile f (Loop.smallstep Loop.show)
    
let file f = Loop.loopFile f (Loop.usual Loop.show)

exception Error
open Lexing

let parse s = 
  let n = ref 0 in
  let f = fun () -> if !n = 0 then Lexer.lex n else Lexer.comment n in
  let lbuf = Lexing.from_string s in
  try
    Parser.parse (f ()) lbuf
  with
  | Lexer.Error msg ->
    let _ = Printf.eprintf "%s%!" msg in
    raise Error
  | Parser.Error -> 
    let pos = Lexing.lexeme_start_p lbuf in
    let _ = Printf.eprintf "At line %d and column %d: syntax error === %s.\n%!"
      pos.pos_lnum (pos.pos_cnum - pos.pos_bol) (Lexing.lexeme lbuf) in
    raise Error
