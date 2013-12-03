open Lib

module M = Minml

type exp = M.exp

  let paren lvl oplvl string =
    if oplvl < lvl then "(" ^ string ^ ")"
    else string

  let po_prec p = match p with
    | M.Equals   -> 3
    | M.LessThan -> 3
    | M.Plus     -> 4
    | M.Minus    -> 4
    | M.Times    -> 5
    | M.Negate   -> 7

  let rec po p = match p with
    | M.Equals   -> "="
    | M.LessThan -> "<"
    | M.Plus     -> "+"
    | M.Minus    -> "-"
    | M.Times    -> "*"
    | M.Negate   -> "~"

  and expstr lvl e = let f = expstr in match e with
    | M.Int i -> string_of_int i
    | M.Bool true -> "true"
    | M.Bool false -> "false"
    | M.If (ec, et, ef) ->
      paren lvl 1 ("if " ^ f 2 ec ^ " then " ^ f 2 et ^ " else " ^ f 2 ef)
    | M.Primop (p, []) -> "(bad primop)"
    | M.Primop (p, [e]) -> paren lvl 7 (po p ^ f 7 e)
    | M.Primop (p, e::es) ->
      let f' b a = b ^ " " ^ po p ^ " " ^ (f (po_prec p) a) in
      paren lvl (po_prec p) (List.fold_left f' (f (po_prec p) e) es)
    | M.Tuple es -> "(" ^ separate ", " (f 0) es ^ ")"
    | M.Fn (x, None, e) ->
      paren lvl 2 ("fn " ^ x ^  " => " ^ f 0 e)
    | M.Fn (x, Some t, e) ->
      paren lvl 2 ("fn " ^ x ^  " : " ^ Type.toString t  ^ " => " ^ f 0 e)
    | M.Rec (ff, None, e) ->
      paren lvl 2 ("rec " ^ ff ^  " => " ^ f 0 e)
    | M.Rec (ff, Some ftype, e) ->
      paren lvl 2 ("rec " ^ ff ^  " : " ^ Type.toString ftype ^ " => " ^ f 0 e)
    | M.Let (decs, e) ->
      "let " ^ separate "\n    " decToString decs ^ " in " ^ f 0 e ^ " end"
    | M.Apply (e1, e2) ->
      paren lvl 6 ((f 6 e1) ^ " " ^ (f 7 e2))
    | M.Var v -> v
    | M.Anno (e, t) -> paren lvl 0 (f 1 e ^ " : " ^ Type.toString t)

  and expToString e = expstr 0 e

  and decToString e = let f = expToString in match e with
    | M.Val (M.Rec (ff, Some (Type.Arrow (t1, t2)), M.Fn(x, Some t, body)) as r, gg) ->
      if ff = gg then
        "fun " ^ ff ^ " (" ^ x ^ " : " ^ Type.toString t ^ ") " 
        ^  " : " ^ Type.toString t2 ^ " = " ^ f body
      else "val " ^ gg ^ " = " ^ f r

    | M.Val (M.Rec (ff, None, M.Fn(x, None, body)) as r, gg) ->
      if ff = gg then
        "fun " ^ ff ^ " " ^ x ^  " = " ^ f body
      else "val " ^ gg ^ " = " ^ f r

    | M.Val (e1, x) ->
      "val " ^ x ^ " = " ^ f e1

    | M.ByName (e1, x) ->
      "name " ^ x ^ " = " ^ f e1

    | M.Valtuple (e1, xs) ->
      "val (" ^ separate ", " (fun name -> name) xs ^ ") = " ^ f e1

  let rec insertTabs n = if n = 0 then "" else "  " ^ (insertTabs (n-1))

  let rec astToStr e = match e with
    | M.Int i -> "Int (" ^ string_of_int i ^ ")"
    | M.Bool true -> "Bool true"
    | M.Bool false -> "Bool false"
    | M.If (ec, et, ef) -> 
      "If (" ^ astToStr ec ^  ", " 
      ^ astToStr et ^ ", " ^ astToStr ef ^ ")"
    | M.Primop (p, []) -> "(bad primop)"
    | M.Primop (p, [e]) -> "Primop (" ^ (po p ^ astToStr e) ^ ")"
    | M.Primop (p, es) -> "Primop (" ^ po p ^ "," ^
      (List.fold_left (fun s e -> astToStr e ^ ", " ^ s) "" es) ^ ")"
    | M.Tuple es -> "Tuple (" ^ separate ", " astToStr es ^ ")"
    | M.Fn (x, None, e) ->
      "Fn (" ^ x ^  ", None, " ^ astToStr e ^ ")"
    | M.Rec (ff, None, e) ->
      "Rec (" ^ ff ^  ", None, " ^ astToStr e ^ ")"
    | M.Fn (x, Some t, e) ->
      "Fn (" ^ x ^  ", Some (" ^ astTypeToString t ^ "), " ^ astToStr e ^ ")"
    | M.Rec (ff, Some ftype, e) ->
      "Rec (" ^ ff ^  ", Some (" ^ astTypeToString ftype ^ "), " ^ astToStr e ^ ")"
    | M.Let (decs, e) ->
      "Let ([" ^ separate ", " astDecToString decs ^ "], " ^ astToStr e ^ ")"
    | M.Apply (e1, e2) ->
      "Apply (" ^ astToStr e1 ^ ", " ^ astToStr e2 ^ ")"
    | M.Var v -> "Var " ^ v
    | M.Anno (e, t) -> "Anno (" ^ astToStr e ^ ", " ^ astTypeToString t ^ ")"

  and astDecToString e = match e with
    | M.Val (e1, x) ->
      "Val (" ^ astToStr e1 ^ ", " ^ x ^ ")"

    | M.ByName (e1, x) ->
      "ByName (" ^ astToStr e1 ^ ", " ^ x ^ ")"

    | M.Valtuple (e1, xs) ->
      "ValTuple (" ^ astToStr e1 ^ ", [" ^ separate ", " (fun name -> name) xs ^ "])"

  and astTypeToString e = match e with
    | Type.Arrow (t1, t2) ->
      "Arrow (" ^ astTypeToString t1 ^ ", " ^ astTypeToString t2 ^ ")"
    | Type.Product xs -> "Product [" ^ separate ", " astTypeToString xs ^ "]"
    | Type.Int -> "Int"
    | Type.Bool -> "Bool"
    | Type.TVar x -> "TVar (" ^ (match !x with
      | None -> "None"
      | Some t -> "Some" ^ astTypeToString t) ^ ")"

  let astToString e = astToStr e
