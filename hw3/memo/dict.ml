module type DICT =
sig
  module Key : ORDERED 
  type 'a dict 
  val empty : 'a dict
  val insert : 'a dict -> Key.t * 'a -> 'a dict
  val lookup : 'a dict -> Key.t -> 'a option
  val remove : 'a dict -> Key.t -> 'a dict 
end;;


module Dict (K : ORDERED) : (DICT with type Key.t = K.t) =
struct
  module Key  = K  

  type 'a dict = 
    | Empty 
    | Node of 'a dict * (Key.t * 'a) * 'a dict

  let empty = Empty


  let rec insert t (k,v) = match t with 
    | Empty -> Node(Empty, (k, v), Empty)
    | Node(l, (k',v'), r) -> 
      if Key.lt(k,k') then 
	Node(insert l (k, v), (k',v'), r)
      else 	
	(if Key.eq(k', k) then 
	  (* overshadow earlier entries *)
	  Node(l, (k,v), r)
	else 
	  Node(l, (k',v'), insert r (k,v)))


  let rec lookup t k = match t with 
    | Empty -> None
    | Node(l, (k',v), r) -> 
      if Key.eq(k, k') then Some v
      else
	  (if Key.lt(k, k') then lookup l k  else lookup r k)

  let rec rightmost t = match t with
    | Empty -> None
    | Node (l, (k, v), r) -> match rightmost r with
        | None -> Some ((k, v), l)
        | Some (p, r') -> Some (p, Node (l, (k, v), r'))


  let rec remove t (k:Key.t) = match t with 
    | Empty -> Empty
    | Node (l, (k',v'), r) -> match Key.compare k k' with
	| Key.Equal -> (match rightmost l with
     	            | None -> r
		    | Some ((kr,vr) , l') -> Node (l', (kr, vr), r))
	| Key.Less -> Node (remove l k, (k',v'), r)
	| Key.Greater -> Node (l, (k',v'), remove r k) 
end;;


module ID = Dict(IntLt) 
module BigIntDict = Dict(BigInt) 
