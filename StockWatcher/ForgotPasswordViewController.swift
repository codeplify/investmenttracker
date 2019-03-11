//
//  ForgotPasswordViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/22/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ForgotPasswordViewController: UIViewController {

    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var txtEmailAddress: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoSigninProviderKey)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? ConfirmForgotPasswordViewController {
            newPasswordViewController.user = self.user
        }
    }
    
    @IBAction func btnForgotPassword(_ sender: Any) {
        
        guard let username = self.txtEmailAddress.text, !username.isEmpty else {
            
            let alertController = UIAlertController(title: "Missing UserName",
                                                    message: "Please enter a valid user name.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        self.user = self.pool?.getUser(self.txtEmailAddress.text!)
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    strongSelf.performSegue(withIdentifier: "confirmForgotPasswordSegue", sender: sender)
                }
            })
            return nil
        }
    }
    
    

}
