#use "sources.ml";;

let number = 50;;

let time f x =
    let t = Sys.time() in
    let fx = f x in
    Printf.printf "Execution time: %fs\n" (Sys.time() -. t);
    fx
;;

print_string "Fibonacci of 69\t: ";;
print_string (Big_int.string_of_big_int  (MF.fib number));;
print_string "\t";;
time MF.fib number;;
print_string "\n";;

print_string "PoorImplemented\t: ";;
print_string (Big_int.string_of_big_int (PMF.fib number));;
print_string "\t";;
time PMF.fib number;;
print_string "\n";;

print_string "Automemoed fibo\t: ";;
print_string (Big_int.string_of_big_int (AMF.fib number));;
print_string "\t";;
time AMF.fib number;;
print_string "\n";;