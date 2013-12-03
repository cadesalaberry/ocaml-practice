type context  (* Context of typing assumptions; example: x : int, p : bool *)
val empty : context
  
val infer : context -> Minml.exp -> Type.tp

exception TypeError of string
