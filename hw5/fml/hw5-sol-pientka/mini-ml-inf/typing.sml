(* Type checking MinML *)
(* Operates on MinML expressions 
(where variables are encoded as strings) *)

signature TYPING =
sig

  exception Error of string

  (* typeOf (e) = t for the t such that |- e : t *)
  (* raises Error if no such t exists *)
  val typeOf : MinML.exp -> T.typ

 
  (* unify (T1, T2) = () if there exists some substitution s
     for the free type variables in T1 and T2 s.t.
     [s]T1 = [s]T2 
   *)
  val unify : T.typ * T.typ -> unit

end;  (* signature TYPING *)

structure Typing :> TYPING =
struct

  open T
  open MinML

  exception Error of string


(* ------------------------------------------------------------ *)
(* QUESTION : Unification                                       *) 
(* -------------------------------------------------------------*)

(* unify: typ * typ -> unit 

   unify(T1, T2) = () 
   
   succeeds if T1 and T2 are unifiable, fails otherwise.

   Side Effect: Type variables in T1 and T2 will have been
    updated, s.t. if T1 and T2 are unifiable AFTER unification
    they will denote the "same" type.

*)
fun occurs (_, INT) = false
  | occurs (_, BOOL) = false
  | occurs (s, (ARROW (t1, t2))) =
      occurs (s, t1) orelse occurs (s, t2)
  | occurs (s, CROSS (t1, t2)) =
      occurs (s, t1) orelse occurs (s, t2)
  | occurs (s, t as VAR (ref NONE)) = (s = t)
  | occurs (s, t as VAR (ref (SOME t'))) =
      (s = t) orelse occurs (s, t')

fun unify (INT, INT) = ()
  | unify (BOOL, BOOL) = ()
  | unify (ARROW (s1, s2), ARROW (t1, t2)) =
      (unify (s1, t1); unify (s2, t2))
  | unify (CROSS (s1, s2), CROSS (t1, t2)) =
      (unify (s1, t1); unify (s2, t2))
  | unify (t, s as VAR (ref (SOME s'))) =
      unify (s', t)
  | unify (s as VAR (ref (SOME s')), t) =
      unify (s', t)
  | unify (s as VAR (s' as ref NONE), t as VAR (ref NONE)) =
      if s = t then () else s' := SOME t
  | unify (s as VAR (s' as ref NONE), t) =
      if occurs (s, t) then
        raise Error "Cannot unify"
      else
        s' := SOME t
  | unify (t, s as VAR (s' as ref NONE)) =
      if occurs (s, t) then
        raise Error "Cannot unify"
      else
        s' := SOME t
  | unify _ = raise Error "Cannot unify";


fun unifiable (t, t') = 
  (unify (t, t') ; true) handle Error s => false

(* Use Print.typToString: T.typ -> string to print types *)

(* ------------------------------------------------------------ *)
(* QUESTION  : Type Inference (EXTRA CREDIT)                    *) 
(* -------------------------------------------------------------*)
(* typeOf: MinML.exp  -> T.typ
 
   Implement a function typeOf which infers the most general type 
   for an expression. 

   raises exception Error if the input expression e has
   no type.

   Implement typeOf, using the auxiliary function 

  typeOf' (G,e) = T   s.t. G |- e:T 

  typeOf' infers the type T for expression e in the typing context G 
  If e has no type, it will raise the exception typeError.

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
