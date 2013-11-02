(*
   Purpose: dble the number n
            assumes n >= 0

   Examples:
   dble 0 ==> 0
   dble 3 ==> 6

 
*)

let dble n = match n with
  | 0 -> 0
  | _ -> 2 * n


(*
   Purpose: compute n! = n * (n-1) * (n-2) * ... * 1
            assumes n >= 0

   Examples:
   fact 0 ==> 1
   fact 5 ==> 120

   fact : int -> int
*)

let rec fact (n : int)  = match n with 
  |  0 -> 1
  |  _ -> n * (fact (n - 1))


