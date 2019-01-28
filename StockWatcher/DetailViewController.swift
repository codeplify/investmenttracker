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
    
  var detailCandy: Candy? {
    didSet {
      configureView()
    }
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
        }
    }catch{
        print(error)
    }
    
    return false
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
                print("Stock saved!")
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

