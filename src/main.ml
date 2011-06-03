(*pp $PP *)

include Nrepl_frontend
include Usage

let _ =
  match (List.tl (Array.to_list Sys.argv)) with
    "vm" :: []      -> pe vm_usage
  | "vm" :: xs      -> Nrepl.vm (car xs) ~arg:(cdr xs) ()
  | "cp" :: []      -> pe cp_usage
  | "cp" :: xs      -> Nrepl.cp (car xs) ~arg:(cdr xs) ()
  | "ns" :: []      -> pe ns_usage
  | "ns" :: xs      -> Nrepl.ns (car xs) ~arg:(cdr xs) ()
  | "package" :: [] -> pe package_usage
  | "package" :: xs -> pe (Nrepl.package (car xs) ~arg:(cdr xs) ())
  | "swank" :: []   -> pe swank_usage
  | "swank" :: xs   -> Nrepl.swank (car xs) ~arg:(cdr xs) ()
  | "repo" :: []    -> pe repo_usage
  (* | "repl" :: []    -> run_repl ~show:1 () *)
  | "version" :: [] -> pe Nrepl.version
  | "--version" :: [] -> pe Nrepl.version
  | "-v" :: []      -> pe Nrepl.version
  | "-e" :: xs      ->  Nrepl.eval_exp (car xs) ~run:1 ()
  | "install" :: [] -> pe Nrepl.install
  |  _              -> pe usage; 
 
