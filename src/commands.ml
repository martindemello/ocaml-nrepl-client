include Nrepl_frontend
open ExtList
open ExtString
open Printf
open Datatypes
include Config
open Fs

let vm_start ?(run = 0) () =
  if run=1 then begin
    let c = "java -cp " ^ cp_boot ^ " jark.vm 9000 &" in
    ignore (Sys.command c);
    getc;
    Unix.sleep 5
  end
      
let vm_connect ?(host="localhost") ?(port=9000) () =
  let env = (set_env ~host:host ~port:port ()) in
  Nrepl.eval env "(jark.vm/stats)"

let cp_add path ?(run = 0) () =
  (* FIXME: path is a list, an item in path can be a directory *)
  if run=1 then begin
    let apath = (Fs.abspath path) in
    let env = get_env in
    printf "Adding classpath %s\n" apath;
    Nrepl.eval env (sprintf "(jark.cp/add \"%s\")" apath)
  end

let ns_load file ?(run = 0) () =
  if run=1 then begin
    let env = get_env in
    Nrepl.eval env (sprintf "(jark.ns/load-clj \"%s\")" file)
  end
      
(* commands *)
      
let cp cmd ?(arg = []) () =
  match cmd with
  | "usage"   -> pe cp_usage
  | "help"    -> pe cp_usage
  | "list"    -> Nrepl.eval_cmd (q "jark.cp") (q "ls") ~run:1 ()
  | "add"     -> cp_add (List.nth arg 0) ~run:1 ()
  |  _        -> pe cp_usage
        
let vm cmd ?(arg = []) () =
  match cmd with
  | "usage"   -> pe vm_usage
  | "start"   -> vm_start ~run:1 ()
  | "connect" -> begin 
      vm_connect ~host:(List.nth arg 1) ~port:(String.to_int (List.nth arg 3)) ()
      end
  | "stat"    -> Nrepl.eval_cmd (q "jark.vm") (q "stats")  ~run:1 ()
  | "uptime"  -> Nrepl.eval_cmd (q "jark.vm") (q "uptime") ~run:1 ()
  | "gc"      -> Nrepl.eval_cmd (q "jark.vm") (q "gc")     ~run:1 ()
  | "threads" -> Nrepl.eval_cmd (q "jark.vm") (q "threads")  ~run:1 ()
  |  _        -> pe vm_usage 
        
let ns cmd ?(arg = [] ) () =
  match cmd with
  | "usage"   -> pe ns_usage
  | "list"    -> Nrepl.eval_cmd (q "jark.ns") (q "list") ~run:1 ()
  | "find"    -> Nrepl.eval_cmd (q "jark.ns") (q "list") ~run:1 ()
  | "load"    -> ns_load (List.first arg) ~run:1 ()
  | "run"     -> Nrepl.eval_cmd (q "jark.ns") (q "list") ~run:1 () 
  | "repl"    -> Nrepl.eval_cmd (q "jark.ns") (q "list") ~run:1 ()
  |  _        -> pe ns_usage
        
let package cmd ?(arg = []) () =
  match cmd with
  | "usage"     -> package_usage
  | "install"   -> "Install package"
  | "uninstall" -> "Uninstall package " ^ (String.concat " " arg)
  | "versions"  -> "package versions"
  | "deps"      -> "dependencies"
  | "installed" -> "install a package"
  | "latest"    -> "Latest"
  |  _          -> package_usage
        
let swank cmd ?(arg = [] ) () =
  match cmd with
  | "usage"   -> pe swank_usage
  | "start"   -> Nrepl.eval_exp "(jark.swank/start \"0.0.0.0\" 4005)" ~run:1 ()
  |  _        -> pe swank_usage
        
let version = 
  "version 0.4"
    
let install ?(run = 0) () =
  if run=1 then begin
    ignore (Sys.command("mkdir -p " ^ cljr_lib));
    ignore (Sys.command("wget --user-agent jark " ^ url_clojure ^ " -O" ^ cljr_lib ^ "/clojure-1.2.1.jar"));
    ignore (Sys.command("wget --user-agent jark " ^ url_clojure_contrib ^ " -O"  ^ cljr_lib ^ "/clojure-contrib-1.2.0.jar"));
    ignore (Sys.command("wget --user-agent jark " ^ url_nrepl ^ " -O" ^ cljr_lib ^ "/tools.nrepl-0.0.5.jar"));
    ignore (Sys.command("wget --user-agent jark " ^ url_jark  ^ " -O" ^ cljr_lib ^ "/jark-0.4.jar"));
    pe "Installed components successfully"
  end
