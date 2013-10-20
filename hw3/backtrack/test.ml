module Test = 
struct

module L = Lexer;

(* Definition of test cases *)

  let tokList1 = [L.INT(9); L.PLUS; L.INT(8); L.TIMES; L.LPAREN; L.INT(4); L.PLUS;
		L.INT(7);L.RPAREN; L.SEMICOLON]
(* ==> 9 + 8 * (4 + 7)   represented as  Plus(Int(9); Times (Int(8);
		Plus(Int(4);Int(7)))) *)

  let  tl1 = L.lex "9 + 8 * (4 + 7);"
  let  tl2 = L.lex "((9 ) + 8 ) * ( 2* 4 + 7 );"

(*
Parser.parse "9 + 8 * (4 + 7);";;
- : Parser.exp =
Parser.Sum (Parser.Int 9,
 Parser.Prod (Parser.Int 8, Parser.Sum (Parser.Int 4, Parser.Int 7)))
# 
*)

end
