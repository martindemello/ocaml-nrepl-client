module Nrepl :
  sig
    val send_msg : Datatypes.env -> Datatypes.nrepl_message -> Datatypes.response

    val eval_cmd : string -> string -> unit

    val eval_exp : string -> unit

    val eval : Datatypes.env -> string -> unit

  end
