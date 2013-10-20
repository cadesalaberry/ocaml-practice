module type FIBO =
sig
  (* on input n, computes the nth Fibonacci number *)
  val fib : int -> Big_int.big_int
end

module Fibo : FIBO = 
struct
  let rec fib n = match n with
    | 0 -> Big_int.big_int_of_int 0  
    | 1 -> Big_int.big_int_of_int 1 
    | _ -> Big_int.add_big_int (fib(n-2)) (fib(n-1))
end
