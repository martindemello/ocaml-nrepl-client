
val exists: string -> bool

val isdir: string -> bool

val list_of_dir: string -> string list

val fold_directory: ('a -> string -> 'a) -> 'a -> string -> 'a

val abspath: string -> string

val getfirstline: string -> string

val getlines: string -> string list
