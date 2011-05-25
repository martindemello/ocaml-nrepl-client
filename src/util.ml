(*pp $PP *)

open Printf
open String

(* utility functions *)


let split x y = Str.split (Str.regexp x) y

let lines x = split "\n" x

let unlines xs = concat "\n" xs

let q str = sprintf "\"%s\"" str

let uq str = strip ~chars:"\"" str 

let unsome default = function
  | None -> default
  | Some v -> v

let notnone x = x != None

let us x = unsome "" x

let ends_with src pat =
  if ((String.length src) >= (String.length pat)) then
    (pat =
     String.sub src
       ((String.length src) - (String.length pat)) (String.length pat))
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

let strip str =
    let len = String.length str
    and is_space char = (char = ' ' || char = '\t') in
    let start = ref 0
    and stop = ref (len - 1)
    and seen_non_space = ref false in
    for ii = 0 to len - 1 do
      if is_space str.[ii] then
        (if not !seen_non_space then
          start := ii + 1)
      else
        (seen_non_space := true;
         stop := ii)
    done;
    String.sub str !start (!stop - !start +1)
