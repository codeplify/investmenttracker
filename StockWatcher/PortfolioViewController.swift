//
//  PortfolioViewController.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/4/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import UIKit
import CoreData

class PortfolioViewController: UIViewController {

    
    var portfolio: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadPortfolio(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Investment")
    
        do{
            portfolio = try managedContext.fetch(fetchRequest)
            
            
            for p in portfolio{
                print("p:\(p.value(forKey: "total")!)")
            }
        }catch let error as NSError {
            print(error)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
