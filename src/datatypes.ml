type env = {
  ns          : string;
  debug       : bool;
  host        : string;
  port        : int;
}

type nrepl_message = {
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
