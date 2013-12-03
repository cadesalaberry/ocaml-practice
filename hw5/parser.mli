exception Error

type token = 
  | VAR of (string)
  | VAL
  | TRUE
  | TIMES
  | THEN
  | SEMICOLON
  | RPAREN
  | PLUS
  | NUM of (int)
  | NEGATE
  | NAME
  | MINUS
  | LPAREN
  | LET
  | LESSTHAN
  | INT
  | IN
  | IF
  | FUN
  | FN
  | FALSE
  | EQUAL
  | EOF
  | END
  | ELSE
  | DARROW
  | COMMA
  | COLON
  | BOOL
  | ARROW


val parse_exps: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Minml.exp list)
val parse: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Minml.exp)