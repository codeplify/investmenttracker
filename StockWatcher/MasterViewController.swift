import CoreData
import UIKit
import AWSCognitoIdentityProvider
import SVProgressHUD

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UISplitViewControllerDelegate{
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
    
  var wpresenter: WatchlistPresenter?
  var mpresenter: MasterPresenter?
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

    self.mpresenter = MasterPresenter(delegate: self)
    
    DispatchQueue.main.async {
        self.filteredCandies.removeAll()
        self.candies.removeAll()
         self.candies = (self.mpresenter?.loadStocks())!
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
    if watchlistCount == 0 {
        searchController.searchBar.selectedScopeButtonIndex = 2}
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
  
    //TO-DO: Manage Coredata outside of view Controller

    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
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
                        for (index,s) in stocks.enumerated(){
                            if $0.name ==  "\(s.value(forKey: "scode")!)" {
                                //TODO:- Control by a manager
                                if index <= userAccess {
                                    temp.append($0)
                                    print("appended \($0.name)")
                                }
                                return $0
                            }
                        }
                        return $0
                    }
                
                if temp.count == 0 && searchController.searchBar.selectedScopeButtonIndex == 0 {
                    tableView.setEmptyView(title: "Empty Watchlist", message: "Your watchlist is empty you can search from list of stocks from All segments")
                }else{
                    print("else has value")
                    tableView.restore()
                }
                
                print("selected scope \(searchController.searchBar.selectedScopeButtonIndex)")
                
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
            
            if searchController.searchBar.selectedScopeButtonIndex == 0 {
                tableView.restore()
            }
            print("selected scope \(searchController.searchBar.selectedScopeButtonIndex)")
        }
        
        if(scope == "Portfolio"){
            
            filteredCandies.removeAll()
            var temp = [Candy]()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            var temp2 = [Candy]()
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StocksDB")
            var stock2 :[NSManagedObject] = []
            do{
                stock2 = try managedContext.fetch(fetchRequest)
                print("Stock Count Port=> \(stocks.count)")
                
                temp2.removeAll()
                filteredCandies = candies.map {
                    for (index,s) in stocks.enumerated(){
                        if $0.name ==  "\(s.value(forKey: "scode")!)" {
                            //TODO:- to manage by manager
                            if index <= userAccess {
                                if mpresenter!.isPortfolioExist(code: $0.name){
                                    temp2.append($0)
                                    print("appended \($0.name)")
                                    return $0
                                }
                            }
                        }
                    }
                    return $0
                }
                
                print("selected scope \(searchController.searchBar.selectedScopeButtonIndex)")
                
                if temp2.count == 0 && searchController.searchBar.selectedScopeButtonIndex == 1 {
                    print("empty portfolio")
                    tableView.setEmptyView(title: "Empty Portfolio", message: "You have no investment yet.")
                }else{
                    tableView.backgroundView = nil
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
      if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
        self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
      }
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
            cell.imageView?.image = UIImage(imageLiteralResourceName: "download-arrow")
        }else{
            cell.imageView?.image = UIImage(imageLiteralResourceName: "up-arrow")
        }
    
        return cell
  }
  
  // MARK: - Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
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

extension MasterViewController: MasterDelegate {
    func loadStocks() {}
    
    func showProgress() {
       SVProgressHUD.show(withStatus: "Loading stocks...")
    }
    
    func hideProgress() {
        SVProgressHUD.dismiss()
        self.tableView.reloadData()
        self.searchController.isActive = true
        self.searchController.becomeFirstResponder()
    }
}
