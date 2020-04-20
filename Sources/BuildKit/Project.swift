/**
    Project.swift
    BuildKit
 
    Created by Tibor Bödecs on 2019.01.01.
    Copyright Binary Birds. All rights reserved.
 */

import ShellKit

/// Representation of a Swift project
public final class Project: Shell {

    /// build configurations
    public enum BuildConfig: String {
        /// debug build configuration
        case debug
        /// release build configuration
        case release
    }

    /// basic commands [build, run, package, test]
    public enum Command {

        /// package subcommands
        public enum Subcommand {

            /// --type   empty|library|executable|system-module
            public enum PackageType: String {
                case empty
                case library
                case executable
                case systemModule = "system-module"
            }

            /// init                    Initialize a new package
            case initialize(PackageType)
            /// update                  Update package dependencies
            case update
            /// generate-xcodeproj      Generates an Xcode project
            case generateXcodeProject
            /// clean                   Delete build artifacts
            case clean
            /// completion-tool         Completion tool (for shell completions)
            case completionTool
            /// describe                Describe the current package
            case describe
            /// dump-package            Print parsed Package.swift as JSON
            case dumpPackage
            /// edit                    Put a package in editable mode
            case edit(String)
            /// reset                   Reset the complete cache/build directory
            case reset
            /// resolve                 Resolve package dependencies
            case resolve
            /// show-dependencies       Print the resolved dependency graph
            case showDependencies
            /// tools-version           Manipulate tools version of the current package
            case toolsVersion
            /// unedit                  Remove a package from editable mode
            case unedit(String)

            fileprivate var rawValue: String {
                switch self {
                case .initialize(let type):
                    return "init --type \(type.rawValue)"
                case .update:
                    return "update"
                case .generateXcodeProject:
                    return "generate-xcodeproj"
                case .clean:
                    return "clean"
                case .completionTool:
                    return "completion-tool"
                case .describe:
                    return "describe"
                case .dumpPackage:
                    return "dump-package"
                case .edit(let name):
                    return "edit \(name)"
                case .reset:
                    return "reset"
                case .resolve:
                    return "resolve"
                case .showDependencies:
                    return "show-dependencies"
                case .toolsVersion:
                    return "tools-version"
                case .unedit(let name):
                    return "unedit \(name)"
                }
            }
        }

        case build
        case run
        case test
        case package(Subcommand)

        fileprivate var rawValue: String {
            switch self {
            case .run:
                return "run"
            case .build:
                return "build"
            case .test:
                return "test"
            case .package(let subcommand):
                return "package \(subcommand.rawValue)"
            }
        }
    }
    
    /// build flags
    public enum Flag {
        /// --help, -h              Display available options
        case help
        /// --configuration, -c     Build with configuration (debug|release) [default: debug]
        case config(BuildConfig)
        
        /// -Xcc                    Pass flag through to all C compiler invocations
        case c(String)
        /// -Xcxx                   Pass flag through to all C++ compiler invocations
        case cxx(String)
        /// -Xlinker                Pass flag through to all linker invocations
        case linker(String)
        /// -Xswiftc                Pass flag through to all Swift compiler invocations
        case swift(String)

        /// for example: -D DEBUG (you only have to provide the value)
        case macro(String)
        /// for example: -target x86_64-apple-macosx10.12 (you only have to provide the value)
        case target(String)
        
        /// - false: --no-static-swift-stdlib Do not link Swift stdlib statically [default]
        /// - true: --static-swift-stdlib   Link Swift stdlib statically
        case stdlib(Bool)
        
        /// --build-path            Specify build/cache directory [default: ./.build]
        case buildPath(String)
        /// --show-bin-path
        case showBinaryPath
        /// --verbose, -v           Increase verbosity of informational output
        case verbose
        
        /// --filter                Run test cases matching regular expression
        ///
        /// Format: `<test-target>.<test-case>` or `<test-target>.<test-case>/<test>`
        case filter(String)
        /// --parallel              Run the tests in parallel.
        case parallel
        /// --list-tests, -l        Lists test methods in specifier format
        case listTests
        /// --generate-linuxmain    Generate LinuxMain.swift entries for the package
        case generateLinuxMain
        /// --enable-code-coverage  Available only from Swift 5.0
        case enableCodeCoverage
        
        /// --disable-prefetching
        case disablePrefetching
        /// --disable-sandbox       Disable using the sandbox when executing subprocesses
        case disableSandbox
        /// --enable-build-manifest-caching Enable llbuild manifest caching [Experimental]
        case enableBuildManifestCaching
        /// --package-path          Change working directory before any other operation
        case packagePath(String)
        /// --sanitize              Turn on runtime checks for erroneous behavior
        case sanitize
        /// --skip-build            Skip building the test target
        case skipBuild
        /// --skip-update           Skip updating dependencies from their remote during a resolution
        case skipUpdate
        
