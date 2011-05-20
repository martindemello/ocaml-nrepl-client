(*pp $PP *)

include Util
include Nrepl_client
open Printf

module Nrepl =
  struct
    open Datatypes

    let strip_fake_newline str =
      if S.ends_with str "\\n" then
        S.rchop (S.rchop str)
      else
        str

    let format_value value =
      strip_fake_newline value

    let nrepl_send repl msg =
      let res = NreplClient.send_msg repl (unlines msg) in
      if notnone res.err then
        printf "%s\n" (format_value (us res.err))
      else
        begin
          if notnone res.out then printf "%s\n" (us res.out);
          if notnone res.value then printf "-> %s\n" (format_value (us res.value))
        end;
        flush stdout

    let clj_message_packet msg =
      ["2"; q "id"; q msg.mid; q "code"; q msg.code]

    let replid repl = sprintf "%s:%d" repl.host repl.port

    let clj_eval_message repl exp =
      { mid = (replid repl) ^ "-repl"; code = exp }

    let clj_dispatch_message repl exp =
      { mid = replid repl; code = sprintf "(jark.ns/dispatch %s)" exp }

    let clj_string repl exp =
      let s = sprintf "(do (in-ns '%s) %s)" repl.ns exp in
      Str.global_replace (Str.regexp "\"") "\\\"" s

    let eval repl code =
      let expr = clj_string repl code in
      nrepl_send repl (clj_message_packet (clj_eval_message repl expr))

  end
