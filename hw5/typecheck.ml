open Type
module M = Minml
open Unify
  
type context = Ctx of (M.name * tp) list

let empty = Ctx []

exception Unimplemented

exception NotFound
let rec assoc x y = match y with
  | [] -> raise NotFound
  | (y, r)::rest -> if x = y then r else assoc x rest

let rec lookup ctx x = let Ctx list = ctx in assoc x list
let extend ctx (x, v) = let Ctx list = ctx in Ctx ((x,v)::list)

let rec extend_list ctx l = match l with
  | [] -> ctx
  | (x,y) :: pairs -> extend_list (extend ctx (x, y)) pairs

exception TypeError of string

let fail message = raise (TypeError message)

let primopType p = match p with
  | M.Equals   -> Arrow(Product[Int; Int], Bool)
  | M.LessThan -> Arrow(Product[Int; Int], Bool)
  | M.Plus     -> Arrow(Product[Int; Int], Int)
  | M.Minus    -> Arrow(Product[Int; Int], Int)
  | M.Times    -> Arrow(Product[Int; Int], Int)
  | M.Negate   -> Arrow(Int, Int)

(* Question 3. *)

(* infer : context -> M.exp -> tp  *)
let rec infer ctx exp = raise Unimplemented


