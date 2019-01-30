import UIKit
import CoreData
/**
    Todo: Clean this code apply MVP
 */

class DetailViewController: UIViewController {
  
  @IBOutlet weak var detailDescriptionLabel: UILabel!
    //@IBOutlet weak var candyImageView: UIImageView!
    @IBOutlet weak var lblVolume: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnWatchButton: UIButton!
    @IBOutlet weak var btnUnWatchButton: UIButton!
    
    var isWatched = false
    
  var detailCandy: Candy? {
    didSet {
      configureView()
    }
  }
  
  func configureView() {
    if let detailCandy = detailCandy {
        
        //TODO:- Check if being watched...
        
        
        
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
            }else{
                btnUnWatchButton.isHidden = false
            }
        
            
            if search(code: detailCandy.name){
                
                lblStatus.text = "Unwatched"
                btnUnWatchButton.isHidden = true
            }else{
                lblStatus.text = "Watching"
                btnWatchButton.isHidden = true
                loadStock(code: detailCandy.name)
                
            }
            lblVolume.text = "\(Int(detailCandy.volume)!.formattedWithSeparator)"
            lblPercentage.text = "\(detailCandy.percent_change)%"
            lblAmount.text = "\(detailCandy.currency) \(detailCandy.price)"
            print("detailCandy \(detailCandy)")
            title = detailCandy.category
            
            
            
          }
        
    }
  }
   
 func search(code:String) -> Bool{
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return false
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StocksDB")
        fetchRequest.predicate = NSPredicate(format: "scode = %@", code)
    
    do{
        let candy = try managedContext.fetch(fetchRequest)
        if(candy.count == 0){
            return true
        }else{
           //found here
            
        }
    }catch{
        print(error)
    }
    
    return false
 }
    
    func loadStock(code:String){
        //https://www.pse.com.ph/stockMarket/companyInfo.html?id=118&security=547&tab=3
        //https://www.pse.com.ph/stockMarket/companyInfoHistoricalData.html?method=getRecentSecurityQuoteData&security=547&ajax=false
        
        print("stock reloaded")
        
        guard let url = URL(string: "https://www.pse.com.ph/stockMarket/companyInfo.html?id=118&security=547&tab=3") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url){data,response,error in
            guard let dataResponse = data,error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            guard let url2 = URL(string: "https://www.pse.com.ph/stockMarket/companyInfoHistoricalData.html?method=getRecentSecurityQuoteData&security=547&ajax=false") else {
                return
            }
            
            let task2 = URLSession.shared.dataTask(with: url2){
                data,response,error in
                
                guard let dataResponse = data,error == nil else{
                    print(error?.localizedDescription ?? "Response Error")
                    return
                }
                
                print(dataResponse)
                
                guard let rootJSON = try? JSONSerialization.jsonObject(with: dataResponse, options: []) else {
                    print("failed")
                    return
                }
                
                print(rootJSON)
                
            }
            
            task2.resume()
            
            
        }
        
        task.resume()
    }
  
    
  //Remove data from watchlist
  func deleteData(code:String){
        print("code to delete \(code)")
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StocksDB")
        fetchRequest.predicate = NSPredicate(format: "scode = %@",code)
    do{
        let candy = try managedContext.fetch(fetchRequest)
        print("candy \(candy.count)")
        let del = candy[0] as! NSManagedObject
        
        managedContext.delete(del)
        
        do{
            try managedContext.save()
            btnWatchButton.isHidden = false
            btnUnWatchButton.isHidden = true
        }catch{
            print(error)
        }
        
        print("\(code) has been deleted")
        
    }catch{
        print(error)
    }
    
  }
    @IBAction func btnDeleteWatchStock(_ sender: UIButton) {
        deleteData(code: (detailCandy?.name)!)
        lblStatus.text = "Unwatched"
        
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
    
    @IBAction func btnWatchTapped(_ sender: UIButton) {
        if search(code: detailCandy!.name) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "StocksDB", in: managedContext)!
            let stock = NSManagedObject(entity: entity, insertInto: managedContext)
            
            stock.setValue(detailCandy?.category, forKey: "details")
            stock.setValue(Double(detailCandy?.price as! String), forKey: "amount")
            stock.setValue(detailCandy?.currency, forKey: "currency")
            stock.setValue(detailCandy?.name, forKey: "scode")
            stock.setValue(1, forKey: "status")
            
            // 1 - Watching
            // 2 - Invested
            // Check here if it is already tapped...
            
            do{
                try managedContext.save()
                lblStatus.text = "Watched"
                print("Stock saved!")
                btnWatchButton.isHidden = true
                btnUnWatchButton.isHidden = false
            }catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }else{
            print("Already added to watchlist")
        }
        
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

