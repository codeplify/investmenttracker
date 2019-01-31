//
//  MonitorViewController.swift
//  CandySearch
//
//  Created by Loey Agdan on 1/24/19.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

/*
    - Keyboard number
    - Save via CoreData
    - Automatic computation on textfield change
 
 */

import UIKit

class MonitorViewController: UIViewController {

    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var txtStocks: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtCharge: UITextField!
    @IBOutlet weak var txtTax: UITextField!
    @IBOutlet weak var lblTotalAmtInvested: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        computeInv()
    }
    
    func computeInv(){
        let stockPrice = Double(price.text!)
        let stocks = Double(txtStocks.text!)
        let c = Double(txtCharge.text!)!
        let tax = Double(txtTax.text!)!
        let amountTotal = (stockPrice! * stocks!) - ( c + tax )
        lblTotalAmtInvested.text = String(amountTotal)
    }
}
