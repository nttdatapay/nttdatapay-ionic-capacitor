import Foundation
import UIKit
import WebKit
import Capacitor
import CommonCrypto
/**
 * Official Ndps ionic capacitor plugin developed by Sagar Gopale
 * Ndps Website: https://nttdatapay.com
 */
@objc(NdpsAESLibraryPlugin)
public class NdpsAESLibraryPlugin: CAPPlugin, WKUIDelegate, WKNavigationDelegate {
    private let implementation = NdpsAESLibrary()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    @objc func NdpsAipayPayments(_ call: CAPPluginCall) {
        let merchData = call.getObject("value") ?? [:]
        ndpsConstants.merchId = merchData["merchId"] as Any as! String
        ndpsConstants.password = merchData["password"] as Any as! String
        ndpsConstants.merchTxnId = merchData["merchTxnId"] as Any as! String
        ndpsConstants.product = merchData["product"] as Any as! String
        ndpsConstants.custAccNo = merchData["custAccNo"] as Any as! String
        ndpsConstants.txnCurrency = merchData["txnCurrency"] as Any as! String
        ndpsConstants.custFirstName = merchData["custFirstName"] as Any as! String
        ndpsConstants.amount = merchData["amount"] as Any as! String
        ndpsConstants.responseHashKey = merchData["responseHashKey"] as Any as! String
        ndpsConstants.udf1 = merchData["udf1"] as Any as! String
        ndpsConstants.udf2 = merchData["udf2"] as Any as! String
        ndpsConstants.udf3 = merchData["udf3"] as Any as! String
        ndpsConstants.udf4 = merchData["udf4"] as Any as! String
        ndpsConstants.udf5 = merchData["udf5"] as Any as! String
        ndpsConstants.custEmail = merchData["custEmail"] as Any as! String
        ndpsConstants.custMobile = merchData["custMobile"] as Any as! String
        ndpsConstants.encryptionKey = merchData["encryptionKey"] as Any as! String
        ndpsConstants.decryptionKey = merchData["decryptionKey"] as Any as! String
        ndpsConstants.payMode = merchData["payMode"] as Any as! String
        
        let rawJsonString = "{\"payInstrument\":{\"headDetails\":{\"version\":\"OTSv1.1\",\"api\":\"AUTH\",\"platform\": \"FLASH\"},\"merchDetails\":{\"merchId\":\""+ndpsConstants.merchId+"\",\"userId\":\"\",\"password\": \""+ndpsConstants.password+"\",\"merchTxnId\":\""+ndpsConstants.merchTxnId+"\",\"merchTxnDate\":\""+Date.getCurrentDate()+"\"},\"payDetails\":{\"amount\":\""+ndpsConstants.amount+"\",\"product\":\""+ndpsConstants.product+"\", \"custAccNo\":\""+ndpsConstants.custAccNo+"\",\"txnCurrency\":\""+ndpsConstants.txnCurrency+"\"}, \"custDetails\":{\"custFirstName\":\""+ndpsConstants.custFirstName+"\",\"custEmail\": \""+ndpsConstants.custEmail+"\",\"custMobile\":\""+ndpsConstants.custMobile+"\"},\"extras\":{\"udf1\": \""+ndpsConstants.udf1+"\",\"udf2\":\""+ndpsConstants.udf2+"\",\"udf3\": \""+ndpsConstants.udf3+"\",\"udf4\": \""+ndpsConstants.udf4+"\",\"udf5\":\""+ndpsConstants.udf5+"\"}}}";
    
        print("json generated: ", rawJsonString)
        let getAtomEncryption = getAtomEncryption(plainText: rawJsonString, key: merchData["encryptionKey"] as? String)!;
        let parameters = "encData="+getAtomEncryption+"&merchId="+ndpsConstants.merchId
        let postData =  parameters.data(using: .utf8)
        var authUrl = ndpsConstants.prodAuthAPIUrl
        if(ndpsConstants.payMode == "uat"){
            authUrl = ndpsConstants.uatAuthAPIUrl
        }
       
         var request = URLRequest(url: URL(string: authUrl)!,timeoutInterval: Double.infinity)
         request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
         request.httpMethod = "POST"
         request.httpBody = postData
         let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
           guard let data = data else {
             print(String(describing: error))
             return
           }
           let authAPIResponse = String(data: data, encoding: .utf8)!
           if !authAPIResponse.isEmpty {
               let string = authAPIResponse.replacingOccurrences(of: "encData=", with: "")
               let temp = string.replacingOccurrences(of: "merchId=\(ndpsConstants.merchId)", with: "")
               let decyptedResponse = getAtomDecryption(cipherText: temp, key: merchData["decryptionKey"] as? String)
               if decyptedResponse != nil {
                   do {
                       let authResponseData = Data(decyptedResponse!.utf8)
                       if let json = try JSONSerialization.jsonObject(with: authResponseData, options: []) as? [String: Any] {
                           ndpsConstants.AtomTokenId = String(describing: json["atomTokenId"]!)
                          
                           DispatchQueue.main.async {
                             let webView = WKWebView(frame: (self.bridge?.viewController!.view.bounds)!)
                               var loadLocalHtmlFile = "aipay-prod";
                               if(ndpsConstants.payMode == "uat"){
                                   loadLocalHtmlFile = "aipay-uat";
                               }
                               guard let fileURL = Bundle(for: type(of: self)).url(forResource: loadLocalHtmlFile, withExtension:"html") else {
                                      print("Local html file for aipay payments not found")
                                      return
                               }
                               self.bridge?.viewController!.view.addSubview(webView)
                               let request = URLRequest(url: fileURL)
                               webView.navigationDelegate = self
                               webView.uiDelegate = self
                               self.webView = webView
                               if #available(iOS 14.0, *) {
                                   webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
                               } else {
                                   webView.configuration.preferences.javaScriptEnabled = true // Fallback on earlier versions
                               }
                               webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
                               webView.load(request)
                               webView.allowsBackForwardNavigationGestures = true
                           }
                       }
                   } catch let error as NSError {
                       print("Failed to load NDPS payments : \(error.localizedDescription)")
                   }
               }else{
                   print("NDSPS plugin decryption issue found", authAPIResponse)
               }
           } else {
               print("Auth API request failed with blank response")
               NdpsUtils.showToast(controller: (self.bridge?.viewController)!, message: "Ndps Auth API request failed with blank response", seconds: 2)
           }
         }
         task.resume()
         call.resolve(["value": "Running ndps ionic plugin" as Any])
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString{
               if url.contains("aipay-uat.html") ||  url.contains("aipay-prod.html") {
                   webView.evaluateJavaScript("mainInit('"+ndpsConstants.AtomTokenId+"','"+ndpsConstants.merchId+"','"+ndpsConstants.custEmail+"','"+ndpsConstants.custMobile+"');", completionHandler: { (value, err) in
                     if let error = err {
                          print("Error: ", error)
                     }
                })
               }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      if let urlStr = navigationAction.request.url?.absoluteString {
          if urlStr.contains("mobilesdk/param") {
               if let response = navigationAction.request.httpBody {
                let responseStr = String(decoding: response, as: UTF8.self)
                var finalResponseString = "";
               if(responseStr.contains("cancelTransaction")){
                   finalResponseString = NdpsUtils.getCancelTransactionMsg()
               } else if(responseStr.contains("upiIntentResponse")){
                    let replaced = responseStr.replacingOccurrences(of: "&upiIntentResponse=upiIntentResponse", with: "")
                    let merchIdReplaced = replaced.replacingOccurrences(of: "&merchId=\(ndpsConstants.merchId)", with: "")
                    let encDataReplaced = merchIdReplaced.replacingOccurrences(of: "encData=", with: "")
                    let UPIIntentFormattedResponseFunc = self.UPIIntentFormattedResponse(finaltrim: encDataReplaced)
                    finalResponseString = UPIIntentFormattedResponseFunc
               } else {
                    let string = responseStr.replacingOccurrences(of: "encData=", with: "")
                    let temp = string.replacingOccurrences(of: "merchId=\(ndpsConstants.merchId)", with: "")
                    finalResponseString = getAtomDecryption(cipherText: temp, key: ndpsConstants.decryptionKey) ?? "NA"
                }

                self.bridge!.triggerWindowJSEvent(eventName: "ndps_pg_response", data: "{ 'response': '"+finalResponseString+"' }")
                DispatchQueue.main.async {
                    webView.stopLoading()
                    webView.removeFromSuperview()
                }
            }
            decisionHandler(.cancel)
          }else if let url = navigationAction.request.url,
                   url.absoluteString.hasPrefix("upi://") {
              let checkPhonePe = NdpsUtils.isAppInstalled("phonepe")
              let checkPayTM = NdpsUtils.isAppInstalled("paytmmp")
              let checkGPay = NdpsUtils.isAppInstalled("tez")
              if(checkPhonePe || checkPayTM || checkGPay) {
                  let aipayBundle = Bundle(for: SheetViewController.self)
                  let mainStoryboard = UIStoryboard(name: "Sheet", bundle: aipayBundle)
                  let aipayCustomDrawerViewController = mainStoryboard.instantiateViewController(withIdentifier: "SheetViewController") as! SheetViewController
                  aipayCustomDrawerViewController.upiIntentURL = url.absoluteString
                  aipayCustomDrawerViewController.checkPhonePe = checkPhonePe
                  aipayCustomDrawerViewController.checkPayTM = checkPayTM
                  aipayCustomDrawerViewController.checkGPay = checkGPay
                  self.bridge?.viewController?.present(aipayCustomDrawerViewController, animated: true, completion: {
                      aipayCustomDrawerViewController.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
                    })
              }else{
                  NdpsUtils.showToast(controller: (self.bridge?.viewController)!, message: "No UPI app found!", seconds: 2)
              }
              decisionHandler(.cancel)
         } else {
            decisionHandler(.allow)
        }
      }
    }
    
    private func getAtomEncryption(plainText: String!, key: String!) -> String? {
          let pswdIterations:UInt32 = 65536
          let keySize:UInt = 32
          let ivBytes: Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
                let derivedKey = PBKDF.deriveKey(password: key,
                                                 salt: key,
                                                 prf: .sha512,
                                                 rounds: pswdIterations,
                                                 derivedKeyLength: keySize)
                let cryptor = Cryptor(operation: .encrypt,
                                      algorithm: .aes,
                                      options: [.PKCS7Padding],
                                      key: derivedKey,
                                      iv: ivBytes)
                let cipherText = cryptor.update(plainText)?.final()
                let hexStr = hexString(fromArray:cipherText.map{$0}!)
                return hexStr.uppercased()
    }
    
    public func hexString(fromArray : [UInt8], uppercase : Bool = false) -> String {
           return fromArray.map() { String(format:uppercase ? "%02X" : "%02x", $0) }.reduce("", +)
    }
    
    public func getAtomDecryption(cipherText: String!, key: String!) -> String? {
            let pswdIterations:UInt32 = 65536
            let keySize:UInt = 32
            let ivBytes: Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
               let derivedKey = PBKDF.deriveKey(password: key,
                                                salt: key,
                                                prf: .sha512,
                                                rounds: pswdIterations,
                                                derivedKeyLength: keySize)
               let cryptor = Cryptor(operation: .decrypt,
                                     algorithm: .aes,
                                     options: [.PKCS7Padding],
                                     key: derivedKey,
                                     iv: ivBytes)
          if let data = hexadecimal(content: cipherText!),
                  let decryptedPlainText = cryptor.update(data)?.final() {
                   let decryptedString = String(bytes: decryptedPlainText,
                                                encoding: .utf8)
                   return decryptedString
               }
               return nil
           }
    
       public func hexadecimal(content: String!) -> Data? {
                let regexPattern = "[0-9a-f]{1,2}";
                var data = Data(capacity: content.count / 2)
                let regex = try! NSRegularExpression(pattern: regexPattern,
                                                     options: .caseInsensitive)
                regex.enumerateMatches(in: content,
                                       options: [],
                                       range: NSMakeRange(0, content.count)) { match, flags, stop in
                    let byteString = (content as NSString).substring(with: match!.range)
                    var num = UInt8(byteString, radix: 16)!
                    data.append(&num, count: 1)
                }
                guard data.count > 0 else {
                    return nil
                }
                return data
      }
    
    func UPIIntentFormattedResponse(finaltrim: String) -> String {
        struct payDetails: Codable {
         let atomTxnId: Int
         let product: String
         let amount: Double
         let surchargeAmount: Double
         let totalAmount: Double
        }

       struct merchDetails: Codable {
         let merchId: Int
         let merchTxnId: String
         let merchTxnDate: String
       }

       struct settlementDetails: Codable {
         let reconStatus: String
       }

       struct bankDetails: Codable {
         let otsBankId: Int
         let bankTxnId: String
         let otsBankName: String
       }

       struct payModeSpecificData: Codable {
         let subChannel: String
         let bankDetails: bankDetails
       }

       struct responseDetails: Codable {
         let statusCode: String
         let message: String
         let description: String
       }

       struct payInstrumentDetails: Codable {
         let settlementDetails: settlementDetails
         let merchDetails: merchDetails
         let payDetails: payDetails
         let payModeSpecificData: payModeSpecificData
         let responseDetails: responseDetails
       }

       struct payInstrument: Codable {
         let payInstrument: [payInstrumentDetails]
       }
       
       struct testGetDataDirectJson: Codable {
           var payInstrument: String
       }

       let upiStrResponse = getAtomDecryption(cipherText: finaltrim, key: ndpsConstants.decryptionKey) ?? "NA"
       let upiStrResponseData = Data(upiStrResponse.utf8)
        
       do{
           let upiStrResponse = try JSONDecoder().decode(payInstrument.self, from: upiStrResponseData)
           
           let setMerchDetailsJson = merchDetails(merchId: upiStrResponse.payInstrument[0].merchDetails.merchId, merchTxnId: upiStrResponse.payInstrument[0].merchDetails.merchTxnId, merchTxnDate: upiStrResponse.payInstrument[0].merchDetails.merchTxnDate)
           
           let setResponseDetailsJson = responseDetails(statusCode: upiStrResponse.payInstrument[0].responseDetails.statusCode, message: upiStrResponse.payInstrument[0].responseDetails.message, description: upiStrResponse.payInstrument[0].responseDetails.description)
           
           struct payModeSpecificData: Codable {
             let subChannel: [String]
             let bankDetails: bankDetails
           }
           
           let setPayModeSpecificDataJson = payModeSpecificData(subChannel: ["upi"], bankDetails: bankDetails(otsBankId: upiStrResponse.payInstrument[0].payModeSpecificData.bankDetails.otsBankId, bankTxnId: upiStrResponse.payInstrument[0].payModeSpecificData.bankDetails.bankTxnId, otsBankName: upiStrResponse.payInstrument[0].payModeSpecificData.bankDetails.otsBankName))
           
           struct payInstrumentBodyJson: Codable {
             let merchDetails: merchDetails
             let payDetails: payDetails
             let payModeSpecificData: payModeSpecificData
             let responseDetails: responseDetails
           }
           
           struct payInstrumentJson: Codable {
             let payInstrument: payInstrumentBodyJson
           }
           
           let NewTotalAmount = upiStrResponse.payInstrument[0].payDetails.totalAmount
           
           let NewSurchargeAmount = upiStrResponse.payInstrument[0].payDetails.surchargeAmount
           
           let NewAmount = upiStrResponse.payInstrument[0].payDetails.amount
           
           let setpayDetailsJson = payDetails(atomTxnId: upiStrResponse.payInstrument[0].payDetails.atomTxnId, product: upiStrResponse.payInstrument[0].payDetails.product, amount: NewAmount, surchargeAmount: NewSurchargeAmount, totalAmount: NewTotalAmount)
           
           let setPayInstrumentBodyJson = payInstrumentBodyJson(merchDetails: setMerchDetailsJson, payDetails: setpayDetailsJson, payModeSpecificData: setPayModeSpecificDataJson, responseDetails: setResponseDetailsJson)
           
           let setPayInstrumentMainJson = payInstrumentJson(payInstrument: setPayInstrumentBodyJson)
           let getFinalUPIIntentResponse = String(try! NdpsUtils.encodeData(setPayInstrumentMainJson))
           return getFinalUPIIntentResponse
       }catch {
           print("Error has been occured in UPi Intent response handling")
       }
       return String()
    }
    
}
