module Jark :
  sig

    val eval_cmd : string -> string -> unit

    val eval_exp : string -> unit

    val eval : Datatypes.env -> string -> unit

    val vm_start : string -> unit

    val vm_connect : string -> int -> unit

    val cp_add : string -> unit

    val ns_load : string -> unit

    val install : string -> unit

   end
