module Change = 
struct

exception TODO

let rec change coins amt sc fc = raise TODO

(* if you write the function change directly, you do not
   need to implement change'. It is only if you want to
   develop the program incrementally, first only dealing with 
   the success continuation and leaving the backtracking to
   the exception handler *)

exception NoChange
let rec change' coins amt sc  = raise TODO

let listToString l = match l with 
  | [] -> ""
  | l -> 
    let rec toString l = match l with 
      | [h]  -> string_of_int h
      | h::t -> string_of_int h ^ ", " ^ toString t
    in
      toString l

let give_change coins amt =
  begin try 
    let c = change coins amt (fun r -> r) (fun () -> raise NoChange) in
      print_string ("Return coins: " ^ listToString c ^ "\n")
    with NoChange -> print_string ("Sorry, I cannot give change\n")
  end 


end;;
