type tp =
| Arrow of tp * tp
| Product of tp list
| Int
| Bool
| TVar of (tp option) ref
    
val eq : tp * tp -> bool

val toString : tp -> string
