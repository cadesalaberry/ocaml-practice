signature TYPE = sig
  datatype tp =
    Arrow of tp * tp
  | Product of tp list
  | Int
  | Bool

  val eq : tp * tp -> bool

  val toString : tp -> string
end

structure Type :> TYPE = struct

  datatype tp =
    Arrow of tp * tp
  | Product of tp list
  | Int
  | Bool

  open Lib

  fun eq (Arrow(domain1, range1), Arrow(domain2, range2)) =
            eq(domain1, domain2) andalso eq(range1, range2)
    | eq (Product ts1, Product ts2) =
            length ts1 = length ts2 andalso List.all eq (ListPair.zip (ts1, ts2))
    | eq (Int, Int) = true
    | eq (Bool, Bool) = true
    | eq (_, _) = false

  fun paren lvl oplvl string =
    if oplvl < lvl then "(" ^ string ^ ")"
    else string

  fun s lvl tp = case tp of
     Arrow(domain, range) => paren lvl 0 ((s 1 domain) ^ " -> " ^ s 0 range)
   | Product [] => "()"
   | Product tps => paren lvl 1 (separate " * " (s 2) tps)
   | Int => "int"
   | Bool => "bool"

  fun toString tp = s 0 tp
end
