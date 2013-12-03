type name = Minml.name
type env
type obj =
| Exp of Minml.exp
| Closure of Minml.exp * env

val empty : env

val lookup : env -> name -> obj

val extend : env -> name * obj -> env

val extend_list : env -> (name * obj) list -> env

val extend_rec : env -> name * obj -> env

val toString : env -> string

exception NotFound
