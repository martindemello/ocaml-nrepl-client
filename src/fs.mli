
(** Returns true if the specified file exists; false otherwise. *)
val exists: string -> bool

(** Returns true if the specified file exists and is a directory. *)
val isdir: string -> bool

(** {6 Directory processing}
These functions help process directories.
*)

(** Returns a list of all entries, exclusive of "." and "..", in the
specified directory. *)
val list_of_dir: string -> string list

(** Folds over the specified directory *)
val fold_directory: ('a -> string -> 'a) -> 'a -> string -> 'a

(** Returns the absolute path of name.

This does not necessarily resolve symlinks.

Side-effects: the current working directory is briefly changed, but is changed
back.  If [os.getcwd ()] returns an invalid cwd to start with, results
are undefined and may cause an exception (since it then cannot change back).
This circumstance is rare and probably not of concern to you.
*)
val abspath: string -> string
