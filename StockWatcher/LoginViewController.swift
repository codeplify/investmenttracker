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

    
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
         setupCognitoUserPool()

       
        
       
    
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
        let email = AWSCognitoIdentityUserAttributeType.init()
        email?.name = "email"
        email?.value = "loeyagdan@yahoo.com"
        
        //pool.signUp("loey@yahoo.com", password: "12345", userAttributes: nil, validationData: nil)
    }
    
    
    func setupCognitoUserPool(){
        let clientId = "339tdnbbo4u0jqr4i4ri52oaio"
        let poolId = "us-east-2_rDd0DiSnB"
        let clientSecret = "1a73ina32e6h3ng9cdvv3e52pf11av5b465cpdbv6ndhsui8igap"
        //let region = "us-east-2"
        
        let serviceConfiguration: AWSServiceConfiguration = AWSServiceConfiguration(region: .USEast2, credentialsProvider: nil)
        let cognitoConfiguration: AWSCognitoIdentityUserPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: clientSecret, poolId: poolId)
        
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: cognitoConfiguration, forKey: poolId)
    }
    
}
