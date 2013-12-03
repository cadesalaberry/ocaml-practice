(* Evaluation of MinML Expression *)
signature EVAL =
sig

  exception Stuck of string

  (* evaluation, raises Stuck if impossible *)
  val eval : MinML.exp -> MinML.exp
  val subst: (MinML.exp * MinML.name) -> MinML.exp -> MinML.exp

end;  (* signature EVAL *)

structure Eval :> EVAL =
struct

  open T
  open MinML
  structure S = Stream

  exception Stuck of string
  exception Done 

 local
    (* local counter to guarantee new internal variables *)
    val counter = ref 0
  in
    (* newVar () ===> a,  where a is a new internal variables *)
    (*
       Internal variables are natural numbers,
       so they cannot conflict with external variables.
    *)
    fun newVar () =
	(counter := !counter+1;
	 Int.toString (!counter))
  end

(* ------------------------------------------------------------ *)
(* QUESTION : Substitution                                      *) 
(* ------------------------------------------------------------ *)
(* Substitution 

   subst (e',x) e = [e/x]e 

  subst which will replace any occurrence of the variable x 
  in the expression e' with e.

  subst: (exp * string) -> exp -> exp

  YOUR TASK: Extend the function below to also handle the cases
  for let-name, pairs, projections (fst and snd), functions, 
  function application, and recursion. 

 *)

  fun substArg s ([]) = []
    | substArg s (a::args) = (subst s a)::(substArg s args)

  and subst (e,x) (Var y) = 
    if (x = y) then e
      else Var y
    (* arithmetic operations and integers *)
    | subst s (Int n) = Int n 
    | subst s (Bool b) = Bool b
    | subst s (Primop(po, args)) = Primop(po, substArg s args)
    | subst s (If(e, e1, e2)) = 
	If(subst s e, subst s e1, subst s e2)
    | subst s (Let (e, (x,e'))) = 
	let
	  val e1 = subst s e
	  val (x',e1') = rename (x,e')
	  val e2 = subst s e1'
	in 
	  Let (e1, (x', e2))
	end 
    | subst s (Pair(e1,e2)) = Pair(subst s e1, subst s e2)
    | subst s (Fst e) = Fst (subst s e)
    | subst s (Snd e) = Snd (subst s e)
    | subst s (Letp (e1,(x,y,e2))) =
        let
          val e1' = subst s e1
          val (x',e2') = rename (x,e2)
          val (y',e2'') = rename (y,e2')
          val e2''' = subst s e2''
        in
          Letp (e1', (x',y', e2'''))
        end
    | subst s (Fn(t1,(x,e))) =
        let
          val (x',e') = rename (x,e)
          val e'' = subst s e'
        in
          Fn(t1, (x', e''))
        end
    | subst s (Fun(t1,t2,(f,x,e))) =
       let
          val (f',e') = rename (f,e)
          val (x',e'') = rename (x,e')
          val e''' = subst s e''
        in
          Fun (t1, t2,(f',x', e'''))
        end
    | subst s (Apply (e1,e2)) = Apply (subst s e1, subst s e2)

and rename (x, e) = 
  let
    val x' = newVar () 
  in
    (x', subst (Var x', x) e)
  end


(*-------------------------------------------------------------------*)
(* QUESTION: Evaluation                                              *)
(*-------------------------------------------------------------------*)
(* YOUR TASK: Implement the evaluator such that we can
   evaluate these expressions. Follow the description presented in
   class.
*)


(* eval : exp -> exp *)
and  eval (Int n) = Int n
   | eval (Bool b) = Bool b
   | eval (Primop (p,es)) =
      (case (evalOp (p, map eval es)) of
         SOME v => v
       | NONE   => raise Stuck "Failed to evaluate primitive op")
   | eval (If (e1,e2,e3)) =
      (case (eval e1) of
          Bool true => eval e2
        | Bool false => eval e3
        | _ => raise Stuck "Condition did not evaluate to a boolean")
   | eval (Var x) = raise Stuck "Encountered free variable"
   | eval (Pair(e1,e2)) = Pair(eval e1, eval e2)
   | eval (Fst e) = (case eval e of Pair(e1,e2) => eval e1
                             |_ => raise Stuck "in Fst")
   | eval (Snd e) = (case eval e of Pair(e1,e2) => eval e2
                             |_ => raise Stuck "in Snd")
   | eval (Fn(t1,(x,e))) = Fn(t1,(x,e))
   | eval (Fun(t1,t2,(f,x,e))) = Fun(t1,t2,(f,x,e))
   | eval (Apply(e1,e2)) = (case eval e1 of Fn(t1,(x,e)) => eval(subst (eval e2,x) e)
                      | Fun(t1,t2,(f,x,e))=>eval(subst (Fun (t1,t2,(f,x,e)),f) (subst (eval e2, x) e))
                      | _ => raise Stuck "in Apply")
   | eval (Let(e1,(x,e2))) = eval(subst (e1,x) e2)
   | eval (Letp(e1,(x,y,e2))) =
     let
         val Pair(v1,v2) = eval e1
     in   
         eval(subst (v2,y) (subst (v1,x) e2)) 
     end


end;  (* structure Eval *)
