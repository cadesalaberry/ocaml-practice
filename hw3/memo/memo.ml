module type POORMEMOIZER =
sig
  (* used to store the mapping *)
  type key

  (* given a function, returns a poorly memoized version of that function *)
  val memo :  (key -> 'a) -> (key -> 'a)
end;;


module PoorMemoizer (D:DICT) : (POORMEMOIZER with type key = D.Key.t) =
struct

  type key = D.Key.t

  let memo f =
    let hist : 'a D.dict ref = ref D.empty in 
    let rec f_memoed x = match  D.lookup (!hist) x with
      | Some b -> b
      | None ->
          let res = f x in 
	    (hist := D.insert (!hist) (x,res);
             res)
      in
        f_memoed

end;;

module PoorAutoMemoFibo : FIBO =
struct
  module PM = PoorMemoizer (ID)
  let fib = PM.memo Fibo.fib
end


module PMF = PoorAutoMemoFibo
