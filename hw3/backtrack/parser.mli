module type PARSER = 
sig

  type exp = Sum of exp * exp | Prod of exp * exp | Int of int

  exception Error of string

  val parse : string -> exp

end 
