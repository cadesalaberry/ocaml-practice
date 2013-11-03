#use "sources.ml";;

let number = 30;;




print_string "Fibonacci of 69\t: ";;
print_string (Big_int.string_of_big_int  (MF.fib number));;
print_string "\n";;

print_string "PoorImplemented\t: ";;
print_string (Big_int.string_of_big_int (PMF.fib number));;
print_string "\n";;

print_string "Automemoed fibo\t: ";;
print_string (Big_int.string_of_big_int (AMF.fib number));;
print_string "\n";;


module AutoMemoedPrintFibo : FIBO =
struct
module IntMemo = Memoize (ID) 

let rec fib (f:IntMemo.key -> Big_int.big_int) (n:IntMemo.key) = match n with    
| 0  -> print_int 0; print_string " "; Big_int.big_int_of_int 0 
| 1  -> print_int 1; print_string " "; Big_int.big_int_of_int 1
| n  -> print_int n; print_string "-"; Big_int.add_big_int  (f (n - 1))  (f (n - 2))

let fib = IntMemo.memo fib;;
end
module AMPF = (AutoMemoedPrintFibo : FIBO);;

print_string "Automemoed prnt\t: ";;
print_string (Big_int.string_of_big_int (AMPF.fib number));;
print_string "\n";;
