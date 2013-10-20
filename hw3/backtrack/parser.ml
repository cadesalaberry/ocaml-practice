module  Parser : PARSER = 
struct

(* In this exercise, you implement a  parser for a
 simple context free grammar using exceptions. The grammar parses arithmetic
 expressions with +,*, and ()'s.  The n represents an integer and is a
 terminal symbol. Top-level start symbol for this grammar is E.  

E -> S;
S -> P + S | P   % P = plus sub-expressions
P -> A * P | A   % A = arithmetic expression, 
A -> n | (S)


Expressions wil be lexed into a list of tokens of type Token shown
 below. The parser's job is to translate this list into an abstract
 syntax tree, given by type Exp also shown below. 

*)

module L = Lexer

type exp = Sum of exp * exp | Prod of exp * exp | Int of int

(* Success exceptions *)
(* SumExpr (S, toklist') : 
    Indicates that we successfully parsed a list of tokens called toklist
   into an S-Expression S and a remaining list of tokens called toklist'
   toklist' is what remains from toklist after we peeled of all the tokens
   necessary to build the S-Expression S.
 *)

exception SumExpr of exp * L.token list

(* ProdExpr (S, toklist') : 
    Indicates that we successfully parsed a list of tokens called toklist
   into an P-Expression P and a remaining list of tokens called toklist'
   toklist' is what remains from toklist after we peeled of all the tokens
   necessary to build the P-Expression P.
 *)

exception ProdExpr of exp * L.token list
(* AtomicExpr (A, toklist') : 
    Indicates that we successfully parsed a list of tokens called toklist
   into an A-Expression A and a remaining list of tokens called toklist'
   toklist' is what remains from toklist after we peeled of all the tokens
   necessary to build the A-Expression A.
 *)

exception AtomicExpr of exp * L.token list

(* Indicating failure to parse a given list of tokens *)

 exception Error of string

(* Example: 
   parse [INT(9),PLUS,INT(8),TIMES,INT(7),SEMICOLON]
   ===> Sum(Int 9, Prod (Int 8, Int 7))
*)

 exception NotImplemented 

 let rec parseExp toklist = match toklist with
   | [] -> raise (Error "Expected Expression: Nothing to parse")
   | tlist ->  
    try parseSumExp tlist with 
      | NotImplemented -> raise NotImplemented
      | SumExpr (exp, [L.SEMICOLON]) -> exp
      | Error msg -> raise (Error msg)
      | _ -> raise (Error "Error: Expected Semicolon")

 and parseSumExp toklist = raise NotImplemented

 and parseProdExp toklist = raise NotImplemented
	      
 and parseAtom toklist = raise NotImplemented 

 let parse string  = parseExp (L.lex string)

end


