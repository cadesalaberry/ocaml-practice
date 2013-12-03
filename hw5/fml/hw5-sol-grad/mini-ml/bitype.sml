signature TYPECHECK = sig

  type context  (* Context of typing assumptions; example: x : int, p : bool *)
  val empty : context

  (* Synthesize a type from an expression, returning the type *)
  val synth : context -> MinML.exp -> Type.tp

  (* Check an expression against the type it's supposed to have*)
  val check : context -> MinML.exp -> Type.tp -> unit

  exception TypeError of string
end

structure Typecheck :> TYPECHECK = struct

  open Type
  structure M = MinML

  datatype context = Ctx of (M.name * tp) list

  val empty = Ctx []

  exception Unimplemented

  exception NotFound
  fun assoc x [] = raise NotFound
    | assoc x ((y, r)::rest) = if x = y then r else assoc x rest

  fun lookup (Ctx list) x = assoc x list
  fun extend (Ctx list) (x, v) = Ctx((x, v)::list)

  fun extend_list ctx [] = ctx
    | extend_list ctx ((x, v)::pairs) = extend_list (extend ctx (x, v)) pairs

  exception TypeError of string

  (* fail : string -> 'a
   *
   * Raises the TypeError exception, for ill-typed MinML programs.
   *)
  fun fail message = raise TypeError message

  fun primopType primop = case primop of
        M.Equals => Arrow(Product[Int, Int], Bool)
      | M.LessThan => Arrow(Product[Int, Int], Bool)
      | M.Plus => Arrow(Product[Int, Int], Int)
      | M.Minus => Arrow(Product[Int, Int], Int)
      | M.Times => Arrow(Product[Int, Int], Int)
      | M.Negate => Arrow(Int, Int)

  (* synth : context -> M.exp -> tp
   *
   * Synthesize a type from an expression.
   * Returns the synthesized (inferred) type if one exists;
   *   otherwise raises TypeError.
   *) 
  fun synth ctx exp = case exp of
      M.Int _ => Int
    | M.Bool _ => Bool
    | M.Primop(po, exps) =>
         let val poType as Arrow(domain, range) = primopType po
             val productizedExps = case exps of [one] => one
                                              | several => M.Tuple several
         in
           check ctx productizedExps domain;
           range
         end

    (* This case is for example called from the function bind to
       handle n-ary tuple declarations                                *)
    | M.Tuple es =>
         Product (List.map (synth ctx) es)

    | M.Apply (e1, e2) =>
       (case (synth ctx e1) of
           Arrow (t1,t2) => (check ctx e2 t1; t2)
         | _ => fail "Expected function type in function position") 
                            
    | M.Var x => lookup ctx x

    | M.Anno (e, t) =>
        (check ctx e t;
         t)

    | M.Rec (f, ftype, e) =>
	(check (extend ctx (f,ftype)) e ftype; ftype)
    | M.Let(decs, exp) => 
       let val ctx' = bind ctx decs
       in
	synth (extend_list ctx ctx') exp
       end 
    | _ => fail "Can't synthesize type"

  (* check : context -> M.exp -> tp -> unit
   *
   * Check an expression against a type.
   * Returns () if it succeeds; otherwise raises TypeError.
   *) 
  and check ctx exp t : unit = case (exp, t) of

      (M.If(e, e1, e2), t) =>
         (check ctx e Bool;
	  check ctx e1 t;
	  check ctx e2 t) 

    | (M.Tuple es, Product ts) =>
	ListPair.appEq (fn (ei,ti) => check ctx ei ti) (es,ts)
    | (M.Fn(x, body), Arrow(domain, range)) =>
	check (extend ctx (x,domain)) body range
    | (e, t) =>
         let val synthesizedType = synth ctx e
         in
           if Type.eq (synthesizedType, t) then ()
           else fail ("Checking against " ^ Type.toString t
                    ^ ", but synthesized type " ^ Type.toString synthesizedType)
         end

  (* bind : context -> M.dec list -> M.dec list
   *
   * Synthesizes types for declarations, returning a context with appropriate
   *  new typing assumptions; or, if not type-correct, raises TypeError.
   *
   * This function implements the rules deriving  Gamma |- decs  up  Gamma'.
   *)
  and bind ctx [] = []
    | bind ctx (dec::decs) =
        let val ctx1 = decSynth ctx dec
            val ctx2 = bind (extend_list ctx ctx1) decs 
	in
	  ctx2 @ ctx1
	end
  and decSynth ctx (M.Val (e,x)) = [(x,synth ctx e)]
    | decSynth ctx (M.Valtuple (e,xs)) =
        let val Product ts = synth ctx e
	in
       	  ListPair.zipEq (xs,ts)
	end 

end
