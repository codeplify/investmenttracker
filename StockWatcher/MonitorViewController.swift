//
//  MonitorViewController.swift
//  CandySearch
//
//  Created by Loey Agdan on 1/24/19.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

//TODO:- Add listing of portfolio / portfolio managing

import UIKit
import CoreData

class MonitorViewController: UIViewController {

    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var txtStocks: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtCharge: UITextField!
    @IBOutlet weak var txtTax: UITextField!
    @IBOutlet weak var lblTotalAmtInvested: UILabel!
    
    var portfolio: [NSManagedObject] = []
    
    var inv: Portfolio = Portfolio()
    var code:String!
    var presenter:PortfolioPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(true, animated: false)
        price.placeholder = "0.00"
        txtStocks.placeholder = "0"
        txtAmount.placeholder = "0.00"
        txtCharge.placeholder = "0.00"
        txtTax.placeholder = "0.00"
        
        price.keyboardType = UIKeyboardType.decimalPad
        txtStocks.keyboardType = UIKeyboardType.decimalPad
        txtAmount.keyboardType = UIKeyboardType.decimalPad
        txtCharge.keyboardType = UIKeyboardType.decimalPad
        txtTax.keyboardType = UIKeyboardType.decimalPad
        
        price.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtStocks.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtCharge.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtTax.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.presenter = PortfolioPresenter(delegate: self as PortfolioDelegate)
        loadInvested()
        
       
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        computeInv()
    }
    
    
    
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        if Double(lblTotalAmtInvested.text!)! > 0 {
            inv.charge = Double(txtCharge.text!)!
            inv.price = Double(price.text!)!
            inv.stock = Int(txtStocks.text!)!
            inv.tax = Double(txtTax.text!)!
            inv.amount = Double(txtAmount.text!)!
            inv.uid = UUID.init()
            inv.date = "\(Date())"
            inv.code = "\(code!)"
            inv.total = Double(lblTotalAmtInvested.text!)!
            self.presenter?.save(port: inv)
        }
    }
    
    func computeInv(){
        
        guard let stockPrice = Double(price.text!) else{ return }
        guard let stocks = Double(txtStocks.text!) else{ return }
        guard let c = Double(txtCharge.text!) else{ return }
        guard let tax = Double(txtTax.text!) else { return }
        
        let amountPrice = stockPrice * stocks
        let amountTotal = amountPrice - ( c + tax )
        
        txtAmount.text = String(amountPrice)
        lblTotalAmtInvested.text = String(amountTotal)
    }
    
    func loadInvested(){
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
}

extension MonitorViewController: PortfolioDelegate {
    func showProgress() {}
    func hideProgress() {}
    func saveToPortfolioSucceed() {
        print("portfolio saved...")
    }
    func saveToPortfolioFailed(message: String) {
        print(message)
    }
    func deletePortfolioSucceed() {}
    func deletePortfolioFailed(message: String) {}
}
