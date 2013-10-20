(* Using modules for working with different metrics *)

module type METRIC = 
sig 
  type t 
  val unit : t 
  val plus : t -> t -> t 
  val prod : t -> t -> t 
  val toString : t -> string
  val toFloat  : t -> float
  val fromFloat : float -> t
end;;

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.1 *)
(* Define a module Float which provides an implementation of 
   the signature METRIC; 

   We then want use the module Float to create different representations
   for Meter, KM, Feet, Miles, Celsius, and Fahrenheit, Hour 
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)



(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.2 *)
(* Define a functor Speed which implements the module type SPEED. We 
   want to be able to compute the speed km per hour as well as 
   miles per hour. 

   The functor Speed must therefore be parameterized.
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

module type SPEED = 
sig
  type s
  type distance 
  val speed :  distance -> Hour.t -> s 
  val average : s list -> s 
end;;



(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.3 *)
(* Show how to use the functor Speed to obtain an implementations
   for computing miles per hour in the module MilesPerHour and
   and implementation computing kilometers per hour in the module
   KMPerHour
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)


(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.4 *)
(* It is useful to convert between different metrics.

   Define a module type CONVERSION which specifies the following
   conversion functions:
   - feet2meter          meter = feet * 0.3048
   - fahrenheit2celsius  celsius = (fahrenheit - 32) / 1.8
   - miles2KM            km = miles * 1.60934
   - MilesPerHour2KMPerHour 

   Then implement a module which provides these conversion functions.
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

