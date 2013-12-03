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

module Float : METRIC =
struct
  type t = float
  let unit = 1.0
  let plus a b = a +. b
  let prod a b = a *. b
  let toString a = string_of_float a
  let toFloat a = a
  let fromFloat a = a

end;;

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

module Speed (M : METRIC) : (SPEED with type distance = M.t) =
struct
  type s = float
  type distance = M.t

  let speed dist time = (M.toFloat dist) /. (Hour.toFloat time)

  let average l =
    let rec sum l = match l with
      | [] -> 0.
      | h::tail -> h +. sum tail
    in
      match (List.length l > 0) with
      | true -> (sum l) /. (float_of_int (List.length l))
      | 0.
end;;

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.3 *)
(* Show how to use the functor Speed to obtain an implementations
   for computing miles per hour in the module MilesPerHour and
   and implementation computing kilometers per hour in the module
   KMPerHour
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

module Miles = (Float : METRIC)
module MilesPerHour = Speed (Miles)
let dista_1 = Miles.fromFloat 5.0
let hours_1 = Hour.fromFloat 0.5
let speed_1 = MilesPerHour.speed dista_1 hours_2


module KM = (Float : METRIC)
module KMPerHour = Speed (KM)
let dista_2 = KM.fromFloat 10.0
let hours_2 = Hour.fromFloat 0.25
let speed_2 = KMPerHour.speed dista_2 hours_2

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

module Feet = (Float : METRIC)
module Meter = (Float : METRIC)
module Celsius = (Float : METRIC)
module Fahrenheit = (Float : METRIC)

module type CONVERSION =
sig
  val miles2KM : Miles.t -> KM.t
  val feet2meter : Feet.t -> Meter.t
  val fahrenheit2celsius : Fahrenheit.t -> Celsius.t
  val milesPerHour2KMPerHour : MilesPerHour.s -> KMPerHour.s
end;;

module Conversion : CONVERSION =
struct
  let miles2KM dist = KM.fromFloat ((Miles.toFloat dist) *. 1.60934)

  let feet2meter dist = Meter.fromFloat ((Feet.toFloat dist) *. 0.3048)

  let fahrenheit2celsius temp = Celsius.fromFloat (((Fahrenheit.toFloat temp) -. 32.) /. 1.8)

  let milesPerHour2KMPerHour speed = KMPerHour.fromFloat ((MilesPerHour.toFloat speed) *. 1.60934)
end;;
