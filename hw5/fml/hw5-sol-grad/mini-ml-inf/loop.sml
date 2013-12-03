signature LOOP =
sig

  type action = MinML.exp -> unit

  (* print the expression *)
  val show         : action

  (* ... with its type *)
  val showType     : action

  (* apply an action to a completely evaluated expression *)
  val eval : action -> action 
  
  (* typecheck *)
  val check : action -> action 

  (* typecheck; if successful, evaluate *)
  val usual : action -> action

 (* wait after executing an action *)
  val wait       : action -> action

  (* run an action on user input expressions, without translating to deBruijn form *)
  val loop       : action -> unit
  (* ... on a file *)
  val loopFile   : string -> action -> unit

end

structure Loop :> LOOP =
struct

  type action = MinML.exp -> unit

  fun typing e =
      let val t =  Typing.typeOf e in 
	  " : " ^ Print.typToString t end
      handle Typing.Error s => (" has no type.\n ERROR: " ^ s)

  (* A few actions *)

  fun show e =
      List.app print [Print.expToString e, ";\n"]

  fun showType e =
      List.app print [Print.expToString e, typing e, "\n"]

  fun check action e = action
    (let val t = (Typecheck.synth Typecheck.empty e)
     in
       print ("type: " ^ Type.toString t ^ "\n");
       e
     end handle exn as Typecheck.TypeError message =>
                         (print ("Type error: " ^ message ^ "*\n"); e))

  fun eval action e = action (Eval.eval e)
  
  fun usual action e = action
    (let val t = (Typecheck.synth Typecheck.empty e)
     in
       print ("type: " ^ Type.toString t ^ "\n");
       Eval.eval e
     end handle exn as Typecheck.TypeError message =>
                         (print ("Type error: " ^ message ^ "\n"); e))

  fun wait action e =
      (action e;
       print "Press return:";
       TextIO.inputLine TextIO.stdIn;
       ())

  (* Running the actions on an interactive loop or a file *)

  fun loop action =
         Stream.app action
         (Parse.parse (Lexer.lex (Input.promptkeybd "MinML> ")))

  fun loopFile name action =
         Stream.app action
         (Parse.parse (Lexer.lex (Input.readfile name)))

end
