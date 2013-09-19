(*DATA TYPES
*)
(* 1. Non recursive data types:

	- finite collection of elements.
	- Types need to be capitalised.
	- Order in initialisation does not matter.
*)
(* 2 Terminology:
	
	Clubs inabits (is of) type suit

*)

type suit = Clubs | Spades | Hearts | Diamonds

(* We want to define S > H > D > C *)

let rec dom (s1, s2) = match (s1, s2) with
	| (Spades	,	_		)	-> true
	| (Hearts	,	Diamonds)	-> true
	| (Hearts	,	Clubs	)	-> true
	| (Diamonds	,	Clubs	)	-> true
	| (s1		,	s2		)	-> s1 = s2

type rank = Two | Three | Four | Five | Six | Seven | Eight | Nine | Ten | Jack | Queen | King | Ace

type card = rank * suit

type hand = Empty | hand of card * hand

let rec count h = match h with
	| Empty -> 0
	| Hand (_ * h) -> 1 + count h