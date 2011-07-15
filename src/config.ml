(*pp $PP *)
open Printf


let cljr_lib = (Sys.getenv "HOME") ^ "/.cljr/lib"

let url_clojure = "http://build.clojure.org/releases/org/clojure/clojure/1.2.1/clojure-1.2.1.jar"

let url_clojure_contrib = "http://build.clojure.org/releases/org/clojure/clojure-contrib/1.2.0/clojure-contrib-1.2.0.jar"

let url_nrepl =  "http://repo1.maven.org/maven2/org/clojure/tools.nrepl/0.0.5/tools.nrepl-0.0.5.jar"

let url_jark = "http://clojars.org/repo/jark/jark/0.4/jark-0.4.jar"

let cp_boot  = cljr_lib ^ "/clojure-1.2.1.jar" ^ ":" ^
  cljr_lib ^ "/clojure-contrib-1.2.0.jar" ^ ":" ^
  cljr_lib ^ "/tools.nrepl-0.0.5.jar" ^ ":" ^
  cljr_lib ^ "/jark-0.4.jar"

let set k v =
  Sys.command ("mkdir -p " ^ (Sys.getenv "HOME") ^ "/.config/jark");
  let file = (Sys.getenv "HOME") ^ "/.config/jark/" ^ k in
  let f = open_out file in 
  fprintf f "%s\n" v; 
  close_out f

let get k =
  let file = (Sys.getenv "HOME") ^ "/.config/jark/" ^ k in
  let f = open_in file in
  try 
    let line = input_line f in 
    close_in f;
    line
  with e -> 
    close_in_noerr f; 
    raise e 
