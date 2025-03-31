import Foundation

@objc public class NdpsAESLibrary: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
