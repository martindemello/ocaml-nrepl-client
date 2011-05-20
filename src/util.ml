(*pp $PP *)

module B = Batteries_uni
module S = B.String
open Printf

(* utility functions *)

let inspect ary = "[" ^ (S.concat ", " ary) ^ "]"

let split x y = Str.split (Str.regexp x) y

let lines x = split "\n" x

let unlines xs = S.concat "\n" xs

let q str = sprintf "\"%s\"" str

let uq str = S.strip ~chars:"\"" str

let unsome default = function
  | None -> default
  | Some v -> v

let notnone x = x != None

let us x = unsome "" x
