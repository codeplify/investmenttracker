//
//  LoginViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/13/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import SVProgressHUD
import AWSCognitoIdentityProvider

class LoginViewController: UIViewController{
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var usernameText: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.txtPassword.text = nil
        self.txtUsername.text = usernameText
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Signing in...")
        if self.txtUsername.text != nil && self.txtPassword.text != nil {
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.txtUsername.text!, password: self.txtPassword.text!)
            
            self.passwordAuthenticationCompletion?.set(result: authDetails)
            SVProgressHUD.dismiss()
            
        }else{
            let alertController = UIAlertController(title: "", message: "invalid username", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
            SVProgressHUD.dismiss()
        }
    }
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
            
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        
        print("get details reached...")
        DispatchQueue.main.async{
            if self.usernameText == nil {
                self.usernameText = authenticationInput.lastKnownUsername
                print(authenticationInput.lastKnownUsername)
            }
        }
    }

    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                print(error)
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.txtUsername.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}


    
    
  
    

