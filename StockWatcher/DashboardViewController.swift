//
//  DashboardViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/21/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class DashboardViewController: UIViewController {
    
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoSigninProviderKey)
        if self.user == nil {
            self.user = self.pool?.currentUser()
            print("Login value: \(self.user?.username)")
        }
        
        self.refresh()
    }
    
    @IBAction func btnLogoutDashboardTapped(_ sender: Any) {
        self.user?.signOut()
        self.response = nil
        self.refresh()
        
    }
    
    
    @IBAction func btnPortfolioPressed(_ sender: Any) {
        
    }
    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result

            })
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToStocks"  {
            
            //            if let splitViewController = window!.rootViewController as? UISplitViewController {
            //                let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
            //                navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            //                splitViewController.preferredDisplayMode = .allVisible
            //                splitViewController.delegate = self
            //
            //                UISearchBar.appearance().tintColor = .candyGreen
            //                UINavigationBar.appearance().tintColor = .candyGreen
            //            }
            
            guard let splitViewController = segue.destination as? UISplitViewController,
                let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
                let masterViewController = leftNavController.topViewController as? MasterViewController,
                let rightNavController = splitViewController.viewControllers.last as? UINavigationController,
                let detailViewController = rightNavController.topViewController as? DetailViewController
                else { fatalError() }
            
            masterViewController.navigationItem.leftItemsSupplementBackButton = true
            masterViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            
            UISearchBar.appearance().tintColor = .candyGreen
            UINavigationBar.appearance().tintColor = .candyGreen
            
            navigationController?.pushViewController(masterViewController, animated: true)
        }
    }

}
