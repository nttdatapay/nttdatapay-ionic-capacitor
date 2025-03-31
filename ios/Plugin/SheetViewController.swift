//
//  SheetViewController.swift
//
//  Created by Sagar Gopale Atom Technologies on 26/09/23.
//
import UIKit

class SheetViewController: UIViewController, UISheetPresentationControllerDelegate {
    
    var upiIntentURL = ""
    var checkPhonePe = true
    var checkPayTM = true
    var checkGPay = true
    
    @available(iOS 15.0, *)
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showUPIApps(upiIntentURL: upiIntentURL)
        print("checkPhonePe: " , checkPhonePe, " checkPayTM: ", checkPayTM, " checkGPay: ", checkGPay)
        if #available(iOS 15.0, *) {
            view.backgroundColor = .white
            sheetPresentationController.delegate = self
            sheetPresentationController.selectedDetentIdentifier = .medium
            sheetPresentationController.preferredCornerRadius = 32
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.detents = [
                .medium()
            ]
        }
    }
    
    func showUPIApps(upiIntentURL: String){
        print("upiIntentURL inside: ", upiIntentURL)
        DispatchQueue.main.async { [self] in
            
//            guard let phoneFileURL = Bundle(for: type(of: self)).url(forResource: "phonepe", withExtension:"png") else {
//                      print("png file for aipay payments not found")
//                     return
//            }
        
            if(checkPhonePe) {
                let phonepeimg = UIImage(named: "phonepe.png",
                            in: Bundle(for: type(of: self)),
                            compatibleWith: nil)
                let imageView = UIImageView(image: phonepeimg!)
                imageView.frame = CGRect(x: 30, y: 40, width: 50, height: 50)
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openPhonePeApp(sender:))))
                self.view.addSubview(imageView)
                self.view.bringSubviewToFront(imageView)
            }
            
            if(checkPayTM) {
                let paytmimg = UIImage(named: "paytmLogo.png",
                            in: Bundle(for: type(of: self)),
                            compatibleWith: nil)
                let imageViewPayTM = UIImageView(image: paytmimg!)
                imageViewPayTM.frame = CGRect(x: 120, y: 40, width: 52, height: 52)
                imageViewPayTM.isUserInteractionEnabled = true
                imageViewPayTM.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openPayTMApp(sender:))))
                self.view.addSubview(imageViewPayTM)
                self.view.bringSubviewToFront(imageViewPayTM)
            }
            
            if(checkGPay) {
                let gpayimg = UIImage(named: "gpay.png",
                            in: Bundle(for: type(of: self)),
                            compatibleWith: nil)
                let imageViewGPay = UIImageView(image: gpayimg!)
                imageViewGPay.frame = CGRect(x: 214, y: 40, width: 44, height: 44)
                imageViewGPay.isUserInteractionEnabled = true
                imageViewGPay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openGPayApp(sender:))))
                self.view.addSubview(imageViewGPay)
                self.view.bringSubviewToFront(imageViewGPay)
            }
        }
    }
    
    @objc func openPhonePeApp(sender: UIGestureRecognizer) {
        let replaced = upiIntentURL.replacingOccurrences(of: "upi:", with: "phonepe:")
        let appUrl = URL(string: replaced)
        if UIApplication.shared.canOpenURL(appUrl! as URL) {
            UIApplication.shared.open(appUrl!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func openPayTMApp(sender: UIGestureRecognizer) {
        let replaced = upiIntentURL.replacingOccurrences(of: "upi://pay", with: "paytmmp://upi/pay")
        let appUrl = URL(string: replaced)
        if UIApplication.shared.canOpenURL(appUrl! as URL) {
            UIApplication.shared.open(appUrl!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func openGPayApp(sender: UIGestureRecognizer) {
        let replaced = upiIntentURL.replacingOccurrences(of: "upi://pay", with: "gpay://upi/pay")
        let appUrl = URL(string: replaced)
        if UIApplication.shared.canOpenURL(appUrl! as URL) {
            UIApplication.shared.open(appUrl!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
