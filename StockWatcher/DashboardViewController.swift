//
//  DashboardViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/21/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import GoogleMobileAds
import SVProgressHUD

class DashboardTableViewCell : UITableViewCell {
    @IBOutlet weak var lblStockCodeD: UILabel!
    @IBOutlet weak var imgStockMovement: UIImageView!
    @IBOutlet weak var lblAmountValue: UILabel!
    @IBOutlet weak var lblVolumeValue: UILabel!
}

class DashboardViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, GADBannerViewDelegate{

    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var ps:[Portfolio] = [Portfolio]()
    var bannerView: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        //Manage userpool
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoSigninProviderKey)
        if self.user == nil {  self.user = self.pool?.currentUser() }
        self.refresh()
        
        //Adview
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = AdManager.test.banner
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchP()
    }
   
    
    var stocks: [NSManagedObject] = []
    func searchP(){
        
        SVProgressHUD.show(withStatus: "Loading stocks...")
       
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
                            
                            portfolio.code = (p.value(forKey: "scode") as! String)
                            DispatchQueue.global(qos: .default).async {
                                    self.getData(stock: portfolio.code!){
                                        (result) -> () in
                                        portfolio.amount = result.amount!
                                        portfolio.percent = result.percent!
                                        group.leave()
                                    }
                            }
                            
                            group.wait()
                            self.ps.append(portfolio)
                        }
                    SVProgressHUD.dismiss()
                    tableView.reloadData()
                
                }else{
                    SVProgressHUD.dismiss()
                    tableView.setEmptyView(title: "Empty Watchlist", message: "Press search stocks")
                }
            }catch let error as NSError {
                let alert = UIAlertController(title: "", message: "Error getting stocks", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print(error)
            }
    }
    
    @IBAction func btnLogoutDashboardTapped(_ sender: Any) {
        self.user?.signOut()
        self.response = nil
        self.refresh()
    }
    
    //TODO:- Work on segue to detect internet connectivity..
    
    @IBAction func btnPortfolioPressed(_ sender: Any) {
        if appDelegate?.connectivityStatus == true{
            
        }else{
            print("no network detected...")
        }
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
            
            if appDelegate?.connectivityStatus == true {
                
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
            }else{
                print("error on connectiviy")
            }
        }
    }
    
    func getData(stock: String, completion: @escaping ( _ result: Portfolio)->()) {
        
        guard let url = URL(string: "http://phisix-api4.appspot.com/stocks/\(stock).json") else {return}
        let task = URLSession.shared.dataTask(with: url){data,reponse,error in
            guard let dataResponse = data,error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                let alert = UIAlertController(title: "", message: "Cant check updates", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
                return
            }
            
            print("dataResponse \(dataResponse.count)")
            
            guard let rootJSON = try? JSONSerialization.jsonObject(with: dataResponse, options: [])else {
                return
            }
            
            if dataResponse.count > 0 {
            
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
            }else{
                print("cannot connect...")
            }
            
        }
        
        
        task.resume()
    }
}

//tableview
let appDelegate = UIApplication.shared.delegate as? AppDelegate
extension DashboardViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //TODO:- Check internet connectivity here...
       
        if ps.count == 0 {
            print("ps count \(ps.count)")
            if appDelegate?.connectivityStatus == true {
                tableView.setEmptyView(title: "Empty Watchlist", message: "No network access")
            }else{
                 tableView.setEmptyView(title: "Empty Watchlist", message: "Search from the list of stocks")
            }
        }else{
            tableView.restore()
        }
        
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
}

extension DashboardViewController {
    
    //AdBanner
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
}

extension UITableView {
    
    func setEmptyView(title: String, message: String) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        // The only tricky part is here:
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
        
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
}
