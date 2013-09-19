exception NotImplemented

(* ------------------------------------------------------------*)
(* HELPER FUNCTIONS                                            *)
(* ------------------------------------------------------------*)
(* Q2.1: Summation                                             *)
(* ------------------------------------------------------------*)
(* summation float list -> float
  The function takes a list of floats and returns
  their summation.
*)
let rec summation l = match l with
  |[] -> 0.0
  |(h::tail) -> h +. (summation tail);;


(* ------------------------------------------------------------*)
(* QUESTION 2 : WARM-UP                                        *)
(* ------------------------------------------------------------*)
(* Q2.1: Average                                               *)
(* ------------------------------------------------------------*)
(* average: float list -> float

 The function takes a list of integers and returns
 their average as a floating point number
*)
let rec average l = (summation l) /. (float_of_int (List.length l));;

print_string "average [1.0 ;2.5 ;3.0 ;7.1] : ";;
print_float (average [1.0;2.5;3.0;7.1]);;
print_string "\n";;
print_string "average [13.0; 25.2; 2.2; 27.4] : ";;
print_float (average [13.0; 25.2; 2.2; 27.4]);;
print_string "\n";;


(* ------------------------------------------------------------*)
(* HELPER FUNCTIONS                                            *)
(* ------------------------------------------------------------*)
(* Q2.2: Differences and Squares                               *)
(* ------------------------------------------------------------*)
(* getDifferencesWithAvg float list -> float list
  For each value x_i calculates the difference between x_i
  and the average value of the list.
*)
let rec getDifferencesWithAvg l =
  let rec difference (l, avg) = 
    match l with
      |[] -> []
      |(h::tail) -> (h -. avg) :: (difference (tail,avg))
    in
      difference(l, (average l));;

let square x = x *. x 

let squareTheList l = List.map square l;;

(* -------------------------------------------------------------*)
(* Q2.2:  Standard Deviation                                    *) 
(* -------------------------------------------------------------*)

(* stDev: int list -> real 

 The function takes a list of integers and returns their
 the standard deviation as a real number
*)

let rec stDev l = sqrt (average (squareTheList (getDifferencesWithAvg l)));;

print_string "stDev [1.0; 5.0; 2.0; 7.0] : ";;
print_float (stDev [1.0; 5.0; 2.0; 7.0]);;
print_string "\n";;
print_string "stDev [13.2; 25.0; 22.3; 27.8] : ";;
print_float (stDev [13.2; 25.0; 22.3; 27.8]);;
print_string "\n";;

(* ------------------------------------------------------------*)
(* QUESTION 3                                                  *)
(* ------------------------------------------------------------*)

(* Partial sums :

   Given a list of integers, compute the partial sums 
   i.e. the sums of all the prefixes

   psum: int list -> int list

*)

let rec psum l = match l with
  |[] -> []
  |[h] -> [h]
  |(h1::h2::tail) -> h1 :: (psum ((h1 + h2)::tail));;

(* Some test cases 
# psum [1;1;1;1;1];;
- : int list = [1; 2; 3; 4; 5]

# psum [1;2;3;4];;
- : int list = [1; 3; 6; 10]

# psum [];;
- : int list = []

# psum [9];
- : int list = [9]

*)

print_string "psum [1;1;1;1;1];; : ";;
print_string (String.concat " " (List.map string_of_int (psum [1;1;1;1;1])));;
print_string "\n";;
print_string "psum [1;2;3;4] : ";;
print_string (String.concat " " (List.map string_of_int (psum [1;2;3;4])));;
print_string "\n";;

(* ------------------------------------------------------------*)
(* QUESTION 4 : Mobile                                         *) 
(* ------------------------------------------------------------*)

type mobile = Obj of int | Wire of mobile * mobile

(* A object is represented by its weight (= an integer) and a wire
 is represented by the two mobiles attached to its ends 

*)

(* ------------------------------------------------------------*)
(* Q4.1: Weight                                                *)
(* ------------------------------------------------------------*)
(* val weight: mobile -> int
       weight(m) = total weight of the mobile m *)

let rec weight m = match m with
  |Obj node -> node
  |Wire(left, right) -> (weight left) + (weight right);;

let mobileB = Wire(Obj 8, Wire(Wire(Obj 2, Obj 2), Obj 4));;

print_string "weight mobileB : ";;
print_int (weight mobileB);;
print_string "\n";;


