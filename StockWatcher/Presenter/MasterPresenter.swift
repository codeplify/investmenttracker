//
//  MasterPresenter.swift
//  StockWatcher
//
//  Created by Loey Agdan on 3/12/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import Foundation

protocol MasterDelegate {
    func showProgress()
    func hideProgress()
    func loadStocks()
}

class MasterPresenter{
    var delegate: MasterDelegate
    var candies = [Candy]()
    init(delegate:MasterDelegate){
        self.delegate = delegate
    }
    
    func loadStocks()->[Candy]{
        self.delegate.showProgress()
        
        let url = URL(string: pseStocksLink)
        
        let group = DispatchGroup()
        group.enter()
        
        let task = URLSession.shared.dataTask(with: url!){data,response,error in
            guard let dataResponse = data,error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            guard let rootJSON = try? JSONSerialization.jsonObject(with: dataResponse, options: []) else {
                print("failed")
                return
            }
            
            if let JSON = rootJSON as? [String:Any]{
                
                guard let jsonArray = JSON["stock"] as? [[String:Any]] else { return }
                
                for json in jsonArray {
                    guard let stockName = json["name"] as? String else{ return }
                    guard let symbol = json["symbol"] as? String else{ return }
                    guard let per = json["percent_change"] else { return }
                    guard let vol = json["volume"] as? Int else{ return }
                    let price = json["price"] as! [String:Any]
                    
                    self.candies.append(Candy(category:"\(stockName)", name:"\(symbol)",volume:"\(vol)",percent_change:"\(per)",price:"\(String(describing: price["amount"]!))",currency:"\(String(describing: price["currency"]!))"))
                }
                
                self.delegate.hideProgress()
                //TODO:- Do something here end of request
                group.leave()
            }
        }
        
        task.resume()
        group.wait()
        return candies
    }
}
