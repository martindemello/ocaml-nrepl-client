(*pp $PP *)

open Printf
open String

(* utility functions *)

let split x y = Str.split (Str.regexp x) y

let lines x = split "\n" x

let unlines xs = concat "\n" xs

let q str = sprintf "\"%s\"" str

let uq str =
  let l = String.length str - 1 in
  if str.[0] == '"' && str.[l] == '"' then
    String.sub str 1 (l - 1)
  else
    str

let unsome default = function
  | None -> default
  | Some v -> v

let notnone x = x != None

let us x = unsome "" x

let ends_with src pat =
  let l = String.length src in
  let m = String.length pat in
  if l >= m then
    pat = String.sub src (l - m) m
  else
    false

let rchop s =
  if s = "" then s else String.sub s 0 (String.length s - 1);;

let starts_with sw s =
  let sl = String.length s in
  let swl = String.length sw in
  sl >= swl && String.sub s 0 swl = sw

let split path =
  let rec aux path =
    if path = Filename.current_dir_name then []
    else (Filename.basename path) :: aux (Filename.dirname path)
  in List.rev (aux path)
