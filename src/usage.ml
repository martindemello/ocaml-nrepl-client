 (*pp $PP *)

include Util

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