        /// raw string value directly appended to the swift package manager command
        case raw(String)

        
        fileprivate var rawValue: String {
            switch self {
            case .help:
                return "--help"
                
            case .config(let value):
                return "-c \(value.rawValue)"
                
            case .c(let value):
                return "-Xcc \(value)"
            case .cxx(let value):
                return "-Xcxx \(value)"
            case .linker(let value):
                return "-Xlinker \(value)"
            case .swift(let value):
                return "-Xswiftc \(value)"
                
            case .macro(let value):
                return "-Xswiftc \"-D\" -Xswiftc \(value)"
            case .target(let value):
                return "-Xswiftc \"-target\" -Xswiftc \(value)"
            case .stdlib(let value):
                return "--" + (value ? "" : "no-") + "static-swift-stdlib"

            case .buildPath(let value):
                return "--build-path \(value)"
            case .showBinaryPath:
                return "--show-bin-path"
            case .verbose:
                return "-v"

            case .filter(let value):
                return "--filter \(value)"
            case .parallel:
                return "-parallel"
            case .listTests:
                return "--list-tests"
            case .generateLinuxMain:
                return "--generate-linuxmain"
            case .enableCodeCoverage:
                return "--enable-code-coverage"
 
            case .disablePrefetching:
                return "--disable-prefetching"
            case .disableSandbox:
                return "--disable-sandbox"
            case .enableBuildManifestCaching:
                return "--enable-build-manifest-caching"
            case .packagePath(let value):
                return "--package-path \(value)"
            case .sanitize:
                return "--sanitize"
            case .skipBuild:
                return "--skip-build"
            case .skipUpdate:
                return "--skip-update"
                
            case .raw(let value):
                return value
            }
        }
    }
    
    // MARK: - private helper methods
    
    /**
        This method helps to assemble a valid command string
     
        If there is a package path (working directory) presented, proper directories
        will be used & created recursively if a new package is being initialized.
     
        - Parameters:
            - command: The command to be executed
            - flags: Additional flags for the  check the `Flag` enum for more info
     
        - Returns: The command
     */
    private func rawCommand(_ command: Command, flags: [Flag]) -> String {
        var cmd: [String] = []
        // if there is a path let's change directory first
        if let path = self.path {
            // try to create work dir at given path for init command
            if case let .package(subcommand) = command, case .initialize(_) = subcommand {
                cmd += ["mkdir", "-p", path, "&&"]
            }
            cmd += ["cd", path, "&&"]
        }
        cmd += ["swift", command.rawValue]
        let args = flags.map { $0.rawValue }
        cmd += args
        return cmd.joined(separator: " ")
    }
    
    // MARK: - public api

    /// work directory, if peresent a directory change will occur before running any  commands
    ///
    /// NOTE: if the swift package init command is called with a non-existing path, directories
    /// presented in the path string will be created recursively
    public var path: String?
    
    /**
        Initializes a new  object
     
        - Parameters:
            - path: The path of the Swift package (work directory)
            - type: The type of the shell, default: /bin/sh
            - env: Additional environment variables for the shell, default: empty
     
     */
    public init(path: String? = nil, type: String = "/bin/sh", env: [String: String] = [:]) {
        self.path = path

        super.init(type, env: env)
    }

    /**
        Runs a specific command through the current shell.
     
        - Parameters:
            - command: The command to be executed
            - flags: Additional flags for the  check the `Flag` enum for more info
     
        - Throws:
            `ShellError.outputData` if the command execution succeeded but the output is empty,
            otherwise `ShellError.generic(Int, String)` where the first parameter is the exit code,
            the second is the error message
     
        - Returns: The output string of the command without trailing newlines
     */
    @discardableResult
    public func run(_ command: Command, flags: [Flag] = []) throws -> String {
        try self.run(self.rawCommand(command, flags: flags))
    }

    /**
        Async version of the run command
     
        - Parameters:
            - command: The command to be executed
            - flags: Additional flags for the  check the `Flag` enum for more info
            - completion: The completion block with the output and error

        The command will be executed on a concurrent dispatch queue.
     */
    public func run(_ command: Command, flags: [Flag] = [], completion: @escaping ((String?, Swift.Error?) -> Void)) {
        self.run(self.rawCommand(command, flags: flags), completion: completion)
    }
}
