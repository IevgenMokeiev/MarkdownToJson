// String+Extensions

import Foundation

extension String {
    
    func slice(from: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        return String(self[rangeFrom..<self.endIndex])
    }
    
    func slice(to: String) -> String? {
        guard let rangeTo = self.range(of: to)?.lowerBound else { return nil }
        return String(self[self.startIndex..<rangeTo])
    }
    
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
    func sliceOrEnd(from: String, to: String) -> String? {
        let slice = slice(from: from, to: to)
        if let slice {
            return slice
        } else {
            return self.slice(from: from)
        }
    }
    
    func allSlices(from: String, to: String) -> [String] {
        components(separatedBy: from).dropFirst().compactMap { sub in
            (sub.range(of: to)?.lowerBound).flatMap { endRange in
                String(sub[sub.startIndex ..< endRange])
            }
        }
    }
    
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
