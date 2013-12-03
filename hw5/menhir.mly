%{
open Minml
(* Parser generated via menhir.*)
%}

%start <Minml.exp> parse
%start <Minml.exp list> parse_exps

%token <string>VAR
%token <int>NUM
%token SEMICOLON LPAREN RPAREN COMMA DARROW ARROW EQUAL LESSTHAN COLON
%token PLUS MINUS TIMES NEGATE
%token BOOL INT TRUE FALSE FN FUN IF THEN ELSE LET IN END NAME VAL
%token EOF

%nonassoc COLON
%right ELSE

%right ARROW DARROW
%left EQUAL LESSTHAN
%left PLUS MINUS
%left TIMES
%left NEGATE

%%

parse_exps:
| s = exps EOF {s}

exps:
| s = exp_semi+ {s}


parse:
| EOF {raise End_of_file}
| s = exp_semi EOF {s}

exp_semi:
| s = exp SEMICOLON {s}

exp:
| es = simpleexp+
    {List.fold_left (fun x y -> Apply (x, y)) (List.hd es) (List.tl es)}
| IF s = exp THEN s1 = exp ELSE s2 = exp {If (s,s1,s2)}
| s1 = exp EQUAL s2 = exp {Primop (Equals, [s1;s2])}
| s1 = exp LESSTHAN s2 = exp {Primop (LessThan, [s1; s2])}
| s1 = exp PLUS s2 = exp {Primop (Plus, [s1; s2])}
| s1 = exp MINUS s2 = exp {Primop (Minus, [s1; s2])}
| s1 = exp TIMES s2 = exp {Primop (Times, [s1;s2])}
| NEGATE s = exp {Primop (Negate, [s])}
| FN x = VAR COLON t = tp DARROW s = exp {Fn (x, Some t, s)}
| FN x = VAR DARROW s = exp {Fn (x, None, s)}
| LET d = decs IN s = exp END {Let (d, s)}
| s = exp COLON t = tp {Anno (s,t)}

simpleexp:
| s = NUM {Int s}
| TRUE {Bool true}
| FALSE {Bool false}
| s = VAR {Var s}
| LPAREN s = exp RPAREN {s}
| LPAREN t = tuple RPAREN {Tuple t}

args:
| {[]}
| x = VAR a = args {(x, None) :: a}
| LPAREN x = VAR COLON t = tp RPAREN a = args {(x, Some t) :: a} 

decs:
| {[]}
| d = dec; ds = decs {d :: ds}

dec:
| VAL x = VAR EQUAL s = exp {Val (s,x)}
| VAL LPAREN t = tuplename RPAREN EQUAL s = exp {Valtuple (s, t)}
| NAME x = VAR EQUAL s = exp {ByName (s, x)}
| FUN x = VAR; a1 = args COLON t = tp EQUAL e = exp 
    {let g (n, o) ts = match o with
      | Some t -> Type.Arrow (t, ts)
      | None -> Type.Arrow (Type.TVar (ref None), ts)
     in
     let f1 = List.fold_right g a1 t in
     let f2 = List.fold_right (fun (n, t) e -> Fn (n, t, e)) a1 e in
     Val (Rec (x, Some f1, f2), x)}
| FUN x = VAR; a1 = args EQUAL e = exp
    {let g (n, o) ts = match o with
      | Some t -> Type.Arrow (t, ts)
      | None -> Type.Arrow (Type.TVar (ref None), ts)
     in
     let f1 = List.fold_right g a1 (Type.TVar (ref None)) in
     let f2 = List.fold_right (fun (n, t) e -> Fn (n, t, e)) a1 e in
     Val (Rec (x, Some f1, f2), x)}

tp:
| t1 = tp ARROW t2 = tp {Type.Arrow(t1, t2)}
| t1 = tp TIMES t2 = tp
    {match t2 with
    | Type.Product l -> Type.Product (t1::l)
    | _ -> Type.Product [t1;t2]}
| BOOL {Type.Bool}
| INT  {Type.Int}
| LPAREN t = tp RPAREN {t}


tuple:
| {[]}
| s = exp COMMA t = netuple {s :: t}

netuple:
| s = exp {[s]}
| s = exp COMMA t = netuple {s :: t}

tuplename:
| {[]}
| x = VAR COMMA t = netuplename {x::t}

netuplename:
| x = VAR {[x]}
| x = VAR COMMA t = netuplename {x :: t}

