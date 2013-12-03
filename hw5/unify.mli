exception Error of string
 
val freshVar : unit -> Type.tp

(* unify (T1, T2) = () if there exists some substitution s
   for the free type variables in T1 and T2 s.t.
   [s]T1 = [s]T2 
*)
val unify : Type.tp -> Type.tp -> unit
