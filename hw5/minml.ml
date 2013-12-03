
  type name = string

  type primop = Equals | LessThan | Plus | Minus | Times | Negate

  type exp =
  | Int of int                        (* 0 | 1 | 2 | ... *)
  | Bool of bool                      (* true | false *)
  | If of exp * exp * exp             (* if e then e1 else e2 *)
  | Primop of primop * exp list       (* e1 <op> e2  or  <op> e *)
  | Tuple of exp list                 (* (e1, ..., eN) *)
  | Fn of (name * (Type.tp option) * exp)      (* fn x : t => e *)
  | Rec of (name * (Type.tp option) * exp)     (* rec f : t => e *)
  | Let of (dec list * exp)         (* let decs in e end *)
  | Apply of exp * exp                (* e1 e2 *)
  | Var of name                       (* x *)
  | Anno of exp * Type.tp        (* e : t *)

  and dec =
  | Val of exp * name                  (* val x = e *)
  | Valtuple of exp * (name list)      (* val (x1,...,xN) = e *)
  | ByName of exp * name               (* val name x = e1 *)

  let evalOp op = match op with
    | (Equals,   [Int i; Int i']) -> Some (Bool (i = i'))
    | (LessThan, [Int i; Int i']) -> Some (Bool (i < i'))
    | (Plus,     [Int i; Int i']) -> Some (Int (i + i'))
    | (Minus,    [Int i; Int i']) -> Some (Int (i - i'))
    | (Times,    [Int i; Int i']) -> Some (Int (i * i'))
    | (Negate,   [Int i])         -> Some (Int (-i))
    | _                           -> None

