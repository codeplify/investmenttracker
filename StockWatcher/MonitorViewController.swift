//
//  MonitorViewController.swift
//  CandySearch
//
//  Created by Loey Agdan on 1/24/19.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
