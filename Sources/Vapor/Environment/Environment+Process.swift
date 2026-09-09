import Foundation
#if os(Windows)
import ucrt
#endif

#if os(Windows)
private func setProcessEnv(_ key: String, _ value: String?) {
    _ = key.withCString { k in
        (value ?? "").withCString { v in
            _putenv_s(k, v)
        }
    }
}
#endif

extension Environment {    
    /// The process information of an environment. Wraps `ProcessInto.processInfo`.
    @dynamicMemberLookup public struct Process {
        /// The process information of the environment.
        private let _info: ProcessInfo
        
        /// Creates a new `Process` wrapper for process information.
        ///
        /// - parameter info: The process info that the wrapper accesses. Defaults to `ProcessInto.processInfo`.
        internal init(info: ProcessInfo = .processInfo) {
            self._info = info
        }
        
        /// Gets a variable's value from the process' environment, and converts it to generic type `T`.
        ///
        ///     Environment.process.DATABASE_PORT = 3306
        ///     Environment.process.DATABASE_PORT // 3306
        public subscript<T>(dynamicMember member: String) -> T? where T: LosslessStringConvertible {
            get {
                return self._info.environment[member].flatMap { T($0) }
            }

            nonmutating set (value) {
                #if os(Windows)
                setProcessEnv(member, value?.description)
                #else
                if let raw = value?.description {
                    setenv(member, raw, 1)
                } else {
                    unsetenv(member)
                }
                #endif
            }
        }
        
        /// Gets a variable's value from the process' environment as a `String`.
        ///
        ///     Environment.process.DATABASE_USER = "root"
        ///     Environment.process.DATABASE_USER // "root"
        public subscript(dynamicMember member: String) -> String? {
            get {
                return self._info.environment[member]
            }

            nonmutating set (value) {
                #if os(Windows)
                setProcessEnv(member, value)
                #else
                if let raw = value {
                    setenv(member, raw, 1)
                } else {
                    unsetenv(member)
                }
                #endif
            }
        }
    }
}
