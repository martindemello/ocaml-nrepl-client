(*pp $PP *)
(*************************************************************************
 * Requires:
 *   str.cma
 *************************************************************************)

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
  id: string;
  code: string;
}

let initial_repl = {
  ns          = "user";
  debug       = false;
  current_exp = None;
  host        = "localhost";
  port        = "8080"
}

(* repl stuff *)

let prompt_of repl = repl.ns ^ ">> "

let replid repl = repl.host ^ ":" ^ repl.port

let inspect ary = "[" ^ (String.concat ", " ary) ^ "]"

(*************************************************************************
 * nrepl commands
 * ***********************************************************************)

let nrepl_send repl message =
  printf "-> %s\n" (inspect message);
  flush stdout

let clj_string repl exp =
  let s = sprintf "(do (in-ns '%s) %s)" repl.ns exp in
  Str.global_replace (Str.regexp "\"") "\\\"" s

let q str =
  sprintf "\"%s\"\n" str

let clj_message_packet msg =
  ["2"; q "id"; q msg.id; q "code"; q msg.code]

let clj_eval_message repl exp =
  { id = (replid repl) ^ "-repl"; code = exp }

let clj_dispatch_message repl exp =
  { id = replid repl; code = sprintf "(jark.ns/dispatch %s)" exp }

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
  if String.length str == 0 then
    repl
  else if str.[0] == '/' then
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
