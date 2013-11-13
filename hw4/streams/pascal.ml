module Pascal = 
struct
  open Stream
    
    
(* ------------------------------------------------------- *)
(* Computing partial sums lazily over a stream of nats     *)

let rec psums s = raise TODO


(*----------------------------------------------------------------------------*)
(* Pascal's triangle 

We want to produce a stream consisting of streams. 
The first element of the stream is (1 1 1 1 ...), i.e the stream of ones.
The i-th element of the stream is obtained by computing the partial sum
over the (i-1) element of the stream.

 (1 1  1  1 ...) ; 
 (1 2  3  4 ...) ; 
 (1 3  6 10 ...); 
 (1 4 10 20 35; 
 ...

The first element corresponds to the first diagonal in Pascal's triangle;
the second element to the second diagonal, etc.
 
*)
let rec pascal  = raise TODO


let rec getNth n s = raise TODO

let rec row k (s: (int str) str) = raise TODO
 
let rec triangle (s : (int str) str) = raise TODO


(*----------------------------------------------------------------------------*)
(* To illustrate the result ... *) 
let rec map_tolist n f s = if n = 0 then  []
  else (f s.hd) :: map_tolist (n-1) f (force s.tl)

(*----------------------------------------------------------------------------*)

end;;
