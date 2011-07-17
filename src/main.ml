(*pp $PP *)

include Usage
open ExtList
open OptParse
open Nrepl
open Jark

let _ =
  match (List.tl (Array.to_list Sys.argv)) with
    "vm" :: []      -> pe vm_usage
  | "vm" :: xs      -> Jark.vm (List.first xs) (List.tl xs)
  | "cp" :: []      -> pe cp_usage
  | "cp" :: xs      -> Jark.cp (List.first xs) (List.tl xs)
  | "ns" :: []      -> pe ns_usage
  | "ns" :: xs      -> Jark.ns (List.first xs) (List.tl xs)
  | "package" :: [] -> pe package_usage
  | "package" :: xs -> Jark.package (List.first xs) (List.tl xs)
  | "swank" :: []   -> pe swank_usage
  | "swank" :: xs   -> Jark.swank (List.first xs) (List.tl xs)
  | "repo" :: []    -> pe repo_usage
  (* | "repl" :: []    -> run_repl ~show:1 () *)
  | "version" :: [] -> pe Jark.version
  | "--version" :: [] -> pe Jark.version
  | "-v" :: []      -> pe Jark.version
  | "install" :: [] -> Jark.install "jark"
  | "-e" :: xs      -> Nrepl.eval_exp (List.first xs)
  |  _              -> pe usage; 
 
