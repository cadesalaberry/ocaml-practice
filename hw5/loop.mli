type action  = Minml.exp      -> unit

(* print the expression *)
val show         : action

val ast          : action

val freevars     : action

val unusedvars   : action

(* apply an action to a completely evaluated expression *)
val eval : action -> action

val smallstep : action -> action

(* typecheck *)
val check : action -> action

(* typecheck; if successful, evaluate *)
val usual : action -> action

(* wait after executing an action *)
val wait       : action -> action

(* run an action on user input expressions, without translating to deBruijn form *)
val loop       : string -> action -> unit
(* ... on a file *)
val loopFile   : string -> action -> unit
