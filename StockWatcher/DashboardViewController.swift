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
    TODO:- Add AdMob
    TODO:- Add Internet connectivity
 */

import UIKit
import AWSCognitoIdentityProvider

class DashboardTableViewCell : UITableViewCell {
    @IBOutlet weak var lblStockCodeD: UILabel!
    @IBOutlet weak var imgStockMovement: UIImageView!
    @IBOutlet weak var lblAmountValue: UILabel!
    @IBOutlet weak var lblVolumeValue: UILabel!
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
        cell.lblAmountValue.text = "\(p.percent!)%"
        cell.lblVolumeValue.text = "\(p.amount!)"
        
        if "\(p.percent!)".contains("-") {
            cell.imgStockMovement.image = UIImage(named: "download-arrow")
        }
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
                    
                    let group = DispatchGroup()
                    group.enter()
                    
                    portfolio.code = p.value(forKey: "scode") as! String
                    print("display code \(portfolio.code)")
                    
                    
                    DispatchQueue.global(qos: .default).async {
                    
                        self.getData(stock: portfolio.code!){
                            (result) -> () in
                            
                            print("amount completion \(result.amount)")
                            portfolio.amount = result.amount!
                            portfolio.percent = result.percent!
                            group.leave()
                        }
                    }
                    
                    group.wait()
                    self.ps.append(portfolio)
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
    
    func getData(stock: String, completion: @escaping ( _ result: Portfolio)->()) {
        guard let url = URL(string: "http://phisix-api4.appspot.com/stocks/\(stock).json") else {return}
        let task = URLSession.shared.dataTask(with: url){data,reponse,error in
            guard let dataResponse = data,error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            print("dataResponse \(dataResponse)")
            
            guard let rootJSON = try? JSONSerialization.jsonObject(with: dataResponse, options: [])else {
                return
            }
            
            print("root json \(rootJSON)")
            var p = Portfolio()
            
            if let JSON = rootJSON as? [String: Any]{
                guard let jsonArray = JSON["stock"] as? [[String:Any]] else {return}
                print("json_array \(jsonArray)")
                
                for json in jsonArray {
                   // guard let symbol = json["symbol"] as? [[String:Any]] else {return}
                   let price = json["price"] as! [String:Any]
                    print("_price \(price["amount"])")
                    p.amount = price["amount"] as! Double
                    p.percent = json["percent_change"] as! Double
                    print("percent \(p.percent)")
                    //TODO:- Create a Handler callback...
                    
                }
                completion(p)
            }
            
        }
        
        task.resume()
    }
    
    /**
     SVProgressHUD.show(withStatus: "Loading stocks...")
     guard let url = URL(string: "http://phisix-api4.appspot.com/stocks.json")else {return}
     
     let task = URLSession.shared.dataTask(with: url){data,response,error in
     guard let dataResponse = data,error == nil else{
     print(error?.localizedDescription ?? "Response Error")
     return
     }
     
     guard let rootJSON = try? JSONSerialization.jsonObject(with: dataResponse, options: []) else {
     print("failed")
     return
     }
     
     if let JSON = rootJSON as? [String:Any]{
     
     guard let jsonArray = JSON["stock"] as? [[String:Any]] else { return }
     
     for json in jsonArray {
     guard let stockName = json["name"] as? String else{ return }
     guard let symbol = json["symbol"] as? String else{ return }
     guard let per = json["percent_change"] else { return }
     guard let vol = json["volume"] as? Int else{ return }
     let price = json["price"] as! [String:Any]
     
     self.candies.append(Candy(category:"\(stockName)", name:"\(symbol)",volume:"\(vol)",percent_change:"\(per)",price:"\(String(describing: price["amount"]!))",currency:"\(String(describing: price["currency"]!))"))
     }
     
     SVProgressHUD.dismiss()
     self.tableView.reloadData()
     self.searchController.isActive = true
     self.searchController.becomeFirstResponder()
     }
     }
     
     task.resume()
     */

}
