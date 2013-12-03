(* separate : string -> ('a -> string) -> 'a list -> string
 *
 * Example: separate ";" Int.toString [3,4,5]  =  "3;4;5"
 *)
let rec separate separator f l = match l with
  | []       -> ""
  | [x]      -> f(x)
  | (x1::xs) -> f(x1) ^ separator ^ separate separator f xs
    
exception NoValue

let valOf opt = match opt with
  | Some e -> e
  | None   -> raise NoValue
