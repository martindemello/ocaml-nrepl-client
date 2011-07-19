(*pp $PP *)

include Usage
open ExtList
open OptParse
open Jark
open ExtList
open ExtString
open Repl

 let cp cmd arg =
   match cmd with
   | "usage"   -> pe cp_usage
   | "help"    -> pe cp_usage
   | "list"    -> Jark.eval_cmd "jark.cp" "ls"
   | "ls"      -> Jark.eval_cmd "jark.cp" "ls"
   | "add"     -> Jark.cp_add arg
   |  _        -> pe cp_usage
            
let vm cmd arg =
  match cmd with
  | "usage"   -> pe vm_usage
  | "start"   -> Jark.vm_start (List.nth arg 1)
  | "connect" -> begin 
      Jark.vm_connect (List.nth arg 1) (String.to_int (List.nth arg 3))
  end
  | "stat"    -> Jark.eval_cmd "jark.vm" "stats"
  | "uptime"  -> Jark.eval_cmd "jark.vm" "uptime"
  | "gc"      -> Jark.eval_cmd "jark.vm" "gc"
  | "threads" -> Jark.eval_cmd "jark.vm" "threads"
  |  _        -> pe vm_usage 
            
let ns cmd arg =
  match cmd with
  | "usage"   -> pe ns_usage
  | "list"    -> Jark.eval_cmd "jark.ns" "list"
  | "find"    -> Jark.eval_cmd "jark.ns" "list"
  | "load"    -> Jark.ns_load (List.first arg)
  | "run"     -> Jark.eval_cmd "jark.ns" "list"
  | "repl"    -> Jark.eval_cmd "jark.ns" "list"
  |  _        -> pe ns_usage
            
let package cmd arg =
  match cmd with
  | "usage"     -> pe package_usage
  | "install"   -> pe "Install package"
  | "versions"  -> pe "package versions"
  | "deps"      -> pe "dependencies"
  | "installed" -> pe "install a package"
  | "latest"    -> pe "Latest"
  |  _          -> pe package_usage
            
let swank cmd arg =
  match cmd with
  | "usage"   -> pe swank_usage
  | "start"   -> Jark.eval "(jark.swank/start \"0.0.0.0\" 4005)"
  |  _        -> pe swank_usage
        
let version = 
  "version 0.4"
        
let _ =
  match (List.tl (Array.to_list Sys.argv)) with
    "vm" :: []      -> pe vm_usage
  | "vm" :: xs      -> vm (List.first xs) (List.tl xs)
  | "cp" :: []      -> pe cp_usage
  | "cp" :: xs      -> cp (List.first xs) (List.tl xs)
  | "ns" :: []      -> pe ns_usage
  | "ns" :: xs      -> ns (List.first xs) (List.tl xs)
  | "package" :: [] -> pe package_usage
  | "package" :: xs -> package (List.first xs) (List.tl xs)
  | "swank" :: []   -> pe swank_usage
  | "swank" :: xs   -> swank (List.first xs) (List.tl xs)
  | "repo" :: []    -> pe repo_usage
  | "repl" :: []    -> Repl.run "user"
  | "version" :: [] -> pe version
  | "--version" :: [] -> pe version
  | "-v" :: []      -> pe version
  | "install" :: [] -> Jark.install "jark"
  | "-e" :: xs      -> Jark.eval (List.first xs)
  |  _   :: xs      -> Jark.eval_cmd_args (List.nth xs 0) (List.nth xs 1) (List.drop 1 xs)
  |  _              -> pe usage
 
