(* Evaluation of MinML Expression via big step semantics *)
signature EVAL =
sig

  exception Stuck of string

  val subst : MinML.exp * MinML.name -> MinML.exp -> MinML.exp

  (* big-step evaluation; raises Stuck if evaluation is not possible *)
  val eval : MinML.exp -> MinML.exp

  val verbose : int ref   (* 0 for no debugging printing, 1 for printing in eval, 2 for eval and subst *)
end;  (* signature EVAL *)

structure Eval :> EVAL =
struct

  val verbose = ref 0
  val bigstep_depth = ref 0
  fun indent 0 = ""
    | indent n = " " ^ indent (n - 1)

  open MinML

  exception Stuck of string
  exception Unimplemented

  local
      (* to generate new internal variables *)
      val counter = ref 0
  in
      (* freshVar x = a,  where a is a new internal variable.
         Internal variables begin with a natural number,
         so they cannot conflict with external variables.
      *)
      fun freshVar x =
        (counter := !counter+1;
         Int.toString (!counter) ^ x)

    fun resetCtr () = 
      counter := 0
  end

(* ------------------------------------------------------------
 * Free variables
 * ------------------------------------------------------------ *)

fun member x l = List.exists (fn y => y = x) l

fun union ([], l) = []
  | union (x::t, l) = 
      if member x l then
        union(t,l)
      else
        x::union(t,l)

fun unionList sets = foldr (fn (s1,s2) => union(s1, s2)) [] sets

fun delete (vlist,[]) = []
  | delete (vlist, h::t) = 
  if member h vlist then delete(vlist,t)
    else h::delete(vlist,t)

fun boundVars dec = case dec of
      Val (_, name) => [name]
    | Valtuple(_, names) => names

fun varsDecs [] = ([], [])
  | varsDecs (dec1::decs) =
      let val (free, bound) = varsDecs decs
      in
        (union(freeVarsDec dec1, delete(boundVars dec1, free)), bound)
      end

and freeVarsDec dec = case dec of
      Val (exp, name) => freeVars exp
    | Valtuple(exp, names) => freeVars exp

(* freeVars(e) = list of names occurring free in e 

   Invariant: every name occurs at most once.
*)
and freeVars exp = case exp of
    Var y => [y]
  | Int n => []
  | Bool b => []
  | If(e, e1, e2) =>
      union(freeVars e, 
            union(freeVars e1, freeVars e2))
  | Primop (po, args) =>
       foldr (fn (e1,e2) => union(freeVars e1, e2)) [] args 
  | Tuple exps =>
       unionList (List.map freeVars exps)
  | Fn(x, e) =>
      delete([x], freeVars e)
  | Rec(x, t, e) =>
      delete([x], freeVars e)
  | Let(decs, e2) =>
      let val (free, bound) = varsDecs decs
      in
        union(free, delete(bound, freeVars e2))
      end
  | Apply(e1, e2) =>
      union(freeVars e1, freeVars e2)
  | Anno(e, _) =>
      freeVars e

fun freeVariables (e) = freeVars (e)


