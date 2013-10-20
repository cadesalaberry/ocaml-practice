module type LEXER = 
sig
  type token = SEMICOLON | PLUS | TIMES | LPAREN | RPAREN | INT of int

  exception Error of string

  val lex : string -> token list
end;;

module Lexer : LEXER = 
struct

  type token = SEMICOLON | PLUS | TIMES | LPAREN | RPAREN | INT of int

  exception Error of string

  let rec tabulate f n = 
    let rec tab n acc = 
      if n = 0 then (f 0)::acc
      else tab (n-1) ((f n)::acc)
    in
      tab n []

  (* string_explode : string -> char list *)
  let string_explode s = 
    tabulate (fun n -> String.get s n) ((String.length s) - 1)

  (* string_implode : char list -> string *)
  let string_implode l = 
    List.fold_right (fun c s -> Char.escaped c ^ s) l ""
  
  let is_whitespace c = match c with 
    | ' ' -> true 
    | _ -> false

  let rec lexChars l = match l with
    | [] -> []
    | ';' :: l -> SEMICOLON :: lexChars l
    | '+' :: l -> PLUS :: lexChars l
    | '*' :: l -> TIMES :: lexChars l
    | '(' :: l -> LPAREN :: lexChars l
    | ')' :: l -> RPAREN :: lexChars l
    | d :: l ->  
    if is_whitespace d then lexChars l 
    else 
      let (n, l') = lexDigit (d :: l) in INT(n)::lexChars l' 

  and lexDigit l = 
    let rec split l = match l with    
      | [] -> ([], []) 
      | '+' :: _ -> ([], l)
      | '*' :: _ -> ([], l)
      | ';' :: _ -> ([], l)
      | ')' :: _ -> ([], l)
      | '(' :: _ -> ([], l)
      | d :: rest ->  
	  if is_whitespace d then 
	    ([], l)
	  else 
	    let (digit, rest') = split rest in (d :: digit , rest')
    in 
    let (digit_list, rest) = split l  in 
      try 
	let n = int_of_string (string_implode digit_list) 
	in (n, rest)
      with 
	| _ ->  raise (Error (string_implode digit_list))

     
  let lex s = lexChars (string_explode s)

end

