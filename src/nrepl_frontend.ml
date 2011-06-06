(*pp $PP *)

include Util
include Nrepl_client
include Usage
open Datatypes
open Printf
open ExtList
open ExtString
include Config

module Nrepl =
  struct
    open Datatypes

    (* nrepl seems to be appending a literal '\n' *)

    let format_value value =
      String.strip ~chars:"\n" value;
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
      (* set "host" host; *)
      (* set "port" (string_of_int port); *)
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

 end
 
