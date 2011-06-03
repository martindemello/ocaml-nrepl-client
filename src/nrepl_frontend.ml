(*pp $PP *)

include Util
include Nrepl_client
include Usage
open Printf

module Nrepl =
  struct
    open Datatypes

    (* nrepl seems to be appending a literal '\n' *)

    let format_value value =
      strip ~chars:"\n" value;
      strip_fake_newline value

    let nrepl_send env msg  =
      let res = NreplClient.send_msg env msg in
      if notnone res.err then
        printf "%s\n" (format_value (us res.err))
      else
        begin
          if notnone res.out then printf "%s\n" (format_value (us res.out));
          if notnone res.value then printf "%s\n" (format_value (us res.value))
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

    let eval_dispatch env ns fn =
      nrepl_send env (make_dispatch_message env (stringify ns) (stringify fn))

    let set_env ?(host="localhost") ?(port=9000) () =
      (* FIXME: write to disk *)
      {
          ns          = "user";
          debug       = false;
          host        = host;
          port        = 9000
      }

    let get_env = 
      {
          ns          = "user";
          debug       = false;
          host        = "localhost";
          port        = 9000
      } 

    let eval_cmd ns fn ?(run = 0) () = 
      if run=1 then begin
        let env = get_env in
        eval_dispatch env ns fn
      end

    let eval_exp exp ?(run = 0) () = 
      if run=1 then begin
        let env = get_env in
        eval env exp
      end

    (* frontend commands *)
     
    let vm_start ?(run = 0) () =
      if run=1 then begin
        Sys.command "java -cp \"/$HOME/.cljr/lib/*\" jark.vm 9000 &";
        Unix.sleep 5
      end

    let vm_connect ?(host="localhost") ?(port=9000) () =
      let env = (set_env ~host:host ~port:port ()) in
      eval env "(jark.vm/stats)"

    let cp_add path ?(run = 0) () =
      if run=1 then begin
        let env = get_env in
        eval env (sprintf "(jark.cp/add \"%s\")" path)
      end

    let ns_load file ?(run = 0) () =
      if run=1 then begin
        let env = get_env in
        eval env (sprintf "(jark.ns/load-clj \"%s\")" file)
      end

    (* commands *)

    let cp cmd ?(arg = []) () =
      match cmd with
      | "usage"   -> pe cp_usage
      | "help"    -> pe cp_usage
      | "list"    -> eval_cmd (q "jark.cp") (q "ls") ~run:1 ()
      | "add"     -> cp_add (List.nth arg 0) ~run:1 ()
      |  _        -> pe cp_usage

    let vm cmd ?(arg = []) () =
      match cmd with
      | "usage"   -> pe vm_usage
      | "start"   -> (vm_start ~run:1 ())
      | "connect" -> vm_connect ~host:"localhost" ~port:9000 ()
      | "stat"    -> eval_cmd (q "jark.vm") (q "stats")  ~run:1 ()
      | "uptime"  -> eval_cmd (q "jark.vm") (q "uptime") ~run:1 ()
      | "gc"      -> eval_cmd (q "jark.vm") (q "gc")     ~run:1 ()
      | "threads" -> eval_cmd (q "jark.vm") (q "threads")  ~run:1 ()
      |  _        -> pe vm_usage 

    let ns cmd ?(arg = [] ) () =
      match cmd with
      | "usage"   -> pe ns_usage
      | "list"    -> eval_cmd (q "jark.ns") (q "list") ~run:1 ()
      | "find"    -> eval_cmd (q "jark.ns") (q "list") ~run:1 ()
      | "load"    -> ns_load (car arg) ~run:1 ()
      | "run"     -> eval_cmd (q "jark.ns") (q "list") ~run:1 () 
      | "repl"    -> eval_cmd (q "jark.ns") (q "list") ~run:1 ()
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
      | "start"   -> eval_exp "(jark.swank/start \"0.0.0.0\" 4005)" ~run:1 ()
      |  _        -> pe swank_usage


    let version = 
      "version 0.4"

    let install =
      "Downloading clojure jar .."

  end
 
