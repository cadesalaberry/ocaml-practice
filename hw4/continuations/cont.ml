module TailRec  = 
struct
  exception TODO

  let rec aux_filter f l cont = raise TODO 
    
  let rec filter f l = aux_filter f l (fun r -> r)

(*
foldr : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
foldr f [a1; ...; an] b is f a1 (f a2 (... (f an b) ...)). 
*)

  let rec aux_foldr f l b cont = raise TODO 

  let foldr f l b = aux_foldr f l b (fun r -> r)

end;;
