module NreplClient :
  sig
    val send_msg : Datatypes.repl -> string -> Datatypes.response
  end
