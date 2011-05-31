(*pp $PP *)

include Util
include Nrepl_client
open Printf

module Nrepl =
  struct
    open Datatypes

    (* nrepl seems to be appending a literal '\n' *)
    let strip_fake_newline str =
      if ends_with str "\\n" then
        rchop (rchop str)
      else
        str

    let format_value value =
      strip_fake_newline value

    let nrepl_send env msg =
      let res = NreplClient.send_msg env msg in
      if notnone res.err then
        printf "%s\n" (format_value (us res.err))
      else
        begin
          if notnone res.out then printf "%s\n" (us res.out);
          if notnone res.value then printf "-> %s\n" (format_value (us res.value))
        end;
        flush stdout

    let node_id env = sprintf "%s:%d" env.host env.port

    let repl_id env = (node_id env) ^ "-repl"

    let make_eval_message env exp =
      { mid = repl_id env; code = exp }

    let make_dispatch_message env exp =
      { mid = node_id env; code = sprintf "(jark.ns/dispatch %s)" exp }

    let clj_string env exp =
      let s = sprintf "(do (in-ns '%s) %s)" env.ns exp in
      Str.global_replace (Str.regexp "\"") "\\\"" s

    let eval env code =
      let expr = clj_string env code in
      nrepl_send env (make_eval_message env expr)

    (* commands *)
    let vm = 
      "vm command\n"

    let cp = 
      "cp module\n"
      
    let show_repl =
      "repl\n"

  end
