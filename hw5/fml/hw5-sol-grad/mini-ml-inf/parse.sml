(* Parser for MinML *)
(* Generates abstract syntax in named form *)
(* Written as a transducer from token streams to expression streams *)

signature PARSE =
sig
  val parse : Lexer.token Stream.stream -> MinML.exp Stream.stream

  exception Error of string
end;  (* signature PARSE *)

structure Parse :> PARSE =
struct

  exception Error of string

  structure S = Stream
  structure M = MinML
  structure L = Lexer
  structure T = Type

  exception Error of string

  (* next s = (x,s'), where x is the head of s, s' the tail of s
     raises Error if stream is empty
  *)
  fun next s =
      case S.force s
        of S.Nil => raise Error "Unexpected end of stream"
         | S.Cons (result as (tok : Lexer.token, _)) => ( (* print ("next = " ^ Lexer.tokenToString tok ^ "\n"); *) result)

  (* match tok s = s', s' is the tail of s
     raises Error if head of s does not match tok
  *)
  fun match tok s =
      let
        val (n, s') = next s
      in
        if tok = n then s'
        else raise Error ("Expected " ^ Lexer.tokenToString tok ^ " token")
      end

  fun build_primop ((primop, e), e') =
        M.Primop(primop, [e', e])

  (* build_primops: exp -> (primop * exp) list -> exp *)
  fun build_primops exp op_exps =
         foldl build_primop exp op_exps

  (* 
     atomic-tp  ::=  int | bool | "(" tp ")"
     tp-factor  ::=  atomic-tp
     tp-term    ::=  tp-factor | tp-term "*" tp-factor
     tp         ::=  tp-term | tp-term "->" tp
  *)
  fun parse_atomic_tp s = case next s of
      (L.INT, s) => (T.Int, s)
    | (L.BOOL, s) => (T.Bool, s)
    | (L.LPAREN, s) =>
          let val (t, s') = parse_tp s
              val s = match L.RPAREN s'
          in
            (t, s)
          end
    | (_, s) => raise Error "Ill-formed type"
  and parse_tp_factor s = (if 0 = 0 then () else () (* magic incantation to suppress SML/NJ 110.72 bug *);
                           parse_atomic_tp s)
  and parse_tp_term acc s =
    let val (t, s) = parse_tp_factor s
    in
      case next s of
        (L.TIMES, s) =>
           parse_tp_term (acc @ [t]) s
      | (_, _) =>
           (acc @ [t], s)
    end
  and parse_tp s =
    let val (tfactors, s) = parse_tp_term [] s
        val t = case tfactors of [one] => one | tfactors => T.Product tfactors
    in
      case next s of
        (L.ARROW, s) =>
           let val (t2, s) = parse_tp s
           in
             (T.Arrow(t, t2), s)
           end
      | (_, _) => (t, s)
    end

  (* parse_program r = (e,s')
     where e is the result of parsing the beginning of r
     and s' the unprocessed tail of r
  *)
  fun parse_program r =
      let val (e, s) = parse_exp (S.delay (fn () => S.Cons r))
      in
        (e, match L.SEMICOLON s)
      end

  (* parse_factors: Recursively consume adjacent atomic factors (parse_factora),
     forming them into a chain of applications. *)
  and parse_factors s eo =
      case parse_factor_maybe s of
          SOME (e, s) => (case eo of
                              NONE => parse_factors s (SOME e)
                            | SOME f => parse_factors s (SOME (M.Apply(f, e))))
        | NONE => (case eo of
                       NONE => raise Error "Expected expression"
                     | SOME e => (e, s))

  and parse_factor es = parse_factors es NONE

  (* parse_factora (t,s) attempts to find an atomic expression (no applications) 
     starting with the token t, perhaps continuing through the stream. 
     Returns SOME(e, s) if the exp e was successfully recognized, with s
     the stream remaining after it.
     Returns NONE if the token cannot begin any exp.
     May raise exception Error if the input stream does not represent
     any valid MinML program. *)
 (* parse_factora : L.token * L.token S.stream -> (M.exp * L.token S.stream) option *)

  and parse_factora (L.TRUE, s) = SOME (M.Bool true, s)
    | parse_factora (L.FALSE, s) = SOME (M.Bool false, s)
    | parse_factora (L.NUMBER n, s) = SOME (M.Int n, s)
    | parse_factora (L.VAR v, s) = SOME (M.Var v, s)
    | parse_factora (L.IF, s) =
        let
            val (ec, s) = parse_exp s
            val s = match L.THEN s
            val (et, s) = parse_exp s
            val s = match L.ELSE s
            val (ef, s) = parse_exp s
        in
            SOME (M.If(ec, et, ef), s)
        end
    | parse_factora (L.LPAREN, s) =
        let
          val (e, s) = parse_exp s
          val (n, s') = next s
        in
          if n = L.RPAREN then
            SOME (e, s')
          else
            let fun parse_tuple s = case next s of
                     (L.COMMA, s) =>
                       let val (e, s) = parse_exp s
                           val (es, s) = parse_tuple s
                       in
                         (e::es, s)
                       end
                   | (L.RPAREN, s) => ([], s)
                   | _ => raise Error "Ill-formed tuple"

                val (es, s) = parse_tuple s
            in
              SOME(M.Tuple(e::es), s)
            end
        end
(*
    | parse_factora (L.FST, s) = 
        let
          val (e,s') = parse_exp s
        in 
          SOME(M.Fst e, s')
        end
*)
    | parse_factora (L.FN, s) =
        let
            val (x, s) = parse_var (next s)
            val s = match L.DARROW s
            val (e, s) = parse_exp s
        in
            SOME (M.Fn((x, e)), s)
        end
    | parse_factora (L.LET, s) =
         let val (declist, s) = parse_declist s
             val s = match L.IN s
             val (e2, s) = parse_exp s
             val s = match L.END s
         in
           SOME(M.Let(declist, e2), s)
         end

    | parse_factora (p, s) =
        let in case p of
            L.NEGATE =>
               let in case parse_factora (next s) of
                    SOME (operand, s) => SOME (M.Primop (M.Negate, [operand]), s)
                  | NONE => NONE
               end
          | _ => NONE
        end

  and parse_declist s =
      let val (n, _) = next s
      in
        if n = L.VAL orelse n = L.FUN orelse n = L.NAME then
          let val (d, s) = parse_dec s
              val (declist, s) = parse_declist s
          in
            (d::declist, s)
          end
        else
          ([], s)
      end

  and parse_dec s =
      let val (n1, s1) = next s
          val (n2, s2) = next s1
      in
        case (n1, n2) of
          (L.VAL, L.LPAREN) =>
               let fun parse_tuple s = case next s of
                     (L.COMMA, s) =>
                       let val (x, s) = parse_var (next s)
                           val (xs, s) = parse_tuple s
                       in
                         (x::xs, s)
                       end
                   | (L.RPAREN, s) => ([], s)
                   | _ => raise Error "Ill-formed tuple pattern"

                   val (x1, s) = parse_var (next s2)
                   val (xs, s) = parse_tuple s
                   val s = match L.EQUALS s         
                   val (e1,s) = parse_exp s
               in 
                 (M.Valtuple (e1, x1::xs), s)
               end
         | (L.VAL, _) =>
              (* call by value *)
              let val (x, s) = parse_var (next s1)
                  val s = match L.EQUALS s
                  val (e1, s) = parse_exp s
              in
                  (M.Val(e1, x), s)
              end
         | (L.FUN, _) =>
                let val (f, s) = parse_var (next s1)
                    val (ftype, s) = case next s of
                                       (L.COLON, s) => let val (ftype, s) = parse_tp s in (SOME ftype, s) end
                                     | _ => (NONE, s)
                    val (x, xtype, s) =
                          case next s of
                            (L.LPAREN, s) => 
                              let val (x, s) = parse_var (next s)
                                  val (xtype, s) = case next s of
                                                     (L.COLON, s) => let val (xtype, s) = parse_tp s in (SOME xtype, s) end
                                                   | _ => (NONE, s)
                                  val s = match L.RPAREN s
                              in
                                (x, xtype, s)
                              end
                          | _ => let val (x, s) = parse_var (next s)
                                 in
                                   (x, NONE, s)
                                 end 
                    val (rtype, s) =
                          case next s of
                            (L.COLON, s) =>
                               let val (rtype, s) = parse_tp s in (SOME rtype, s) end
                          | _ => (NONE, s)

                    val ftype = case (ftype, xtype, rtype) of
                                  (SOME (ftype as T.Arrow _), NONE, NONE) => ftype
                                | (NONE, SOME xtype, SOME rtype) => T.Arrow(xtype, rtype)
                                | (_, _, _) => raise Error "Need either \"fun f : t1 -> t2 x =\" or \"fun f (x : t1) : t2 =\""
                    val s = match L.EQUALS s
                    val (e, s) = parse_exp s
                in
                  (M.Val(M.Rec(f, ftype, M.Fn(x, e)), f), s)
                end
          | _ => raise Error "Expected VAL or FUN in declaration"
     end


  (* XXX necessary? *)
  and parse_factor_maybe s = case S.force s of
      S.Nil => NONE
    | S.Cons res => parse_factora res

  (* parse_exp_aux : (primop * exp) list -> stream -> (primop * exp) list * stream *)
  and parse_exp_aux acc s =
      let val relop =
          case next s of
              (L.EQUALS, s) => SOME (M.Equals, s)
            | (L.LESSTHAN, s) => SOME (M.LessThan, s)
            | _  => NONE
      in
          case relop of
              SOME (relop, s) => 
                  let val (e, s) = parse_exp' s
                  in
                      parse_exp_aux (acc @ [(relop, e)]) s
                  end
            | NONE => (acc, s)  (* No more exp-primes; return what we have so far. *)
      end

  and parse_exp es =
      let val (e, s) = parse_exp' es
          val (exp's, s) = parse_exp_aux [] s
          val exp = build_primops e exp's
      in
        case next s of
           (L.COLON, s) =>
              let val (t, s) = parse_tp s
              in
                (M.Anno(exp, t), s)
              end
         | _ => (exp, s)
      end

  (* parse_exp'_aux : (primop * exp) list -> stream -> (primop * exp) list * stream *)
  and parse_exp'_aux acc s =
      let val addop =
          case next s of
              (L.PLUS, s) => SOME (M.Plus, s)
            | (L.MINUS, s) => SOME (M.Minus, s)
            | _  => NONE
      in
          case addop of
              SOME (addop, s) => 
                  let val (e, s) = parse_term s
                  in
                      parse_exp'_aux (acc @ [(addop, e)]) s
                  end
            | NONE => (acc, s)  (* No more terms; return what we have so far *)
      end

  and parse_exp' es =
      let val (e, s) = parse_term es
          val (terms, s) = parse_exp'_aux [] s
      in
          (build_primops e terms, s)
      end

  (* parse_term_aux : (primop * exp) list -> stream -> (primop * exp) list * stream *)
  and parse_term_aux acc s =
      let val mulop =
          case next s of
              (L.TIMES, s) => SOME (M.Times, s)
            | _  => NONE
      in
          case mulop of
              SOME (mulop, s) => 
                  let val (e, s) = parse_factor s
                  in
                      parse_term_aux (acc @ [(mulop, e)]) s
                  end
            | NONE => (acc, s)  (* No more factors; return what we have so far. *)
      end

  and parse_term es =
      let val (e, s) = parse_factor es
          val (factors, s) = parse_term_aux [] s
      in
          (build_primops e factors, s)
      end

  and parse_var (L.VAR v, s) = (v, s)
    | parse_var _ = raise Error "Expected var"


  (* exported parsing function *)

  fun parse (s : L.token S.stream) : M.exp S.stream = 
      S.delay (fn () => parse' (S.force s))

  and parse' S.Nil = S.Nil
    | parse' (S.Cons r) = 
      let 
          val (e, s) = parse_program r
      in 
          S.Cons (e, parse s)
      end

end;  (* structure Parse *)
