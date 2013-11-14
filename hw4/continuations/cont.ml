module TailRec  = 
struct
  exception TODO

  let rec aux_filter f l cont = (*raise TODO *)
    match l with
    | []		-> cont []
    | h::tail	->
      match f(h) with
        | true  -> aux_filter f tail (fun x -> cont (h::x))
        | false -> aux_filter f tail cont


  let rec filter f l = aux_filter f l (fun r -> r)

(*
foldr : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
foldr f [a1; ...; an] b is f a1 (f a2 (... (f an b) ...)). 
*)

  let rec aux_foldr f l b cont = (*raise TODO*)
    match l with
    | []		-> cont b
    | h::tail	-> (aux_foldr f tail b (fun x -> cont (f h x)))

  let foldr f l b = aux_foldr f l b (fun r -> r)

end;;

print_string "Hello\n"


  let print_list l =
    print_string (String.concat " " (List.map string_of_int l));
    print_string "\n";;

let a = [1;2;3;4;5;6;7;8;9];;
let f x = x > 3;;
let b = TailRec.filter f a;;
print_list a;;
print_list b;;

let g x y = x + y;;
let r = TailRec.foldr g b 0;;
print_int r;;
print_string "\n";;
  