//
//  DashboardViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/21/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

/**
    TODO:- Add loading current status of invested stocks
    TOFIX:- Back button on detailview fix splitview issue
    TOD0:- Add AdMob
 */

import UIKit
import AWSCognitoIdentityProvider

class DashboardTableViewCell : UITableViewCell {
    @IBOutlet weak var lblStockCodeD: UILabel!
    @IBOutlet weak var imgStockMovement: UIImageView!
}

class DashboardViewController: UIViewController, UITableViewDelegate , UITableViewDataSource{

    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var ps:[Portfolio] = [Portfolio]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoSigninProviderKey)
        if self.user == nil {
            self.user = self.pool?.currentUser()
            print("Login value: \(self.user?.username)")
        }
        
        self.searchP()
        self.refresh()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ps count \(stocks.count)")
        return ps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:DashboardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellDashboard")! as! DashboardTableViewCell
        
        let p = ps[indexPath.row]
        print("stock \(stocks.count)")
        cell.lblStockCodeD.text = "\(p.code!)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    var stocks: [NSManagedObject] = []
    func searchP(){
        
        print("Search Investment...")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StocksDB")
        
        
        do{
            stocks = try managedContext.fetch(fetchRequest)
            
            
            if stocks.count > 0 {
                print("stock count \(stocks.count)")
                ps.removeAll()
                
                for p in stocks{
                    let portfolio = Portfolio()
                    
                    portfolio.code = p.value(forKey: "scode") as! String
                    print("display code \(portfolio.code)")
                    
                    if ps.count <= 2 {
                        ps.append(portfolio)
                    }
                    //TODO:- Find stocks and get updates from api current status of the stock
                }
                
                print("ps count \(ps.count)")
                
            }else{
                print("portfolio not found")
            }
        }catch let error as NSError {
            print(error)
        }
        
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
            
//            detailViewController.navigationItem.leftItemsSupplementBackButton = true
//            detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
//            
            UISearchBar.appearance().tintColor = .candyGreen
            UINavigationBar.appearance().tintColor = .candyGreen
            
            
            
            navigationController?.pushViewController(masterViewController, animated: true)
        }
    }

}
