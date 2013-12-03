(* TEST FILE FOR unification *)

(* Equality testing on types                                         *)
(* equal(t,s) = bool
   
   checks whether type t and s are equal 
  
   equal:tp * tp -> true 
*)
structure T = Type

fun equal(T.Int, T.Int) = true
  | equal(T.Bool, T.Bool) = true
  | equal(T.Arrow (t1, t2), T.Arrow(s1, s2)) = (equal (t1, s1)) andalso equal (t2, s2)
  | equal(T.Product ts, T.Product ss) =
    ListPair.foldr (fn (t, s, b) => equal(t,s) andalso b) true (ts, ss)
  | equal(T.TVar (a as ref(SOME(t))), s) = equal(t, s)
  | equal(t, T.TVar(a as ref(SOME(s)))) = 
     equal(t, s)
  | equal(T.TVar(a as ref(NONE)), T.TVar(b as ref(NONE))) = 
     a = b
  | equal(t, s) = false


(* -------------------------------------------------------------------------*)
(* Some test cases *)
(* -------------------------------------------------------------------------*)
(* Define some type variables *)
val a1 : (T.tp option) ref = ref(NONE);
val a2 : (T.tp option) ref = ref(NONE);

val a3 : (T.tp option) ref = ref(NONE);
val a4 : (T.tp option) ref = ref(NONE);

val a5 : (T.tp option) ref = ref(NONE);
val a6 : (T.tp option) ref = ref(NONE);

val a7 : (T.tp option) ref = ref(NONE);
val a8 : (T.tp option) ref = ref(NONE);

(* Define some types *)
val t1 = T.Arrow(T.Product[T.TVar(a1), T.TVar(a1)], T.TVar(a2));
val t2 = T.Arrow(T.Product[T.Int, T.Int], T.TVar(a1));

val t3 = T.Arrow(T.Product[T.TVar(a3), T.TVar(a4)], T.TVar(a4));
val t4 = T.Arrow(T.Product[T.TVar(a4), T.TVar(a3)], T.TVar(a3));

val t5 = T.Arrow(T.Product[T.TVar(a5), T.TVar(a6)], T.TVar(a6));
val t6 = T.Arrow(T.TVar(a6), T.TVar(a5));

Control.Print.printDepth := 100;

structure Tp = Typing;

(* Tests *)
(*
val it = () : unit
- Tp.unify(t1, t2);
val it = () : unit
- Print.typToString t1;
val it = "((int ) * (int )) -> (int )" : string
- Print.typToString t2;
val it = "((int ) * (int )) -> (int )" : string
- equal (t1,t2);
val it = true : bool
- unify(t3, t4);
stdIn:12.1-12.6 Error: unbound variable or constructor: unify
- Tp.unify(t3, t4);
val it = () : unit
- Print.typToString t3;
val it = "((a1) * (a1)) -> (a1)" : string
- Print.typToString t4;
val it = "((a1) * (a1)) -> (a1)" : string
- equal (t3,t4);
val it = true : bool
- equal (t5,t6);
val it = false : bool
- Tp.unify (t5,t6);

uncaught exception Error
  raised at: ...
-  

*)
