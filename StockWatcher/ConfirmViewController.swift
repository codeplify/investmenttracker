//
//  ConfirmViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/17/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import SVProgressHUD

class ConfirmViewController: UIViewController {

    @IBOutlet weak var txtConfirmationCode: UITextField!
    var user: AWSCognitoIdentityUser?
    
    var destination: String?
    var mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
 
    @IBAction func btnConfirmTapped(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Confirming...")
        
        guard let confirmationCodeValue = self.txtConfirmationCode.text, !confirmationCodeValue.isEmpty else{
            return
        }
        
        self.user?.confirmSignUp(self.txtConfirmationCode.text!).continueWith {
            [weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            
            DispatchQueue.main.async {
                if let error = task.error as NSError? {
                    SVProgressHUD.dismiss()
                    print("error => \(error)")
                    let alertController = UIAlertController(title: "", message: "\(error)", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    strongSelf.present(alertController, animated: true)
                }else{
                    SVProgressHUD.dismiss()
                    let alertController = UIAlertController(title: "", message: "Confirmation code success", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    strongSelf.present(alertController, animated: true)
                }
            }
            
            return nil
        }
    }
    
}

extension ConfirmViewController : AWSCognitoIdentityMultiFactorAuthentication {
    
    func didCompleteMultifactorAuthenticationStepWithError(_ error: Error?) {
        DispatchQueue.main.async(execute: {
            if let error = error as NSError? {
                
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func getCode(_ authenticationInput: AWSCognitoIdentityMultifactorAuthenticationInput, mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>) {
        self.mfaCodeCompletionSource = mfaCodeCompletionSource
        self.destination = authenticationInput.destination
    }
    
}
