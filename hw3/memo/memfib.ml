(* Task 3.1 *)

module MemoedFibo (D : DICT with type Key.t = int) : FIBO =
struct

  exception NotImplemented 

  let rec fib n =

    let hist : 'a BigIntDict.dict ref = ref BigIntDict.empty
    and big n = Big_int.big_int_of_int n
    
    in
      hist := BigIntDict.insert (!hist) (big 0, big 0);
      hist := BigIntDict.insert (!hist) (big 1, big 1);

      let rec smart_fib n = match (BigIntDict.lookup (!hist) (big n)) with
        | None -> (let value = (Big_int.add_big_int (smart_fib (n - 1)) (smart_fib (n - 2)))
          in
            hist := BigIntDict.insert (!hist) (big n, value);
            value)
        | Some v -> v
    in
      smart_fib n
end

module MF = MemoedFibo (ID)

(* Task 3.3 *)
module type MEMOIZER =
sig
  (* used to store the mapping *)
  type key 

  (* given a function, returns a  memoized version of that function. *)
  val memo : ((key -> 'a) -> (key -> 'a)) -> (key -> 'a)
end

module Memoize (D: DICT) : (MEMOIZER with type key = D.Key.t) =
struct

  type key = D.Key.t

  exception NotImplemented 

  let rec memo f = (fun k -> raise NotImplemented)
  end


module AutoMemoedFibo : FIBO =
struct

  module IntMemo = Memoize (ID) 

  let rec fib (f:IntMemo.key -> Big_int.big_int) (n:IntMemo.key) = match n with    
    | 0  -> Big_int.big_int_of_int 0 
    | 1  -> Big_int.big_int_of_int 1
    | n  -> Big_int.add_big_int  (f (n - 1))  (f (n - 2))

  let fib = IntMemo.memo fib
end

module AMF = (AutoMemoedFibo : FIBO)



