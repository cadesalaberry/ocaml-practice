#use "sources.ml";;

print_string "Fibonacci of 69\t: ";;
print_string (Big_int.string_of_big_int (MF.fib 69));;
print_string "\n";;

print_string "Automemoed fibo\t: ";;
print_string (Big_int.string_of_big_int (AMF.fib 69));;
print_string "\n";;