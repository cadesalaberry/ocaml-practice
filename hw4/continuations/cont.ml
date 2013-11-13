module TailRec  = 
struct
  exception TODO

  let rec aux_filter f l cont = (*raise TODO *)
    match l with
    | []		-> cont
    | h::tail	->
      match f(h) with
        | true  -> aux_filter f tail h::cont
        | false -> aux_filter f tail cont
    
  let rec filter f l = aux_filter f l (fun r -> r)

(*
foldr : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
foldr f [a1; ...; an] b is f a1 (f a2 (... (f an b) ...)). 
*)

  let rec aux_foldr f l b cont = (*raise TODO*)
    match l with
    | []		-> cont 
    | h::tail	-> f h (aux_foldr f tail cont)  

  let foldr f l b = aux_foldr f l b (fun r -> r)

end;;

print_string "Hello\n"