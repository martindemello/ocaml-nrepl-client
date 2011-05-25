(*pp $PP *)

include Nrepl_frontend
open Printf
open Datatypes

let initial_env = {
  ns          = "user";
  debug       = false;
  host        = "localhost";
  port        = 9000
}

(*************************************************************************
 * internal commands
 * ***********************************************************************)

let display_help () =
  printf "Type something!\n";
  flush stdout

let set_debug env o =
  let d = match o with
  | "true"  -> true
  | "on"    -> true
  | "false" -> false
  | "off"   -> false
  | _       -> env.debug
  in
  printf "debug = %s\n" (if d then "true" else "false");
  flush stdout;
  {env with debug = d}

let handle_cmd env cmd =
  match Str.bounded_split (Str.regexp " +") cmd 2 with
  | ["/help"]     -> display_help (); env
  | ["/debug"; o] -> set_debug env o
  | _             -> env

(*************************************************************************
 * repl
 * ***********************************************************************)

let prompt_of env = env.ns ^ ">> "

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

let send_cmd env str =
  Nrepl.eval env str;
  flush stdout;
  env

let handle env str =
  if S.length str == 0 then
    env
  else if S.starts_with str "/" then
    handle_cmd env str
  else
    send_cmd env str

let _ =
  try
    let r = ref initial_env in
    while true do
      let str = readline (prompt_of !r) in
      r := handle !r str;
    done;
    flush stdout;
  with End_of_file -> print_newline ();
