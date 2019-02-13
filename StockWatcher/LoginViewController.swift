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
import AWSCognito

class LoginViewController: UIViewController {

    
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: "us-east-2_rDd0DiSnB")
        let configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider: credentialProvider)
        
        AWSServiceManager.default()?.defaultServiceConfiguration = configuration
        
       
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