(* Substitution (corrected description) 
   subst : (exp * name) -> exp -> exp

   subst (e',x) e = [e'/x]e 

   subst replaces every occurrence of the variable x 
   in the expression e with e'.
*)

  fun substArg s ([]) = []
    | substArg s (a::args) = (subst s a)::(substArg s args)
          
  and subst (s as (e',x)) exp = let
  val result = 
    case exp of
      Var y =>
        if x = y then e'
        else Var y

    | Int n => Int n 
    | Bool b => Bool b
    | Primop(po, args) => Primop(po, substArg s args)
    | If(e, e1, e2) =>
        If(subst s e, subst s e1, subst s e2)

    | Anno (e, t) =>
        Anno (subst s e, t)

    | Let([], e2) => Let([], subst s e2)

    | Let(dec1::decs, e2) =>
        let val rest = Let(decs, e2)
        in 
          case dec1 of
            Val(exp, name) =>
              let val (name, rest) = if member name (freeVars e') then rename (name, rest) else (name, rest)
                  val exp = subst s exp
              in
                if name = x then
                  Let(Val(exp, name) :: decs, e2)
                else
                  let val Let(decs, e2) = subst s rest in
                    Let(Val(exp, name) :: decs, e2)
                  end
              end
          | Valtuple(exp, names) =>
              let val (names', rest) = renameListAsNeeded names e' rest
                  val exp = subst s exp
              in
                if member x names then
                  Let(Valtuple(exp, names) :: decs, e2)
                else
                  let val Let(decs, e2) = subst s rest in
                    Let(Valtuple(exp, names') :: decs, e2)
                  end
              end
        end

    | Tuple es => Tuple (map (subst s) es) 

    | Apply (e1, e2) => Apply (subst s e1, subst s e2)

    | Fn (y, e) => 
        if y = x then
          Fn (y, e)
        else
          if member y (freeVars e') then
            let val (y, e1) = rename (y,e)
            in
              Fn (y, subst s e1)
            end
          else
            Fn (y, subst s e)
    | Rec (y, t, e) =>
        if y = x then
          Rec (y, t, e)
        else
          if member y (freeVars e') then
            let val (y, e1) = rename (y,e)
            in
              Rec (y, t, subst s e1)
            end
          else
            Rec (y, t, subst s e)

  in if !verbose >= 2 then 
	 print ("subst: " ^ Print.expToString e' ^ 
		"for " ^ x ^ " in " ^ Print.expToString exp ^ "\n = " ^
		Print.expToString result ^ "\n") else (); result end

and substList [] e = e
  | substList ((x,e')::pairs) e =
     subst (x,e') (substList pairs e)

and rename (x, e) = 
  let
    val x' = freshVar x
  in
    (x', subst (Var x', x) e)
  end

and rename2 (x, y, e1, e2) = 
  let
    val x' = freshVar x 
    val y' = freshVar y 
    fun subst2 e = subst (Var x', x) (subst (Var y', y) e)
  in
    (x', y', subst2 e1, subst2 e2)
  end

and renameAll ([], e) = ([], e)
  | renameAll (x::xs, e) = 
       let val (x', e) = rename (x, e)
           val (xs', e) = renameAll (xs, e)
       in
         (x' :: xs', e)
       end

and renameListAsNeeded names e' exp =
      if List.exists (fn name => member name (freeVars e')) names then
        renameAll(names, exp)
      else
        (names, exp)


(*------------------------------------------------------------------
 * Evaluation
 *-------------------------------------------------------------------*)

fun evalList (exps : exp list) =
  List.map eval exps

(* eval : exp -> exp *)
and eval exp = let
  val _ = if !verbose >= 1 then
            print (indent (!bigstep_depth) ^ "eval { " ^ Print.expToString exp ^ " }\n")
          else ()
  val _ = bigstep_depth := !bigstep_depth + 1
  val result = case exp of

  (* Values evaluate to themselves... *)
    e as Fn _ => e 
  | e as Int _ => e
  | e as Bool _ => e

  | Var x => raise Stuck ("Free variable (" ^ x ^ ") during evaluation")

  | recursiveExp as Rec (f, _, e) =>   
    eval (subst (recursiveExp,f) e)

  (* primitive operations +, -, *, <, = *)
  | Primop(po, args) =>
      let val argvalues = evalList args
      in case evalOp(po, argvalues) of
        NONE => raise Stuck "Bad arguments to primitive operation"
      | SOME v => v
      end

  | Tuple es => Tuple (map eval es)

  | Let([], e2) => eval e2
  | Let((Val (e1,x1))::decs, e) =>
     eval (subst (eval e1, x1) (Let (decs, e)))
  | Let((Valtuple (e1,xs))::decs, e) =>
     let val Tuple vs = eval e1
     in
       eval (substList (ListPair.zipEq (vs, xs)) e)
     end

  | Anno (e, _) => eval e     (* types are ignored in evaluation *)


  | If(e, e1, e2) =>
    let val v = eval e in
	(case v of Bool true => eval e1
		 | Bool false => eval e2
		 | _ => raise (Stuck "Non boolean condition"))
    end

  | Apply (e1, e2) =>
	let val Fn (x,e) = eval e1
	in
	  eval (subst (eval e2, x) e)
	end
  in
    bigstep_depth := !bigstep_depth - 1;
    if !verbose >= 1 then
      print (indent (!bigstep_depth)
          ^ "result of eval { " ^ Print.expToString exp ^ " } = "
          ^ Print.expToString result ^ "\n")
    else ();
    result
  end


end;  (* structure Eval *)
