module NreplClient :
  sig
    val send_msg : Datatypes.env -> string -> Datatypes.response
  end
