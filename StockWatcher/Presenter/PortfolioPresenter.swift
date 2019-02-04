//
//  PortfolioPresenter.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/3/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol PortfolioDelegate {
    func showProgress()
    func hideProgress()
    func saveToPortfolioSucceed()
    func saveToPortfolioFailed(message: String)
    func deletePortfolioSucceed()
    func deletePortfolioFailed(message: String)
}

class PortfolioPresenter {
    var delegate: PortfolioDelegate
    
    init(delegate: PortfolioDelegate){
        self.delegate = delegate
    }
    
    func save(port: Portfolio){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Investment", in: managedContext)!
        let portfolio = NSManagedObject(entity: entity, insertInto: managedContext)
        
        portfolio.setValue(port.charge, forKey: "bcharge")
        portfolio.setValue(port.price, forKey: "price")
        portfolio.setValue(port.stock, forKey: "stocks")
        portfolio.setValue(port.tax, forKey: "tax")
        portfolio.setValue(port.amount, forKey: "amount")
        portfolio.setValue(port.total, forKey: "total")
        portfolio.setValue(port.uid, forKey: "id")
        portfolio.setValue(port.date, forKey: "date")
        portfolio.setValue(port.code, forKey: "code")
        
        do{
            try managedContext.save()
            self.delegate.saveToPortfolioSucceed()
        }catch let error as NSError {
            self.delegate.saveToPortfolioFailed(message: "\(error)")
        }
    }
    
    func computeInv(){
        
    }
    
}
