(*pp $PP *)

include Usage
include Commands
open ExtList
open OptParse

let _ =
  match (List.tl (Array.to_list Sys.argv)) with
    "vm" :: []      -> pe vm_usage
  | "vm" :: xs      -> vm (List.first xs) ~arg:(List.tl xs) ()
  | "cp" :: []      -> pe cp_usage
  | "cp" :: xs      -> cp (List.first xs) ~arg:(List.tl xs) ()
  | "ns" :: []      -> pe ns_usage
  | "ns" :: xs      -> ns (List.first xs) ~arg:(List.tl xs) ()
  | "package" :: [] -> pe package_usage
  | "package" :: xs -> pe (package (List.first xs) ~arg:(List.tl xs) ())
  | "swank" :: []   -> pe swank_usage
  | "swank" :: xs   -> swank (List.first xs) ~arg:(List.tl xs) ()
  | "repo" :: []    -> pe repo_usage
  (* | "repl" :: []    -> run_repl ~show:1 () *)
  | "version" :: [] -> pe version
  | "--version" :: [] -> pe version
  | "-v" :: []      -> pe version
  | "-e" :: xs      ->  Nrepl.eval_exp (List.first xs) ~run:1 ()
  | "install" :: [] -> install ~run:1 ()
  |  _              -> pe usage; 
 
