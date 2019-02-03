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
}

class WatchlistPresenter{
    var delegate: WatchlistDelegate
    
    init(delegate: WatchlistDelegate){
        self.delegate = delegate
    }
    
    func save(stock: Candy){
        if search(scode: stock.name) {
            //Move saving here...
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
    
    func search(scode: String) -> Bool{
        return true
    }
}
