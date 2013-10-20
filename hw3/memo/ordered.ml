(* Defining a signature *)
module type ORDERED =
  sig
    type t  (* making the type abstract *)
    type comparison = Less | Equal | Greater

    val compare : t -> t -> comparison
    val lt : t * t -> bool
    val eq : t * t -> bool
  end

(* The signature above will be augmented with
   the specific specialization for type t *)


module  CharLt =
  struct
    type t = char
    type comparison = Less | Equal | Greater

    let lt (s,t) = s < t
    let eq(s,t) = (s = t)

    let compare s t = 
      if eq (s,t) then Equal 
      else if lt (s,t) then Less
      else Greater
  end

module StringLt =
  struct
    type t = string
    type comparison = Less | Equal | Greater

    let lt(s,t) = String.length(s) < String.length(t)
    let eq(s,t) = String.length(s) = String.length(t)

    let compare s t = 
      if eq (s,t) then Equal 
      else if lt (s,t) then Less
      else Greater
  end

module IntLt = 
  struct
    type t = int
    type comparison = Less | Equal | Greater

    let lt(s,t) = s < t
    let eq(s,t) = (s = t)

    let compare s t = 
      if eq (s,t) then Equal 
      else if lt (s,t) then Less
      else Greater
  end


module IntMod50 =
  struct
    type t = int
    type comparison = Less | Equal | Greater

    let lt(m,n) = (m mod 50) < (n mod 50) 
    let eq(m,n) = (m mod 50) = (n mod 50) 
    let compare s t = 
      if eq (s,t) then Equal 
      else if lt (s,t) then Less
      else Greater

  end


module BigInt =
  struct
    type t = Big_int.big_int
    type comparison = Less | Equal | Greater

    let lt(m,n) =  Big_int.lt_big_int m n
    let eq(m,n) = Big_int.eq_big_int m n
    let compare s t = 
      if eq (s,t) then Equal 
      else if lt (s,t) then Less
      else Greater

  end
