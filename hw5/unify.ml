

(* unify: typ * typ -> unit 

   unify(T1, T2) = () 
   
   succeeds if T1 and T2 are unifiable, fails otherwise.

   Side Effect: Type variables in T1 and T2 will have been
    updated, s.t. if T1 and T2 are unifiable AFTER unification
    they will denote the "same" type.
*)

open Type
module M = Minml

exception Error of string
exception Unimplemented

let freshVar () = TVar (ref None)

let rec occurs s t = match s, t with
  | _, Int -> false
  | _, Bool -> false
  | _, Arrow (t1, t2) ->
      (occurs s t1) || (occurs s t2)
  | _, Product ts ->
      List.exists (occurs s) ts
  | _, TVar r ->
   match !r with
    | None -> (s == r)
    | Some t' -> (s == r) || (occurs s t')

(* Question 4. *)
let rec unify s t = raise Unimplemented

let unifiable (t, t') = 
  try
    let _ = unify t t' in true
  with Error s -> false
