(* Task 3.1 *)

module MemoedFibo (D : DICT with type Key.t = int) : FIBO =
struct

  exception NotImplemented 
  exception NegativeNumber
  let rec fib n = (*raise NotImplemented*)

    let hist : 'a D.dict ref = ref D.empty
    and big_zero = Big_int.big_int_of_int 0
    and big_one  = Big_int.big_int_of_int 1
    and big_n_one = Big_int.big_int_of_int (n - 1)
    and big_n_two = Big_int.big_int_of_int (n - 2)

    in
    let rec smart_fib n = if Big_int.lt_big_int n big_zero then raise NegativeNumber
    else match n with
      | Some 0  -> big_zero 
      | Some 1  -> big_one
      | Some n  -> match (D.lookup !hist n) with
        | None -> let value = smart_fib n in
            (hist := (D.insert !hist (n,value));
            value)
        | Some number -> number

    in Big_int.add_big_int  (smart_fib big_n_one)  (smart_fib big_n_two)
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

  let rec memo f = (fun k -> (*raise NotImplemented*)
    match D.lookup k with
      | None -> let value = f k in
          (D.insert (k,value);
          value)
      | Some n -> n)

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



