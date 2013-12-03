(* Type checking MinML *)
(* Operates on MinML expressions 
(where variables are encoded as strings) *)

signature TYPING =
sig

  exception Error of string

  (* typeOf (e) = t for the t such that |- e : t *)
  (* raises Error if no such t exists *)
  val typeOf : MinML.exp -> Type.tp

 
  (* unify (T1, T2) = () if there exists some substitution s
     for the free type variables in T1 and T2 s.t.
     [s]T1 = [s]T2 
   *)
  val unify : Type.tp * Type.tp -> unit

end;  (* signature TYPING *)

structure Typing :> TYPING =
struct
  open Type
  open MinML

  exception Error of string


(* ------------------------------------------------------------ *)
(* QUESTION 2 : Unification [35 points]                         *) 
(* -------------------------------------------------------------*)

(* unify: tp * tp -> unit 

   unify(T1, T2) = () 
   
   succeeds if T1 and T2 are unifiable, fails otherwise.

   Side Effect: Type variables in T1 and T2 will have been
    updated, s.t. if T1 and T2 are unifiable AFTER unification
    they will denote the "same" type.

*)
fun occurs (_, Type.Int) = false
  | occurs (_, Type.Bool) = false
  | occurs (s, (Arrow (t1, t2))) =
      occurs (s, t1) orelse occurs (s, t2)
  | occurs (s, Product ts) =
      List.exists (fn t => occurs (s, t)) ts
  | occurs (s, t as TVar (ref NONE)) = (s = t)
  | occurs (s, t as TVar (ref (SOME t'))) =
      (s = t) orelse occurs (s, t')

fun unify (Type.Int, Type.Int) = ()
  | unify (Type.Bool, Type.Bool) = ()
  | unify (Arrow (s1, s2), Arrow (t1, t2)) =
      (unify (s1, t1); unify (s2, t2))
  | unify (Product ss, Product ts) =
      ListPair.app (fn (s,t) => unify (s,t)) (ss,ts)
  | unify (t, s as TVar (ref (SOME s'))) =
      unify (s', t)
  | unify (s as TVar (ref (SOME s')), t) =
      unify (s', t)
  | unify (s as TVar (s' as ref NONE), t as TVar (ref NONE)) =
      if s = t then () else s' := SOME t
  | unify (s as TVar (s' as ref NONE), t) =
      if occurs (s, t) then
        raise Error "Cannot unify"
      else
        s' := SOME t
  | unify (t, s as TVar (s' as ref NONE)) =
      if occurs (s, t) then
        raise Error "Cannot unify"
      else
        s' := SOME t
  | unify _ = raise Error "Cannot unify";


fun unifiable (t, t') = 
  (unify (t, t') ; true) handle Error s => false

(* Use Print.typToString: T.tp -> string to print types *)

(* ------------------------------------------------------------ *)
(* QUESTION 3 : Type Inference (EXTRA CREDIT) [20 points]       *) 
(* -------------------------------------------------------------*)
(* typeOf: MinML.exp  -> T.tp
 
   Implement a function typeOf which infers the most general type 
   for an expression. 

   raises exception Error if the input expression e has
   no type.

   Implement typeOf, using the auxiliary function 

  typeOf' (G,e) = T   s.t. G |- e:T 

  typeOf' infers the type T for expression e in the typing context G 
  If e has no type, it will raise the exception Error.

  typeOf : (string * typ) Ctx * MinML.exp -> T.typ


  Adapt your implementation for inferring a type given an annotated
  expression, to allow for full type inference. 

*)

  (* Contexts *)
  datatype 'a Ctx =			(* Contexts                   *)
    Null				(* G ::= .                    *)
  | Decl of 'a Ctx * 'a			(*     | G, D                 *)


(* The context x:int, y:bool is then represented as

   Decl(Decl(Null,("y", BOOL)), ("x", INT))
*)


  fun freshVAR () = ref NONE

  fun typeOf (e) = raise Error "Not Implemented YET! "


end;  (* structure Typing *)
