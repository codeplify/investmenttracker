//
//  WatchlistPresenter.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/3/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import Foundation

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
        if stock.name.isEmpty {
            self.delegate.saveToWatchlistFailed(message: "Failed saving to watchlist")
        }else{
            self.delegate.saveToWatchlistSucceed()
        }
    }
}
