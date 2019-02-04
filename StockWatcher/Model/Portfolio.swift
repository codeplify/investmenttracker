//
//  Portfolio.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/3/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import Foundation

class Portfolio:NSObject {
    
    override init(){ }
    
    var charge:Double?
    var price:Double?
    var stock:Int?
    var tax:Double?
    var amount:Double?
    var uid:UUID?
    var date:String?
    var code:String?
    var total:Double?
}
