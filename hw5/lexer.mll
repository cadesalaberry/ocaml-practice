{
open Parser
exception Error of string
}

let empty = [' ' '\t' '\r']
let newline = ['\n']
let num = ['1'-'9']['0'-'9']*
let id = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule lex n = parse
| empty {lex n lexbuf}
| newline {Lexing.new_line lexbuf; lex n lexbuf}
| ','  {COMMA}
| '('  {LPAREN}
| ')'  {RPAREN}
| ';'  {SEMICOLON}
| "=>" {DARROW}
| '='  {EQUAL}
| '<'  {LESSTHAN}
| '*'  {TIMES}
| '~'  {NEGATE}
| "->" {ARROW}
| '-'  {MINUS}
| '+'  {PLUS}
| ':'  {COLON}

| "(*" {n := 1; comment n lexbuf}

| "bool"  {BOOL}
| "int"   {INT}
| "false" {FALSE}
| "true"  {TRUE}
| "fn"    {FN}
| "fun"   {FUN}
| "if"    {IF}
| "then"  {THEN}
| "else"  {ELSE}
| "let"   {LET}
| "in"    {IN}
| "end"   {END}
| "name"  {NAME}
| "val"   {VAL}

| '0'      {NUM 0}
| num as n {NUM (int_of_string n)}
| id as i  {VAR i}
| eof {EOF}

and comment n = parse
| newline {Lexing.new_line lexbuf; comment n lexbuf}
| "*)" {if !n > 1 then 
          (n := (!n-1); comment n lexbuf)
        else
          (n := 0; lex n lexbuf)}
| "(*" {n := (!n + 1); comment n lexbuf}
| _    {comment n lexbuf}
