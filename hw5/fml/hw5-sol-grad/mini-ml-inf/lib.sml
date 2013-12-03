structure Lib = struct

  (* separate : string -> ('a -> string) -> 'a list -> string
   *
   * Example: separate ";" Int.toString [3,4,5]  =  "3;4;5"
   *)
  fun separate separator f [] = ""
    | separate separator f [x] = f(x)
    | separate separator f (x1::xs) = f(x1) ^ separator ^ separate separator f xs

end
