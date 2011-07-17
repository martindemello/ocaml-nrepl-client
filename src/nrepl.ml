(*pp $PP *)

include Util
open Printf
open ExtList
open ExtString
include Config

module Nrepl =
  struct
    open Datatypes

    let empty_response = {
      id     = None;
      out    = None;
      err    = None;
      value  = None;
      status = None;
    }

    let update_response res (x, y) =
      let y = Some (uq y) in
      match (uq x) with
      | "id"     -> {res with id = y};
      | "out"    -> {res with out = y};
      | "err"    -> {res with err = y};
      | "value"  -> {res with value = y};
      | "status" -> {res with status = y};
      | _        -> res (* TODO: raise malformed response *)

    type state = NewPacket | Receiving of int | Done

    let readlines socket =
      let input = Unix.in_channel_of_descr socket in
      let getline () = try input_line input with End_of_file -> "" in
      let value = ref None in
      let out = ref [] in
      let err = ref None in
      let rec get s res =
        match s with
        | NewPacket ->
            let line = getline () in
            let i = int_of_string line in
            get (Receiving i) empty_response
        | Done ->
            let out = match !out with
            | [] -> None
            | _  -> Some (unlines (List.map us (List.rev !out)))
            in
            {res with value = !value; out = out; err = !err}
        | Receiving 0 ->
            if notnone res.err then err := res.err;
            if notnone res.out then out := res.out :: !out;
            if notnone res.value then value := res.value;
            get NewPacket res
        | Receiving n ->
            let k = getline () in
            let v = getline () in
            let res = update_response res (k, v) in
            match res.status with
            | Some "done"  -> get Done res
            | _            -> get (Receiving (n - 1)) res
            in
            get NewPacket empty_response

    let write_all socket s =
      Unix.send socket s 0 (String.length s) []

    let nrepl_message_packet msg =
      ["2"; q "id"; q msg.mid; q "code"; q msg.code]

    let send_msg env msg =
      let socket = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
      let hostinfo = Unix.gethostbyname env.host in
      let server_address = hostinfo.Unix.h_addr_list.(0) in
      let _ = Unix.connect socket (Unix.ADDR_INET (server_address, env.port)) in
      let msg = unlines (nrepl_message_packet msg) in
      let _ = write_all socket msg in
      let res = readlines socket in
      Unix.close socket;
      res

    (* frontend *)

    let format_value value =
      Str.global_replace (Str.regexp "\\\\n$") " " value

    let nilp value = 
      (String.strip (format_value (us value))) = "nil"

    let nrepl_send env msg  =
      let res = send_msg env msg in
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

    let eval_dispatch env ns fn =
      nrepl_send env (make_dispatch_message env (stringify ns) (stringify fn))

    let eval_cmd ns fn = 
      let env = get_env in
      eval_dispatch env ns fn
          
    let eval_exp exp = 
      let env = get_env in
      eval env exp

  end
