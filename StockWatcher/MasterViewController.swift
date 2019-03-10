import CoreData
import UIKit
import AWSCognitoIdentityProvider
import SVProgressHUD

//TODO:- Fix loading when stuck in downloading of stocks in dashboard

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UISplitViewControllerDelegate{
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
    
  var wpresenter: WatchlistPresenter?
  var detailViewController: DetailViewController? = nil
  var candies = [Candy]()
  var stocks: [NSManagedObject] = []
  var filteredCandies = [Candy]()
  let searchController = UISearchController(searchResultsController: nil)
  var splitViewController1: UISplitViewController?
 
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchController.searchBar.scopeButtonTitles = ["Watch","Portfolio","All"]
    searchController.searchBar.delegate = self
    tableView.isHidden = false

    DispatchQueue.main.async {
        self.filteredCandies.removeAll()
        self.candies.removeAll()
        self.loadStocks()
    }
    
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Stocks"
    searchController.searchBar.showsScopeBar = true
    
    navigationItem.searchController = searchController
    definesPresentationContext = true

    tableView.tableFooterView = searchFooter
    
    
    if let splitViewController = splitViewController {
        let controllers = splitViewController.viewControllers
        detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    
    navigationItem.backBarButtonItem?.tintColor = .candyGreen
  }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailCandy == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
  func loadStocks(){
    SVProgressHUD.show(withStatus: "Loading stocks...")
        guard let url = URL(string: pseStocksLink)else {return}
        
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
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isPortfolioExist(code: String)->Bool{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return false}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Investment")
            fetchRequest.predicate = NSPredicate(format: "code = %@",code)
            
            var portfolio: [NSManagedObject] = []
            do{
                portfolio = try managedContext.fetch(fetchRequest)
                
                if portfolio.count > 0 {
                    return true
                }
                
            }catch let error as NSError {
                print(error)
                return false
            }
            
            return false
    }
    
    var tempCandies:[Candy] = []
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {

        if(scope == "Watch"){
            filteredCandies.removeAll()
            
            var temp = [Candy]()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StocksDB")
            
            do{
              stocks = try managedContext.fetch(fetchRequest)
                 print("Stock Count => \(stocks.count)")
                temp.removeAll()
                
                    filteredCandies = candies.map {
                        for s in stocks{
                            if $0.name ==  "\(s.value(forKey: "scode")!)" {
                                temp.append($0)
                                print("appended \($0.name)")
                                return $0
                            }
                        }
                        return $0
                    }
                
                    filteredCandies.removeAll()
                    filteredCandies = temp
            }catch let error as NSError {
                print(error)
            }
            
        }else if(scope == "All"){
            print("All shows")
            tableView.isHidden = false
            filteredCandies = candies.filter({( candy : Candy) -> Bool in
                let doesCategoryMatch = (scope == "All") || (candy.category == scope)
                
                if searchBarIsEmpty() {
                    print("doesCategoryMatch\(doesCategoryMatch)")
                    return doesCategoryMatch
                } else {
                    print("doesCategoryMatch- false")
                    return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
                }
            })
        }
        
        if(scope == "Portfolio"){
            
            //MARK:- This is only activated when searchbar is selected
            
            print("Portfolio Listings...")
            filteredCandies.removeAll()
            var temp = [Candy]()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            var temp2 = [Candy]()
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StocksDB")
            var stock2 :[NSManagedObject] = []
            do{
                stock2 = try managedContext.fetch(fetchRequest)
                print("Stock Count => \(stocks.count)")
                temp2.removeAll()
                filteredCandies = candies.map {
                    for s in stocks{
                        if $0.name ==  "\(s.value(forKey: "scode")!)" {
                            
                            if isPortfolioExist(code: $0.name){
                                temp2.append($0)
                                print("appended \($0.name)")
                                return $0
                            }
                            
                        }
                    }
                    return $0
                }
                
                filteredCandies.removeAll()
                filteredCandies = temp2
                
            }catch let error as NSError{
                print(error)
            }
        }
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return true
    }
  
  override func viewWillAppear(_ animated: Bool) {
//    if splitViewController!.isCollapsed {
      if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
        self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
      }
//    }
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
    var c:Int = 0
  // MARK: - Table View
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    if isFiltering() {
        searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
        return filteredCandies.count
    }
    
    searchFooter.setNotFiltering()
    print("stock count \(candies.count)")
    
    return candies.count
  }
   
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let candy: Candy
        if isFiltering() {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
    
        cell.textLabel!.text = candy.name
        cell.detailTextLabel!.text = candy.category
        cell.accessoryType = .disclosureIndicator
        
        if candy.percent_change.contains("-") {
            cell.textLabel?.textColor = UIColor.red
            cell.detailTextLabel?.textColor = UIColor.red
            cell.imageView?.image = UIImage(imageLiteralResourceName: "download-arrow")
        }else{
            cell.textLabel?.textColor = UIColor.candyGreen
            cell.detailTextLabel?.textColor = UIColor.candyGreen
            cell.imageView?.image = UIImage(imageLiteralResourceName: "up-arrow")
        }
    
        return cell
    }
    


  
  // MARK: - Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    print("print segue... \(segue.identifier)")
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let candy: Candy
            if isFiltering() {
                candy = filteredCandies[indexPath.row]
            } else {
                candy = candies[indexPath.row]
            }

        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailCandy = candy
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.hidesBackButton = false
       
        if candy.percent_change == "" {
            controller.isWatched = true
        }
        
      }
    }
  }
}

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension MasterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

