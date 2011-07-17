(*pp $PP *)
open Printf
open Datatypes

let user_preferences = Hashtbl.create 0

let line_stream_of_channel channel =
  Stream.from
    (fun _ -> try Some (input_line channel) with End_of_file -> None)
 
let cread config () =
  let comments = Str.regexp "#.*" in
  let leading_white = Str.regexp "^[ \t]+" in
  let trailing_white = Str.regexp "[ \t]+$" in
  let equals_delim = Str.regexp "[ \t]*=[ \t]*" in
  let xs = ref [] in
  Stream.iter
    (fun s ->
       let s = Str.replace_first comments "" s in
       let s = Str.replace_first leading_white "" s in
       let s = Str.replace_first trailing_white "" s in
       if String.length s > 0 then
         match Str.bounded_split_delim equals_delim s 2 with
           | [var; value] -> Hashtbl.replace user_preferences var value
           | _ -> failwith s)
    (line_stream_of_channel config);
  List.rev !xs
 
let cljr_lib = 
  if (Sys.os_type = "Win32") then
    "c:\cljr\lib"
  else
    (Sys.getenv "HOME") ^ "/.cljr/lib"

let url_clojure = "http://build.clojure.org/releases/org/clojure/clojure/1.2.1/clojure-1.2.1.jar"

let url_clojure_contrib = "http://build.clojure.org/releases/org/clojure/clojure-contrib/1.2.0/clojure-contrib-1.2.0.jar"

let url_nrepl =  "http://repo1.maven.org/maven2/org/clojure/tools.nrepl/0.0.5/tools.nrepl-0.0.5.jar"

let url_jark = "http://clojars.org/repo/jark/jark/0.4/jark-0.4.jar"

let cp_boot  = cljr_lib ^ "/clojure-1.2.1.jar" ^ ":" ^
  cljr_lib ^ "/clojure-contrib-1.2.0.jar" ^ ":" ^
  cljr_lib ^ "/tools.nrepl-0.0.5.jar" ^ ":" ^
  cljr_lib ^ "/jark-0.4.jar"

let set k v () =
  ignore (Sys.command("mkdir -p " ^ (Sys.getenv "HOME") ^ "/.config/jark"));
  let file = (Sys.getenv "HOME") ^ "/.config/jark/" ^ k in
  let f = open_out(file) in 
  fprintf f "%s\n" v; 
  close_out f

let get k () =
  let file = (Sys.getenv "HOME") ^ "/.config/jark/" ^ k in
  let f = open_in file in
  try 
    let line = input_line f in 
    close_in f;
    line
  with e -> 
    close_in_noerr f; 
    raise e 

let getc () =
  let config_file = (Sys.getenv "HOME") ^ "/.jarkc" in 
  let xs = cread (open_in config_file) in
  (* List.iter (fun x -> Printf.printf "%d\n" x) xs *)
  xs


let set_env ?(host="localhost") ?(port=9000) () =
  set "host" host;
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

