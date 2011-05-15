(*pp $PP *)
(*************************************************************************
 * Requires:
 *   str.cma
 *************************************************************************)

module B = Batteries_uni
module S = B.String
module Json = Yojson.Basic
open Printf

type repl = {
  ns          : string;
  debug       : bool;
  current_exp : string option;
  host        : string;
  port        : string;
}

type env = {
  mutable repl: repl;
}

type repl_message = {
  mid: string;
  code: string;
}

type response = {
  mutable id     : string option;
  mutable out    : string option;
  mutable err    : string option;
  mutable value  : string option;
  mutable status : string option;
}

let initial_repl = {
  ns          = "user";
  debug       = false;
  current_exp = None;
  host        = "localhost";
  port        = "8080"
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

let replid repl = repl.host ^ ":" ^ repl.port

(* utility functions *)

let inspect ary = "[" ^ (S.concat ", " ary) ^ "]"

let split x y = Str.split (Str.regexp x) y

let lines x = split "\n" x

let q str = sprintf "\"%s\"\n" str

let uq str = S.strip ~chars:"\"" str

let unsome default = function
  | None -> default
  | Some v -> v

let us x = unsome "" x

(*************************************************************************
 * nrepl commands
 * ***********************************************************************)

let nrepl_send repl message =
  printf "-> %s\n" (inspect message);
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

(* response handling *)

let pairs lst =
  let rec _pairs a acc =
    match a with
    | [] -> acc
    | [x] -> acc (* TODO: raise malformed response *)
    | [x; y] -> (x, y) :: acc
    | x :: y :: xs -> _pairs xs ((x, y) :: acc)
  in
  List.rev (_pairs lst [])

let response_of_tuples tuples =
  let res = empty_response in
  let update_res (x, y) =
    let y = Some y in
    match x with
    | "id"     -> res.id <- y;
    | "out"    -> res.out <- y;
    | "err"    -> res.err <- y;
    | "value"  -> res.value <- y;
    | "status" -> res.status <- y;
    | _        -> (); (* TODO: raise malformed response *)
  in
  List.iter update_res tuples

let responses_of_msg msg =
  let msgs = List.map lines (split "\b3\n" msg) in
  List.map (fun x -> response_of_tuples (pairs x)) msgs



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
  clj_eval repl  str;
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
