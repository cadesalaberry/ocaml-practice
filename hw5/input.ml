(* Ocaml version adapted from 
   original sml version by
   Chris Okasaki / Robert Harper
   School of Computer Science
   Carnegie Mellon University
   Pittsburgh, PA 15213
   cokasaki@cs.cmu.edu *)


let getchars file close =
  let rec get () : string  =
    try
      doline (input_line file)
    with End_of_file -> (close_in file; "")
  and doline cs = cs ^ "\n" ^ (get ())
  in get ()

let readfile filename =
  let file = open_in filename
  in
  getchars file (fun () -> close_in file)
    
let readkeybd () = getchars stdin (fun () -> ())

let promptkeybd prompt =
  let rec get () =
    (output_string stdout prompt);
     flush stdout;
     try
       let s = input_line stdin in
       try
         let i = String.index s ';' in
         String.sub s 0 (i + 1)
       with Not_found -> doline s
     with End_of_file -> ""
  and doline cs =  cs ^ "\n" ^ (get ())
  in 
  get ()    

