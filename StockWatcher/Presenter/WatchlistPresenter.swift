//
//  WatchlistPresenter.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/3/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol WatchlistDelegate {
    func showProgress()
    func hideProgress()
    func saveToWatchlistSucceed()
    func saveToWatchlistFailed(message: String)
    func deleteWatchlistSucceed()
    func deleteWatchlistFailed(message: String)
    func deleteStockInvestedSucceed()
    func deleteStockInvestedFailed(message: String)
}

class WatchlistPresenter{
    var delegate: WatchlistDelegate
    
    init(delegate: WatchlistDelegate){
        self.delegate = delegate
    }
    
    func save(stock: Candy){
        if search(code: stock.name) {
            
            //TODO:- Move to data persistence
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "StocksDB", in: managedContext)!
            let stockMO = NSManagedObject(entity: entity, insertInto: managedContext)
            
            stockMO.setValue(stock.category, forKey: "details")
            stockMO.setValue(Double(stock.price as! String), forKey: "amount")
            stockMO.setValue(stock.currency, forKey: "currency")
            stockMO.setValue(stock.name, forKey: "scode")
            stockMO.setValue(1, forKey: "status")
            
            do{
                try managedContext.save()
                self.delegate.saveToWatchlistSucceed()
            }catch let error as NSError {
                self.delegate.saveToWatchlistFailed(message: "Failed saving to watchlist")
            }
        }
    }
    
    func search(code: String) -> Bool{
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
    
    /** MARK:- Remove stock from watchlist */
    func delete(code:String){
        //TODO:- check if there is an existing stocks inside
        if !isPortfolioExist(code: code){
        
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
                    self.delegate.deleteWatchlistSucceed()
                }catch{
                    self.delegate.deleteWatchlistFailed(message: error as! String)
                }
                
            }catch{
                self.delegate.deleteWatchlistFailed(message: error as! String)
            }
            
        }else{
            self.delegate.deleteWatchlistFailed(message: "Cant delete to watchlist as it contains investment")
        }
    }
    
    func deleteInvestment(id:UUID){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Investment")
        fetchRequest.predicate = NSPredicate(format: "id = %@",id as CVarArg)
        
        do{
            let candy = try managedContext.fetch(fetchRequest)
            let del = candy[0] as! NSManagedObject
            managedContext.delete(del)
            
            
            
            do{
                try managedContext.save()
                self.delegate.deleteStockInvestedSucceed()
            }catch{
                self.delegate.deleteStockInvestedFailed(message: "Failed deleting invested stock")
            }
            
        }catch{
            self.delegate.deleteStockInvestedFailed(message: "Cant delete investment")
        }
        
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
    

}
