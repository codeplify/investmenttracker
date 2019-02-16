//
//  LoginViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/13/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider

class LoginViewController: UIViewController {
var pool: AWSCognitoIdentityUserPool?
    
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pool = AWSCognitoIdentityUserPool.init(forKey: "us-east-2_rDd0DiSnB")
        
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
//        let email = AWSCognitoIdentityUserAttributeType.init()
//        email?.name = "email"
//        email?.value = "loeyagdan@yahoo.com"
        
        //pool.signUp("loey@yahoo.com", password: "12345", userAttributes: nil, validationData: nil)
        
       
        //user.signUp("loey@yahoo.com", password: "agdan", userAttributes: nil, validationData: nil)
        
        self.pool?.signUp("loey@yahoo.com", password: "loeyagdan", userAttributes: nil, validationData: nil)
    }
    
    
  
    
}
