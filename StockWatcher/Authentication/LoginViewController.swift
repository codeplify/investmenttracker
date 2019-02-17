//
//  LoginViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/13/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Signing in...")
        
        if self.txtUsername.text != nil && self.txtPassword.text != nil {
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: "loeyagdan0225@gmail.com", password: "loeyagdan123")
            self.passwordAuthenticationCompletion?.set(result: authDetails)
            SVProgressHUD.dismiss()
        }else {
            let alertController = UIAlertController(title: "", message: "Error signing", preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            SVProgressHUD.dismiss()
        }
   }
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication{
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            print("Last known username \(authenticationInput.lastKnownUsername)")
        }
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        if let error = error as NSError? {
            print(error)
        }else{
            print("no error")
        }
    }
    
    
}

    
    
  
    

