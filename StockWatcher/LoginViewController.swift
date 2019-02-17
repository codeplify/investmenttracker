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
    var sentTo: String?
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoSigninProviderKey)
      
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
     
        //put textfield here...
       // if let emailValue = "loey.agdan@yahoo.com", !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = "loey.agdan@yahoo.com"
            attributes.append(email!)
//        }
        
        print("pool must execute")
        self.pool?.signUp("loey.agdan@yahoo.com", password: "swordfish1925", userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    print(error)
                } else if let result = task.result  {
                    print(result)
                }
                
            })
            return nil
        }
        }
    }
    
    
  
    

