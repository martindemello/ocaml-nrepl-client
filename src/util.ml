(*pp $PP *)

open Printf
open String

(* utility functions *)


let split x y = Str.split (Str.regexp x) y

let lines x = split "\n" x

let unlines xs = concat "\n" xs

let q str = sprintf "\"%s\"" str

let strip ?(chars=" \t\r\n") s =
  let p = ref 0 in
  let l = length s in
  while !p < l && contains chars (unsafe_get s !p) do
    incr p;
  done;
  let p = !p in
  let l = ref (l - 1) in
  while !l >= p && contains chars (unsafe_get s !l) do
    decr l;
  done;
  sub s p (!l - p + 1)

let uq str = strip ~chars:"\"" str 

let unsome default = function
  | None -> default
  | Some v -> v

let notnone x = x != None

let us x = unsome "" x

let starts_with str p =
  let len = length p in
  if length str < len then 
    false
  else
    sub str 0 len = p

let ends_with s e =
  let el = length e in
  let sl = length s in
  if sl < el then
    false
  else
    sub s (sl-el) el = e

let rchop s =
  if s = "" then s 
  else String.sub s 0 (String.length s - 1)

let split path =
  let rec aux path =
    if path = Filename.current_dir_name then []
    else (Filename.basename path) :: aux (Filename.dirname path)
  in List.rev (aux path)

let syscall cmd =
  let ic, oc = Unix.open_process cmd in
  let buf = Buffer.create 16 in
  (try
     while true do
       Buffer.add_channel buf ic 1
     done
   with End_of_file -> ());
  let _ = Unix.close_process (ic, oc) in
  (Buffer.contents buf)

let pe s = print_endline s

let car xs = (List.nth xs 0)

let cdr xs = (List.tl xs)

let stringify s = Str.global_replace (Str.regexp "\"") "\\\"" s
        
let strip_fake_newline str =
  if ends_with str "\\n" then
    rchop (rchop str)
  else
    str
