(* interactive loop *)
val loop_print      : unit -> unit
val loop_ast        : unit -> unit
val loop_freevars   : unit -> unit
val loop_unusedvars : unit -> unit
val loop_type       : unit -> unit
val loop_eval       : unit -> unit
val loop_eval_smallstep : unit -> unit

val loop         : unit -> unit   (* typechecks, and if typing was successful, evaluates *)

(* read a MinML source file *)
val file_print      : string -> unit
val file_ast        : string -> unit
val file_freevars   : string -> unit
val file_unusedvars : string -> unit
val file_type       : string -> unit
val file_eval       : string -> unit
val file_eval_smallstep : string -> unit

val file       : string -> unit  (* typechecks, and if typing was successful, evaluates *)

val parse      : string -> Minml.exp
