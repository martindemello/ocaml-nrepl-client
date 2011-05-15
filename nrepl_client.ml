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
}

type env = {
  mutable repl: repl;
}

let initial_repl = {
  ns          = "user";
  debug       = false;
  current_exp = None;
}

let prompt_of repl = String.concat "" [repl.ns; ">> "]

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
  printf "--> %s\n" str;
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
