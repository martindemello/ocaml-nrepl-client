(*pp camlp4o *)

open Unix;;
open Str;;

let exists fn = try ignore (lstat fn); true with error -> false;;

let list_of_dir dirname =
  let dirh = opendir dirname in
  let rec readit () =
    match (try Some (readdir dirh) with End_of_file -> None) with
      Some "." -> readit ()
    | Some ".." -> readit ()
    | Some x -> x :: readit ()
    | None -> []
  in 
  let result = readit () in
  closedir dirh;
  result;;

let fold_directory func firstval dirname =
  List.fold_left func firstval (list_of_dir dirname);;

let isdir name =
  try (stat name).st_kind = S_DIR with error -> false;;

let abspath name =
  if not (Filename.is_relative name) then
    name
  else begin
    let startdir = Sys.getcwd() in
    if isdir name then begin
      chdir name;
      let retval = Sys.getcwd () in
      chdir startdir;
      retval;
    end else begin
      let base = Filename.basename name in
      let dirn = Filename.dirname name in
      chdir dirn;
      let retval = Filename.concat (Sys.getcwd()) base in
      chdir startdir;
      retval;
    end;
  end;;

