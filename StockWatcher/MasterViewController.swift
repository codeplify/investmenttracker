import CoreData
import UIKit


class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
    
  var wpresenter: WatchlistPresenter?
  var detailViewController: DetailViewController? = nil
  var candies = [Candy]()
  var stocks: [NSManagedObject] = []
  var filteredCandies = [Candy]()
  let searchController = UISearchController(searchResultsController: nil)
    
  override func viewDidLoad() {
    super.viewDidLoad()
  
    searchController.searchBar.scopeButtonTitles = ["Portfolio","All","Watch"]
    searchController.searchBar.delegate = self

    DispatchQueue.main.async {
        self.filteredCandies.removeAll()
        self.candies.removeAll()
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
                self.tableView.reloadData()
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
            
            //TODO:- Load all watch here
            //TODO:- Check if there has a existing stocks
            
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
        //TODO:- Change the value of section to filtering -> to set to filtering of only invested amounts
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        //return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
        return true
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

