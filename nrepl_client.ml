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

let initial_repl = {
  ns          = "user";
  debug       = false;
  current_exp = None;
}

let prompt_of repl = String.concat "" [repl.ns; ">> "]


(*************************************************************************
 * main() and friends
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

let handle str =
  printf "%s\n" str;
  flush stdout

let _ =
  try
    let repl = initial_repl in
    while true do
      let str = readline (prompt_of repl) in
      handle str;
    done;
    flush stdout;
  with End_of_file -> print_newline ();
