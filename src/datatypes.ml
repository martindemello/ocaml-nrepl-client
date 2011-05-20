type repl = {
  ns          : string;
  debug       : bool;
  current_exp : string option;
  host        : string;
  port        : int;
}

type env = {
  mutable repl: repl;
}

type repl_message = {
  mid: string;
  code: string;
}

type response = {
  id     : string option;
  out    : string option;
  err    : string option;
  value  : string option;
  status : string option;
}
