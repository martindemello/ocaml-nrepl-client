module Jark :
  sig

    val vm_start: string -> unit

    val vm_connect: string -> int -> unit

    val cp_add: string -> unit

    val ns_load: string -> unit

    val cp: string -> string list -> unit

    val vm: string -> string list -> unit

    val ns: string -> string list -> unit

    val package: string -> string list -> unit

    val swank: string -> string list -> unit

    val version: string

    val install: string -> unit

   end
