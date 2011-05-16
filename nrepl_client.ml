(*pp $PP *)
(*************************************************************************
 * Requires:
 *   str.cma
 *************************************************************************)

module B = Batteries_uni
module S = B.String
open Printf

type repl = {
  ns          : string;
  debug       : bool;
  current_exp : string option;
  host        : string;
  port        : int;
}

type env = {
  mutable repl: repl;
}

type repl_message = {
  mid: string;
  code: string;
}

type response = {
  id     : string option;
  out    : string option;
  err    : string option;
  value  : string option;
  status : string option;
}

let initial_repl = {
  ns          = "user";
  debug       = false;
  current_exp = None;
  host        = "localhost";
  port        = 9000
}

let empty_response = {
  id     = None;
  out    = None;
  err    = None;
  value  = None;
  status = None;
}

(* repl stuff *)

let prompt_of repl = repl.ns ^ ">> "

let replid repl = sprintf "%s:%d" repl.host repl.port

(* utility functions *)

let inspect ary = "[" ^ (S.concat ", " ary) ^ "]"

let split x y = Str.split (Str.regexp x) y

let lines x = split "\n" x

let q str = sprintf "\"%s\"" str

let uq str = S.strip ~chars:"\"" str

let unsome default = function
  | None -> default
  | Some v -> v

let notnone x = x != None

let us x = unsome "" x

let flush stdout = flush stdout

let update_res res (x, y) =
  let y = Some (uq y) in
  match (uq x) with
  | "id"     -> {res with id = y};
  | "out"    -> {res with out = y};
  | "err"    -> {res with err = y};
  | "value"  -> {res with value = y};
  | "status" -> {res with status = y};
  | _        -> res (* TODO: raise malformed response *)

(*************************************************************************
 * message sending and receiving
 * ***********************************************************************)

type state = NewPacket | Receiving of int | Done

let readlines socket =
  let input = Unix.in_channel_of_descr socket in
  let getline () = try input_line input with End_of_file -> "" in
  let value = ref "" in
  let out = ref [] in
  let err = ref "" in
  let rec get s res =
    match s with
    | NewPacket ->
        let line = getline () in
        let i = int_of_string line in
        get (Receiving i) empty_response
    | Done ->
        let out = S.concat "\n" (List.rev !out) in
        {res with value = Some !value; out = Some out; err = Some !err}
    | Receiving 0 ->
        if notnone res.err then err := us res.err;
        if notnone res.out then out := (us res.out) :: !out;
        if notnone res.value then value := us res.value;
        get NewPacket res
    | Receiving n ->
        let k = getline () in
        let v = getline () in
        let res = update_res res (k, v) in
        match res.status with
        | Some "done"  -> get Done res
        | _            -> get (Receiving (n - 1)) res
  in
  get NewPacket empty_response

let write_all socket s =
  Unix.send socket s 0 (S.length s) []

let send_msg repl msg =
  let socket = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  let hostinfo = Unix.gethostbyname repl.host in
  let server_address = hostinfo.Unix.h_addr_list.(0) in
  let _ = Unix.connect socket (Unix.ADDR_INET (server_address, repl.port)) in
  write_all socket msg;
  let rv = readlines socket in
  Unix.close socket;
  rv

(*************************************************************************
 * nrepl commands
 * ***********************************************************************)

let nrepl_send repl msg =
  let res = send_msg repl (S.concat "\n" msg) in
  printf "%s\n" (us res.out);
  printf "-> %s\n" (us res.value);
  flush stdout

let clj_string repl exp =
  let s = sprintf "(do (in-ns '%s) %s)" repl.ns exp in
  Str.global_replace (Str.regexp "\"") "\\\"" s

let clj_message_packet msg =
  ["2"; q "id"; q msg.mid; q "code"; q msg.code]

let clj_eval_message repl exp =
  { mid = (replid repl) ^ "-repl"; code = exp }

let clj_dispatch_message repl exp =
  { mid = replid repl; code = sprintf "(jark.ns/dispatch %s)" exp }

let clj_eval repl code =
  let expr = clj_string repl code in
  nrepl_send repl (clj_message_packet (clj_eval_message repl expr))


(*************************************************************************
 * internal commands
 * ***********************************************************************)

let display_help () =
  printf "Type something!\n";
  flush stdout

let set_debug repl o =
  let d = match o with
  | "true"  -> true
  | "on"    -> true
  | "false" -> false
  | "off"   -> false
  | _       -> repl.debug
  in
  printf "debug = %s\n" (if d then "true" else "false");
  flush stdout;
  {repl with debug = d}

let handle_cmd repl cmd =
  match Str.bounded_split (Str.regexp " +") cmd 2 with
  | ["/help"]  -> display_help (); repl
  | ["/debug"; o] -> set_debug repl o
  | _                -> repl

(*************************************************************************
 * repl
 * ***********************************************************************)

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

let send_cmd repl str =
  clj_eval repl str;
  flush stdout;
  repl

let handle repl str =
  if S.length str == 0 then
    repl
  else if S.starts_with str "/" then
    handle_cmd repl str
  else
    send_cmd repl str

let _ =
  try
    let r = {repl = initial_repl} in
    while true do
      let str = readline (prompt_of r.repl) in
      r.repl <- handle r.repl str;
    done;
    flush stdout;
  with End_of_file -> print_newline ();
