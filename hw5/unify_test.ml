(* TEST FILE FOR unification *)

(* Equality testing on types                                         *)
(* equal(t,s) = bool
   
   checks whether type t and s are equal 
  
   equal:tp * tp -> true 
*)

(* To use this file to test your unify function, you can
 * simply do
   #use "unify_test.ml";;
 * when running the toplevel of MiniML *)

module T = Type

let rec equal s t = match s, t with
  | T.Int, T.Int -> true
  | T.Bool, T.Bool -> true
  | T.Arrow (t1, t2), T.Arrow(s1, s2) ->
     (equal t1 s1) && (equal t2 s2)
  | T.Product ss, T.Product ts ->
      List.for_all (fun (s, t) -> equal s t) (List.combine ss ts)
  | T.TVar {contents = Some s'}, _ ->
     equal s' t
  |  _, T.TVar {contents = Some t'} ->
     equal s t'
  | T.TVar x, T.TVar y ->
     x == y
  | _,_ -> false


(* -------------------------------------------------------------------------*)
(* Some test cases *)
(* -------------------------------------------------------------------------*)
(* Define some type variables *)
let a1 : (T.tp option) ref = ref(None);;
let a2 : (T.tp option) ref = ref(None);;

let a3 : (T.tp option) ref = ref(None);;
let a4 : (T.tp option) ref = ref(None);;

let a5 : (T.tp option) ref = ref(None);;
let a6 : (T.tp option) ref = ref(None);;

let a7 : (T.tp option) ref = ref(None);;
let a8 : (T.tp option) ref = ref(None);;

(* Define some types *)
let t1 = T.Arrow(T.Product [T.TVar(a1); T.TVar(a1)], T.TVar(a2));;
let t2 = T.Arrow(T.Product [T.Int; T.Int], T.TVar(a1));;

let t3 = T.Arrow(T.Product [T.TVar(a3); T.TVar(a4)], T.TVar(a4));;
let t4 = T.Arrow(T.Product [T.TVar(a4); T.TVar(a3)], T.TVar(a3));;

let t5 = T.Arrow(T.Product [T.TVar(a5); T.TVar(a6)], T.TVar(a6));;
let t6 = T.Arrow(T.TVar(a6), T.TVar(a5));;

module Tp = Unify

(* Tests *)
;;
Tp.unify t1 t2;;
(* val it = () : unit *)
T.toString t1;;
(* val it = "((int ) * (int )) -> (int )" : string *)
T.toString t2;;
(* val it = "((int ) * (int )) -> (int )" : string *)
equal t1 t2;;
(* val it = true : bool *)
Tp.unify t3 t4;;
(* val it = () : unit *)
T.toString t3;;
(* val it = "((a1) * (a1)) -> (a1)" : string *)
T.toString t4;;
(* val it = "((a1) * (a1)) -> (a1)" : string *)
equal t3 t4;;
(* val it = true : bool *)
equal t5 t6;;
(* val it = false : bool *)
Tp.unify t5 t6;;
(* uncaught exception Error
  raised at: ...
 *)


