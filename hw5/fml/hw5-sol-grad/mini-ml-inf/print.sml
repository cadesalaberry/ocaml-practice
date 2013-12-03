(* Printing expressions *)
signature PRINT =
sig
  (* print an expression *)
  val expToString : MinML.exp -> string

  (* print a type *)
  val typToString : Type.tp -> string
end

(*--------------------------------------------------*)
structure Print :> PRINT =
struct

  open Lib
  structure M = MinML
  structure T = Type
  type exp = M.exp

 local
    (* local counter to guarantee new internal variables *)
    val counter = ref 0
  in
    (* freshVar () ===> a,  where a is a new internal variables *)
    (*
       Internal variables are natural numbers,
       so they cannot conflict with external variables.
    *)
    fun freshVar () =
	(counter := !counter+1;
	 ("a"^ Int.toString (!counter)))

  fun resetCtr () = 
    counter := 0
  end

  fun paren lvl oplvl string =
    if oplvl < lvl then "(" ^ string ^ ")"
    else string

  fun po_prec M.Equals = 3
    | po_prec M.LessThan = 3
    | po_prec M.Plus = 4
    | po_prec M.Minus = 4
    | po_prec M.Times = 5
    | po_prec M.Negate = 7

  fun po M.Equals = "="
    | po M.LessThan = "<"
    | po M.Plus = "+"
    | po M.Minus = "-"
    | po M.Times = "*"
    | po M.Negate = "~"

  and expstr lvl e = let val f = expstr in case e of
      M.Int i => Int.toString i
    | M.Bool true => "true"
    | M.Bool false => "false"
    | M.If (ec, et, ef) =>
        paren lvl 1 ("if " ^ f 2 ec ^ " then " ^ f 2 et ^ " else " ^ f 2 ef)
    | M.Primop (p, []) => "(bad primop)"
    | M.Primop (p, [e]) => paren lvl 7 (po p ^ f 7 e)
    | M.Primop (p, e::es) =>
        paren lvl (po_prec p) (foldl (fn (a, b) => b ^ " " ^ po p ^ " " ^ f (po_prec p) a) (f (po_prec p) e) es)
    | M.Tuple es => "(" ^ separate ", " (f 0) es ^ ")"
    | M.Fn (x, e) =>
        paren lvl 2 ("fn " ^ x ^  " => " ^ f 0 e)
    | M.Rec (ff, ftype, e) =>
        paren lvl 2 ("rec " ^ ff ^  " : " ^ Type.toString ftype ^ " => " ^ f 0 e)
    | M.Let (decs, e) =>
        "let " ^ separate "\n    " decToString decs ^ " in " ^ f 0 e ^ " end"
    | M.Apply (e1, e2) =>
        paren lvl 6 ((f 6 e1) ^ " " ^ (f 7 e2))
    | M.Var v => v
    | M.Anno (e, t) => paren lvl 0 (f 1 e ^ " : " ^ Type.toString t)
  end

  and expToString e = expstr 0 e

  and decToString e = let val f = expToString in case e of
      M.Val (r as M.Rec (ff, ftype, M.Fn(x, body)), gg) =>
        if ff = gg then
          "fun " ^ ff ^ " : " ^ Type.toString ftype ^ " " ^ x ^  " = " ^ f body
        else "val " ^ gg ^ " = " ^ f r

    | M.Val (e1, x) =>
        "val " ^ x ^ " = " ^ f e1

    | M.Valtuple (e1, xs) =>
        "val (" ^ separate ", " (fn name => name) xs ^ ") = " ^ f e1
  end

  and member ([], r) = NONE
    | member ((a,r)::L, r') = 
      if r = r' then SOME(a) else member (L, r')
					 
  fun typToString'(L, T.Int) = (L, "int ")
    | typToString' (L, T.Bool) = (L, "bool ")
    | typToString' (L, T.Arrow(d, r)) = 
      let
	  val (L', s) =  typToString' (L, d) 
	  val (L'', s') = typToString' (L',r)
      in 
	  (L'', "(" ^ s ^ ") -> (" ^ s' ^ ")")
      end 

    | typToString' (L, T.Product ts) = 
      let
	  val (L', ts') = typsToStringList' (L, ts)
	  val ts'' = String.concatWith ") * ("  ts'
      in 


	  (L', "(" ^ ts'' ^ ")")
      end 
    | typToString' (L, T.TVar (r as ref NONE)) = 
      (case member (L, r) of
	   NONE => let val a = freshVar() in ((a, r)::L, a) end
	 | SOME(a) => (L, a))
    | typToString' (L, T.TVar (r as ref (SOME(T)))) = 
      typToString' (L, T)

  and typsToStringList' (L, []) = (L, [])
    | typsToStringList' (L, t::ts) = 
      let 
	  val (L', s) = typToString' (L, t)
	  val (L'', s') = typsToStringList' (L',ts)
      in
	  (L'', s::s')
      end

  and typToString T = let val (_, t) = typToString' ([], T) in (resetCtr () ; t) end


end;  (* structure Print *)
