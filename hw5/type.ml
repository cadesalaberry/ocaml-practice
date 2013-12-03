type tp =
| Arrow of tp * tp
| Product of tp list
| Int
| Bool
| TVar of (tp option) ref (* Only used for unification and bonus *)

open Lib

let rec eq t = match t with 
  | (Arrow(domain1, range1), Arrow(domain2, range2)) ->
    eq(domain1, domain2) && eq(range1, range2)
  | (Product ts1, Product ts2) ->
    List.length ts1 = List.length ts2 && List.for_all eq (List.combine ts1 ts2)
  | (Int, Int) -> true
  | (Bool, Bool) -> true
  | (_, _) -> false

let rec paren lvl oplvl string =
  if oplvl < lvl then "(" ^ string ^ ")" else string

let counter = ref 0

let freshVar () =
  let _ = counter := !counter + 1 in
  "a" ^ (string_of_int !counter)
    
let resetCtr () =
  counter := 0

let rec member l r = match l with
  | [] -> None
  | (a, r') :: l' -> if r = r' then Some a else member l' r

let rec s lvl l tp = match tp with
  | Arrow(domain, range) -> 
    let (l', t) = s 1 l domain in
    let (l'', t') = s 0 l' range in
    (l'', paren lvl 0 (t ^ " -> " ^ t'))
  | Product [] ->  (l, "()")
  | Product [x] -> s lvl l x
  | Product (t::ts) -> 
    let f = fun (l, t) p -> 
      let (l', t') = s 2 l p in 
       (l', t ^ " * " ^ t')
    in
    let (l', t') = List.fold_left f (s 2 l t) ts in
    (l', paren lvl 1 t')
  | Int -> (l, "int")
  | Bool -> (l, "bool")
  | TVar x -> match !x with
    | None -> (match member l x with
      | None -> let a = freshVar () in ((a,x)::l, a)
      | Some a -> (l, a))
    | Some t -> s 1 l t
    
let rec toString tp = 
  let (_, t) = s 0 [] tp in 
  let _ = resetCtr () in
  t
