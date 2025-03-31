//  NdpsUtils.swift
//  Created by Atom Technologies on 01/10/23.

import Foundation

class NdpsUtils {
    
    init() {
    }
    
    static func isAppInstalled(_ appName:String) -> Bool {
       let appScheme = "\(appName)://app"
       let appUrl = URL(string: appScheme)
       if UIApplication.shared.canOpenURL(appUrl! as URL) {
         return true
       } else {
         return false
       }
   }
    
    static func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        controller.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    static func getCancelTransactionMsg() -> String {
            var finalCancelResponse = ""
            struct responseObjectDetails: Codable {
                var statusCode: String
                var message: String
                var description: String
            }
            struct responseDetailsJson: Codable {
                var responseDetails: responseObjectDetails
            }
            struct payInstrumentJson: Codable {
                var payInstrument: responseDetailsJson
            }
            let responseDetailsObject = responseObjectDetails(statusCode: "OTS0101", message: "CANCELLED", description: "TRANSACTION IS CANCELLED BY USER ON PAYMENT PAGE.")
            let tresponseDetails = responseDetailsJson(responseDetails: responseDetailsObject)
            let payInstrument = payInstrumentJson(payInstrument: tresponseDetails)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .withoutEscapingSlashes
        do {
            let jsonData = try jsonEncoder.encode(payInstrument)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            finalCancelResponse =  jsonString
        } catch {
            print(Error.self)
        }
        return finalCancelResponse
    }
    
    static func encodeData<T : Encodable>(_ options: T) throws -> String {
          do {
              let jsonEncoder = JSONEncoder()
                  jsonEncoder.outputFormatting = .withoutEscapingSlashes
              let json = try jsonEncoder.encode(options)
              if let jsonString = String(data: json, encoding: .utf8) {
                  return jsonString
              }
          }
          catch (let errorStr) {
              print(errorStr)
          }
          return String()
    }
    
}
