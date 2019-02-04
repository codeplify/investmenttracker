import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    //TODO:- transfer code using didSet to MonitorViewController
  
 @IBOutlet weak var btnInvest: UIButton!
 @IBOutlet weak var detailDescriptionLabel: UILabel!
 @IBOutlet weak var lblVolume: UILabel!
 @IBOutlet weak var lblPercentage: UILabel!
 @IBOutlet weak var lblAmount: UILabel!
 @IBOutlet weak var lblStatus: UILabel!
 @IBOutlet weak var btnWatchButton: UIButton!
 @IBOutlet weak var btnUnWatchButton: UIButton!
    
  var isWatched = false
  var presenter: WatchlistPresenter?
    
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
            lblAmount.text = "\(detailCandy.currency) \(detailCandy.price)"
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
    configureView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
  @IBAction func btnWatchTapped(_ sender: UIButton) {
        if (self.presenter?.search(code: detailCandy!.name))! {
            self.presenter?.save(stock: detailCandy!)
        }
  }
    
}

extension DetailViewController: WatchlistDelegate {
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

