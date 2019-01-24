

import CoreData
import UIKit

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var filteredCandies = [Candy]()
  let searchController = UISearchController(searchResultsController: nil)
    
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
  
  var detailViewController: DetailViewController? = nil
  var candies = [Candy]()
  
  var stocks: [NSManagedObject] = []
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup the Scope Bar
    searchController.searchBar.scopeButtonTitles = ["All","Watch"]
    searchController.searchBar.delegate = self

    DispatchQueue.main.async {
        self.loadStocks()
    }
    
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Stocks"
    navigationItem.searchController = searchController
    definesPresentationContext = true
    
    if let splitViewController = splitViewController {
      let controllers = splitViewController.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    
    tableView.tableFooterView = searchFooter
    
  }
    
    func loadStocks(){
        guard let url = URL(string: "http://phisix-api4.appspot.com/stocks.json")else {
            return}
        
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
                print("Latest: \(JSON["as_of"] as? String)")
                
                guard let jsonArray = JSON["stock"] as? [[String:Any]] else {
                    return
                }
                
                print(jsonArray)
                
                for json in jsonArray {
                    
                    guard let stockName = json["name"] as? String else{
                        return
                    }
                    
                    guard let symbol = json["symbol"] as? String else{
                        return
                    }
                    
                    guard let per = json["percent_change"] else {
                        return
                    }
                    
                    guard let vol = json["volume"] as? Int else{
                        return
                    }
                    
                   
                    let price = json["price"] as! [String:Any]
                    
                    self.candies.append(Candy(category:"\(stockName)", name:"\(symbol)",volume:"\(vol)",percent_change:"\(per)",price:"\(String(describing: price["amount"]!))",currency:"\(String(describing: price["currency"]!))"))
                    
                }
                
               self.tableView.reloadData()
                
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredCandies.removeAll()
        
        if(scope == "Watch"){
            //Fetching CoreData
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StocksDB")
            
            do{
              stocks = try managedContext.fetch(fetchRequest)
                for s in stocks{
                    print(s.value(forKey: "scode"))
                    
                    filteredCandies.append(Candy(category:"\(s.value(forKey: "details")!)",name:"\(s.value(forKey: "scode")!)",volume:"0",percent_change:"",price:"",currency:""))
                    
                }
            }catch let error as NSError {
                print(error)
            }
            
        }else{
            filteredCandies = candies.filter({( candy : Candy) -> Bool in
                let doesCategoryMatch = (scope == "All") || (candy.category == scope)
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
                }
                
            })
            
            
        }
        tableView.reloadData()
       
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
  
  override func viewWillAppear(_ animated: Bool) {
    if splitViewController!.isCollapsed {
      if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
        self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
      }
    }
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table View
  func numberOfSections(in tableView: UITableView) -> Int {
    if isFiltering() {
        searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
        return filteredCandies.count
    }
    
    searchFooter.setNotFiltering()
    return candies.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCandies.count
        }
        
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
        
        if candy.percent_change.contains("-") {
            cell.textLabel?.textColor = UIColor.red
            cell.detailTextLabel?.textColor = UIColor.red
        }else{
            cell.textLabel?.textColor = UIColor.candyGreen
            cell.detailTextLabel?.textColor = UIColor.candyGreen
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
      }
    }
  }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
//    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }

}

extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

