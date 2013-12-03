open Top
open Lexing

let print_usage () =
  let _ = print_endline "Usage:" in
  let _ = print_endline "top.native" in
  let _ = print_endline "\tstarts the interactive mode" in
  let _ = print_endline "\ntop.native filename" in
  let _ = print_endline "\treads the file \'filename\' and performs typechecking then evaluation" in
  let _ = print_endline "\ntop.native action filename" in
  let _ = print_endline "\tperforms a specific action on the file \'filename\'. The possible actions are:" in
  let _ = print_endline "\t\ttype - Performs type checking of the provided file" in
  let _ = print_endline "\t\teval - Performs bigstep evaluation of the provided file" in
  let _ = print_endline "\t\tsmallstep - Performs smallstep evaluation of the provided file" in
  let _ = print_endline "\t\tprint - Simply pretty prints the expression from the file" in
  let _ = print_endline "\t\tunusedvars - Returns the unused variables in an expression" in
  let _ = print_endline "\t\tfreevars - Returns the free variables in an expression" in
  ()

let print_help () =
  let _ = print_endline "\ttype - Type checking expressions" in
  let _ = print_endline "\teval - Performing bigstep evaluation of expressions" in
  let _ = print_endline "\tsmallstep - Performing smallstep evaluation of expressions" in
  let _ = print_endline "\tprint - pretty printing expressions" in
  let _ = print_endline "\tusual - type checking then performing bigstep evaluation of expressions" in
  let _ = print_endline "\thelp - printing this help message" in
  let _ = print_endline "\t\tunusedvars - Returns the unused variables in an expression" in
  let _ = print_endline "\t\tfreevars - Returns the free variables in an expression" in
  ()

let () =
  let argslength = Array.length Sys.argv in
    match argslength with
    | 1 -> (try
             let rec command () =
               let _ = output_string stdout "MiniML - Selecting command> " in
               let _ = flush stdout in
               match input_line stdin with
               | "help" -> let _ = print_help () in
                           command ()
               | "freevars" -> 
                 (try 
                    let rec f () = let _ = loop_freevars () in f ()
                    in f ()
                  with End_of_file -> 
                    let _ = print_endline "" in command ())
               | "unusedvars" -> 
                 (try 
                    let rec f () = let _ = loop_unusedvars () in f ()
                    in f ()
                  with End_of_file -> 
                    let _ = print_endline "" in command ())
               | "ast" -> 
                 (try 
                    let rec f () = let _ = loop_ast () in f ()
                    in f ()
                  with End_of_file -> 
                    let _ = print_endline "" in command ())

               | "type" -> 
                 (try 
                    let rec f () = let _ = loop_type () in f ()
                    in f ()
                  with End_of_file -> 
                    let _ = print_endline "" in command ())
               | "eval" -> 
                 (try 
                    let rec f () = let _ = loop_eval () in f ()
                    in f ()
                  with End_of_file -> 
                    let _ = print_endline "" in command ())
               | "smallstep" -> 
                 (try 
                    let rec f () = let _ = loop_eval_smallstep () in f ()
                    in f ()
                  with End_of_file -> 
                    let _ = print_endline "" in command ())
               | "print" -> 
                 (try 
                    let rec f () = let _ = loop_print () in f ()
                    in f ()
                  with End_of_file -> 
                    let _ = print_endline "" in command ())
               | "usual" ->
                 (try
                    let rec f () = let _ = loop () in f ()
                    in f ()
                  with End_of_file ->
                    let _ = print_endline "" in command ())
               | _ -> let _ = print_endline "This command is not valid" in
                      let _ = print_help () in
                      command ()
             in command ()
      with End_of_file -> print_endline "")

    | 2 -> 
      let filename = Sys.argv.(1) in file filename

    | 3 -> let filename = Sys.argv.(2) in
           (match Sys.argv.(1) with
             | "type"        -> file_type           filename
             | "eval"        -> file_eval           filename
             | "smallstep"   -> file_eval_smallstep filename
             | "print"       -> file_print          filename
             | "usual"       -> file                filename
             | "ast"         -> file_ast            filename
             | "freevars"    -> file_freevars       filename
             | "unusedvars"  -> file_unusedvars     filename
             | _             -> print_usage         ())

    | _ -> print_usage ()
