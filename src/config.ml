(*pp $PP *)
open Printf

let set k v =
  Sys.command ("mkdir -p " ^ (Sys.getenv "HOME") ^ "/.config/jark");
  let file = (Sys.getenv "HOME") ^ "/.config/jark/" ^ k in
  let f = open_out file in 
  fprintf f "%s\n" v; 
  close_out f

let get k =
  let file = (Sys.getenv "HOME") ^ "/.config/jark/" ^ k in
  let f = open_in file in
  try 
    let line = input_line f in 
    close_in f;
    line
  with e -> 
    close_in_noerr f; 
    raise e 
