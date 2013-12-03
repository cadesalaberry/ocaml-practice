(* MinML abstract syntax
   COMP 302, Winter 2010
   Joshua Dunfield
*)

signature MINML =
sig
  (* Variables *)
  type name = string

  (* Primitive operations *)
  datatype primop = Equals | LessThan | Plus | Minus | Times | Negate

  (* Expression *)
  (* Binders are grouped with their scope, e.g. Fn of (name * exp) *)
  datatype exp =
      Int of int                        (* 0 | 1 | 2 | ... *)
    | Bool of bool                      (* true | false *)
    | If of exp * exp * exp             (* if e then e1 else e2 *)
    | Primop of primop * exp list       (* e1 <op> e2  or  <op> e *)
    | Tuple of exp list                 (* (e1, ..., eN) *)
    | Fn of (name * exp)                (* fn x => e *)
    | Rec of (name * Type.tp * exp)     (* rec f => e  ---Recursive expression *)
    | Let of (dec list * exp)           (* let decs in e end *)
    | Apply of exp * exp                (* e1 e2 *)
    | Var of name                       (* x *)
    | Anno of exp * Type.tp        (* e : t *)

  and dec =
      Val of exp * name                  (* val x = e *)
    | Valtuple of exp * (name list)      (* val (x1,...,xN) = e *)

  (* given a primop and some arguments, apply it *)
  val evalOp : primop * exp list -> exp option

end;  (* signature MINML *)


structure MinML :> MINML =
struct

  type name = string

  datatype primop = Equals | LessThan | Plus | Minus | Times | Negate

  datatype exp =
      Int of int                        (* 0 | 1 | 2 | ... *)
    | Bool of bool                      (* true | false *)
    | If of exp * exp * exp             (* if e then e1 else e2 *)
    | Primop of primop * exp list       (* e1 <op> e2  or  <op> e *)
    | Tuple of exp list                 (* (e1, ..., eN) *)
    | Fn of (name * exp)                (* fn x => e *)
    | Rec of (name * Type.tp * exp)     (* rec f => e *)
    | Let of (dec list * exp)         (* let decs in e end *)
    | Apply of exp * exp                (* e1 e2 *)
    | Var of name                       (* x *)
    | Anno of exp * Type.tp        (* e : t *)

  and dec =
      Val of exp * name                  (* val x = e *)
    | Valtuple of exp * (name list)      (* val (x1,...,xN) = e *)

  (* Evaluation of primops on evaluated arguments *)
  fun evalOp (Equals, [Int i, Int i']) = SOME (Bool (i = i'))
    | evalOp (LessThan, [Int i, Int i']) = SOME (Bool (i < i'))
    | evalOp (Plus, [Int i, Int i']) = SOME (Int (i + i'))
    | evalOp (Minus, [Int i, Int i']) = SOME (Int (i - i'))
    | evalOp (Times, [Int i, Int i']) = SOME (Int (i * i'))
    | evalOp (Negate, [Int i]) = SOME (Int (~i))
    | evalOp _ = NONE

end;  (* structure MinML *)
