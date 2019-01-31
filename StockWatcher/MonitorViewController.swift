//
//  MonitorViewController.swift
//  CandySearch
//
//  Created by Loey Agdan on 1/24/19.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

/*
    - Keyboard number
    X Save via CoreData
    - Automatic computation on textfield change
 
 */

import UIKit
import CoreData

class MonitorViewController: UIViewController {

    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var txtStocks: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtCharge: UITextField!
    @IBOutlet weak var txtTax: UITextField!
    @IBOutlet weak var lblTotalAmtInvested: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(true, animated: false)
        price.placeholder = "0.00"
        txtStocks.placeholder = "0"
        txtAmount.placeholder = "0.00"
        txtCharge.placeholder = "0.00"
        txtTax.placeholder = "0.00"
    }
    
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        computeInv()
    }
    
    func computeInv(){
        let stockPrice = Double(price.text!)
        let stocks = Double(txtStocks.text!)
        let c = Double(txtCharge.text!)!
        let tax = Double(txtTax.text!)!
        var amountTotal = (stockPrice! * stocks!) - ( c + tax )
        txtAmount.text = String(stockPrice! * stocks!)
        lblTotalAmtInvested.text = String(amountTotal)
        
//        if amountTotal > 0 {
//            //TODO:- Add confirmation to save here...
//            saveInv()
//        }
        
    }
    
    func saveInv(){
//        if Double(lblTotalAmtInvested.text!)! > 0 {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Investment", in: managedContext)!
            let portfolio = NSManagedObject(entity: entity, insertInto: managedContext)
            
            portfolio.setValue(Double(txtCharge.text!)!, forKey: "bcharge")
            portfolio.setValue(Double(price.text!)!, forKey: "price")
            portfolio.setValue(Int(txtStocks.text!)!, forKey: "stocks")
            portfolio.setValue(Double(txtTax.text!)!, forKey: "tax")
            portfolio.setValue(Double(txtAmount.text!)!, forKey: "amount")
            portfolio.setValue(Double(lblTotalAmtInvested.text!)!, forKey: "total")
            portfolio.setValue(UUID.init().uuidString, forKey: "id")
            portfolio.setValue("\(Date())", forKey: "date")
            portfolio.setValue(String(""), forKey: "code")
            
            do{
                try managedContext.save()
                print("Investment saved...")
            }catch let error as NSError {
                print("\(error)")
            }
            
//        }
    }
}
