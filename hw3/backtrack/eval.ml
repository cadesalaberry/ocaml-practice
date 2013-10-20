module type EVAL = 
sig
  val eval : string -> int
end;;

module Eval: EVAL = 
struct

  module P = Parser

  let rec eval e = match e with
    | P.Sum (e1, e2) -> eval e1 + eval e2
    | P.Prod (e1, e2) -> eval e1 * eval e2
    | P.Int n -> n

  let eval e = eval (P.parse e)

end;;
