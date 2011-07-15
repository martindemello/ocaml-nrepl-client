include Nrepl_frontend
open ExtList
open ExtString
open Printf
open Datatypes
include Config

let vm_start ?(run = 0) () =
  if run=1 then begin
    Sys.command("java -cp " ^ cp_boot ^ " jark.vm 9000 &");
    Unix.sleep 5
  end
      
let vm_connect ?(host="localhost") ?(port=9000) () =
  let env = (Nrepl.set_env ~host:host ~port:port ()) in
  Nrepl.eval env "(jark.vm/stats)"
    
let cp_add path ?(run = 0) () =
  if run=1 then begin
    let env = Nrepl.get_env in
    Nrepl.eval env (sprintf "(jark.cp/add \"%s\")" path)
  end
      
let ns_load file ?(run = 0) () =
  if run=1 then begin
    let env = Nrepl.get_env in
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
  | "start"   -> (vm_start ~run:1 ())
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
    Sys.command("mkdir -p " ^ cljr_lib);
    Sys.command("wget --user-agent jark " ^ url_clojure ^ " -O" ^ cljr_lib ^ "/clojure-1.2.1.jar");
    Sys.command("wget --user-agent jark " ^ url_clojure_contrib ^ " -O"  ^ cljr_lib ^ "/clojure-contrib-1.2.0.jar");
    Sys.command("wget --user-agent jark " ^ url_nrepl ^ " -O" ^ cljr_lib ^ "/tools.nrepl-0.0.5.jar");
    Sys.command("wget --user-agent jark " ^ url_jark  ^ " -O" ^ cljr_lib ^ "/jark-0.4.jar");
    pe "Installed components successfully"
  end


(* REPL *)
    
let initial_env = {
  ns          = "user";
  debug       = false;
  host        = "localhost";
  port        = 9000
}

let display_help () =
  printf "Type something!\n";
  flush stdout

let set_debug env o =
  let d = match o with
  | "true"  -> true
  | "on"    -> true
  | "false" -> false
  | "off"   -> false
  | _       -> env.debug
  in
  printf "debug = %s\n" (if d then "true" else "false");
  flush stdout;
  {env with debug = d}

let handle_cmd env cmd =
  match Str.bounded_split (Str.regexp " +") cmd 2 with
  | ["/help"]     -> display_help (); env
  | ["/debug"; o] -> set_debug env o
  | _             -> env


(*************************************************************************
 * repl
 * ***********************************************************************)

let prompt_of env = env.ns ^ ">> "

let readline prompt =
  let stdin = stdin in
  Ledit.set_prompt prompt;
  let buf = Buffer.create 4096 in
  let rec loop c = match c with
  | "\n" -> Buffer.contents buf
  | _    -> Buffer.add_string buf c; loop (Ledit.input_char stdin)
  in
  loop (Ledit.input_char stdin);;

let show_exc x = Printf.printf "Exception: %s\n%!" (Printexc.to_string x)

let bad_command () =
  printf "Bad command\n";
  flush stdout

let send_cmd env str =
  Nrepl.eval env str;
  flush stdout;
  env

let handle env str =
  if String.length str == 0 then
    env
  else if String.starts_with str "/" then
    handle_cmd env str
  else
    send_cmd env str

let run_repl ?(show = 0) () =
  if show=1 then begin
    try
      let r = ref initial_env in
      while true do
        let str = readline (prompt_of !r) in
        r := handle !r str;
      done;
      flush stdout;
    with End_of_file -> print_newline ()
  end
