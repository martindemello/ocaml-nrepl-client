module Jark :
  sig

    val eval_cmd : string -> string -> unit

    val eval : string -> unit

    val vm_start : string -> unit

    val vm_connect : string -> int -> unit

    val cp_add : string list -> unit

    val ns_load : string -> unit

    val install : string -> unit

   end
