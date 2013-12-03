(* Type checking MinML *)
(* Operates on MinML expressions 
(where variables are encoded as strings) *)

signature TYPING =
sig

  exception Error of string

  (* typeOf (e) = t for the t such that |- e : t *)
  (* raises Error if no such t exists *)
  val typeOf : MinML.exp -> T.typ

end;  (* signature TYPING *)

structure Typing :> TYPING =
struct

  open T
  open MinML

  exception Error of string

  (* Contexts *)
  datatype 'a Ctx =			(* Contexts                   *)
    Null				(* G ::= .                    *)
  | Decl of 'a Ctx * 'a			(*     | G, D                 *)


(* The context x:int, y:bool is then represented as

   Decl(Decl(Null,("y", BOOL)), ("x", INT))
*)

fun lookup (Null, x) = NONE
  | lookup (Decl (G, (y, t)), x) = if x = y then SOME t else lookup (G, x)

(* ------------------------------------------------------------ *)
(* QUESTION : Type Checking                                     *) 
(* -------------------------------------------------------------*)
(* typeOf: MinML.exp  -> T.typ
 
   Implement a function typeOf which infers the type for
   an annotated expression. NOTE: we use type annotations
   to resolve ambiguity. You do not need to consider full
   type inference for expressions without annotations!

   raises exception Error if the input expression e has
   no type.

   Implement typeOf, using the auxiliary function 

  typeOf' (G,e) = T   s.t. G |- e:T 

  typeOf' infers the type T for expression e in the typing context G 
  If e has no type, it will raise the exception typeError.

  typeOf : (string * typ) Ctx * MinML.exp -> T.typ

*)

fun typeOf' (G, expr) = case expr of
	  Int _ => T.INT
	| Bool _ => T.BOOL
	| If (e, e1, e2) =>
		if typeOf' (G, e) = T.BOOL
		then
			let
				val t1 = typeOf' (G, e1)
				val t2 = typeOf' (G, e2)
			in
				if t1 = t2
				then t1
				else raise Error "The then and else branches of an if must have the same type."
			end
		else raise Error "Cannot use a non-boolean expression as a condition."
	| Primop (p, es) =>
		let
			val (ts, t) = MinML.typeOfOp p 
		in
			if (map (fn e => typeOf' (G, e)) es) = ts
			then t
			else raise Error "Invalid operand argument types"
		end
	| Pair (e1, e2) => T.CROSS (typeOf' (G, e1), typeOf' (G, e2))
	| Fst e =>
		(case (typeOf' (G, e)) of
		   T.CROSS (t1, _) => t1
		 | _ => raise Error "Cannot use Fst on a non-product expression")
	| Snd e =>
		(case (typeOf' (G, e)) of
		   T.CROSS (_, t2) => t2
		 | _ => raise Error "Cannot use Snd on a non-product expression")
	| Fun (t1, t2, (f, x, e)) =>
		let
			val fun_type = T.ARROW (t1, t2)
			val t = typeOf' (Decl (Decl (G, (x, t1)), (f, fun_type)), e)
		in
			if t = t2
			then fun_type
			else raise Error "Function body type does not match declared return type"
		end
	| Fn (t1, (x, e)) => T.ARROW (t1, typeOf' (Decl (G, (x, t1)), e))
	| Let (e1, (x, e2)) => typeOf' (Decl (G, (x, typeOf' (G, e1))), e2)
	| Letp (e1, (x, y, e2)) =>
		(case (typeOf' (G, e1)) of
		    T.CROSS (t1, t2) => typeOf' (Decl (Decl (G, (y, t2)), (x, t1)), e2)
		  | _ => raise Error "Letp expects a product")
	| Apply (e1, e2) =>
		(case (typeOf' (G, e1)) of
		  T.ARROW (t1, t2)
			=> (if (typeOf' (G, e2)) = t1
			then t2
			else raise Error "Argument type does not match parameter type")
		 | _ => raise Error "Cannot apply an expression that is not a function")
	| Var x => (case (lookup (G, x)) of
		      SOME t => t
		    | NONE => raise Error ("Cannot get the type of unbound variable " ^ x))

fun typeOf expr = typeOf' (Null, expr)

end;  (* structure Typing *)
