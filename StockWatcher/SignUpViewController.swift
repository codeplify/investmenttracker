//
//  SignUpViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/17/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import SVProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    var pool: AWSCognitoIdentityUserPool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoSigninProviderKey)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?){
        if let signupConfirmationViewController = segue.destination as? ConfirmViewController {
            signupConfirmationViewController.user = self.pool?.getUser(txtEmail.text!)
        }
    }
    
    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Signing up...")
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        if let emailValue = txtEmail.text, !emailValue.isEmpty{
            //TODO:- Check here if valid email
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        self.pool?.signUp(txtEmail.text!, password: txtPassword.text!, userAttributes: attributes, validationData: nil).continueWith{
            [weak self] (task) -> Any? in
            
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async {
                if let error = task.error as NSError? {
                    print(error)
                    SVProgressHUD.dismiss()
                    
                    let alert = UIAlertController(title: "", message: "Error: \(error)", preferredStyle: .alert)
                    self!.present(alert, animated: true)
                    
                }else if let result = task.result {
                    
                    if result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed {
                        strongSelf.performSegue(withIdentifier: "SegueConfirmSignup", sender: sender)
                    }
                    
                    SVProgressHUD.dismiss()
                    print("Result => \(result)")
                }
            }
            
            return nil
        }
        
    }
}
