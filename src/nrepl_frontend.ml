(*pp $PP *)

include Util
include Nrepl_client
open Printf

module Nrepl =
  struct
    open Datatypes

    (* nrepl seems to be appending a literal '\n' *)
    let strip_fake_newline str =
      if ends_with str "\\n" then
        rchop (rchop str)
      else
        str

    let format_value value =
      strip_fake_newline value

    let nrepl_send env msg =
      let res = NreplClient.send_msg env msg in
      if notnone res.err then
        printf "%s\n" (format_value (us res.err))
      else
        begin
          if notnone res.out then printf "%s\n" (us res.out);
          if notnone res.value then printf "-> %s\n" (format_value (us res.value))
        end;
        flush stdout

    let node_id env = sprintf "%s:%d" env.host env.port

    let repl_id env = (node_id env) ^ "-repl"

    let make_eval_message env exp =
      { mid = repl_id env; code = exp }

    let make_dispatch_message env exp =
      { mid = node_id env; code = sprintf "(jark.ns/dispatch %s)" exp }

    let clj_string env exp =
      let s = sprintf "(do (in-ns '%s) %s)" env.ns exp in
      Str.global_replace (Str.regexp "\"") "\\\"" s

    let eval env code =
      let expr = clj_string env code in
      nrepl_send env (make_eval_message env expr)

    (* command usage *)
    let vm_usage = 
      unlines ["vm start [--port -p (9000)] [--jvm_opts o]" ;
                "\tStart a local Jark server. Takes optional JVM options as a \" delimited string" ;
                "\tTakes optional JVM options as a \" delimited string" ;
                 "vm stop" ;
                "\tShuts down the current Jark server" ;
                "vm connect [--host -r (localhost)] [--port -p (9000)]" ;
                "\tConnect to a remote JVM" ;
                "vm threads" ;
                "\tPrint a list of JVM threads" ;
                "vm uptime" ;
                "\tThe uptime of the current Jark server" ;
                "vm gc" ;
                "\tRun garbage collection on the current Jark server" ]

    let repo_usage =
      unlines ["repo list" ; 
                "\tList current repositories" ;
                "repo add URL" ;
                "\tAdd repository" ;
                "remove URL" ;
                "\t Remove repository"]

    let cp_usage = 
      unlines ["cp list" ;
                "\tList the classpath for the current Jark server" ;
                "cp add args+" ;
                "\tAdd to the classpath for the current Jark server";
                "cp run main-class" ;
                "\tRun main-class on the current Jark server"]

    let ns_usage = 
      unlines ["ns list (prefix)?" ;
               "\tList all namespaces in the classpath. Optionally takes a namespace prefix" ;
               "ns find prefix" ;
               "\tFind all namespaces starting with the given name" ;
               "ns load file" ;
               "\tLoads the given clj file, and adds relative classpath" ;
               "ns run main-ns args*" ;
               "\tRuns the given main function with args" ;
               "ns repl namespace" ;
               "\tLaunch a repl at given ns" ]

    let package_usage = 
      unlines ["package install (--package -p PACKAGE) [--version -v]" ;
                "\tInstall the relevant version of package from clojars" ;
                "package uninstall (--package -p PACKAGE)" ;
                 "\tUninstall the package" ;
                "package versions (--package -p PACKAGE)" ;
                "\tList the versions of package installed" ;
                "package deps (--package -p PACKAGE) [--version -v]" ;
                "\tPrint the library dependencies of package" ;
                "package search (--package -p PACKAGE)" ;
                "\tSearch clojars for package" ;
                "package installed" ;
                "\tList all packages installed" ;
                 "package latest (--package -p PACKAGE)" ;
                 "\tPrint the latest version of the package" ]

    let usage =
      unlines ["cp\tlist add" ;
               "doc\tsearch examples comments" ;
               "ns\tlist find load run repl" ;
               "package\tinstall uninstall versions deps search installed latest" ;
               "repo\tlist add remove" ;
               "vm\tstart connect stop stat uptime threads" ]

    let vm_start ?(run = 0) =
      if run=1 then begin
        Sys.command "java -cp \"/$HOME/.cljr/lib/*\" jark.vm 9000 &";
        Unix.sleep 5;
        "Started JVM on port 9000"
      end
      else "Not starting JVM"

    (* commands *)

    let cp cmd ?(arg = []) =
      match cmd with
      | "usage"   -> cp_usage
      | "help"    -> cp_usage
      | "list"    -> "Listing classpath"
      | "add"     -> "Adding jar " ^ (String.concat " " arg)
      |  _        -> cp_usage

    let vm cmd ?(arg = []) =
      match cmd with
      | "usage"   -> vm_usage
      | "start"   -> vm_start ~run:1
      | "connect" -> "Connecting vm" ^ (String.concat " " arg)
      | "stat"    -> "VM stat"
      | "uptime"  -> "VM uptime"
      | "thread"  -> "VM threads"
      |  _        -> vm_usage

    let ns cmd ?(arg = []) =
      match cmd with
      | "usage"   -> ns_usage
      | "list"    -> "List namespaces"
      | "find"    -> "find namespaces " ^ (String.concat " " arg)
      | "load"    -> "Load namespace"
      | "run"     -> "run namespace"
      | "repl"    -> "repl"
      |  _        -> ns_usage

    let package cmd ?(arg = []) =
      match cmd with
      | "usage"     -> package_usage
      | "install"   -> "Install package"
      | "uninstall" -> "Uninstall package " ^ (String.concat " " arg)
      | "versions"  -> "package versions"
      | "deps"      -> "dependencies"
      | "installed" -> "install a package"
      | "latest"    -> "Latest"
      |  _          -> package_usage

    let version = 
      "version 0.4"

  end
 