(* ------------------------------------------------------------*)
(* Q4.2: Balance                                               *)
(* ------------------------------------------------------------*)
(* val balanced : mobile -> bool 
   balanced (m) ==> true, if weight of m's left end = weight of m's
                          right end; and each of the sub-parts are also 
			  balanced.
                   false otherwise

  Note: it is not simply enough to check that two
  children have the same weight == it still could mean
  that a sub-tree is unbalanced.

*)
let rec balanced m = match m with
  |Obj node -> true
  |Wire(left, right) ->
       (balanced left)
    && (balanced right)
    && (weight left = weight right);;

print_string "is mobileB balanced ? ";;
(*print_bool (balanced mobileB);;*)
print_string "\n";;

(* ------------------------------------------------------------*)
(* Q4.3: Reflection                                            *)
(* ------------------------------------------------------------*)
(* We can reflect a mobile about its verical axis: for an
 object, the reflection is just itself; for a wire, we swap the
 positions of the two mobiles hanging off its end. Reflection
 is applied recursively on the subparts. *)

(*   val reflect: mobile -> mobile 
   reflect(m) => a mobile that is the complete reflection of m
*)

let rec reflect m = match m with
  |Obj node -> Obj node
  |Wire(left, right) -> (Wire (reflect right, reflect left));;


(* ------------------------------------------------------------*)
(* Q4.4 Weight of the Mobile                                   *)
(* ------------------------------------------------------------*)
(* We modify the representation of the mobile slightly and keep the
 weight information at the wire. The weight at the wire is the sum of
 the weight of each mobiles attached to it. 
*)
 
type rmobile = RObj of int | RWire of rmobile * int * rmobile

(* val rweight: rmobile -> int 
  constant time function which computes the total weight of an rmobile
  *)
let rec rweight m = match m with
  |RObj node -> node
  |RWire(_, node, _) -> node;;

(* ------------------------------------------------------------*)
(* QUESTION 5                                                  *)
(* ------------------------------------------------------------*)

(* Binary numbers *)
type bnum = E | Zero of bnum | One of bnum

(* Binary numbers are represented in REVERSE ORDER

   for example : 

    110 =  zero (one (one e)) =  6                 (no leading zero)
   0110 =  zero (one (one (zero e))) = 6           (one leading zero)
  00110 =  zero (zero (one (one (zero e)))) = 6    (two leading zero)
   0101 =  one (zero (one (zero e))) = 5           (no leading zero)

*)

(* ------------------------------------------------------------*)
(* QUESTION 5.1                                                *)
(* ------------------------------------------------------------*)

(* Write a function which converts an integer n (n >= 0)
   into a binary number with no leading zeros.
   
   intToBin : int -> bnum *)

let rec intToBin b = match b with
  |0 -> (Zero E)
  |1 -> (One E)
  |nbr -> if (nbr mod 2 = 0)
    then (Zero(intToBin (nbr/2)))
    else (One(intToBin (nbr/2)));;

(* Some test cases

   - intToBin(5);
   val it = one (zero (one e)) : bnum

   - intToBin(6);
   val it = zero (one (one e)) : bnum

   - intToBin(8);
   val it = zero (zero (zero (one e))) : bnum

   - intToBin(7);
   val it = one (one (one e)) : bnum
  
*)

(* ------------------------------------------------------------*)
(* QUESTION 5.2                                                *)
(* ------------------------------------------------------------*)

(* Write a function which converts a binary number possibly with
   leading zeros into an integer n where n >= 0.

   binToInt : bnum -> int *)

let rec binToInt (b) = match b with
  |(E)       -> 0
  |(Zero E)  -> 0
  |(One E)   -> 1
  |Zero(nbr) -> 2 * (binToInt nbr)
  |One(nbr)  -> 2 * (binToInt nbr) + 1;;

(* Some test cases :


# binToInt (One (Zero (One (Zero E))));;
- : int = 5
# binToInt (One (Zero (One (Zero (Zero E)))));;
- : int = 5
# binToInt (Zero (One (One E)));;
- : int = 6
# binToInt (Zero (One (One (Zero E))));;
- : int = 6
#  
*)

print_string "binToInt (One (Zero (One (Zero E)))) : ";;
print_int (binToInt (One (Zero (One (Zero E)))));;
print_string "\n";
print_string "binToInt (One (Zero (One (Zero (Zero E))))) : ";;
print_int (binToInt (One (Zero (One (Zero (Zero E))))));;
print_string "\n";

