import Basic
import Darwin
import Foundation

let system_glob = Darwin.glob

extension AbsolutePath {
    static var current: AbsolutePath {
        return AbsolutePath(FileManager.default.currentDirectoryPath)
    }

    public func glob(_ pattern: String) -> [AbsolutePath] {
        var gt = glob_t()
        let cPattern = strdup(pattern)
        defer {
            globfree(&gt)
            free(cPattern)
        }

        let flags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
        if system_glob(cPattern, flags, nil, &gt) == 0 {
            let matchc = gt.gl_matchc
            return (0 ..< Int(matchc)).compactMap { index in
                if let path = String(validatingUTF8: gt.gl_pathv[index]!) {
                    return AbsolutePath(path)
                }
                return nil
            }
        }
        return []
    }
}
