//
//  AtomtechPayments+Extension.swift
//  AtomtechPayments
//
//  Created by Datamatics on 28/04/22.
//

import Foundation
import CommonCrypto

extension String {
    /// To get the formatted amount
    /// - Returns: Retuns the amount with proper decimal format
    func getFormattedAmount() -> String {
        let price = Double(self)
        let strPrice = String(format: "%.2f", price ?? 0.0)
        return strPrice
    }
    
    /// To get signature hex string
    /// - Parameter key: Pass the request hash key
    /// - Returns: Retuns the HMAC (HEX)string
    func hmac(hashKey key: String) -> String {
        var digest = [UInt8](repeating: 0,
                             count: Int(CC_SHA512_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512),
               key,
               key.count,
               self,
               self.count,
               &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Date {
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}
