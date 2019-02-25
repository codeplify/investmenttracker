import UIKit
import CoreData
import AWSCognitoIdentityProvider

class PortfolioTableViewCell : UITableViewCell {
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
}

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
 //TODO:- transfer code using didSet to MonitorViewController
 @IBOutlet weak var btnInvest: UIButton!
 @IBOutlet weak var detailDescriptionLabel: UILabel!
 @IBOutlet weak var lblVolume: UILabel!
 @IBOutlet weak var lblPercentage: UILabel!
 @IBOutlet weak var lblAmount: UILabel!
 @IBOutlet weak var lblStatus: UILabel!
 @IBOutlet weak var btnWatchButton: UIButton!
 @IBOutlet weak var btnUnWatchButton: UIButton!
 @IBOutlet weak var tableView: UITableView!
 @IBOutlet weak var lblDateList: UILabel!
 @IBOutlet weak var lblAmtList: UILabel!
 @IBOutlet weak var lblProfit: UILabel!
 @IBOutlet weak var lblStockOwned: UILabel!
 @IBOutlet weak var labelDesignProfit: UILabel!
 @IBOutlet weak var labelStockOwn: UILabel!
    
 var ps:[Portfolio] = [Portfolio]()
 var isWatched = false
 var presenter: WatchlistPresenter?
 var detailCandy: Candy? {
    didSet {
      configureView()
    }
  }
    
  @IBOutlet weak var btnLogout: UIButton!
    
  @IBAction func btnLogoutPressed(_ sender: Any) {
        
  }
    
  func configureView() {
    if let detailCandy = detailCandy {
        
          if let detailDescriptionLabel = detailDescriptionLabel {
            detailDescriptionLabel.text = detailCandy.name
            
            let percentChange = detailCandy.percent_change.contains("-")
            
            if percentChange {
                lblPercentage.textColor = UIColor.red
            }else{
                lblPercentage.textColor = UIColor.green
            }
            
            if btnWatchButton.isHidden {
                btnUnWatchButton.isHidden = true
                btnInvest.isHidden = false
            }else{
                btnUnWatchButton.isHidden = false
            }
        
            if (self.presenter?.search(code: detailCandy.name))! {
                lblStatus.text = "Unwatched"
                btnUnWatchButton.isHidden = true
            }else{
                lblStatus.text = "Watching"
                btnWatchButton.isHidden = true
                btnInvest.isHidden = false
            }
            
            lblVolume.text = "\(Int(detailCandy.volume)!.formattedWithSeparator)"
            lblPercentage.text = "\(detailCandy.percent_change)%"
            lblAmount.text = "\(detailCandy.currency) \(detailCandy.price)" // remove formatting as number .formatted
            print("detailCandy \(detailCandy)")
            title = detailCandy.category
            
          }
    }
  }

  @IBAction func btnDeleteWatchStock(_ sender: UIButton) {
        self.presenter?.delete(code: (detailCandy?.name)!)
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.presenter = WatchlistPresenter(delegate: self as WatchlistDelegate)
    
    tableView.dataSource = self
    tableView.delegate = self
    configureView()
  }
    
  override func viewWillAppear(_ animated: Bool) {
      searchPortfolio()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
  @IBAction func btnWatchTapped(_ sender: UIButton) {
        if (self.presenter?.search(code: detailCandy!.name))! {
            self.presenter?.save(stock: detailCandy!)
        }
  }
    
    
  @IBAction func btnInvestTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MonitorVC") as! MonitorViewController
        
        controller.code = detailCandy?.name
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        self.navigationController?.pushViewController(controller, animated: true)
  }
    
    
    /**
     Tableview:
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PortfolioTableViewCell
        let p = ps[indexPath.row]
        
        cell.lblAmount?.text = "\(p.total!.formatted)"
        cell.lblDate?.text = "\(p.date!)"
        
        print(p.date!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let p = ps[indexPath.row]
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let alert = UIAlertController(title: "", message: "Are you sure you want to delete?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
                action in
                
                print("delete investment \(p.uid)")
                
                self.presenter?.deleteInvestment(id: p.uid!)
                //self.ps.remove(at: indexPath.row)
               
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
                action in
                print("cancel deleting")
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
   
    func searchPortfolio() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Investment")
            fetchRequest.predicate = NSPredicate(format: "code = %@",(detailCandy?.name)!)
        var portfolio: [NSManagedObject] = []
        do{
            portfolio = try managedContext.fetch(fetchRequest)
            
            if portfolio.count > 0 {
                
                ps.removeAll()
                
                tableView.isHidden = false
                btnUnWatchButton.isHidden = true
                labelDesignProfit.isHidden = false
                labelStockOwn.isHidden = false
                lblProfit.isHidden = false
                lblStockOwned.isHidden = false
                
                var totalInvested:[Double] = []
                
                for p in portfolio {
                    print("p:\(p.value(forKey: "total")!)")
                    let portfolio = Portfolio()
                    portfolio.amount = p.value(forKey: "amount") as! Double
                    portfolio.charge = p.value(forKey: "bcharge") as! Double
                    portfolio.code = p.value(forKey: "code") as! String
                    portfolio.date = p.value(forKey: "date") as! String
                    portfolio.uid = p.value(forKey: "id") as! UUID
                    portfolio.price = p.value(forKey: "price") as! Double
                    portfolio.stock = p.value(forKey: "stocks") as! Int
                    portfolio.tax = p.value(forKey: "tax") as! Double
                    portfolio.total = p.value(forKey: "total") as! Double
                    
                    ps.append(portfolio)
                }
                
                let total = ps.reduce(0.00){
                    (result , a)-> Double in
                    return result + (a.total as! Double)
                }
                
                let totalStocks = ps.reduce(0){
                    (result, a)-> Int in
                    return result + (a.stock as! Int)
                }
                
                let currentValue = Double(totalStocks) * Double(detailCandy?.price as! String)!
                
                print("Total invested amount \(total) current value \(currentValue) total stocks \(totalStocks)")
                print("total=> \( currentValue-total)")
                
                let totalProfit =  currentValue-total
                lblProfit.text = "\(totalProfit)"
                lblStockOwned.text = "\(totalStocks)"
                
                if "\(totalProfit)".contains("-") {
                    lblProfit.textColor = UIColor.red
                }
                
            }else{
                
                tableView.isHidden = true
                btnUnWatchButton.isHidden = false
                labelStockOwn.isHidden = true
                labelDesignProfit.isHidden = true
                lblStockOwned.isHidden = true
                lblProfit.isHidden = true
            }
            print("count portfolio \(ps.count)")
            self.tableView.reloadData()
            
            print(ps.count)
        }catch let error as NSError {
            print(error)
        }
    }
    
}

extension DetailViewController: WatchlistDelegate {
    func deleteStockInvestedSucceed() {
        print("investment deleted")
     //   searchPortfolio()
        
    }
    
    func deleteStockInvestedFailed(message: String) {
        print(message)
    }
    
    func deleteWatchlistSucceed() {
         btnWatchButton.isHidden = false
         btnUnWatchButton.isHidden = true
         btnInvest.isHidden = true
         lblStatus.text = "Unwatched"
    }
    
    func deleteWatchlistFailed(message: String) {
        print("failed deleting from watchlist\(message)")
    }
    
    func showProgress() {
        print("show progress bar")
    }
    
    func hideProgress() {
        print("hide progress bar")
    }
    
    func saveToWatchlistSucceed() {
        lblStatus.text = "Watched"
        btnWatchButton.isHidden = true
        btnUnWatchButton.isHidden = false
        btnInvest.isHidden = false
    }
    
    func saveToWatchlistFailed(message: String) {
        print(message)
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension Double {
    static let twoFractionDigits: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    var formatted: String {
        return Double.twoFractionDigits.string(for: self) ?? ""
    }
}
