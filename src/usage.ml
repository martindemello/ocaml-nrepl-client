 (*pp $PP *)

include Util

(* command usage *)
let vm_usage = 
  unlines ["usage: jark [options] vm <command> <args>";
            "Available commands for 'vm' module:\n";
            "    start     [-p|--port=<9000>] [-j|--jvm_opts=<opts>] [--log=<path>] [-n|--name=<vm-name>]" ;
            "              Start a local Jark server. Takes optional JVM options as a \" delimited string\n" ;
            "    stop      [-n|--name=<vm-name>]";
            "              Shuts down the current instance of the JVM\n" ;
            "    connect   [-a|--host=<localhost>] [-p|--port=<port>] [-n|--name=<vm-name>]" ;
            "              Connect to a remote JVM\n" ;
            "    threads   Print a list of JVM threads\n" ;
            "    uptime    uptime of the current instance of the JVM\n" ;
            "    gc        Run garbage collection on the current instance of the JVM" ]

let repo_usage =
  unlines ["usage: jark [options] repo <command> <args>";
            "Available commands for 'repo' module:\n";
            "    list      List current repositories\n" ;
            "    add       URL" ;
            "              Add repository\n" ;
            "    remove    URL" ;
            "              Remove repository"]

let swank_usage =
  unlines ["usage: jark [options] swank <command> <args>";
            "Available commands for 'swank' module:\n";
            "    start     [--port 4005]" ; 
            "              Start a swank server on given port\n" ;
            "    stop      Stop an instance of the server"]

let cp_usage = 
  unlines ["usage: jark [options] cp <command> <args>";
            "Available commands for 'cp' module:\n";
            "    list      List the classpath for the current instance of the JVM\n" ;
            "    add       path+" ;
            "              Add to the classpath for the current instance of the JVM"]

let ns_usage = 
  unlines ["usage: jark [options] ns <command> <args>";
            "Available commands for 'ns' module:\n";
            "    list      [prefix]" ;
            "              List all namespaces in the classpath. Optionally takes a namespace prefix\n" ;
            "    load      [--env=<string>] file" ;
            "              Loads the given clj file, and adds relative classpath"]

let package_usage = 
  unlines ["usage: jark [options] package <command> <args>";
            "Available commands for 'package' module:\n";
            "    install    -p|--package <package> [-v|--version <version>]" ;
            "               Install the relevant version of package from clojars\n" ;
            "    uninstall  -p|--package <package>" ;
            "               Uninstall the package\n" ;
            "    versions   -p|--package <package>" ;
            "               List the versions of package installed\n" ;
            "    deps       -p|--package <package> [-v|--version <version>]" ;
            "               Print the library dependencies of package\n" ;
            "    search     -p|--package <package>" ;
            "               Search clojars for package\n" ;
            "    list       List all packages installed\n" ;
            "    latest     -p|--package <package>" ;
            "               Print the latest version of the package" ]

let usage =
  unlines ["usage: jark [-v|--version] [-h|--help]" ;
            "            [-r|repl] [-e|--eval]" ;
            "            [-a|--host=<hostname>] [-p|--port=<port>] <module> <command> <args>" ;
            "";
            "The most commonly used jark modules are:" ;
            "    cp       list add" ;
            "    doc      search examples comments" ;
            "    ns       list find load run repl" ;
            "    package  install uninstall versions deps search installed latest" ;
            "    repo     list add remove" ;
            "    swank    start stop" ;
            "    vm       start connect stop stat uptime threads gc";
            "";
            "See 'jark <module>' for more information on a specific module."]
