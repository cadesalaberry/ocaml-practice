module Pascal = 
struct
  open Stream
    
(* ------------------------------------------------------- *)
(* Computing partial sums lazily over a stream of nats     *)

let rec psums s = (*raise TODO*)
  let rec buffered_psums s buff =
    { hd = s.hd + buff;
      tl = Susp(fun () -> (buffered_psums (force s.tl) (s.hd + buff)))
    }
  in
    buffered_psums s 0;;

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
let rec ones = {hd = 1 ; tl = Susp (fun () -> ones)} ;;(**)

let rec pascal = (*raise TODO*)
  let rec buffered_pascal buff =
  	{ hd = buff;
  	  tl = Susp(fun () -> buffered_pascal (psums buff))
  	}
  in
  	buffered_pascal ones (*Should replace ones by Stream.ones*)


let rec getNth n s = (*raise TODO*)
  match n with 
    | 0 -> s.hd
    | n -> getNth (n - 1) (force s.tl)


let rec row k (s: (int str) str) = (*raise TODO*)
  let rec row' k2 s2 buff =
  	match k2 with 
  	| 0 -> (s2.hd.hd)::buff
  	| _ -> row (k-1) (force s.tl) @ [getNth k s.hd]
  in
  	row' k s []  


let rec triangle (s : (int str) str) = (*raise TODO*)
  let rec buffered_triangle buff s =
    { hd = row buff;
      tl = Susp(fun () -> (buffered_triangle (buff + 1) s))
    }
  in
    buffered_triangle 0 s


(*----------------------------------------------------------------------------*)
(* To illustrate the result ... *) 
let rec map_tolist n f s = if n = 0 then  []
  else (f s.hd) :: map_tolist (n-1) f (force s.tl)

(*----------------------------------------------------------------------------*)

end;;
