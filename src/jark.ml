open ExtList
open ExtString
open Printf
open Datatypes
include Config
include Util
include Usage
open File
open Nrepl

module Jark =
  struct
    open Datatypes

    let vm_start port =
      let c = "java -cp " ^ cp_boot ^ " jark.vm " ^ port ^ " &" in
      ignore (Sys.command c);
      getc;
      Unix.sleep 5
        
    let vm_connect host port =
      let env = (set_env ~host:host ~port:port ()) in
      Nrepl.eval env "(jark.vm/stats)"
        
    let cp_add_file path =
      let env = get_env in
      printf "Adding classpath %s\n" path;
      Nrepl.eval env (sprintf "(jark.cp/add \"%s\")" path)

    let cp_add path =
      let apath = (File.abspath path) in
      let f = apath ^ "/" in
      if (File.exists apath) then begin
        if (File.isdir apath) then 
          List.iter (fun x -> cp_add_file (f ^ x)) (File.list_of_dir apath)
        else
          cp_add_file(apath);
        ()
      end
      else begin
        printf "File not found %s\n" apath;
        ()
      end

    let ns_load file =
      let env = get_env in
      Nrepl.eval env (sprintf "(jark.ns/load-clj \"%s\")" file)
        
(* command dispatcher *)

    let cp cmd arg =
      match cmd with
      | "usage"   -> pe cp_usage
      | "help"    -> pe cp_usage
      | "list"    -> Nrepl.eval_cmd (q "jark.cp") (q "ls")
      | "add"     -> cp_add (List.nth arg 0)
      |  _        -> pe cp_usage
            
    let vm cmd arg =
      match cmd with
      | "usage"   -> pe vm_usage
      | "start"   -> vm_start (List.nth arg 1)
      | "connect" -> begin 
          vm_connect (List.nth arg 1) (String.to_int (List.nth arg 3))
      end
      | "stat"    -> Nrepl.eval_cmd (q "jark.vm") (q "stats")
      | "uptime"  -> Nrepl.eval_cmd (q "jark.vm") (q "uptime")
      | "gc"      -> Nrepl.eval_cmd (q "jark.vm") (q "gc")    
      | "threads" -> Nrepl.eval_cmd (q "jark.vm") (q "threads")
      |  _        -> pe vm_usage 
            
    let ns cmd arg =
      match cmd with
      | "usage"   -> pe ns_usage
      | "list"    -> Nrepl.eval_cmd (q "jark.ns") (q "list")
      | "find"    -> Nrepl.eval_cmd (q "jark.ns") (q "list")
      | "load"    -> ns_load (List.first arg)
      | "run"     -> Nrepl.eval_cmd (q "jark.ns") (q "list")
      | "repl"    -> Nrepl.eval_cmd (q "jark.ns") (q "list")
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
      | "start"   -> Nrepl.eval_exp "(jark.swank/start \"0.0.0.0\" 4005)"
      |  _        -> pe swank_usage
            
    let version = 
      "version 0.4"
        
    let install component =
      ignore (Sys.command("mkdir -p " ^ cljr_lib));
      ignore (Sys.command("wget --user-agent jark " ^ url_clojure ^ " -O" ^ cljr_lib ^ "/clojure-1.2.1.jar"));
      ignore (Sys.command("wget --user-agent jark " ^ url_clojure_contrib ^ " -O"  ^ cljr_lib ^ "/clojure-contrib-1.2.0.jar"));
      ignore (Sys.command("wget --user-agent jark " ^ url_nrepl ^ " -O" ^ cljr_lib ^ "/tools.nrepl-0.0.5.jar"));
      ignore (Sys.command("wget --user-agent jark " ^ url_jark  ^ " -O" ^ cljr_lib ^ "/jark-0.4.jar"));
      pe "Installed components successfully";

end
