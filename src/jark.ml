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

    let format_value value =
      Str.global_replace (Str.regexp "\\\\n$") " " value

    let nilp value = 
      (String.strip (format_value (us value))) = "nil"

    let nrepl_send env msg  =
      let res = Nrepl.send_msg env msg in
      if notnone res.err then
        printf "%s\n" (format_value (us res.err))
      else
        begin
          ignore (format_value (us res.out));
          if notnone res.out then printf "%s\n" (format_value (us res.out));
          if notnone res.value then begin
            if not (nilp res.value) then
              printf "%s\n" (format_value (us res.value));
          end
        end;
        flush stdout

    let node_id env = sprintf "%s:%d" env.host env.port

    let repl_id env = (node_id env) ^ "-repl"

    let make_eval_message env exp =
      { mid = repl_id env; code = exp }

    let make_dispatch_message env ns fn =
      { mid = node_id env; code = sprintf "(jark.ns/dispatch %s %s)" ns fn }

    let clj_string env exp =
      let s = sprintf "(do (in-ns '%s) %s)" env.ns exp in
      Str.global_replace (Str.regexp "\"") "\\\"" s

    let eval env code =
      let expr = clj_string env code in
      nrepl_send env (make_eval_message env expr)

    let eval_cmd ns fn = 
      let env = get_env in
      nrepl_send env (make_dispatch_message env (stringify ns) (stringify fn))
          
    let eval_exp exp = 
      let env = get_env in
      eval env exp

    (* commands *)

    let vm_start port =
      let c = "java -cp " ^ cp_boot ^ " jark.vm " ^ port ^ " &" in
      ignore (Sys.command c);
      getc;
      Unix.sleep 5
        
    let vm_connect host port =
      let env = (set_env ~host:host ~port:port ()) in
      eval env "(jark.vm/stats)"
        
    let cp_add_file path =
      let env = get_env in
      printf "Adding classpath %s\n" path;
      eval env (sprintf "(jark.cp/add \"%s\")" path)

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
      eval env (sprintf "(jark.ns/load-clj \"%s\")" file)
        
    let install component =
      ignore (Sys.command("mkdir -p " ^ cljr_lib));
      ignore (Sys.command("wget --user-agent jark " ^ url_clojure ^ " -O" ^ cljr_lib ^ "/clojure-1.2.1.jar"));
      ignore (Sys.command("wget --user-agent jark " ^ url_clojure_contrib ^ " -O"  ^ cljr_lib ^ "/clojure-contrib-1.2.0.jar"));
      ignore (Sys.command("wget --user-agent jark " ^ url_nrepl ^ " -O" ^ cljr_lib ^ "/tools.nrepl-0.0.5.jar"));
      ignore (Sys.command("wget --user-agent jark " ^ url_jark  ^ " -O" ^ cljr_lib ^ "/jark-0.4.jar"));
      pe "Installed components successfully";

end
