module Nrepl :
  sig
    val send_msg : Datatypes.env -> Datatypes.nrepl_message -> Datatypes.response
  end
